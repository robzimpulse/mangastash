/**
 * Android entry activity of Manga Stash.
 *
 * Purpose: besides hosting the Flutter engine it exposes one platform channel,
 * `com.robzimpulse.mangastash/webview_renderer`, with a single method
 * `terminate`. Every WebView of an Android app shares ONE renderer process, so
 * a JS source script that never returns (`while(true){}`) keeps spinning after
 * its headless webview is disposed and every later webview call times out
 * until the app is killed (issue #115). flutter_inappwebview exposes no way to
 * stop that renderer for a headless webview (`onRenderProcessUnresponsive`
 * needs input events), so `terminate` calls
 * `WebView.getWebViewRenderProcess().terminate()` (API 29+) on the live
 * headless webviews; the next webview gets a fresh renderer.
 *
 * The renderer is NOT terminated while a visible (non-headless) WebView is
 * attached to the window: the visible log_box webview screens register no
 * `onRenderProcessGone`, so Android would kill the whole app with the renderer.
 * (core_network's `VisibleWebviewGuard` covers the sessions the app opens
 * itself; this scan also covers the log inspector's own webview entries.)
 *
 * Usage: core_network's `HeadlessWebviewManager` invokes `terminate` (returns
 * true when a renderer was terminated, false when none was running or the
 * platform is older than API 29) right after a script run times out, before
 * disposing the webview. Webviews still attached receive
 * `onRenderProcessGone`, which the manager always handles.
 *
 * Compat: `terminateRenderers` reaches into flutter_inappwebview_android
 * 1.1.3 internals (`headlessInAppWebViewManager.webViews`); the Dart side
 * pins `flutter_inappwebview: ^6.1.0` (core_network/pubspec.yaml). A plugin
 * bump that moves that field makes this channel log a warning and return
 * false — runaway scripts then can no longer be terminated, so re-verify
 * this channel on every plugin upgrade.
 */
package com.robzimpulse.mangastash

import android.os.Build
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.webkit.WebView
import com.pichillilorenzo.flutter_inappwebview_android.InAppWebViewFlutterPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.robzimpulse.mangastash/webview_renderer",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "terminate" -> result.success(terminateRenderers(flutterEngine))
                else -> result.notImplemented()
            }
        }
    }

    /** Terminates the shared WebView renderer via a live headless webview. */
    private fun terminateRenderers(flutterEngine: FlutterEngine): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return false
        val plugin = flutterEngine.plugins.get(InAppWebViewFlutterPlugin::class.java)
            as? InAppWebViewFlutterPlugin ?: return false
        // Reach-in contract (see the class doc): when the plugin object exists
        // but its headless map does not, the plugin changed under us — log it
        // loudly instead of silently returning false, which would let a
        // runaway script wedge the shared renderer until the app is
        // force-stopped (review on #194).
        val headlessWebViews = plugin.headlessInAppWebViewManager?.webViews?.values?.toList()
        if (headlessWebViews == null) {
            Log.w(
                "mangastash/WebviewRenderer",
                "flutter_inappwebview internals changed: headlessInAppWebViewManager" +
                    ".webViews is unavailable; runaway source scripts can no longer " +
                    "be terminated",
            )
            return false
        }
        var terminated = false
        // Every headless webview is attached to the window hierarchy by the
        // plugin (HeadlessInAppWebView.prepare adds its view to the content
        // view), so the scan below must exempt ALL of them: exempting only
        // the current iteration's webview makes any second live headless
        // webview look "visible" and skips every termination (review on
        // #194).
        val headlessViews = headlessWebViews.mapNotNull { it.flutterWebView?.webView }
        for (headless in headlessWebViews) {
            val webView = headless.flutterWebView?.webView ?: continue
            // Re-checked per webview, as late as possible: the scan is not
            // atomic with the kill below, and a visible webview can attach in
            // between (e.g. the user opening the log inspector while a script
            // times out). Terminating the shared renderer under a visible
            // webview whose screen registers no onRenderProcessGone would
            // make Android kill the whole app (review on #194).
            if (hasVisibleWebView(window.decorView, headlessViews)) continue
            val renderer = webView.webViewRenderProcess ?: continue
            if (renderer.terminate()) terminated = true
        }
        return terminated
    }

    /** Whether [view] contains a WebView that is not one of the [headless] ones. */
    private fun hasVisibleWebView(view: View?, headless: List<View>): Boolean {
        if (view is WebView) return headless.none { it === view }
        if (view is ViewGroup) {
            for (i in 0 until view.childCount) {
                if (hasVisibleWebView(view.getChildAt(i), headless)) return true
            }
        }
        return false
    }
}
