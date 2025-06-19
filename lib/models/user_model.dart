import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:growmee/utils/user_session.dart';

class UserModel {
  final String uid;
  final String email;
  final String? riskLevel;
  final String? name;
  final bool fingerprintEnabled; // ✅ Tambahan

  UserModel({
    required this.uid,
    required this.email,
    this.riskLevel,
    this.name,
    this.fingerprintEnabled = false, // ✅ Default false
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      riskLevel: map['riskLevel'],
      name: map['name'],
      fingerprintEnabled: map['fingerprintEnabled'] ?? false, // ✅ Ambil dari Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'riskLevel': riskLevel,
      'name': name,
      'fingerprintEnabled': fingerprintEnabled, // ✅ Simpan ke Firestore
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? riskLevel,
    String? name,
    bool? fingerprintEnabled,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      riskLevel: riskLevel ?? this.riskLevel,
      name: name ?? this.name,
      fingerprintEnabled: fingerprintEnabled ?? this.fingerprintEnabled,
    );
  }

  static UserModel? fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return null;

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      riskLevel: data['riskLevel'],
      name: data['name'],
      fingerprintEnabled: data['fingerprintEnabled'] ?? false, // ✅
    );
  }

  // Untuk menyimpan session ke UserSession
  void updateSession(UserSession session) {
    session.setUserId(uid);
    session.setUserName(name ?? '');
  }
}
