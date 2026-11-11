// In-memory storage stub for VM widget & unit tests
final Map<String, String> _vmMemoryStore = {};

String? loadStorageValueImpl(String key) => _vmMemoryStore[key];

void saveStorageValueImpl(String key, String value) {
  _vmMemoryStore[key] = value;
}

void resetStorageForTestsImpl(String key) {
  _vmMemoryStore.remove(key);
}
