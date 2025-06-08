class UserModel {
  final String uid;
  final String email;
  final String? riskLevel;

  UserModel({
    required this.uid,
    required this.email,
    this.riskLevel,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      riskLevel: map['riskLevel'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'riskLevel': riskLevel,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? riskLevel,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      riskLevel: riskLevel ?? this.riskLevel,
    );
  }
}
