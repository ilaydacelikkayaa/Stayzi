import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/onboard/onboard_screen.dart';
import 'package:stayzi_ui/services/api_service.dart';
import 'package:stayzi_ui/services/storage_service.dart';
// import 'package:stayzi_ui/screens/navigation/bottom_nav.dart'; // No longer needed for direct route

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Test StorageService import
  final storageService = StorageService();
  print('StorageService initialized');
  
  // Test ApiService import
  final apiService = ApiService();
  print('ApiService initialized');
  
  // Check if user is logged in and set token
  try {
    final isLoggedIn = await storageService.isLoggedIn();
    print('🔍 Giriş durumu: $isLoggedIn');
    
    if (isLoggedIn) {
      final token = await storageService.getAccessToken();
      print('🔑 Token: ${token != null ? "Var" : "Yok"}');

      if (token != null && token.isNotEmpty) {
        apiService.setAuthToken(token);
        print('🔐 Token set edildi');
      }
    }
  } catch (e) {
    print('❌ Token kontrolü hatası: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stayzi',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const OnboardScreen(),
      // routes: {
      //   '/home': (context) => const BottomNavigationWidget(),
      // },
    );
  }
}
