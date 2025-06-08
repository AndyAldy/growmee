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

@override
void initState() {
  super.initState();
  // Tunggu widget ter-build sebelum ambil data dari Provider
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final userController = Provider.of<UserController>(context, listen: false);
    setState(() {
      _selectedRisk = userController.userModel?.riskLevel;
    });
  });
}


  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Risiko'),
    leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Get.back(),
  ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RadioListTile<String>(
              title: const Text('Rendah'),
              value: 'Rendah',
              groupValue: _selectedRisk,
              onChanged: (val) {
                setState(() => _selectedRisk = val);
                if (val != null) {
                  userController.updateRiskLevel(val);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Sedang'),
              value: 'Sedang',
              groupValue: _selectedRisk,
              onChanged: (val) {
                setState(() => _selectedRisk = val);
                if (val != null) {
                  userController.updateRiskLevel(val);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Tinggi'),
              value: 'Tinggi',
              groupValue: _selectedRisk,
              onChanged: (val) {
                setState(() => _selectedRisk = val);
                if (val != null) {
                  userController.updateRiskLevel(val);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
