import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSession extends GetxController {
  final userId = ''.obs;
  final userName = ''.obs;

  void setUserId(String id) {
    userId.value = id;
    loadUserData(id);
  }

  void setUserName(String name) {
    userName.value = name;
  }

  Future<void> loadUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        userName.value = data?['name'] ?? ''; // ✅ ganti dari 'nama' jadi 'name'
        print('[DEBUG] Nama pengguna: ${userName.value}');
      } else {
        print('[DEBUG] Data user tidak ditemukan untuk UID: $uid');
      }
    } catch (e) {
      print('[ERROR] Gagal mengambil data user: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    ever(userId, (value) {
      print('[DEBUG] User ID updated globally: $value');
    });
  }
}
