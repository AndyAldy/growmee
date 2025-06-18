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

  // Fungsi untuk menyimpan data awal user ke Firestore
  Future<void> saveInitialUserData(String userId, String email, String name) async {
    try {
      final userDoc = _db.collection('users').doc(userId);

      await userDoc.set({
        'email': email,
        'name': name,
        'riskLevel': null,
      }, SetOptions(merge: true));

      _userModel = UserModel(uid: userId, email: email, name: name, riskLevel: null);
      notifyListeners();
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  // Fungsi untuk mengambil data user
Future<void> fetchUserData(String userId) async {
  final uid = _auth.currentUser?.uid;
  if (uid == null) return;

  try {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      _userModel = UserModel(
        uid: uid,
        email: data['email'] ?? '',
        name: data['name'] ?? '',
        riskLevel: data['riskLevel'],
      );

      // ✅ Set ke session
      final session = Get.find<UserSession>();
      session.setUserId(uid);
      session.setUserName(_userModel!.name ?? '');

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

}