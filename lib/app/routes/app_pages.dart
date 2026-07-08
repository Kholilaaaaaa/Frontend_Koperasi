import 'package:get/get.dart';
import '../modules/buka_simpanan/bindings/buka_simpanan_binding.dart';
import '../modules/buka_simpanan/views/buka_simpanan_view.dart';
import '../modules/notifikasi/bindings/notifikasi_binding.dart';
import '../modules/notifikasi/views/notifikasi_view.dart';
import '../modules/penarikan/bindings/penarikan_binding.dart';
import '../modules/penarikan/views/penarikan_view.dart';

import '../modules/daftar_anggota/bindings/daftar_anggota_binding.dart';
import '../modules/daftar_anggota/views/daftar_anggota_view.dart';
import '../modules/dashboard_status/bindings/dashboard_status_binding.dart';
import '../modules/dashboard_status/views/dashboard_status_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/member_dashboard/bindings/member_dashboard_binding.dart';
import '../modules/member_dashboard/views/member_dashboard_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/signup/bindings/signup_binding.dart';
import '../modules/signup/views/signup_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/visitor_dashboard/views/visitor_dashboard_view.dart';
import '../modules/verification/bindings/verification_binding.dart';
import '../modules/verification/views/verification_view.dart';
import '../modules/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/forgot_password/views/forgot_password_view.dart';
import '../modules/change_password/bindings/change_password_binding.dart';
import '../modules/change_password/views/change_password_view.dart';
import '../modules/resign/bindings/resign_binding.dart';
import '../modules/resign/views/resign_view.dart';
import 'app_routes.dart';
import 'visitor_dashboard_binding.dart';

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
    GetPage(
      name: Routes.DASHBOARD_STATUS,
      page: () => const DashboardStatusView(),
      binding: DashboardStatusBinding(),
    ),
    GetPage(
      name: Routes.MEMBER_DASHBOARD,
      page: () => const MemberDashboardView(),
      binding: MemberDashboardBinding(),
    ),
    GetPage(
      name: Routes.BUKA_SIMPANAN,
      page: () => const BukaSimpananView(),
      binding: BukaSimpananBinding(),
    ),
    GetPage(
      name: Routes.PENARIKAN,
      page: () => const PenarikanView(),
      binding: PenarikanBinding(),
    ),
    GetPage(
      name: Routes.NOTIFIKASI,
      page: () => const NotifikasiView(),
      binding: NotifikasiBinding(),
    ),
    GetPage(
      name: Routes.VERIFICATION,
      page: () => const VerificationView(),
      binding: VerificationBinding(),
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: Routes.CHANGE_PASSWORD,
      page: () => const ChangePasswordView(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: Routes.RESIGN,
      page: () => const ResignMembershipView(),
      binding: ResignBinding(),
    ),
  ];
}
