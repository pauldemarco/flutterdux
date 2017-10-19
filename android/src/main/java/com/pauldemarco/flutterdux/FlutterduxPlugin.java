package com.pauldemarco.flutterdux;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.net.Uri;
import android.net.http.SslError;
import android.os.Build;
import android.os.Message;
import android.support.customtabs.CustomTabsIntent;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.ConsoleMessage;
import android.webkit.JavascriptInterface;
import android.webkit.SslErrorHandler;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterView;

/**
 * FlutterduxPlugin
 */
public class FlutterduxPlugin implements MethodCallHandler {
  private static final String TAG = "FlutterDuxPlugin";

  private final Activity activity;
  private final MethodChannel channel;
  private final WebView webview;
  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutterdux");
    channel.setMethodCallHandler(new FlutterduxPlugin(registrar.activity(), channel));
  }

  private FlutterduxPlugin(Activity activity, MethodChannel channel) {
    this.channel = channel;
    this.activity = activity;
    this.webview = createWebView();
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("loadUrl")) {
      String url = (String)call.arguments;
      webview.loadUrl(url);
      result.success(null);
    } else if (call.method.equals("evaluateJavascript")) {
      String javaScript = (String)call.arguments;
      Log.d(TAG, "onMethodCall: " + javaScript);
      webview.evaluateJavascript(javaScript, new ValueCallback<String>() {
        @Override
        public void onReceiveValue(String value) {
          //do nothing
        }
      });
      result.success(null);
    } else {
      result.notImplemented();
    }
  }

  private WebView createWebView() {
    WebView webview = new WebView(activity);
    webview.getSettings().setJavaScriptEnabled(true);
    webview.getSettings().setDomStorageEnabled(true);
    webview.getSettings().setSupportMultipleWindows(true);
    webview.getSettings().setJavaScriptCanOpenWindowsAutomatically(true);
    webview.addJavascriptInterface(new WebAppInterface(activity), "Mobile");
    webview.setWebChromeClient(new WebChromeClient() {
      public void onProgressChanged(WebView view, int progress) {
        // Activities and WebViews measure progress with different scales.
        // The progress meter will automatically disappear when we reach 100%
        activity.setProgress(progress * 1000);
      }

      @TargetApi(Build.VERSION_CODES.FROYO)
      @Override
      public boolean onConsoleMessage(ConsoleMessage consoleMessage) {
        Log.d(TAG, consoleMessage.message());
        return super.onConsoleMessage(consoleMessage);
      }

      @Override
      public boolean onCreateWindow(WebView view, boolean isDialog, boolean isUserGesture, Message resultMsg) {
        Log.d(TAG, "onCreateWindow: ");
//        final FlutterView flutterView = (FlutterView) ((ViewGroup) activity.findViewById(android.R.id.content)).getChildAt(0);
//        final ViewGroup viewGroup = (ViewGroup) activity.findViewById(android.R.id.content);
//        final View popupView = createPopupWebview(resultMsg);
//        viewGroup.addView(popupView);
        return true;
      }
    });

    webview.setWebViewClient(new WebViewClient() {
      @Override
      public void onPageFinished(WebView view, String url) {
        Log.d(TAG, "onPageFinished " + url);
        channel.invokeMethod("onPageFinished",null);
      }

      @Override
      public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
        Log.d(TAG, "onReceivedError " + error.getDescription() );
      }

      @Override
      public void onReceivedHttpError(
              WebView view, WebResourceRequest request, WebResourceResponse errorResponse) {
        Log.d(TAG, "onReceivedHttpError " + errorResponse.getReasonPhrase() );
      }

      @Override
      public void onReceivedSslError(WebView view, SslErrorHandler handler,
                                     SslError error) {
        Log.d(TAG, "onReceivedSslError " );
      }
    });

    return webview;
  }

  private View createPopupWebview(Message resultMsg) {
    WebView webview = new WebView(activity);
    webview.getSettings().setJavaScriptEnabled(true);
    webview.getSettings().setSupportZoom(true);
    webview.getSettings().setBuiltInZoomControls(true);
    webview.getSettings().setPluginState(WebSettings.PluginState.ON);
    webview.getSettings().setSupportMultipleWindows(true);

    WebView.WebViewTransport transport = (WebView.WebViewTransport) resultMsg.obj;
    transport.setWebView(webview);
    resultMsg.sendToTarget();

    webview.setWebViewClient(new WebViewClient() {
      @Override
      public boolean shouldOverrideUrlLoading(WebView view, String url) {
        view.loadUrl(url);
        return true;
      }
    });
    return webview;
  }

  public class WebAppInterface {
    Context mContext;

    /** Instantiate the interface and set the context */
    WebAppInterface(Context c) {
      mContext = c;
    }

    @JavascriptInterface
    public void sendState(String state) {
      Log.d(TAG, "sendState String: " + state);
      channel.invokeMethod("State", state);
    }

  }
}
