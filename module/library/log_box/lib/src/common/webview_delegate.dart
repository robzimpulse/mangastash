import 'dart:ui';

import 'package:uuid/uuid.dart';

import '../manager/storage.dart';
import '../model/webview_entry.dart';
import 'enum.dart';

class WebviewDelegate {
  final Storage _storage;

  final String _id;

  WebviewDelegate({required Storage storage})
    : _storage = storage,
      _id = const Uuid().v4();

  void set({Uri? uri, String? html, Object? error}) {
    _storage.add(
      log: WebviewEntry(id: _id, uri: uri, html: html, error: error),
    );
  }

  void onWebViewCreated({required Uri uri, List<String> scripts = const []}) {
    _storage.add(
      log: WebviewEntry(
        id: _id,
        scripts: scripts,
        uri: uri,
        events: [WebviewEntryLog(event: WebviewEvent.onWebViewCreated)],
      ),
    );
  }

  void onAjaxRequest({Map<String, dynamic>? extra}) {
    _storage.add(
      log: WebviewEntry(
        id: _id,
        events: [
          WebviewEntryLog(
            event: WebviewEvent.onAjaxRequest,
            extra: extra,
          ),
        ],
      ),
    );
  }

  void onContentSizeChanged({Size? previous, Size? current}) {
    _storage.add(
      log: WebviewEntry(
        id: _id,
        events: [
          WebviewEntryLog(
            event: WebviewEvent.onContentSizeChanged,
            extra: {
              'previous': previous.toString(),
              'current': current.toString(),
            },
          ),
        ],
      ),
    );
  }

  void onLoadStart({Uri? uri}) {
    _storage.add(
      log: WebviewEntry(
        id: _id,
        events: [
          WebviewEntryLog(
            event: WebviewEvent.onLoadStart,
            extra: {'uri': uri.toString()},
          ),
        ],
      ),
    );
  }

  void onLoadStop({Uri? uri}) {
    _storage.add(
      log: WebviewEntry(
        id: _id,
        events: [
          WebviewEntryLog(
            event: WebviewEvent.onLoadStop,
            extra: {'uri': uri.toString()},
          ),
        ],
      ),
    );
  }

  void onProgressChanged({int? progress}) {
    _storage.add(
      log: WebviewEntry(
        id: _id,
        events: [
          WebviewEntryLog(
            event: WebviewEvent.onProgressChanged,
            extra: {'progress': progress},
          ),
        ],
      ),
    );
  }

  void onReceivedError({String? message, Map<String, dynamic>? extra}) {
    _storage.add(
      log: WebviewEntry(
        id: _id,
        events: [
          WebviewEntryLog(
            event: WebviewEvent.onProgressChanged,
            extra: {'message': message, ...?extra},
          ),
        ],
      ),
    );
  }

  void onConsoleMessage({Map<String, dynamic>? extra}) {
    _storage.add(
      log: WebviewEntry(
        id: _id,
        events: [
          WebviewEntryLog(event: WebviewEvent.onConsoleMessage, extra: extra),
        ],
      ),
    );
  }

  void shouldOverrideUrlLoading({Map<String, dynamic>? extra}) {
    _storage.add(
      log: WebviewEntry(
        id: _id,
        events: [
          WebviewEntryLog(
            event: WebviewEvent.shouldOverrideUrlLoading,
            extra: extra,
          ),
        ],
      ),
    );
  }

  void onRunJavascript({required String script}) {
    _storage.add(
      log: WebviewEntry(
        id: _id,
        events: [
          WebviewEntryLog(
            event: WebviewEvent.onRunJavascript,
            extra: {'script': script},
          ),
        ],
      ),
    );
  }
}
