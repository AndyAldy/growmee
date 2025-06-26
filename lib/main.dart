import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // --- Pastikan import ini ada
import 'package:growmee/theme/theme_provider.dart';
import 'package:growmee/controllers/user_controller.dart';
import 'package:growmee/routes.dart';
import 'package:growmee/firebase_options.dart';
import 'package:growmee/utils/helpers.dart';
import 'package:growmee/utils/user_session.dart';
import 'package:growmee/controllers/chart_data_controller.dart';
import 'package:growmee/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Pastikan binding framework siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- PERUBAHAN DI SINI ---
  // Inisialisasi GetStorage agar bisa digunakan oleh ThemeProvider
  await GetStorage.init();

  // Menyiapkan state management GetX
  Get.put(UserSession(), permanent: true);
  Get.put(ChartDataController(), permanent: true);

  // Mengecek status login user saat aplikasi dimulai
  final user = FirebaseAuth.instance.currentUser;

  runApp(
    MultiProvider(
      providers: [
        // Daftarkan semua provider Anda di sini
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserController()),
      ],
      child: GrowME(initialRoute: user != null ? '/' : '/', userId: user?.uid),
    ),
  );
}

class GrowME extends StatelessWidget {
  final String initialRoute;
  final String? userId;

  const GrowME({
    super.key,
    required this.initialRoute,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GetMaterialApp(
          title: 'GrowMe',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          // Mengambil themeMode dari ThemeProvider
          themeMode: themeProvider.themeMode,
          initialRoute: initialRoute,
          getPages: appPages,
          // Logika onGenerateRoute Anda tidak perlu diubah
          onGenerateRoute: (settings) {
            return GetPageRoute(
              settings: settings,
              page: () => Get.arguments == null
                  ? routeSettingsToWidget(settings.name!, userId)
                  : routeSettingsToWidget(settings.name!, Get.arguments),
            );
          },
        );
      },
    );
  }
}
