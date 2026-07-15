import 'package:get/get.dart';
import '../../../config/routes/app_pages.dart';

import 'package:handy/core/services/notification_service.dart';
import 'package:handy/core/services/auth_service.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find();

  final isSlowConnection = false.obs;
  bool _isNavigated = false;

  @override
  void onInit() {
    super.onInit();
    _startSlowConnectionTimer();
    navigate();
  }

  void _startSlowConnectionTimer() {
    Future.delayed(const Duration(seconds: 30), () {
      if (!_isNavigated) {
        isSlowConnection.value = true;
      }
    });
  }

  Future<void> navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!_authService.isLoggedIn.value) {
      await _authService.initDevice();
    }

    _isNavigated = true;
    Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR);

    // Check if there's an initial push notification payload that needs to route the user
    if (Get.isRegistered<NotificationService>()) {
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.find<NotificationService>().handlePendingInitialMessage();
      });
    }
  }
}
