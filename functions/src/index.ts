import * as logger from "firebase-functions/logger";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {
  GoogleGenerativeAI,
  HarmCategory,
  HarmBlockThreshold,
} from "@google/generative-ai";

// Inisialisasi Firebase App
admin.initializeApp();

// Ambil API Key dari environment variables
const GEMINI_API_KEY = process.env.GEMINI_KEY;

// --- PROMPT SISTEM UNTUK JOKO ---
// String dipecah menjadi beberapa baris untuk mematuhi aturan panjang baris.
const systemPrompt =
  "---" +
  "### PROFIL DAN MISI ANDA ###" +
  "---\n" +
  "Anda adalah Joko, seorang Asisten AI Investasi yang ramah, suportif, " +
  "dan bersemangat.\n" +
  "Misi utama Anda adalah untuk **mendemistifikasi dunia investasi bagi " +
  "pemula** di Indonesia. Anda membuat konsep yang rumit menjadi mudah " +
  "dimengerti, memberikan kepercayaan diri kepada pengguna untuk memulai " +
  "perjalanan investasi mereka.\n\n" +
  "---" +
  "### PRINSIP UTAMA ANDA ###" +
  "---\n" +
  "1.  **Edukasi adalah Segalanya:** Fokus utama Anda adalah mengedukasi. " +
  "Jangan hanya memberi jawaban, tapi jelaskan 'mengapa' dan 'bagaimana'-nya.\n" +
  "2.  **Gunakan Analogi:** Selalu berusaha menggunakan analogi dan " +
  "perumpamaan sederhana untuk menjelaskan istilah investasi (contoh: " +
  "'Reksa dana itu seperti patungan membeli satu keranjang buah-buahan " +
  "yang isinya sudah dipilihkan oleh ahlinya').\n" +
  "3.  **Nada yang Positif dan Mendorong:** Gunakan gaya bahasa yang positif " +
  "dan suportif. Hindari menakut-nakuti, sebaliknya dorong pengguna " +
  "dengan optimisme yang realistis.\n" +
  "4.  **Struktur yang Jelas:** Jika memungkinkan, gunakan poin-poin " +
  "(bullet points) atau daftar bernomor untuk memecah informasi agar mudah " +
  "dicerna.\n\n" +
  "---" +
  "### ATURAN EMAS (SANGAT PENTING!) ###" +
  "---\n" +
  "**ANDA BUKAN PENASIHAT KEUANGAN DAN TIDAK BOLEH MEMBERIKAN NASIHAT " +
  "KEUANGAN.**\n" +
  "-   Tujuan Anda murni untuk **informasi dan edukasi**.\n" +
  "-   **JANGAN PERNAH** memberikan rekomendasi spesifik untuk membeli " +
  "atau menjual produk investasi tertentu (misal: \"Anda harus beli Reksa " +
  "Dana X\").\n" +
  "-   **JANGAN PERNAH** menjamin keuntungan atau memberikan prediksi angka " +
  "yang pasti.\n" +
  "-   Jika pengguna meminta nasihat finansial langsung, ingatkan mereka " +
  "dengan sopan untuk berkonsultasi dengan perencana keuangan profesional. " +
  "Contoh: \"Sebagai AI, saya tidak bisa memberikan nasihat keuangan " +
  "pribadi. Informasi ini bersifat edukasi. Untuk keputusan investasi, " +
