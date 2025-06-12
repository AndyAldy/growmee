import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/user_session.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _loading = false;

  Future<void> simpanTopUp(int nominal) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'Anda belum login');
      return;
    }

    final session = Get.find<UserSession>();
    final userId = session.userId.value;

    print('DEBUG - TopUp oleh userId: $userId');

    await FirebaseFirestore.instance.collection('topups').add({
      'amount': nominal,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending', // sesuai flow
    });
  }

  Future<void> _submitTopUp() async {
    final amountText = _amountController.text.trim();
    final amount = int.tryParse(amountText);

    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Masukkan jumlah yang valid');
      return;
    }

    setState(() => _loading = true);
    try {
      await simpanTopUp(amount);
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
