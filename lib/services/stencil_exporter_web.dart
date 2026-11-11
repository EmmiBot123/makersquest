// Browser Blob SVG stencil downloader for Flutter Web
import 'dart:js_interop';
import 'package:web/web.dart' as web;

bool downloadTextFileImpl(String filename, String mimeType, String content) {
  try {
    final parts = <JSAny>[content.toJS].toJS;
    final blob = web.Blob(parts, web.BlobPropertyBag(type: mimeType));
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = filename;
    anchor.click();
    web.URL.revokeObjectURL(url);
    return true;
  } catch (_) {
    return false;
  }
}
