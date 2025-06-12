import 'package:get/get.dart';

class UserSession extends GetxController {
  final userId = ''.obs;

  void setUserId(String id) {
    userId.value = id;
  }

  @override
  void onInit() {
    super.onInit();

    // Tambahkan listener global setiap kali userId berubah
    ever(userId, (value) {
      print('[DEBUG] User ID updated globally: $value');
    });
  }
}
