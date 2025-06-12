import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/user_session.dart'; // pastikan path ini sesuai

class JualScreen extends StatefulWidget {
  const JualScreen({super.key});

  @override
  State<JualScreen> createState() => _JualScreenState();
}

// Fungsi simpan data penjualan
Future<void> simpanPenjualan(String produk, int jumlah) async {
    final session = Get.find<UserSession>();
    final userId = session.userId.value;
  if (userId.isEmpty) {
    Get.snackbar('Error', 'Session user tidak ditemukan');
    return;
  }

  await FirebaseFirestore.instance.collection('penjualan').add({
    'produk': produk,
    'jumlah': jumlah,
    'userId': userId,
    'timestamp': FieldValue.serverTimestamp(),
    'status': 'pending', // opsional
  });
}

class _JualScreenState extends State<JualScreen> {
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _loading = false;

  Future<void> _submitJual() async {
    final product = _productController.text.trim();
    final amountText = _amountController.text.trim();

    if (product.isEmpty || amountText.isEmpty) {
      Get.snackbar('Error', 'Semua kolom harus diisi');
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Jumlah jual harus valid');
      return;
    }

    setState(() => _loading = true);
    try {
      await simpanPenjualan(product, amount);
      Get.snackbar('Sukses', 'Penjualan berhasil disimpan');
      _productController.clear();
      _amountController.clear();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan data: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jual Reksadana'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('Masukkan data penjualan reksadana:'),
            const SizedBox(height: 10),
            TextField(
              controller: _productController,
              decoration: const InputDecoration(
                labelText: 'Nama Reksadana',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Penjualan (Rp)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submitJual,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Jual Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}
