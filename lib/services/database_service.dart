import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // UID user aktif, jika tidak ada maka kosong
  String get uid => _auth.currentUser?.uid ?? '';

  // Stream riwayat jual user saat ini
  Stream<QuerySnapshot<Map<String, dynamic>>> getHistoryJualStream() {
    if (uid.isEmpty) {
      // Jika user belum login, bisa return stream kosong atau error stream
      return const Stream.empty();
    }
    return _db
        .collection('users')
        .doc(uid)
        .collection('history_jual')
        .orderBy('tanggal', descending: true)
        .snapshots();
  }

  // Stream riwayat pembelian user
  Stream<QuerySnapshot<Map<String, dynamic>>> getHistoryPembelianStream() {
    if (uid.isEmpty) return const Stream.empty();
    return _db
        .collection('users')
        .doc(uid)
        .collection('history_pembelian')
        .orderBy('tanggal', descending: true)
        .snapshots();
  }

  // Stream riwayat pengalihan user
  Stream<QuerySnapshot<Map<String, dynamic>>> getHistoryPengalihanStream() {
    if (uid.isEmpty) return const Stream.empty();
    return _db
        .collection('users')
        .doc(uid)
        .collection('history_pengalihan')
        .orderBy('tanggal', descending: true)
        .snapshots();
  }

Stream<QuerySnapshot<Map<String, dynamic>>> getReksadanaPortfolioStream(String userId) {
  if (userId.isEmpty) return const Stream.empty();
  return _db
      .collection('users')
      .doc(userId)
      .collection('portfolio_reksadana')
      .snapshots();
}
Stream<QuerySnapshot<Map<String, dynamic>>> getCurrentUserReksadanaPortfolio() {
  return getReksadanaPortfolioStream(uid);
}
Future<String?> getCurrentUserRiskLevel() {
  return getUserRiskLevel(uid);
}

Stream<QuerySnapshot<Map<String, dynamic>>> getSekuritasPortfolioStream(String userId) {
  if (userId.isEmpty) return const Stream.empty();
  return _db
      .collection('users')
      .doc(userId)
      .collection('portfolio_sekuritas')
      .snapshots();
}

Future<String?> getUserRiskLevel(String userId) async {
  if (userId.isEmpty) return null;
  final doc = await _db.collection('users').doc(userId).get();
  return doc.data()?['riskLevel'] as String?;
}


Future<void> setUserRiskLevel(String userId, String riskLevel) async {
  if (userId.isEmpty) return;
  await _db.collection('users').doc(userId).set(
    {'riskLevel': riskLevel},
    SetOptions(merge: true),
  );
}
}
