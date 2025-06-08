import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'controllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:growmee/theme/theme_provider.dart';
import 'routes.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserController()..fetchUserData()),
        // Jika AuthController juga pakai ChangeNotifier, bisa ditambahkan:
        // ChangeNotifierProvider(create: (_) => AuthController()),
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

