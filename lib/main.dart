import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'firebase_options.dart';
import 'routes/app_routes.dart'; 
import 'pages/auth/login_page.dart';
import 'pages/home/home_page.dart';
import 'pages/repot/report_desktop.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory App',
      initialRoute: AppRoutes.login,

      routes: {
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.home: (context) => const HomePage(),
        AppRoutes.report: (context) => const ReportDesktop(),
      },
    );
  }
}