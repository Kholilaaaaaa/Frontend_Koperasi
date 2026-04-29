import 'package:get/get.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/bindings/home_binding.dart';

import '../modules/profile/views/profile_view.dart';
import '../modules/profile/bindings/profile_binding.dart';

import '../modules/splash/views/splash_view.dart';
import '../modules/splash/bindings/splash_binding.dart';

import '../modules/login/views/login_view.dart';
import '../modules/login/bindings/login_binding.dart';

import '../modules/signup/views/signup_view.dart';
import '../modules/signup/bindings/signup_binding.dart';
import '../modules/visitor_dashboard/views/visitor_dashboard_view.dart';
import '../modules/visitor_dashboard/bindings/visitor_dashboard_binding.dart';
import '../modules/daftar_anggota/views/daftar_anggota_view.dart';
import '../modules/daftar_anggota/bindings/daftar_anggota_binding.dart';

import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: Routes.VISITOR_DASHBOARD,
      page: () => VisitorDashboardView(),
      binding: VisitorDashboardBinding(),
    ),
    GetPage(
      name: Routes.DAFTAR_ANGGOTA,
      page: () => DaftarAnggotaView(),
      binding: DaftarAnggotaBinding(),
    ),
  ];
}