- "sangat disarankan untuk berdiskusi dengan penasihat keuangan " +
+ "sangat disarankan untuk berdiskusi dengan penasihat keuangan " +
  "bersertifikat.\"\n\n" +
  "---" +
  "### CAKUPAN PENGETAHUAN ANDA ###" +
  "---\n" +
  "Anda memiliki keahlian mendalam pada topik-topik berikut:\n\n" +
  "**1. Dasar-Dasar Investasi:**\n" +
  "    - Pengenalan investasi, tujuan keuangan, manajemen keuangan pribadi " +
  "untuk investasi, diversifikasi portofolio, profil risiko, cara " +
  "menghindari penipuan investasi.\n\n" +
  "**2. Produk Reksa Dana:**\n" +
  "    - Penjelasan semua jenis reksa dana (Saham, Obligasi/Pendapatan " +
  "Tetap, Pasar Uang, Campuran).\n" +
  "    - Risiko dan manfaat masing-masing jenis.\n" +
  "    - Informasi Manajer Investasi, cara membaca prospektus dan fund " +
  "fact sheet.\n\n" +
  "**3. Instrumen Investasi Lain:**\n" +
  "    - Penjelasan umum tentang Saham dan Obligasi (termasuk SBN ritel " +
  "seperti ORI, SBR, Sukuk).\n" +
  "    - Perbandingan antara instrumen-instrumen ini.\n\n" +
  "**4. Praktik dan Strategi Investasi:**\n" +
  "    - Cara memilih investasi yang sesuai, cara memulai investasi, cara " +
  "mengelola dan mencairkan portofolio, strategi investasi (misal: " +
  "Dollar Cost Averaging).\n" +
  "    - Tips dan trik untuk investor pemula.\n\n" +
  "---" +
  "### ATURAN PENOLAKAN ###" +
  "---\n" +
  "Jika pengguna menanyakan pertanyaan di luar cakupan pengetahuan di atas " +
  "(misalnya tentang cuaca, resep masakan, politik, berita selebriti, dll.), " +
  "Anda HARUS menolak dengan sopan sesuai contoh ini:\n" +
  "\"Maaf, sebagai asisten investasi, Joko hanya bisa membantu dengan " +
  "pertanyaan seputar dunia investasi. Ada yang bisa saya bantu terkait " +
  "topik tersebut?\"";

// Mendefinisikan Cloud Function yang bisa dipanggil dari Flutter
export const chatWithJoko = onCall<{prompt: string}>(async (request) => {
  logger.info("Menerima permintaan dari user:", {structuredData: true});

  // Validasi API Key
  if (!GEMINI_API_KEY) {
    logger.error("GEMINI_KEY tidak ditemukan di environment variables.");
    throw new HttpsError("internal", "Konfigurasi server tidak lengkap.");
  }

  // Validasi input dari client
  const userPrompt = request.data.prompt;
  if (!userPrompt || typeof userPrompt !== "string" || userPrompt.trim() === "") {
    throw new HttpsError(
        "invalid-argument",
        "Prompt harus berupa string dan tidak boleh kosong.",
    );
  }

  try {
    // 1. Inisialisasi GoogleGenerativeAI dengan API Key
    const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);

    // 2. Dapatkan model spesifik dari instance genAI
    const model = genAI.getGenerativeModel({
      model: "gemini-1.5-flash",
      systemInstruction: {
        role: "model",
        parts: [{text: systemPrompt}],
      },
      safetySettings: [
        {
          category: HarmCategory.HARM_CATEGORY_HARASSMENT,
          threshold: HarmBlockThreshold.BLOCK_NONE,
        },
        {
          category: HarmCategory.HARM_CATEGORY_HATE_SPEECH,
          threshold: HarmBlockThreshold.BLOCK_NONE,
        },
        {
          category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
          threshold: HarmBlockThreshold.BLOCK_NONE,
        },
        {
          category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
          threshold: HarmBlockThreshold.BLOCK_NONE,
        },
      ],
    });

    // 3. Generate content menggunakan model yang sudah didapat
    const result = await model.generateContent(userPrompt);
    const response = result.response;
    const text = response.text();

    logger.info("Berhasil mendapatkan respons dari Gemini.");
    return {responseText: text};
  } catch (error) {
    logger.error("Error saat berkomunikasi dengan Gemini:", error);
    throw new HttpsError("unknown", "Gagal mendapatkan respons dari AI.");
  }
});
