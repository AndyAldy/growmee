import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSession extends GetxController {
  final _storage = GetStorage();

  static const _userIdKey = 'userId';
  static const _userNameKey = 'userName';
  static const _fingerprintEnabledKey = 'fingerprintEnabled';

  final userId = ''.obs;
  final userName = ''.obs;
  final isFingerprintEnabled = false.obs;

  UserSession() {
    userId.value = _storage.read(_userIdKey) ?? '';
    userName.value = _storage.read(_userNameKey) ?? '';
    isFingerprintEnabled.value = _storage.read(_fingerprintEnabledKey) ?? false;
    if (userId.value.isNotEmpty) {
      loadUserData(userId.value);
    }
  }

  void setUserId(String id) {
    userId.value = id;
    _storage.write(_userIdKey, id);
    if (id.isNotEmpty) {
      loadUserData(id);
    }
  }

  void setUserName(String name) {
    userName.value = name;
    _storage.write(_userNameKey, name);
  }

  void setFingerprintEnabled(bool isEnabled) {
    isFingerprintEnabled.value = isEnabled;
    _storage.write(_fingerprintEnabledKey, isEnabled);
  }

  Future<void> loadUserData(String uid) async {
    if (uid.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        final name = data?['name'] ?? '';
        final fingerprintStatus = data?['fingerprintEnabled'] ?? false;

        userName.value = name;
        isFingerprintEnabled.value = fingerprintStatus;
        _storage.write(_userNameKey, name);
        _storage.write(_fingerprintEnabledKey, fingerprintStatus);

        print('[DEBUG] Nama pengguna dimuat: $name');
        print('[DEBUG] Status Fingerprint: $fingerprintStatus');

      } else {
        print('[DEBUG] Data user tidak ditemukan untuk UID: $uid');
      }
    } catch (e) {
      print('[ERROR] Gagal mengambil data user: $e');
    }
  }

  void clear() {
    userId.value = '';
    userName.value = '';
    isFingerprintEnabled.value = false;
    _storage.remove(_userIdKey);
    _storage.remove(_userNameKey);
    _storage.remove(_fingerprintEnabledKey);
    print('[DEBUG] Session dihapus');
  }

  @override
  void onInit() {
    super.onInit();
    ever(userId, (String value) {
      print('[DEBUG] User ID berubah menjadi: $value');
      if (value.isEmpty) {
        clear();
      }
    });
  }
}