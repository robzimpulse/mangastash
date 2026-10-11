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
 * Usage: core_network's `HeadlessWebviewManager` invokes `terminate` (returns
 * true when a renderer was terminated, false when none was running or the
 * platform is older than API 29) right after a script run times out, before
 * disposing the webview. Webviews still attached receive
 * `onRenderProcessGone`, which the manager always handles.
 */
package com.robzimpulse.mangastash

import android.os.Build
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
        var terminated = false
        val headlessWebViews = plugin.headlessInAppWebViewManager?.webViews?.values?.toList()
            ?: return false
        for (headless in headlessWebViews) {
            val renderer = headless.flutterWebView?.webView?.webViewRenderProcess ?: continue
            if (renderer.terminate()) terminated = true
        }
        return terminated
    }
}
