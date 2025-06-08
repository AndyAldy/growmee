import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../services/database_service.dart';

class PortfolioReksadanaScreen extends StatelessWidget {
  final String userId;
  final DatabaseService _dbService = DatabaseService();

  PortfolioReksadanaScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portofolio Reksadana'),
    leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Get.back(),
  ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _dbService.getReksadanaPortfolioStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada portofolio reksadana.'));
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['nama_fund'] ?? 'Reksadana'),
                subtitle: Text('Jumlah Unit: ${data['jumlah_unit']}'),
                trailing: Text('Nilai: Rp ${data['nilai']}'),
              );
            },
          );
        },
      ),
    );
  }
}
