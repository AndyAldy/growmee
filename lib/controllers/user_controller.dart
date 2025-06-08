import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserController with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? get userData => _userData;

  get userModel => null;

  Future<void> fetchUserData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        _userData = null;
        notifyListeners();
        return;
      }

      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _userData = doc.data();
      } else {
        _userData = null;
      }
      notifyListeners();
    } catch (e) {
      // Bisa tambahkan logging error disini
      print('Error fetching user data: $e');
    }
  }

  Future<void> updateRiskLevel(String riskLevel) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await _db.collection('users').doc(uid).set({'riskLevel': riskLevel}, SetOptions(merge: true));
      if (_userData != null) {
        _userData!['riskLevel'] = riskLevel;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating risk level: $e');
    }
  }
}
