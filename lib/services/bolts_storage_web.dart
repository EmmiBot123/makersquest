// Browser localStorage implementation for MakerQuest Flutter Web
import 'package:web/web.dart' as web;

String? loadStorageValueImpl(String key) {
  try {
    return web.window.localStorage.getItem(key);
  } catch (_) {
    return null;
  }
}

void saveStorageValueImpl(String key, String value) {
  try {
    web.window.localStorage.setItem(key, value);
  } catch (_) {}
}

void resetStorageForTestsImpl(String key) {
  try {
    web.window.localStorage.removeItem(key);
  } catch (_) {}
}
