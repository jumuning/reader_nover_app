import 'package:get/get.dart';
import 'logic.dart';

class BookSourceEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BookSourceEditLogic());
  }
}
