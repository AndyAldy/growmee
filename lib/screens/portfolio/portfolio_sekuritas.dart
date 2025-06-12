import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../services/database_service.dart';
import '../../utils/user_session.dart';

class PortfolioSekuritasScreen extends StatelessWidget {
  final DatabaseService _dbService = DatabaseService();
  PortfolioSekuritasScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final userId = Get.find<UserSession>().userId.value;
    return Scaffold(
      appBar: AppBar(title: const Text('Portofolio Sekuritas'),
    leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Get.back(),
  ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _dbService.getSekuritasPortfolioStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada portofolio sekuritas.'));
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['nama_saham'] ?? 'Saham'),
                subtitle: Text('Jumlah Saham: ${data['jumlah_saham']}'),
                trailing: Text('Nilai: Rp ${data['nilai']}'),
              );
            },
          );
        },
      ),
    );
  }
}
