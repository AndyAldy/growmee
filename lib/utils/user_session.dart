import 'package:get/get.dart';

class UserSession extends GetxController {
  var userId = ''.obs;

  void setUserId(String id) {
    userId.value = id;
  }
}
