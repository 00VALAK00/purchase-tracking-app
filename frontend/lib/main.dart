import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';


void main() {
  runApp(const PurchaseTrackingApp());
}

class PurchaseTrackingApp extends StatelessWidget {
  const PurchaseTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Purchase Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return authProvider.isAuthenticated 
                ? const HomeScreen() 
                : const LoginScreen();
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
