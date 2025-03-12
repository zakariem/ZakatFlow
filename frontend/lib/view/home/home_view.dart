import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../auth/login_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});
  static Route route() {
    return MaterialPageRoute(builder: (context) => HomeView());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                LoginView.route(),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: const Center(child: Text('Home Page')),
    );
  }
}
