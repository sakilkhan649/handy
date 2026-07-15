import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handy/config/constants/image_paths.dart';
import 'package:handy/config/themes/app_theme.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            CircleAvatar(
              radius: 50.r,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.backgroundColor
                  : AppTheme.white,
              child: ClipOval(
                child: Image.asset(
                  ImagePaths.appLogo,
                  fit: BoxFit.cover,
                  width: 200.h,
                  height: 200.h,
                ),
              ),
            ),
            Obx(() {
              if (controller.isSlowConnection.value) {
                return Column(
                  children: [
                    SizedBox(height: 30.h),
                    CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Internet connection is slow...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.white.withValues(alpha: 0.7)
                            : AppTheme.black.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
