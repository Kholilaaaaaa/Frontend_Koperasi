import 'package:get/get.dart';

class HomeController extends GetxController {
  var count = 0.obs;

  void increment() => count++;
  void decrement() => count--;
  void reset() => count.value = 0;
}