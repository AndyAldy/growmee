import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _loading = false;

  Future<void> _submitTopUp() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      Get.snackbar('Error', 'Jumlah top up tidak boleh kosong');
      return;
    }
    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Masukkan jumlah valid');
      return;
    }

    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('topups').add({
        'amount': amount,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending', // bisa kamu ubah sesuai flow
      });
      Get.snackbar('Sukses', 'Top Up berhasil disimpan');
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
        title: const Text('Top Up'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('Masukkan jumlah top up:'),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Contoh: 100000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submitTopUp,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Lanjutkan Top Up'),
            ),
          ],
        ),
      ),
    );
  }
}
