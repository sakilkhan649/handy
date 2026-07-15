import 'package:get/get.dart';
import '../../config/routes/app_pages.dart';

/// ===================== INTERNET CONTROLLER =====================
/// Reactive controller that tracks internet connectivity state.
/// Used by ConnectivityService, ApiClient, and SafeNetworkImage.
class InternetController extends GetxController {
  final hasInternet = true.obs;
  final isShowingNoInternet = false.obs;

  void setOffline() {
    hasInternet.value = false;
    if (!isShowingNoInternet.value) {
      isShowingNoInternet.value = true;
      Get.toNamed(AppRoutes.NO_INTERNET);
    }
  }

  void setOnline() {
    hasInternet.value = true;
    if (isShowingNoInternet.value) {
      isShowingNoInternet.value = false;
      if (Get.currentRoute == AppRoutes.NO_INTERNET) {
        Get.back();
      }
    }
  }

  /// Toggle connectivity (useful for testing)
  void toggle() {
    hasInternet.value ? setOffline() : setOnline();
  }
}
