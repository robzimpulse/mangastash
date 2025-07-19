enum NavigationAction {
  push,
  pop,
  remove,
  replace,
}

enum WebviewEvent {
  onWebViewCreated,
  onContentSizeChanged,
  onLoadStart,
  onLoadStop,
  onProgressChanged,
  onReceivedError,
  onConsoleMessage,
  onNavigationResponse,
  shouldOverrideUrlLoading,
}