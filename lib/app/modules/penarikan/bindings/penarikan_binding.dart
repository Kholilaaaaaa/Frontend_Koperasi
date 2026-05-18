import 'package:get/get.dart';
import '../controllers/penarikan_controller.dart';

class PenarikanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PenarikanController>(
      () => PenarikanController(),
    );
  }
}
