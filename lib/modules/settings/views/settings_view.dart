import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/change_password_controller.dart';
import 'package:handy/config/themes/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../controllers/settings_controller.dart';
import 'package:handy/core/widgets/custom_gradient_header.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomGradientHeader(
            title: 'Settings',
            subtitle: 'PIWC Stoneyburn',
            showBackButton: true,
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primaryColor,
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.white
                          : AppTheme.black,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildNotificationsCard(),
                  SizedBox(height: 32.h),
                  Text(
                    'Appearance',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.white
                          : AppTheme.black,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildAppearanceCard(context),
                  SizedBox(height: 32.h),
                  Text(
                    'Account',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.white
                          : AppTheme.black,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildAccountCard(context),
                  SizedBox(height: 32.h),
                  Text(
                    'About',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.white
                          : AppTheme.black,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildAboutCard(),
                  SizedBox(height: 40.h),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Made with ',
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppTheme.white.withValues(alpha: 0.5)
                                  : AppTheme.black.withValues(alpha: 0.5),
                              fontSize: 13.sp,
                            ),
                          ),
                          TextSpan(
                            text: '❤️',
                            style: TextStyle(fontSize: 13.sp),
                          ),
                          TextSpan(
                            text: ' for the PIWC Stoneyburn family',
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppTheme.white.withValues(alpha: 0.5)
                                  : AppTheme.black.withValues(alpha: 0.5),
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.containerColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.secondaryColor),
      ),
      child: Column(
        children: [
          _buildSwitchRow(
            'Sunday Service Reminder',
            'Reminder every Saturday at 6:00 PM before Sunday service',
            controller.sundayServiceReminder,
          ),
          Divider(
            color: AppTheme.secondaryColor,
            height: 1,
            indent: 20.w,
            endIndent: 20.w,
          ),
          _buildSwitchRow(
            'Event Reminders',
            "1-hour reminder before events you've saved",
            controller.eventReminders,
          ),
          Divider(
            color: AppTheme.secondaryColor,
            height: 1,
            indent: 20.w,
            endIndent: 20.w,
          ),
          _buildSwitchRow(
            'New Sermons',
            'Notified when a new sermon is uploaded',
            controller.newSermons,
          ),
          Divider(
            color: AppTheme.secondaryColor,
            height: 1,
            indent: 20.w,
            endIndent: 20.w,
          ),
          _buildSwitchRow(
            'Prayer Updates',
            'Notified when someone prays for your request',
            controller.prayerUpdates,
          ),
          Divider(
            color: AppTheme.secondaryColor,
            height: 1,
            indent: 20.w,
            endIndent: 20.w,
          ),
          _buildSwitchRow(
            'New Devotionals',
            'Notified when a new devotional is posted',
            controller.devotionalUpdates,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.containerColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.secondaryColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dark Mode',
                        style: TextStyle(
                          color: AppTheme.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Toggle application theme',
                        style: TextStyle(
                          color: AppTheme.white.withValues(alpha: 0.5),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (val) {
                    Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                  },
                  activeThumbColor: AppTheme.white,
                  activeTrackColor: AppTheme.accentBlue,
                  inactiveThumbColor: AppTheme.white,
                  inactiveTrackColor: AppTheme.white.withValues(alpha: 0.1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.containerColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.secondaryColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            _showChangePasswordBottomSheet(context);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 16.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Change Password',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.white.withValues(alpha: 0.5),
                  size: 24.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordBottomSheet(BuildContext context) {
    final pwdCtrl = Get.put(ChangePasswordController());

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          top: 24.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
        ),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Form(
            key: pwdCtrl.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppTheme.white,
                        size: 20.w,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Change Password',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20.w), // Balance for centering
                  ],
                ),
                SizedBox(height: 32.h),
                Text(
                  'Change Password',
                  style: TextStyle(
                    color: AppTheme.white.withValues(alpha: 0.7),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 24.h),
                Obx(
                  () => CustomTextField(
                    controller: pwdCtrl.oldPasswordController,
                    label: 'Old Password',
                    hintText: 'Enter Old Password',
                    obscureText: !pwdCtrl.isOldPasswordVisible.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        pwdCtrl.isOldPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppTheme.white.withValues(alpha: 0.5),
                      ),
                      onPressed: pwdCtrl.toggleOldPasswordVisibility,
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Old password is required'
                        : null,
                  ),
                ),
                SizedBox(height: 20.h),
                Obx(
                  () => CustomTextField(
                    controller: pwdCtrl.newPasswordController,
                    label: 'New Password',
                    hintText: 'Enter New Password',
                    obscureText: !pwdCtrl.isNewPasswordVisible.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        pwdCtrl.isNewPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppTheme.white.withValues(alpha: 0.5),
                      ),
                      onPressed: pwdCtrl.toggleNewPasswordVisibility,
                    ),
                    validator: pwdCtrl.validateNewPassword,
                  ),
                ),
                SizedBox(height: 20.h),
                Obx(
                  () => CustomTextField(
                    controller: pwdCtrl.confirmPasswordController,
                    label: 'Confirm Password',
                    hintText: 'Enter Confirm Password',
                    obscureText: !pwdCtrl.isConfirmPasswordVisible.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        pwdCtrl.isConfirmPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppTheme.white.withValues(alpha: 0.5),
                      ),
                      onPressed: pwdCtrl.toggleConfirmPasswordVisibility,
                    ),
                    validator: pwdCtrl.validateConfirmPassword,
                  ),
                ),
                SizedBox(height: 32.h),
                // Save Button
                Obx(
                  () => CustomButton(
                    text: 'Save',
                    backgroundColor: AppTheme.orange500,
                    isLoading: pwdCtrl.isLoading.value,
                    onPressed: () {
                      pwdCtrl.changePassword();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSwitchRow(
    String title,
    String subtitle,
    RxBool value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.white.withValues(alpha: 0.5),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Switch(
              value: value.value,
              onChanged: (val) => value.value = val,
              activeThumbColor: AppTheme.white,
              activeTrackColor: AppTheme.accentBlue, // Royal Blue
              inactiveThumbColor: AppTheme.white,
              inactiveTrackColor: AppTheme.white.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.containerColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.secondaryColor),
      ),
      child: Column(
        children: [
          _buildInfoRow('App Version', '1.0.0'),
          Divider(
            color: AppTheme.secondaryColor,
            height: 1,
            indent: 20.w,
            endIndent: 20.w,
          ),
          _buildInfoRow('Church', 'PIWC Stoneyburn', isValueBold: true),
          Divider(
            color: AppTheme.secondaryColor,
            height: 1,
            indent: 20.w,
            endIndent: 20.w,
          ),
          _buildInfoRow(
            'Website',
            'gracecommunity.church',
            valueColor: AppTheme.accentBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isValueBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.white.withValues(alpha: 0.5),
              fontSize: 15.sp,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppTheme.white,
              fontSize: 15.sp,
              fontWeight: isValueBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
