import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:handy/config/themes/app_theme.dart';
import '../controllers/give_controller.dart';
import '../../../config/routes/app_pages.dart';
import 'package:handy/core/widgets/custom_gradient_header.dart';
import 'package:handy/core/utils/helpers.dart';
import '../../../core/widgets/shimmers/shimmer_helper.dart';

class GiveView extends GetView<GiveController> {
  const GiveView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.fetchFunds,
        color: AppTheme.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context),
              StreamBuilder<bool>(
                stream: controller.showHistory.stream,
                initialData: controller.showHistory.value,
                builder: (context, snapshot) {
                  return (snapshot.data == true)
                      ? _buildHistoryList(context)
                      : _buildGiveForm(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return CustomGradientHeader(
      title: 'Give',
      trailingWidget: Obx(() {
        return GestureDetector(
          onTap: () {
            controller.toggleHistory();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppTheme.warningColor,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                Icon(
                  controller.showHistory.value
                      ? Icons.arrow_back_rounded
                      : Icons.history_rounded,
                  color: AppTheme.black,
                  size: 16.w,
                ),
                SizedBox(width: 6.w),
                Text(
                  controller.showHistory.value ? 'Back' : 'History',
                  style: TextStyle(
                    color: AppTheme.black,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      bottomWidget: Obx(() {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppTheme.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your giving this year',
                style: TextStyle(
                  color: AppTheme.white.withValues(alpha: 0.8),
                  fontSize: 14.sp,
                ),
              ),
              Text(
                '£${controller.totalThisYear.value.toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppTheme.warningColor,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildGiveForm(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Select Fund'),
          _buildFundGrid(context),
          SizedBox(height: 24.h),
          _buildSectionTitle(context, 'Amount (£)'),
          _buildAmountSelection(context),
          SizedBox(height: 32.h),
          _buildGiveNowButton(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.white
              : AppTheme.black,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFundGrid(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.funds.isEmpty) {
        return GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.containerColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppTheme.secondaryColor, width: 1),
              ),
              child: ShimmerHelper(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShimmerContainer(
                      width: 24.w,
                      height: 24.w,
                      borderRadius: 12.r,
                    ),
                    SizedBox(height: 12.h),
                    ShimmerContainer(width: 80.w, height: 16.h),
                    SizedBox(height: 4.h),
                    ShimmerContainer(width: 100.w, height: 12.h),
                  ],
                ),
              ),
            );
          },
        );
      }

      if (controller.funds.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Text(
              'No funds available at the moment',
              style: TextStyle(
                color: AppTheme.white.withValues(alpha: 0.5),
                fontSize: 14.sp,
              ),
            ),
          ),
        );
      }

      return GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.funds.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (context, index) {
          final fund = controller.funds[index];
          return Obx(() {
            final isSelected = controller.selectedFundId.value == fund.id;
            return GestureDetector(
              onTap: () => controller.selectedFundId.value = fund.id,
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isSelected ? fund.color : AppTheme.containerColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : AppTheme.secondaryColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      fund.icon,
                      color: isSelected ? AppTheme.white : fund.color,
                      size: 24.w,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      fund.title,
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      fund.desc,
                      style: TextStyle(
                        color: AppTheme.white.withValues(alpha: 0.5),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      );
    });
  }

  Widget _buildAmountSelection(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: controller.presetAmounts.map((amount) {
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: Obx(() {
                  final isSelected = controller.selectedAmount.value == amount;
                  return GestureDetector(
                    onTap: () {
                      controller.selectAmount(amount);
                    },
                    child: Container(
                      width: 60.w,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.containerColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.secondaryColor,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '£$amount',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppTheme.containerColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.secondaryColor),
          ),
          child: Row(
            children: [
              Text(
                '£',
                style: TextStyle(
                  color: AppTheme.brightBlue,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextField(
                  controller: controller.amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  cursorColor: AppTheme.white,
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    hintStyle: TextStyle(
                      color: AppTheme.white.withValues(alpha: 0.5),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: false,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGiveNowButton() {
    return GestureDetector(
      onTap: () async {
        if (controller.selectedAmount.value <= 0) {
          Helpers.showError('Please select or enter an amount to donate');
          return;
        }

        final fundId = controller.selectedFundId.value;
        if (fundId.isEmpty) {
          Helpers.showError('Please select a fund');
          return;
        }

        final fund =
            controller.funds.firstWhereOrNull((f) => f.id == fundId)?.title ??
            'Fund';
        final amount = controller.selectedAmount.value;

        Get.toNamed(
          AppRoutes.DONATE,
          arguments: {'fundId': fundId, 'fund': fund, 'amount': amount},
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Donate',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right, color: AppTheme.white, size: 20.w),
          ],
        ),
      ),
    );
  }

  // Giving History List
  Widget _buildHistoryList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(20.w),
          child: Text(
            'Giving History',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.white
                  : AppTheme.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Obx(() {
          if (controller.isHistoryLoading.value) {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
              itemCount: 3,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppTheme.containerColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppTheme.secondaryColor),
                  ),
                  child: ShimmerHelper(
                    child: Row(
                      children: [
                        ShimmerContainer(
                          width: 48.w,
                          height: 48.w,
                          borderRadius: 12.r,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerContainer(width: 100.w, height: 16.h),
                              SizedBox(height: 4.h),
                              ShimmerContainer(width: 80.w, height: 12.h),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ShimmerContainer(width: 60.w, height: 16.h),
                            SizedBox(height: 4.h),
                            ShimmerContainer(width: 50.w, height: 12.h),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          if (controller.historyData.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Text(
                  'No giving history found.',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.white.withValues(alpha: 0.5)
                        : AppTheme.black.withValues(alpha: 0.5),
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
            itemCount: controller.historyData.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final item = controller.historyData[index];
              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppTheme.containerColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppTheme.secondaryColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: AppTheme.primaryColor,
                        size: 24.w,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            item.date,
                            style: TextStyle(
                              color: AppTheme.white.withValues(alpha: 0.5),
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.amount,
                          style: TextStyle(
                            color: AppTheme.warningColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: const BoxDecoration(
                                color: AppTheme.successColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              item.status,
                              style: TextStyle(
                                color: AppTheme.successColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
