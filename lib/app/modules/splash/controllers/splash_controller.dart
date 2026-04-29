import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // Memberikan delay sedikit untuk efek splash screen
    await Future.delayed(Duration(seconds: 2));

    bool isLoggedIn = box.read('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // Jika sudah login, langsung ke Dashboard
      Get.offAllNamed(Routes.VISITOR_DASHBOARD);
    } else {
      // Jika belum login, ke halaman Login
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
}
