import 'package:get/get.dart';
import '../controllers/daftar_anggota_controller.dart';

class DaftarAnggotaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DaftarAnggotaController>(
      () => DaftarAnggotaController(),
    );
  }
}
