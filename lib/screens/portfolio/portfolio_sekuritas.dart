import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';

class PortfolioSekuritasScreen extends StatelessWidget {
  final String userId;
  final DatabaseService _dbService = DatabaseService();

  PortfolioSekuritasScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portofolio Sekuritas')),
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
