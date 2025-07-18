import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:growmee/screens/portfolio/Chart_screen.dart';
import 'package:growmee/theme/theme_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../widgets/nav_bar.dart';
import '../../utils/user_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final session = Get.find<UserSession>();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: Text(
          'Kalkulator Investasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: isDark ? Colors.white : Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Obx(() => Text(
                'Halo ${session.userName.value.isNotEmpty ? session.userName.value : 'Calon Investor'}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              )),
          const SizedBox(height: 28),
          Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickAction(
                icon: Icons.show_chart,
                label: 'Live Chart',
                isDark: isDark,
                onTap: () => Get.to(() => const ChartScreen()),
              ),
              _QuickAction(
                icon: Icons.support_agent,
                label: 'Joko',
                isDark: isDark,
                onTap: () => Get.toNamed('/ai'),
              ),
              _QuickAction(
                icon: Icons.account_circle_outlined,
                label: 'Profile',
                isDark: isDark,
                onTap: () => Get.toNamed('/profile'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Kalkulator Investasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          InvestmentCalculator(isDark: isDark),
        ],
      ),
      bottomNavigationBar: const NavBar(currentIndex: 0),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isDark ? Colors.grey[800] : Colors.white,
            child: Icon(icon, size: 28, color: Colors.blueAccent),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
class InvestmentCalculator extends StatefulWidget {
  final bool isDark;

  const InvestmentCalculator({super.key, required this.isDark});

  @override
  State<InvestmentCalculator> createState() => _InvestmentCalculatorState();
}

class _InvestmentCalculatorState extends State<InvestmentCalculator> {
  final TextEditingController _monthlyController = TextEditingController(text: '10000');
  int _selectedYear = 1;
  double? _result;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _reksadanaList = [];
  String? _selectedReksadanaId;
  String? _selectedReksadanaType;

  @override
  void initState() {
    super.initState();
    _fetchAllReksadana();
  }

  Future<void> _fetchAllReksadana() async {
    final snapshot = await _db.collection('reksadana_market').get();
    setState(() {
      _reksadanaList = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'],
          'type': data['type'],
        };
      }).toList();

      if (_reksadanaList.isNotEmpty) {
        final first = _reksadanaList.first;
        _selectedReksadanaId = first['id'];
        _selectedReksadanaType = first['type'];
      }
    });
  }

  double getEstimatedReturn(String type, int year) {
    final Map<String, Map<int, double>> returnTable = {
      'Pasar Uang': {1: 0.05, 2: 0.06, 3: 0.08, 4: 0.12, 5: 0.13, 6: 0.15, 7: 0.20},
      'Obligasi':   {1: 0.06, 2: 0.08, 3: 0.10, 4: 0.14, 5: 0.16, 6: 0.18, 7: 0.22},
      'Saham':      {1: 0.10, 2: 0.15, 3: 0.18, 4: 0.22, 5: 0.28, 6: 0.32, 7: 0.40},
    };

    return returnTable[type]?[year] ?? 0.05;
  }

void _calculate() {
  final monthly = double.tryParse(_monthlyController.text.replaceAll('.', '')) ?? 0;
  if (monthly == 0 || _selectedReksadanaType == null) {
    setState(() => _result = null);
    return;
  }

  final totalInvest = monthly * 12 * _selectedYear;

  print('>> Selected type: $_selectedReksadanaType');
  print('>> Selected year: $_selectedYear');

  final returnRate = getEstimatedReturn(_selectedReksadanaType!, _selectedYear);
  print('>> Return rate: $returnRate');

  final gain = totalInvest * returnRate;
  setState(() {
    _result = totalInvest + gain;
  });
}


  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nominal per Bulan:', style: TextStyle(color: widget.isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 8),
          TextField(
            controller: _monthlyController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '10000',
              filled: true,
              fillColor: widget.isDark ? Colors.grey[800] : Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (Value) {
              setState(() {
                _result = null;
              });
            }
          ),
          const SizedBox(height: 16),
          Text('Pilih Reksadana:', style: TextStyle(color: widget.isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedReksadanaId,
            decoration: InputDecoration(
              filled: true,
              fillColor: widget.isDark ? Colors.grey[800] : Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: _reksadanaList.map((rek) {
              final label = '${rek['type']} - ${rek['name']}';
              return DropdownMenuItem<String>(
                value: rek['id'],
                child: Text(label),
              );
            }).toList(),
            onChanged: (val) {
              if (val == null) return;
              final selected = _reksadanaList.firstWhere((rek) => rek['id'] == val, orElse: () => {});
              setState(() {
                _selectedReksadanaId = val;
                _selectedReksadanaType = selected['type'];
                _result = null;
              });
            },
          ),
          const SizedBox(height: 16),
          Text('Durasi Investasi (tahun):', style: TextStyle(color: widget.isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _selectedYear,
            decoration: InputDecoration(
              filled: true,
              fillColor: widget.isDark ? Colors.grey[800] : Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: List.generate(7, (i) => i + 1).map((year) {
              return DropdownMenuItem(value: year, child: Text('$year Tahun'));
            }).toList(),
            onChanged: (val) {
            if (val != null) {
              setState(() {
                   _selectedYear = val;
                  _result = null;
              });
          }
        },

          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculate,
              child: const Text('Hitung Keuntungan'),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            Divider(color: widget.isDark ? Colors.white24 : Colors.grey),
            const SizedBox(height: 12),
            Text(
              'Hasil Perhitungan:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Investasi:', style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black87)),
                Text(
                  formatter.format(double.parse(_monthlyController.text.replaceAll('.', '')) * 12 * _selectedYear),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Keuntungan Estimasi:', style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black87)),
                Text(
                  formatter.format(_result! - (double.parse(_monthlyController.text.replaceAll('.', '')) * 12 * _selectedYear)),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Akhir:', style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black87)),
                Text(
                  formatter.format(_result),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}
