import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../services/database_service.dart';

class HistoryPengalihanScreen extends StatelessWidget {
  final DatabaseService _dbService = DatabaseService();

  HistoryPengalihanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pengalihan'),
    leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Get.back(),
  ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _dbService.getHistoryPengalihanStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada riwayat pengalihan.'));
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['produk'] ?? 'Produk'),
                subtitle: Text('Jumlah: ${data['jumlah']} - Tanggal: ${data['tanggal'].toDate()}'),
                trailing: Text('Tujuan: ${data['tujuan']}'),
              );
            },
          );
        },
      ),
    );
  }
}
