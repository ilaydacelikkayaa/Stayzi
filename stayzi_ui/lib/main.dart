import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/myHomes/add_home_screen.dart';
import 'package:stayzi_ui/screens/navigation/bottom_nav.dart';
import 'package:stayzi_ui/screens/onboard/onboard_screen.dart';
import 'package:stayzi_ui/services/api_service.dart';
import 'package:stayzi_ui/services/storage_service.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isLoading = true;
  String _initialRoute = '/onboard';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final storageService = StorageService();
      final isLoggedIn = await storageService.isLoggedIn();

      if (isLoggedIn) {
        final token = await storageService.getAccessToken();
        if (token != null) {
          // Token'ı API service'e set et
          ApiService().setAuthToken(token);
          print('🔐 Uygulama başlatıldı, token set edildi: $token');
          _initialRoute = '/home';
        } else {
          print('⚠️ Token bulunamadı, giriş sayfasına yönlendiriliyor');
          _initialRoute = '/onboard';
        }
      } else {
        print('ℹ️ Kullanıcı giriş yapmamış, giriş sayfasına yönlendiriliyor');
        _initialRoute = '/onboard';
      }
    } catch (e) {
      print('❌ Uygulama başlatılırken hata: $e');
      _initialRoute = '/onboard';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF1E88E5),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Stayzi Yükleniyor...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      initialRoute: _initialRoute,
      routes: {
        '/add_home': (context) => const AddHomeScreen(),
        '/onboard': (context) => const OnboardScreen(),
        '/home': (context) => const BottomNavigationWidget(),
      },
    );
  }
}
