import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/network/translations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart'; // Generated Firebase config
import 'app/network/api_client.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  
  // Background handler HARUS didaftarkan sebelum Firebase.initializeApp
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register device token
  String? fcmToken;
  try {
    fcmToken = await FirebaseMessaging.instance.getToken();
  } catch (e) {
    print("Warning: Failed to get FCM token: $e");
  }

  if (fcmToken != null) {
    try {
      await authorizedPost('/api/member/fcm-token', {'token': fcmToken});
    } catch (e) {
      // ignore errors
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    bool isDark = box.read('isDarkMode') ?? false;
    String langCode = box.read('langCode') ?? 'id';
    String countryCode = box.read('countryCode') ?? 'ID';

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Koperasi Simpanku',
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
      translations: AppTranslations(),
      locale: Locale(langCode, countryCode),
      fallbackLocale: const Locale('id', 'ID'),
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF6B0D0D),
        scaffoldBackgroundColor: const Color(0xFFFFF9F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B0D0D),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6B0D0D),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B0D0D),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
