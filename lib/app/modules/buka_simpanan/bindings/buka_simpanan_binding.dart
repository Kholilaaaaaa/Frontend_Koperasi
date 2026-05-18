import 'package:get/get.dart';
import '../controllers/buka_simpanan_controller.dart';

class BukaSimpananBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BukaSimpananController>(
      () => BukaSimpananController(),
    );
  }
}
