import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserController with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  /// Fetch data user dari Firestore dan simpan ke model
  Future<void> fetchUserData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        _userModel = null;
        notifyListeners();
        return;
      }

      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _userModel = UserModel.fromMap(doc.data()!, uid);
      }

      notifyListeners();
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  /// Update level risiko user
  Future<void> updateRiskLevel(String riskLevel) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await _db.collection('users').doc(uid).set(
        {'riskLevel': riskLevel},
        SetOptions(merge: true),
      );

      if (_userModel != null) {
        _userModel = UserModel(
          uid: _userModel!.uid,
          email: _userModel!.email,
          riskLevel: riskLevel,
        );
      }

      notifyListeners();
    } catch (e) {
      print('Error updating risk level: $e');
    }
  }

  /// Simpan data awal user ke Firestore setelah register
  Future<void> saveInitialUserData(String email) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final userDoc = _db.collection('users').doc(uid);

      await userDoc.set({
        'email': email,
        'riskLevel': null,
      }, SetOptions(merge: true));

      _userModel = UserModel(uid: uid, email: email, riskLevel: null);
      notifyListeners();
    } catch (e) {
      print('Error saving user data: $e');
    }
  }
}
