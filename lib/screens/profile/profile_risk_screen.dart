import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../controllers/user_controller.dart';

class ProfileRiskScreen extends StatefulWidget {
  const ProfileRiskScreen({super.key});

  @override
  State<ProfileRiskScreen> createState() => _ProfileRiskScreenState();
}

class _ProfileRiskScreenState extends State<ProfileRiskScreen> {
  String? _selectedRisk;
  double _riskLevelValue = 1;

  String _mapLevelToRisk(double level) {
    if (level <= 3) return 'Rendah';
    if (level <= 6) return 'Sedang';
    return 'Tinggi';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userController = Provider.of<UserController>(context, listen: false);
      setState(() {
        _selectedRisk = userController.userModel?.riskLevel ?? 'Rendah';

        // konversi dari risk string ke angka default slider
        if (_selectedRisk == 'Sedang') {
          _riskLevelValue = 4;
        } else if (_selectedRisk == 'Tinggi') {
          _riskLevelValue = 7;
        } else {
          _riskLevelValue = 1;
        }
      });
    });
  }

  void _updateRiskFromSlider(double value, UserController userController) {
    final mappedRisk = _mapLevelToRisk(value);
    setState(() {
      _riskLevelValue = value;
      _selectedRisk = mappedRisk;
    });
    userController.updateRiskLevel(mappedRisk);
  }

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Risiko'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tentukan level kenyamananmu terhadap risiko investasi (1-10):',
              style: TextStyle(fontSize: 16),
            ),
            Slider(
              value: _riskLevelValue,
              min: 1,
              max: 10,
              divisions: 9,
              label: _riskLevelValue.round().toString(),
              onChanged: (value) => _updateRiskFromSlider(value, userController),
            ),
            const SizedBox(height: 8),
            Text(
              'Profil Risiko: ${_selectedRisk ?? '-'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_selectedRisk == 'Rendah') ...[
              const Text(
                'Konservatif (Rendah)\nLebih nyaman dengan risiko rendah dan fluktuasi kecil. Cocok untuk tujuan jangka pendek.',
              ),
            ] else if (_selectedRisk == 'Sedang') ...[
              const Text(
                'Moderat (Sedang)\nBersedia mengambil risiko menengah demi hasil lebih tinggi. Cocok untuk tujuan jangka menengah.',
              ),
            ] else if (_selectedRisk == 'Tinggi') ...[
              const Text(
                'Agresif (Tinggi)\nNyaman dengan fluktuasi besar demi potensi hasil besar. Cocok untuk jangka panjang.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
