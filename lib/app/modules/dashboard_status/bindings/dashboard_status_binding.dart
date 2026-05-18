import 'package:get/get.dart';

import '../controllers/dashboard_status_controller.dart';

class DashboardStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardStatusController>(
      () => DashboardStatusController(),
    );
  }
}
