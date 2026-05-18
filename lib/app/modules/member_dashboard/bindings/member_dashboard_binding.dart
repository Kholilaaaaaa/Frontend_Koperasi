import 'package:get/get.dart';

import '../controllers/member_dashboard_controller.dart';

class MemberDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MemberDashboardController>(
      () => MemberDashboardController(),
    );
  }
}
