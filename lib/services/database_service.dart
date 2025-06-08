import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  // Stream riwayat jual user saat ini
  Stream<QuerySnapshot<Map<String, dynamic>>> getHistoryJualStream() {
    if (uid.isEmpty) return const Stream.empty();
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

  // Stream riwayat topup user
  Stream<QuerySnapshot<Map<String, dynamic>>> getHistoryTopupStream() {
    if (uid.isEmpty) return const Stream.empty();
    return _db
        .collection('users')
        .doc(uid)
        .collection('history_topup')
        .orderBy('tanggal', descending: true)
        .snapshots();
  }

  // Dapatkan saldo user sekarang
  Future<num> getCurrentSaldo() async {
    if (uid.isEmpty) return 0;
    final doc = await _db.collection('users').doc(uid).get();
    return (doc.data()?['saldo'] ?? 0) as num;
  }

  // Update saldo user dengan nilai baru
  Future<void> updateSaldo(num newSaldo) async {
    if (uid.isEmpty) return;
    await _db.collection('users').doc(uid).set({
      'saldo': newSaldo,
    }, SetOptions(merge: true));
  }

  // Fungsi Top Up
  Future<void> topUp({required num amount}) async {
    if (uid.isEmpty) return;

    final currentSaldo = await getCurrentSaldo();

    // Tambah saldo
    final newSaldo = currentSaldo + amount;

    // Update saldo di dokumen user
    await updateSaldo(newSaldo);

    // Simpan riwayat topup
    await _db
        .collection('users')
        .doc(uid)
        .collection('history_topup')
        .add({
      'jumlah': amount,
      'tanggal': FieldValue.serverTimestamp(),
    });
  }

  // Fungsi Jual (mengurangi investasi, menambah saldo)
  Future<void> jual({required String produk, required num jumlah, required num hasilJual}) async {
    if (uid.isEmpty) return;

    final currentSaldo = await getCurrentSaldo();
    final newSaldo = currentSaldo + hasilJual;

    // Update saldo user
    await updateSaldo(newSaldo);

    // Simpan riwayat jual
    await _db
        .collection('users')
        .doc(uid)
        .collection('history_jual')
        .add({
      'produk': produk,
      'jumlah': jumlah,
      'hasil': hasilJual,
      'tanggal': FieldValue.serverTimestamp(),
    });

    // TODO: Update portfolio_reksadana atau portfolio_sekuritas sesuai penjualan (kurangi jumlah investasi)
  }

  // Fungsi Beli (mengurangi saldo, menambah investasi)
  Future<void> beli({required String produk, required num jumlah, required num hargaTotal}) async {
    if (uid.isEmpty) return;

    final currentSaldo = await getCurrentSaldo();
    if (currentSaldo < hargaTotal) {
      throw Exception('Saldo tidak cukup');
    }
    final newSaldo = currentSaldo - hargaTotal;

    // Update saldo user
    await updateSaldo(newSaldo);

    // Simpan riwayat pembelian
    await _db
        .collection('users')
        .doc(uid)
        .collection('history_pembelian')
        .add({
      'produk': produk,
      'jumlah': jumlah,
      'harga_total': hargaTotal,
      'tanggal': FieldValue.serverTimestamp(),
    });

    // TODO: Update portfolio_reksadana atau portfolio_sekuritas sesuai pembelian (tambah jumlah investasi)
  }

  // Fungsi lain (portfolio, riskLevel, dll) seperti di kode kamu sebelumnya
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
