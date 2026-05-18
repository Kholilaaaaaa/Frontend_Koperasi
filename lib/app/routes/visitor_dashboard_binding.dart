import 'package:get/get.dart';
import '../modules/visitor_dashboard/controllers/visitor_dashboard_controller.dart';

class VisitorDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VisitorDashboardController>(
      () => VisitorDashboardController(),
    );
  }
}
