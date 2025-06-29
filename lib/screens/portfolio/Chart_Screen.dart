import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:growmee/theme/theme_provider.dart';
import 'package:growmee/widgets/nav_bar.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:intl/intl.dart'; 
import 'package:provider/provider.dart';
import '../../controllers/chart_data_controller.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({Key? key}) : super(key: key);

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final ChartDataController controller = Get.find<ChartDataController>();
  Stream<List<FlSpot>>? _stream;

  @override
  void initState() {
    super.initState();
    _setupStream(controller.selectedProduct.value);
  }

  void _setupStream(String type) {
    // ---- PERUBAHAN UTAMA ADA DI SINI ----
    // Kita panggil setState untuk memberitahu Flutter agar membangun ulang widget
    // dengan stream yang baru.
    setState(() {
      _stream = _priceStream(type);
    });
  }

  Stream<List<FlSpot>> _priceStream(String type) async* {
    int x = 0;
    List<FlSpot> buffer = [];

    while (true) {
      final price = await _fetchPrice(type);
      if (price > 0) {
        x++;
        controller.updatePrice(price);
        buffer.add(FlSpot(x.toDouble(), price));
        if (buffer.length > 30) buffer.removeAt(0);
        yield List.from(buffer);
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<double> _fetchPrice(String type) async {
    try {
      if (type == 'Reksadana') {
        final uri = Uri.parse(
            'https://arima-reksadana-api.vercel.app/api?rd=RD13&days=1');
        final res = await http.get(uri).timeout(const Duration(seconds: 3));
        final d = jsonDecode(res.body);
        final price = (d['data'].last['close'] as num).toDouble();
        controller.updateReturnRate(0.08);
        return price;
      } else if (type == 'Saham') {
        final res = await http
            .get(Uri.parse('https://api.goapi.io/quotes?symbol=BBCA'))
            .timeout(const Duration(seconds: 3));
        final data = jsonDecode(res.body);
        controller.updateReturnRate(0.12);
        return (data['price'] as num).toDouble();
      } else if (type == 'Obligasi') {
        final res = await http
            .get(Uri.parse(
                'https://api.tradingeconomics.com/historical/country/indonesia/government-bond-yield?&c=API_KEY'))
            .timeout(const Duration(seconds: 3));
        final data = jsonDecode(res.body);
        controller.updateReturnRate(0.06);
        return (data['price'] as num).toDouble();
      }
      return controller.latestPrice.value;
    } catch (_) {
      return controller.latestPrice.value + Random().nextDouble() * 10 - 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Obx(() => Text(
              'Grafik ${controller.selectedProduct.value}',
              style: TextStyle(color: isDark ? Colors.white : Colors.white),
            )),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedProduct.value,
                  decoration: InputDecoration(
                    labelText: 'Pilih Produk',
                    border: const OutlineInputBorder(),
                    labelStyle:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                  dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  iconEnabledColor: isDark ? Colors.white : Colors.black,
                  items: ['Reksadana', 'Obligasi', 'Saham']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      // Cukup panggil updateProduct. _setupStream akan dipanggil dari setState.
                      controller.updateProduct(val); 
                      _setupStream(val);
                    }
                  },
                )),
          ),
          Expanded(
            child: StreamBuilder<List<FlSpot>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.length < 2) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;
                final minY = data.map((e) => e.y).reduce(min);
                final maxY = data.map((e) => e.y).reduce(max);

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: LineChart(
                    LineChartData(
                      minY: minY * 0.98,
                      maxY: maxY * 1.02,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50, 
                          getTitlesWidget: (value, meta) {
                            if (value == meta.max || value == meta.min) {
                              return const SizedBox();
                            }
                            
                            final formatter = NumberFormat.compactSimpleCurrency(locale: 'id_ID');

                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                formatter.format(value),
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        )),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (value) {
                          return const FlLine(color: Colors.grey, strokeWidth: 0.4);
                        },
                        getDrawingVerticalLine: (value) {
                          return const FlLine(color: Colors.grey, strokeWidth: 0.4);
                        },
                      ),
                      borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.grey, width: 0.5)),
                      lineBarsData: [
                        LineChartBarData(
                          spots: data,
                          isCurved: true,
                          color: isDark ? Colors.cyanAccent : Colors.blueAccent,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                (isDark ? Colors.cyanAccent : Colors.blueAccent).withOpacity(0.3),
                                (isDark ? Colors.cyanAccent : Colors.blueAccent).withOpacity(0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
      bottomNavigationBar: const NavBar(currentIndex: 1),
    );
  }
}