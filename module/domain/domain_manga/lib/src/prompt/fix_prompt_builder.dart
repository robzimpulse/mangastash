// Helpers behind the "copy fix prompt" feature of scripted sources (issue #115,
// spec §10.1): trimming captured page HTML, building the self-contained
// prompt a user pastes into any chatbot, and pulling the fixed script back out
// of the chatbot's reply.
//
// Usage:
//   final prompt = await FixPromptBuilder(loadAsset: rootBundle.loadString)
//       .build(code: ..., function: 'search', url: ..., errorMessage: ...,
//              html: ...);          // copy `prompt` to the clipboard
//   final script = extractScriptFromReply(pastedReply); // null = nothing usable
import 'dart:async';

/// Reduces page HTML to something that fits a chatbot message: drops
/// `<script>`, `<style>` and `<svg>` blocks (case-insensitive, multiline),
/// collapses every whitespace run to one space and, when longer than
/// [maxChars], keeps the first [maxChars] characters and appends
/// `\n<!-- truncated N chars -->` where N is the number of dropped characters.
String trimPageHtml(String html, {int maxChars = 60000}) {
  final collapsed = html
      .replaceAll(_blocks, '')
      .replaceAll(RegExp(r'\s+'), ' ');
  if (collapsed.length <= maxChars) return collapsed;
  final dropped = collapsed.length - maxChars;
  return '${collapsed.substring(0, maxChars)}\n<!-- truncated $dropped chars -->';
}

final RegExp _blocks = RegExp(
  r'<(script|style|svg)\b[^>]*>[\s\S]*?</\1\s*>',
  caseSensitive: false,
);

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
