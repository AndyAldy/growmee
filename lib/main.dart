import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:growmee/theme/theme_provider.dart';
import 'package:growmee/controllers/user_controller.dart';
import 'package:growmee/routes.dart';
import 'package:growmee/firebase_options.dart';
import 'package:growmee/utils/user_session.dart';
import 'package:growmee/controllers/chart_data_controller.dart';
import 'package:growmee/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await GetStorage.init();

  Get.put(UserSession(), permanent: true);
  Get.put(ChartDataController(), permanent: true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserController()),
      ],
      child: const GrowME(),
    ),
  );
}

class GrowME extends StatelessWidget {
  const GrowME({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GetMaterialApp(
          title: 'GrowMe',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          // Rute awal sekarang selalu splash screen
          initialRoute: '/',
          getPages: appPages,
        );
      },
    );
  }
}