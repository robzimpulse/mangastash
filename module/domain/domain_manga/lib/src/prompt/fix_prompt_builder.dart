// Helpers behind the "copy fix prompt" feature of scripted sources (issue #115,
// spec §10.1): trimming captured page HTML (head, scripts, comments and long
// attribute values dropped so the cards fit the budget), building the
// self-contained
// prompt a user pastes into any chatbot, and pulling the fixed script back out
// of the chatbot's reply.
//
// Usage:
//   final prompt = await FixPromptBuilder(loadAsset: rootBundle.loadString)
//       .build(code: ..., function: 'search', url: ..., errorMessage: ...,
//              html: ...);          // copy `prompt` to the clipboard
//   final script = extractScriptFromReply(pastedReply); // null = nothing usable
import 'dart:async';

/// Longest attribute value kept by [trimPageHtml]; longer ones (astro-island
/// `props`, `data:` URIs, inline JSON) are cut to this many characters + `…`.
const int _maxAttributeChars = 200;

/// Elements removed together with their content.
const Set<String> _droppedBlocks = {'script', 'style', 'svg', 'noscript'};

final RegExp _whitespace = RegExp(r'\s+');

/// Reduces page HTML to something that fits a chatbot message, so the markup
/// a fixer needs (the cards, rows, images) fits the budget instead of the
/// page's boilerplate:
///   - `<head>` is dropped except its `<title>`; `<script>`, `<style>`,
///     `<svg>` and `<noscript>` blocks and HTML comments are dropped;
///   - attribute values longer than 200 characters are cut to 200 characters
///     followed by `…` (they hold serialized state, not selectors);
///   - every whitespace run collapses to one space;
///   - when still longer than [maxChars], the first [maxChars] characters are
///     kept and `\n<!-- truncated N chars -->` is appended, N being the
///     number of dropped characters.
/// Tag names are matched case-insensitively. It is a single linear scan (no
/// backtracking patterns), so pathological input such as thousands of
/// unterminated `<script` or `<!--` openers cannot blow up; an unterminated
/// block or comment swallows the rest of the document, like a browser does.
String trimPageHtml(String html, {int maxChars = 60000}) {
  final collapsed = _strip(html).replaceAll(_whitespace, ' ');
  if (collapsed.length <= maxChars) return collapsed;
  final dropped = collapsed.length - maxChars;
  return '${collapsed.substring(0, maxChars)}\n<!-- truncated $dropped chars -->';
}

/// Lowercases ASCII letters only, so the result has the same length as the
/// input and indexes into both strings agree.
String _asciiLower(String value) {
  final out = List<int>.of(value.codeUnits);
  for (var i = 0; i < out.length; i++) {
    final c = out[i];
    if (c >= 0x41 && c <= 0x5A) out[i] = c + 0x20;
  }
  return String.fromCharCodes(out);
}

bool _isLetter(int c) => (c >= 0x61 && c <= 0x7A) || (c >= 0x41 && c <= 0x5A);

bool _isNameChar(int c) {
  return _isLetter(c) || (c >= 0x30 && c <= 0x39) || c == 0x2D;
}

/// The (already lowercased) tag name starting at [from], or `''`.
String _tagName(String lower, int from) {
  if (from >= lower.length || !_isLetter(lower.codeUnitAt(from))) return '';
  var end = from;
  while (end < lower.length && _isNameChar(lower.codeUnitAt(end))) {
    end++;
  }
  return lower.substring(from, end);
}

/// Index just after the next `>` at or after [from], or the input length.
int _afterGreaterThan(String html, int from) {
  final index = html.indexOf('>', from);
  return index == -1 ? html.length : index + 1;
}

String _strip(String html) {
  final lower = _asciiLower(html);
  final out = StringBuffer();
  final length = html.length;
  var i = 0;
  while (i < length) {
    final lt = html.indexOf('<', i);
    if (lt == -1) {
      out.write(html.substring(i));
      break;
    }
    out.write(html.substring(i, lt));
    i = lt;

    if (html.startsWith('<!--', i)) {
      final end = html.indexOf('-->', i + 4);
      if (end == -1) break;
      i = end + 3;
      continue;
    }

    final next = i + 1 < length ? html.codeUnitAt(i + 1) : 0;
    // A `<` that cannot start a tag (`1 < 2`) is plain text.
    if (!_isLetter(next) && next != 0x2F && next != 0x21 && next != 0x3F) {
      out.write('<');
      i++;
      continue;
    }

    final name = _tagName(lower, i + 1);
    if (_droppedBlocks.contains(name)) {
      final close = lower.indexOf('</$name', i + 1 + name.length);
      if (close == -1) break;
      i = _afterGreaterThan(html, close);
      continue;
    }
    if (name == 'head') {
      i = _skipHead(html, lower, i, out);
      continue;
    }
    i = _copyTag(html, i, out);
  }
  return out.toString();
}

