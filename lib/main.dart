import 'package:flutter/material.dart';
import 'routes.dart';
import 'constants/colors.dart';
import 'theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const GrowMEApp());
}

class GrowMEApp extends StatelessWidget {
  const GrowMEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'GrowME',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              scaffoldBackgroundColor: skyBlue,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData.dark(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/',
            routes: appRoutes,
          );
        },
      ),
    );
  }
}