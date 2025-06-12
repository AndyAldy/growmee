import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/user_session.dart';

class BeliScreen extends StatefulWidget {
  const BeliScreen({super.key});

  @override
  State<BeliScreen> createState() => _BeliScreenState();
}
Future<void> simpanPenjualan(String produk, int jumlah) async {
    final session = Get.find<UserSession>();
    final userId = session.userId.value;
  if (userId.isEmpty) {
    Get.snackbar('Error', 'Session user tidak ditemukan');
    return;
  }
  await FirebaseFirestore.instance.collection('pembelian').add({
    'produk': produk,
    'jumlah': jumlah,
    'userId': userId,
    'timestamp': FieldValue.serverTimestamp(),
  });
}


class _BeliScreenState extends State<BeliScreen> {
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _loading = false;

  Future<void> _submitBeli() async {
    final product = _productController.text.trim();
    final amountText = _amountController.text.trim();

    if (product.isEmpty || amountText.isEmpty) {
      Get.snackbar('Error', 'Semua kolom harus diisi');
      return;
    }
    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Jumlah beli harus valid');
      return;
    }

    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('pembelian').add({
        'produk': product,
        'jumlah': amount,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Get.snackbar('Sukses', 'Pembelian berhasil disimpan');
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
        title: const Text('Beli Reksadana'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('Pilih produk dan jumlah yang ingin dibeli:'),
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
                labelText: 'Jumlah Pembelian (Rp)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submitBeli,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Beli Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}
