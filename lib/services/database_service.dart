import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  /// Stream riwayat jual user saat ini
  Stream<QuerySnapshot<Map<String, dynamic>>> getHistoryJualStream() {
    if (uid.isEmpty) return const Stream.empty();
    return _db
        .collection('users')
        .doc(uid)
        .collection('history_jual')
        .orderBy('tanggal', descending: true)
        .snapshots();
  }

  /// Stream riwayat pembelian user
  Stream<QuerySnapshot<Map<String, dynamic>>> getHistoryPembelianStream() {
    if (uid.isEmpty) return const Stream.empty();
    return _db
        .collection('users')
        .doc(uid)
        .collection('history_pembelian')
        .orderBy('tanggal', descending: true)
        .snapshots();
  }

  /// Stream riwayat pengalihan user
  Stream<QuerySnapshot<Map<String, dynamic>>> getHistoryPengalihanStream() {
    if (uid.isEmpty) return const Stream.empty();
    return _db
        .collection('users')
        .doc(uid)
        .collection('history_pengalihan')
        .orderBy('tanggal', descending: true)
        .snapshots();
  }

  /// Get current user saldo
  Future<num> getCurrentSaldo() async {
    if (uid.isEmpty) return 0;
    final doc = await _db.collection('users').doc(uid).get();
    return (doc.data()?['saldo'] ?? 0) as num;
  }

  /// Update user saldo
  Future<void> updateSaldo(num newSaldo) async {
    if (uid.isEmpty) return;
    await _db.collection('users').doc(uid).set({
      'saldo': newSaldo,
    }, SetOptions(merge: true));
  }

  /// Top up saldo
  Future<void> topUp({required num amount}) async {
    if (uid.isEmpty) return;
    final currentSaldo = await getCurrentSaldo();
    final newSaldo = currentSaldo + amount;
    await updateSaldo(newSaldo);
    await _db.collection('users').doc(uid).collection('history_topup').add({
      'jumlah': amount,
      'tanggal': FieldValue.serverTimestamp(),
    });
  }

  /// Proses jual produk
  Future<void> jual({required String produk, required num jumlah, required num hasilJual}) async {
    if (uid.isEmpty) return;
    final currentSaldo = await getCurrentSaldo();
    final newSaldo = currentSaldo + hasilJual;
    await updateSaldo(newSaldo);
    await _db.collection('users').doc(uid).collection('history_jual').add({
      'produk': produk,
      'jumlah': jumlah,
      'hasil': hasilJual,
      'tanggal': FieldValue.serverTimestamp(),
    });
  }

  /// Proses beli produk
  Future<void> beli({required String produk, required num jumlah, required num hargaTotal}) async {
    if (uid.isEmpty) return;
    final currentSaldo = await getCurrentSaldo();
    if (currentSaldo < hargaTotal) throw Exception('Saldo tidak cukup');
    final newSaldo = currentSaldo - hargaTotal;
    await updateSaldo(newSaldo);
    await _db.collection('users').doc(uid).collection('history_pembelian').add({
      'produk': produk,
      'jumlah': jumlah,
      'harga_total': hargaTotal,
      'tanggal': FieldValue.serverTimestamp(),
    });
  }

  /// Portfolio reksadana user tertentu
  Stream<QuerySnapshot<Map<String, dynamic>>> getReksadanaPortfolioStream(String userId) {
    if (userId.isEmpty) return const Stream.empty();
    return _db.collection('users').doc(userId).collection('portfolio_reksadana').snapshots();
  }

  /// Portfolio reksadana user login saat ini
  Stream<QuerySnapshot<Map<String, dynamic>>> getCurrentUserReksadanaPortfolio() {
    return getReksadanaPortfolioStream(uid);
  }

  /// Portfolio sekuritas user tertentu
  Stream<QuerySnapshot<Map<String, dynamic>>> getSekuritasPortfolioStream(String userId) {
    if (userId.isEmpty) return const Stream.empty();
    return _db.collection('users').doc(userId).collection('portfolio_sekuritas').snapshots();
  }

  /// Mendapatkan risk level user
  Future<String?> getUsersaldo(String userId) async {
    if (userId.isEmpty) return null;
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data()?['saldo'] as String?;
  }

  /// Set risk level user
  Future<void> setUsersaldo(String userId, String saldo) async {
    if (userId.isEmpty) return;
    await _db.collection('users').doc(userId).set({
      'saldo': saldo,
    }, SetOptions(merge: true));
  }

  /// Risk level user saat ini
  Future<String?> getCurrentUsersaldo() {
    return getUsersaldo(uid);
  }

  /// Ambil saldo user lain
  Future<num> getSaldoUser(String userId) async {
    if (userId.isEmpty) return 0;
    final doc = await _db.collection('users').doc(userId).get();
    return (doc.data()?['saldo'] ?? 0) as num;
  }

  /// Simpan riwayat pengalihan
  Future<void> simpanPengalihan({
    required String dariProduk,
    required String keProduk,
    required num jumlah,
    required num biayaPengalihan,
  }) async {
    if (uid.isEmpty) return;
    final currentSaldo = await getCurrentSaldo();
    final newSaldo = currentSaldo - biayaPengalihan;
    await updateSaldo(newSaldo);
    await _db.collection('users').doc(uid).collection('history_pengalihan').add({
      'dari': dariProduk,
      'ke': keProduk,
      'jumlah': jumlah,
      'biaya': biayaPengalihan,
      'tanggal': FieldValue.serverTimestamp(),
    });
  }

  /// Ambil daftar reksadana market
  Future<List<Map<String, dynamic>>> fetchAllReksadanaMarket() async {
    final snapshot = await _db.collection('reksadana_market').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Ambil data reksadana berdasarkan ID
  Future<Map<String, dynamic>?> fetchReksadanaById(String id) async {
    final doc = await _db.collection('reksadana_market').doc(id).get();
    return doc.exists ? doc.data() : null;
  }
    Future<List<Map<String, dynamic>>> fetchReksadanaMarket() async {
    final snapshot = await _db.collection('reksadana_market').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'type': data['type'] ?? '',
        'price': data['price'] ?? 0,
        'return': data['Keuntungan'] ?? 0.0,
      };
    }).toList();
  }
}
