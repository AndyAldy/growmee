import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'controllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:growmee/theme/theme_provider.dart';
import 'routes.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase sesuai dengan platform (Android/iOS/Web)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserController()..fetchUserData(),
        ),
        // Tambahkan AuthController jika diperlukan
      ],
      child: const GrowME(),
    ),
  );
}

class GrowME extends StatelessWidget {
  const GrowME({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GrowMe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      getPages: appPages,
    );
  }
}
