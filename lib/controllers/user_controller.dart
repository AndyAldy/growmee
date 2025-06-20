import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:get/get.dart';
import '../utils/user_session.dart';

class UserController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  Future<bool> checkUserExists(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists;
  }

  Future<void> saveInitialUserData(String userId, String email, String name) async {
    try {
      final userDoc = _db.collection('users').doc(userId);

      // Buat instance UserModel terlebih dahulu
      _userModel = UserModel(
        uid: userId,
        email: email,
        name: name,
        riskLevel: null,
        fingerprintEnabled: false,
      );

      // Gunakan toMap() dari model untuk konsistensi
      await userDoc.set(_userModel!.toMap(), SetOptions(merge: true));

      notifyListeners();
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  Future<void> fetchUserData(String userId) async {
    // Menggunakan userId dari parameter agar lebih fleksibel, tapi bisa juga pakai _auth.currentUser
    if (userId.isEmpty) return;

    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        // Gunakan factory constructor dari UserModel
        _userModel = UserModel.fromDocument(doc);
        
        // ✅ SINKRONISASI DENGAN USER_SESSION (LEBIH BAIK)
        if (_userModel != null) {
          final session = Get.find<UserSession>();
          _userModel!.updateSession(session); // Memanggil method dari model
        }

        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void updateRiskLevel(String val) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      await _db.collection('users').doc(uid).update({'riskLevel': val});
      _userModel = _userModel?.copyWith(riskLevel: val);
      notifyListeners();
    } catch (e) {
      print('Error updating risk level: $e');
    }
  }

Future<void> updateFingerprintStatus(bool isEnabled) async {
  final userId = _auth.currentUser?.uid;
  if (userId == null) return;

  try {
    await _db.collection('users').doc(userId).update({
      'fingerprintEnabled': isEnabled,
    });

    if (_userModel != null) {
      _userModel = _userModel!.copyWith(fingerprintEnabled: isEnabled);
    }

    final session = Get.find<UserSession>();
    session.setFingerprintEnabled(isEnabled);

    notifyListeners();
    Get.snackbar('Sukses', 'Pengaturan fingerprint berhasil diperbarui.');

  } catch (e) {
    print('Error updating fingerprint status: $e');
  }
}
}