import 'package:flutter/material.dart';

class ReksadanaCard extends StatelessWidget {
  final String title;
  final String risk;
  final double returnPercent;
  final double amount;

  const ReksadanaCard({
    super.key,
    required this.title,
    required this.risk,
    required this.returnPercent,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Risiko: $risk'),
          const SizedBox(height: 4),
          Text('Return: ${returnPercent.toStringAsFixed(2)}%'),
          const SizedBox(height: 4),
          Text('Investasi Anda: Rp ${amount.toStringAsFixed(0)}'),
        ],
      ),
    );
  }
}
