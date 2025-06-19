import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:growmee/widgets/nav_bar.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
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
    _stream = _priceStream(type);
  }

  Stream<List<FlSpot>> _priceStream(String type) async* {
    int x = 0;
    List<FlSpot> buffer = [];

    while (true) {
      final price = await _fetchPrice(type);
      if (price > 0) {
        x++;
        controller.updatePrice(price); // update harga
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
        final uri = Uri.parse('https://arima-reksadana-api.vercel.app/api?rd=RD13&days=1');
        final res = await http.get(uri).timeout(const Duration(seconds: 3));
        final d = jsonDecode(res.body);
        final price = (d['data'].last['close'] as num).toDouble();
        controller.updateReturnRate(0.08);
        return price;
      } else if (type == 'Saham') {
        final res = await http.get(Uri.parse('https://api.goapi.io/quotes?symbol=BBCA'))
            .timeout(const Duration(seconds: 3));
        final data = jsonDecode(res.body);
        controller.updateReturnRate(0.12);
        return (data['price'] as num).toDouble();
      } else if (type == 'Obligasi') {
        final res = await http.get(Uri.parse('https://api.tradingeconomics.com/historical/country/indonesia/government-bond-yield?&c=API_KEY'))
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
    final isDark = AppTheme(context).isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Obx(() => Text('Grafik ${controller.selectedProduct.value}')),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() => DropdownButtonFormField<String>(
            value: controller.selectedProduct.value,
            decoration: const InputDecoration(
              labelText: 'Pilih Produk',
              border: OutlineInputBorder(),
            ),
            items: ['Reksadana', 'Obligasi', 'Saham']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {
              if (val != null) {
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
              final diffY = maxY - minY;
              final minX = data.first.x;
              final maxX = data.last.x;
              final diffX = maxX - minX;
              final yInt = max(1.0, (diffY / 4).ceilToDouble());
              final xInt = max(1.0, (diffX / 4).ceilToDouble());

              return Padding(
                padding: const EdgeInsets.all(16),
                child: LineChart(
                  LineChartData(
                    minY: minY * 0.95,
                    maxY: maxY * 1.05,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, interval: xInt)),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, interval: yInt)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                          spots: data,
                          isCurved: true,
                          color: isDark ? Colors.cyanAccent : Colors.blueAccent,
                          barWidth: 3)
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ]),
      bottomNavigationBar: const NavBar(currentIndex: 1),
    );
  }
}
