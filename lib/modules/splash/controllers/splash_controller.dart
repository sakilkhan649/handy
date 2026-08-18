import 'package:get/get.dart';
import '../../../config/routes/app_pages.dart';

import 'package:handy/core/services/notification_service.dart';
import 'package:handy/core/services/deep_link_service.dart';
import 'package:handy/core/services/auth_service.dart';
import 'package:handy/core/controllers/internet_controller.dart';

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

    // If we started offline, re-push No Internet screen because offAllNamed removed it
    if (Get.isRegistered<InternetController>()) {
      final internet = Get.find<InternetController>();
      if (internet.isShowingNoInternet.value) {
        Get.toNamed(AppRoutes.NO_INTERNET);
      }
    }

    // Check if there's an initial push notification payload that needs to route the user
    if (Get.isRegistered<NotificationService>()) {
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.find<NotificationService>().handlePendingInitialMessage();
      });
    }

    // Check if there's an initial deep link payload that needs to route the user
    if (Get.isRegistered<DeepLinkService>()) {
      Future.delayed(const Duration(milliseconds: 350), () {
        Get.find<DeepLinkService>().handlePendingDeepLinkOnAppReady();
      });
    }
  }
}
