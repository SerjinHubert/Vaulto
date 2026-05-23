import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaulto/providers/auth_provider.dart';
import 'package:vaulto/providers/finance_provider.dart';
import 'package:vaulto/data/services/firestore_service.dart';
import 'package:vaulto/ui/screens/main_screen.dart';
import 'package:vaulto/ui/screens/auth_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      return const AuthScreen();
    }

    return ChangeNotifierProvider(
      create: (_) => FinanceProvider(FirestoreService(authProvider.user!.uid)),
      child: const MainScreen(),
    );
  }
}
