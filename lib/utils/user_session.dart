import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSession extends GetxController {
  final _storage = GetStorage();
  final userId = ''.obs;
  final userName = ''.obs;

  UserSession() {
    // Load dari local storage saat inisialisasi
    userId.value = _storage.read('userId') ?? '';
    userName.value = _storage.read('userName') ?? '';

    if (userId.value.isNotEmpty) {
      loadUserData(userId.value);
    }
  }

  void setUserId(String id) {
    userId.value = id;
    _storage.write('userId', id);
    loadUserData(id);
  }

  void setUserName(String name) {
    userName.value = name;
    _storage.write('userName', name);
  }

  Future<void> loadUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        final name = data?['name'] ?? '';
        userName.value = name;
        _storage.write('userName', name);
        print('[DEBUG] Nama pengguna dimuat: $name');
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
    _storage.remove('userId');
    _storage.remove('userName');
    print('[DEBUG] Session dihapus');
  }

  @override
  void onInit() {
    super.onInit();
    ever(userId, (value) {
      print('[DEBUG] User ID berubah menjadi: $value');
    });
  }
}
