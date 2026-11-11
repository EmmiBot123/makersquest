// Web URL launcher implementation for MakerQuest
import 'package:web/web.dart' as web;

void openExternalUrlImpl(String url) {
  try {
    web.window.open(url, '_blank', 'noopener,noreferrer');
  } catch (_) {}
}

