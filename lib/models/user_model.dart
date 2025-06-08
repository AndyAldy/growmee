class UserModel {
  final String uid;
  final String email;
  final String? riskLevel;
  final String? name; // tambahkan name jika memang ingin disimpan

  UserModel({
    required this.uid,
    required this.email,
    this.riskLevel,
    this.name,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      riskLevel: map['riskLevel'],
      name: map['name'], // pastikan field ini sesuai di Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'riskLevel': riskLevel,
      'name': name,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? riskLevel,
    String? name,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      riskLevel: riskLevel ?? this.riskLevel,
      name: name ?? this.name,
    );
  }
}
