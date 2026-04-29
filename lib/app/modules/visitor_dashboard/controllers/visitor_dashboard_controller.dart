import 'package:get/get.dart';

class VisitorDashboardController extends GetxController {
  final savingsAmount = 500000.obs;
  final estimatedRate = 12.5;

  double get estimatedYearlySHU => savingsAmount.value * (estimatedRate / 100);

  void setSavingsAmount(int amount) {
    savingsAmount.value = amount;
  }
}
