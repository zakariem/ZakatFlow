import 'package:flutter/material.dart';
import 'auth/login_view.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zakat App',
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: const LoginView(),
    );
  }
}
