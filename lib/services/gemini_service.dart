import 'package:cloud_functions/cloud_functions.dart';

class GeminiService {
  // Inisialisasi object untuk memanggil Cloud Function
  final HttpsCallable _chatCallable =
      FirebaseFunctions.instanceFor(region: 'us-central1') // Sesuaikan region jika perlu
          .httpsCallable('chatWithJoko');

  // Tidak ada lagi System Prompt, API Key, atau GenerativeModel di sini.
  // Semuanya sudah dipindahkan ke server.

  /// Mengirim pesan ke Cloud Function dan mengembalikan respons teks
  Future<String> sendMessage(String prompt) async {
    try {
      // Memanggil Cloud Function dengan prompt dari pengguna
      final response = await _chatCallable.call<Map<String, dynamic>>({
        'prompt': prompt,
      });

      // Mengambil hasil teks dari respons function
      final responseData = response.data;
      final text = responseData['responseText'] as String?;

      if (text == null) {
        return "Maaf, saya tidak dapat memberikan respons saat ini. Coba lagi.";
      }
      return text;

    } on FirebaseFunctionsException catch (e) {
      // Menangani error spesifik dari Cloud Functions
      print("FirebaseFunctionsException: ${e.code} - ${e.message}");
      throw Exception('Gagal berkomunikasi dengan server AI. Coba lagi nanti.');
    } catch (e) {
      // Menangani error umum lainnya
      print("Error sending message via Cloud Function: $e");
      rethrow;
    }
  }
}