/// Skips the `<head>` element that opens at [start], writing only its
/// `<title>`; returns the index to continue from.
int _skipHead(String html, String lower, int start, StringBuffer out) {
  final afterOpen = start + 5;
  final close = lower.indexOf('</head', afterOpen);
  // Without a closing tag the head ends where the body starts.
  final end = close != -1 ? close : lower.indexOf('<body', afterOpen);
  final headEnd = end == -1 ? html.length : end;

  final titleStart = lower.indexOf('<title', afterOpen);
  if (titleStart != -1 && titleStart < headEnd) {
    final textStart = html.indexOf('>', titleStart);
    final textEnd = lower.indexOf('</title', titleStart);
    if (textStart != -1 && textEnd != -1 && textStart < textEnd) {
      out
        ..write('<title>')
        ..write(html.substring(textStart + 1, textEnd))
        ..write('</title>');
    }
  }
  return close != -1 ? _afterGreaterThan(html, close) : headEnd;
}

/// Whether the quote at [index] opens an attribute value (`name="`).
bool _opensValue(String html, int index) {
  var i = index - 1;
  while (i >= 0) {
    final c = html.codeUnitAt(i);
    if (c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D || c == 0x0C) {
      i--;
      continue;
    }
    return c == 0x3D;
  }
  return false;
}

/// Copies the tag starting at [start] to [out], cutting attribute values
/// longer than [_maxAttributeChars]; returns the index after the tag.
int _copyTag(String html, int start, StringBuffer out) {
  final length = html.length;
  var i = start;
  var pending = start;
  while (i < length) {
    final c = html.codeUnitAt(i);
    if (c == 0x3E) {
      out.write(html.substring(pending, i + 1));
      return i + 1;
    }
    if ((c == 0x22 || c == 0x27) && _opensValue(html, i)) {
      final close = html.indexOf(String.fromCharCode(c), i + 1);
      final valueEnd = close == -1 ? length : close;
      if (valueEnd - (i + 1) > _maxAttributeChars) {
        out
          ..write(html.substring(pending, i + 1 + _maxAttributeChars))
          ..write('…');
        pending = valueEnd;
      }
      i = close == -1 ? length : close + 1;
      continue;
    }
    i++;
  }
  out.write(html.substring(pending));
  return length;
}

const String _headerMarker = '==MangaStashSource==';

final RegExp _fence = RegExp(r'```([^\n`]*)\n([\s\S]*?)```');

/// Extracts the script from a chatbot [reply] (CRLF is normalized to LF).
///
/// Order of preference: the content of the first fenced block whose info
/// string is `js` or `javascript` (case-insensitive); else the content of the
/// first fenced block of any info string containing `==MangaStashSource==`;
/// else the trimmed whole reply when it contains that marker; else `null`.
/// Returned content is trimmed.
String? extractScriptFromReply(String reply) {
  final text = reply.replaceAll('\r\n', '\n');
  final fences = _fence.allMatches(text).toList();

  for (final fence in fences) {
    final info = fence.group(1)!.trim().toLowerCase();
    if (info == 'js' || info == 'javascript') return fence.group(2)!.trim();
  }
  for (final fence in fences) {
    final content = fence.group(2)!;
    if (content.contains(_headerMarker)) return content.trim();
  }
  return text.contains(_headerMarker) ? text.trim() : null;
}

/// Builds the fix prompt from the template shipped at
/// `packages/domain_manga/assets/prompt/fix_source_prompt.md`.
///
/// The template holds five placeholders, replaced in a single pass (so
/// placeholder-like text inside a value is never expanded again):
/// `{{script}}` the current script, `{{function}}` the failing function name,
/// `{{url}}` the URL that was loaded, `{{error}}` the error or validation
/// message and `{{html}}` the page HTML as the webview saw it, passed through
/// [trimPageHtml]. Unknown `{{...}}` text is left untouched.
class FixPromptBuilder {
  static const String templateAsset =
      'packages/domain_manga/assets/prompt/fix_source_prompt.md';

  final Future<String> Function(String path) loadAsset;

  const FixPromptBuilder({required this.loadAsset});

  Future<String> build({
    required String code,
    required String function,
    required String url,
    required String errorMessage,
    required String html,
  }) async {
    final template = await loadAsset(templateAsset);
    final values = <String, String>{
      'script': code,
      'function': function,
      'url': url,
      'error': errorMessage,
      'html': trimPageHtml(html),
    };
    return template.replaceAllMapped(
      RegExp(r'\{\{(script|function|url|error|html)\}\}'),
      (match) => values[match.group(1)]!,
    );
  }
}
