import 'package:get/get.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialization moved to main() for proper async ordering.
  }
}
