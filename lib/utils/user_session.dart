import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSession extends GetxController {
  final _storage = GetStorage();

  // Kunci untuk local storage
  static const _userIdKey = 'userId';
  static const _userNameKey = 'userName';
  static const _fingerprintEnabledKey = 'fingerprintEnabled'; // <-- TAMBAHKAN KUNCI BARU

  // Properti reaktif
  final userId = ''.obs;
  final userName = ''.obs;
  final isFingerprintEnabled = false.obs; // <-- TAMBAHKAN PROPERTI REAKTIF BARU

  UserSession() {
    // Load dari local storage saat inisialisasi
    userId.value = _storage.read(_userIdKey) ?? '';
    userName.value = _storage.read(_userNameKey) ?? '';
    isFingerprintEnabled.value = _storage.read(_fingerprintEnabledKey) ?? false; // <-- MUAT STATUS FINGERPRINT

    // Jika ada user ID saat pertama kali buka, muat datanya dari Firestore
    if (userId.value.isNotEmpty) {
      loadUserData(userId.value);
    }
  }

  void setUserId(String id) {
    userId.value = id;
    _storage.write(_userIdKey, id);
    // Secara otomatis memuat data user (termasuk nama & status fingerprint) saat ID di-set
    if (id.isNotEmpty) {
      loadUserData(id);
    }
  }

  void setUserName(String name) {
    userName.value = name;
    _storage.write(_userNameKey, name);
  }

  // Method ini bisa dipanggil dari halaman setting jika user mengubah preferensi fingerprint
  void setFingerprintEnabled(bool isEnabled) {
    isFingerprintEnabled.value = isEnabled;
    _storage.write(_fingerprintEnabledKey, isEnabled);
  }

  Future<void> loadUserData(String uid) async {
    if (uid.isEmpty) return; // Jangan lakukan apa-apa jika uid kosong
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        final name = data?['name'] ?? '';
        final fingerprintStatus = data?['fingerprintEnabled'] ?? false; // <-- AMBIL STATUS FINGERPRINT DARI FIRESTORE

        // Update properti reaktif dan simpan ke local storage
        userName.value = name;
        isFingerprintEnabled.value = fingerprintStatus;
        _storage.write(_userNameKey, name);
        _storage.write(_fingerprintEnabledKey, fingerprintStatus); // <-- SIMPAN STATUS FINGERPRINT

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
    // Listener ini bagus untuk debugging, tidak perlu diubah
    ever(userId, (String value) {
      print('[DEBUG] User ID berubah menjadi: $value');
      if (value.isEmpty) {
        clear(); // Pastikan semua data bersih jika user ID menjadi kosong
      }
    });
  }
}