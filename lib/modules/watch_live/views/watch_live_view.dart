import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:handy/config/themes/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:handy/core/utils/helpers.dart';
import '../controllers/watch_live_controller.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/widgets/shimmers/shimmer_helper.dart';

class WatchLiveView extends GetView<WatchLiveController> {
  const WatchLiveView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.white, size: 20.w),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Watch Live',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'PIWC Stoneyburn',
              style: TextStyle(
                color: AppTheme.warningColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 20.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppTheme.red600,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: AppTheme.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryLighter, // Lighter blue
                AppTheme.primaryDarker, // Darker blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppTheme.primaryColor,
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.youtubeStatus.value == null) {
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: ShimmerHelper(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerContainer(
                        width: double.infinity,
                        height: 200.h,
                        borderRadius: 24.r,
                      ),
                      SizedBox(height: 30.h),
                      ShimmerContainer(width: 100.w, height: 20.h),
                      SizedBox(height: 16.h),
                      ShimmerContainer(
                        width: double.infinity,
                        height: 60.h,
                        borderRadius: 16.r,
                      ),
                      SizedBox(height: 12.h),
                      ShimmerContainer(
                        width: double.infinity,
                        height: 80.h,
                        borderRadius: 16.r,
                      ),
                      SizedBox(height: 20.h),
                      ShimmerContainer(
                        width: double.infinity,
                        height: 150.h,
                        borderRadius: 20.r,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final serviceInfo = controller.serviceInfo.value;
          final channelInfo = controller.youtubeChannel.value;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: controller.scrollController,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Blue Background Header containing the Red Card or Video Player
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryLighter, // Lighter blue
                          AppTheme.primaryDarker, // Darker blue
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 30.h),
                      child: Obx(() {
                        if (controller.currentVideoId.value != null &&
                            controller.ytController != null) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.deepRed.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24.r),
                              child: YoutubePlayer(
                                controller: controller.ytController!,
                              ),
                            ),
                          );
                        }

                        // Placeholder Design based on Live Status
                        final status = controller.youtubeStatus.value;
                        final isLive = status?.isLive ?? false;

                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: 40.h,
                            horizontal: 20.w,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isLive
                                  ? [
                                      AppTheme.red700, // Red
                                      const Color.fromARGB(
                                        255,
                                        172,
                                        10,
                                        32,
                                      ), // Dark Red
                                    ]
                                  : [
                                      const Color.fromARGB(255, 134, 3, 3),
                                      const Color.fromARGB(255, 207, 11, 11),
                                    ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.black.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                isLive ? Icons.videocam : Icons.event,
                                color: AppTheme.white,
                                size: 56.w,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                isLive
                                    ? "We're Live Now!"
                                    : "Join Our Next Service",
                                style: TextStyle(
                                  color: AppTheme.white,
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                "Sunday Worship Service",
                                style: TextStyle(
                                  color: AppTheme.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                "PIWC Stoneyburn",
                                style: TextStyle(
                                  color: AppTheme.white.withValues(alpha: 0.7),
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30.h),
                        Text(
                          'Watch on',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.white
                                : AppTheme.black,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Watch Live Button
                        GestureDetector(
                          onTap: () {
                            final status = controller.youtubeStatus.value;
                            if (status?.isLive == true &&
                                status?.liveStream != null) {
                              String? url;
                              if (status!.liveStream is Map) {
                                url =
                                    status.liveStream['url'] ??
                                    status.liveStream['watchUrl'];
                              }
                              if (url != null) {
                                controller.launchExternalUrl(url);
                              } else {
                                Helpers.showCustomSnackBar(
                                  'There is no live stream running at the moment.',
                                  title: 'Not Live',
                                  type: SnackBarType.warning,
                                );
                              }
                            } else {
                              Helpers.showCustomSnackBar(
                                'There is no live stream running at the moment.',
                                title: 'Not Live',
                                type: SnackBarType.warning,
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.red600,
                                  Color(0xFFFF5722),
                                ], // Red to Orange gradient
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.videocam,
                                  color: AppTheme.white,
                                  size: 24.w,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Watch Live on YouTube Live',
                                  style: TextStyle(
                                    color: AppTheme.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppTheme.white,
                                  size: 20.w,
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (controller.platforms.isNotEmpty) ...[
                          Text(
                            'Other Platforms',
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppTheme.white
                                  : AppTheme.black,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          ...controller.platforms.map((platform) {
                            Color color = AppTheme.standardBlue;
                            if (platform.color != null &&
                                platform.color!.length >= 7) {
                              try {
                                color = Color(
                                  int.parse(
                                        platform.color!.substring(1, 7),
                                        radix: 16,
                                      ) +
                                      0xFF000000,
                                );
                              } catch (e) {
                                // Ignore parsing error
                              }
                            }

                            IconData iconData = Icons.language;
                            if (platform.icon == 'youtube') {
                              iconData = Icons.ondemand_video;
                            } else if (platform.icon == 'facebook') {
                              iconData = Icons.facebook;
                            }

                            final isSelected =
                                platform.isYoutube == true &&
                                platform.watchUrl != null &&
                                controller.currentVideoId.value != null &&
                                controller.currentVideoId.value ==
                                    controller.extractYoutubeId(
                                      platform.watchUrl!,
                                    );

                            return GestureDetector(
                              onTap: () =>
                                  controller.handlePlatformClick(platform),
                              child: Container(
                                margin: EdgeInsets.only(bottom: 12.h),
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardColor,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.red500
                                        : AppTheme.white.withValues(
                                            alpha: 0.05,
                                          ),
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48.w,
                                      height: 48.w,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: Icon(
                                        iconData,
                                        color: AppTheme.white,
                                        size: 24.w,
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            platform.label ?? '',
                                            style: TextStyle(
                                              color: AppTheme.white,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            platform.description ?? '',
                                            style: TextStyle(
                                              color: AppTheme.mutedTextColor,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        width: 24.w,
                                        height: 24.w,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.red500,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: AppTheme.white,
                                          size: 16.w,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],

                        // Service Times
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Service Times',
                                style: TextStyle(
                                  color: AppTheme.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20.h),
                              _buildServiceTimeRow(
                                Icons.calendar_today,
                                serviceInfo?.schedule?.trim().isNotEmpty == true
                                    ? serviceInfo!.schedule!
                                    : 'Not Available',
                              ),
                              SizedBox(height: 16.h),
                              _buildServiceTimeRow(
                                Icons.access_time,
                                serviceInfo?.time?.trim().isNotEmpty == true
                                    ? serviceInfo!.time!
                                    : 'Not Available',
                              ),
                              SizedBox(height: 16.h),
                              _buildServiceTimeRow(
                                Icons.location_on,
                                serviceInfo?.address?.trim().isNotEmpty == true
                                    ? serviceInfo!.address!
                                    : 'Not Available',
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 40.h),

                        // Always show the header
                        Text(
                          'Recent Videos',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.white
                                : AppTheme.black,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        if (controller.recentVideos.isNotEmpty)
                          ...controller.recentVideos.map((video) {
                            final videoId = video.url != null && video.url!.isNotEmpty
                                ? controller.extractYoutubeId(video.url!)
                                : video.id;
                            final isSelected =
                                videoId != null &&
                                controller.currentVideoId.value != null &&
                                controller.currentVideoId.value == videoId;

                            return _buildRecentServiceCard(
                              title: video.title ?? '',
                              speaker: 'PIWC Stoneyburn',
                              time: '${video.duration} · ${video.publishedAt}',
                              thumbnailUrl: video.thumbnailUrl,
                              isSelected: isSelected,
                              onTap: () {
                                controller.handleRecentVideoClick(video);
                              },
                            );
                          })
                        else
                          Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: Text(
                              'No recent services available.',
                              style: TextStyle(
                                color: AppTheme.mutedTextColor,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),

                        SizedBox(height: 24.h),

                        if (channelInfo != null)
                          // Subscribe Card
                          GestureDetector(
                            onTap: () {
                              if (channelInfo.channelUrl != null &&
                                  channelInfo.channelUrl!.isNotEmpty) {
                                controller.launchExternalUrl(
                                  channelInfo.channelUrl!,
                                );
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppTheme.red600, Color(0xFFFF5722)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Row(
                                children: [
                                  if (channelInfo.thumbnailUrl != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20.r),
                                      child: CachedNetworkImage(
                                        imageUrl: channelInfo.thumbnailUrl!,
                                        memCacheWidth: 200,
                                        memCacheHeight: 200,
                                        width: 40.w,
                                        height: 40.w,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                              color: AppTheme.white.withValues(
                                                alpha: 0.2,
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                              Icons.error,
                                              color: AppTheme.white,
                                            ),
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.notifications,
                                      color: AppTheme.white,
                                      size: 28.w,
                                    ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          channelInfo.channelTitle ??
                                              'Never miss a service',
                                          style: TextStyle(
                                            color: AppTheme.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          '${channelInfo.subscriberCount} Subscribers',
                                          style: TextStyle(
                                            color: AppTheme.white.withValues(
                                              alpha: 0.9,
                                            ),
                                            fontSize: 12.sp,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      'Subscribe',
                                      style: TextStyle(
                                        color: AppTheme.white,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildServiceTimeRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentBlue, size: 20.w),
        SizedBox(width: 12.w),
        Text(
          text,
          style: TextStyle(color: AppTheme.white, fontSize: 15.sp),
        ),
      ],
    );
  }

  Widget _buildRecentServiceCard({
    required String title,
    required String speaker,
    required String time,
    String? thumbnailUrl,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? AppTheme.red500
                : AppTheme.white.withValues(alpha: 0.05),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
        children: [
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryLighter,
              borderRadius: BorderRadius.circular(12.r),
              image: thumbnailUrl != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(
                        thumbnailUrl,
                        maxWidth: 400,
                        maxHeight: 400,
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: thumbnailUrl == null
                ? Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: AppTheme.white,
                      size: 28.w,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Text(
                  speaker,
                  style: TextStyle(
                    color: AppTheme.mutedTextColor,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppTheme.mutedTextColor,
                      size: 12.w,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      time,
                      style: TextStyle(
                        color: AppTheme.mutedTextColor,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isSelected)
            Container(
              width: 24.w,
              height: 24.w,
              decoration: const BoxDecoration(
                color: AppTheme.red500,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: AppTheme.white, size: 16.w),
            )
          else
            Icon(
              Icons.chevron_right,
              color: AppTheme.mutedTextColor,
              size: 24.w,
            ),
          ],
        ),
      ),
    );
  }
}
