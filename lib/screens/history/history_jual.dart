import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/database_service.dart';
import 'package:get/get.dart';

class HistoryJualScreen extends StatelessWidget {
  const HistoryJualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Jual'),
      leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Get.back(),
  ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: dbService.getHistoryJualStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error mengambil data'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Belum ada riwayat jual'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final tanggal = data['tanggal'] != null ? (data['tanggal'] as Timestamp).toDate() : null;
              final jumlah = data['jumlah'] ?? 0;
              final produk = data['produk'] ?? '-';

              return ListTile(
                title: Text(produk),
                subtitle: Text('Jumlah: $jumlah\nTanggal: ${tanggal?.toLocal().toString().split(' ')[0]}'),
              );
            },
          );
        },
      ),
    );
  }
}
