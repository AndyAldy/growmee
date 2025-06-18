import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'controllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:growmee/theme/theme_provider.dart';
import 'routes.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import '../../../utils/helpers.dart';
import '../../utils/user_session.dart';
import 'controllers/chart_data_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Tambahkan semua controller yang dibutuhkan sebelum runApp
  Get.put(UserSession(), permanent: true);
  Get.put(ChartDataController(), permanent: true);

  final user = FirebaseAuth.instance.currentUser;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserController()),
      ],
      child: GrowME(initialRoute: user != null ? '/home' : '/', userId: user?.uid),
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
    return GetMaterialApp(
      title: 'GrowMe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      getPages: appPages,
      onGenerateRoute: (settings) {
        return GetPageRoute(
          settings: settings,
          page: () => Get.arguments == null
              ? routeSettingsToWidget(settings.name!, userId)
              : routeSettingsToWidget(settings.name!, Get.arguments),
        );
      },
    );
  }
}
