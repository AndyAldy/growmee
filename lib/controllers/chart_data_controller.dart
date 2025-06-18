import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ChartDataController extends GetxController {
  var latestPrice = 1000.0.obs;
  var selectedProduct = 'Reksadana'.obs;
  var returnRate = 0.08.obs;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void updatePrice(double price) {
    latestPrice.value = price;
  }

  void updateProduct(String product) {
    selectedProduct.value = product;
  }

  void updateReturnRate(double rate) {
    returnRate.value = rate;
  }

  Future<void> fetchDataFromAPI() async {
    final snapshot = await _db.collection('reksadana_market').limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      updateProduct(data['name']);
      updatePrice((data['price'] ?? 1000).toDouble());
      updateReturnRate((data['return_rate'] ?? 0.08).toDouble());
    }
  }
}
