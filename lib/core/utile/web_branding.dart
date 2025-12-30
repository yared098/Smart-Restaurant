import 'dart:js' as js;

class WebBranding {
  static void setTitle(String title) {
    js.context.callMethod('updateAppTitle', [title]);
    js.context.callMethod('updateAppleTitle', [title]);
  }

  static void setFavicon(String url) {
    if (url.isNotEmpty) {
      js.context.callMethod('updateFavicon', [url]);
    }
  }
}
