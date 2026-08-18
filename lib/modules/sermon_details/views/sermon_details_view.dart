import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/sermon_details_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import 'package:handy/config/themes/app_theme.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../data/models/sermon_response_model.dart';
import '../../../core/widgets/custom_gradient_appbar.dart';
import '../../../core/widgets/shimmers/details_shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/constants/api_constants.dart';
import 'package:share_plus/share_plus.dart';

class SermondetailsView extends GetView<SermondetailsController> {
  const SermondetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Get the sermon from arguments or controller
      final sermon = controller.sermonDetail.value;

      if (controller.isLoading.value && sermon == null) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: const CustomGradientAppBar(
            title: 'Sermon',
            showBackButton: true,
          ),
          body: const DetailsShimmer(),
        );
      }

      if (sermon == null) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: const CustomGradientAppBar(
            title: 'Sermon',
            showBackButton: true,
          ),
          body: RefreshIndicator(
            onRefresh: controller.refreshData,
            color: AppTheme.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: 600.h,
                alignment: Alignment.center,
                child: const Text(
                  "Sermon not found",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        );
      }

      return Scaffold(
        appBar: CustomGradientAppBar(
          title: 'Sermon',
          subtitle: 'PIWC Stoneyburn',
          actions: [
            if (Get.parameters['hideSaveIcon'] != 'true')
              Obx(() {
                final profileController = Get.find<ProfileController>();
                final sermonId = sermon.sId ?? sermon.id;
                final isFav = sermonId != null
                    ? profileController.isSermonFavorite(sermonId)
                    : false;

                return IconButton(
                  icon: Icon(
                    isFav ? Icons.bookmark : Icons.bookmark_border,
                    color: AppTheme.white,
                    size: 24.w,
                  ),
                  onPressed: () {
                    if (sermonId != null) {
                      profileController.toggleFavoriteSermon(sermonId);
                    }
                  },
                );
              }),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: controller.refreshData,
          color: AppTheme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVideoPlayer(context, sermon),
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sermon.title ?? 'No Title',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.white
                                : AppTheme.black,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          sermon.speaker ?? 'Unknown Speaker',
                          style: TextStyle(
                            color: AppTheme.accentBlue,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        _buildAboutSection(context, sermon),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAboutSection(BuildContext context, SermonModel sermon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sermon.keyScripture != null && sermon.keyScripture!.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              sermon.keyScripture!,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.white.withValues(alpha: 0.9)
                    : AppTheme.black.withValues(alpha: 0.9),
                fontSize: 16.sp,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
        Text(
          'About This Message',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.white
                : AppTheme.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          sermon.description ?? "No description available.",
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.white.withValues(alpha: 0.6)
                : AppTheme.black.withValues(alpha: 0.6),
            fontSize: 14.sp,
            height: 1.6,
          ),
        ),
        SizedBox(height: 20.h),
        // Tags
        if (sermon.tags != null && sermon.tags!.isNotEmpty) ...[
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: sermon.tags!.map((tag) => _buildTag('#$tag')).toList(),
          ),
        ] else ...[
          Row(
            children: [
              _buildTag('#hope'),
              SizedBox(width: 12.w),
              _buildTag('#faith'),
            ],
          ),
        ],
        SizedBox(height: 24.h),
        // Share Button
        Builder(
          builder: (btnContext) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: () {
                  final sermonTitle = sermon.title ?? 'Inspiring Sermon';
                  final speaker = sermon.speaker ?? 'PIWC Stoneyburn';
                  final playStoreLink =
                      'https://play.google.com/store/apps/details?id=com.piwc.stoneyburn';

                  final box = btnContext.findRenderObject() as RenderBox?;

                  // ignore: deprecated_member_use
                  Share.share(
                    '🎧 Listen to "$sermonTitle" by $speaker on the PIWC Stoneyburn app!\n\n'
                    '📲 Download / Open on Google Play:\n$playStoreLink',
                    subject: sermonTitle,
                    sharePositionOrigin: box != null
                        ? box.localToGlobal(Offset.zero) & box.size
                        : null,
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppTheme.primaryLighter, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.share, color: AppTheme.brightBlue, size: 20.w),
                      SizedBox(width: 12.w),
                      Text(
                        'Share This Sermon',
                        style: TextStyle(
                          color: AppTheme.brightBlue,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppTheme.containerColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.white.withValues(alpha: 0.7),
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context, SermonModel sermon) {
    return GetBuilder<SermondetailsController>(
      builder: (ctrl) {
        if (ctrl.youtubePlayerController != null) {
          return Container(
            width: double.infinity,
            color: AppTheme.black,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(
                controller: ctrl.youtubePlayerController!,
                aspectRatio: 16 / 9,
              ),
            ),
          );
        } else {
          final String hostUrl = ApiConstants.baseUrl.replaceAll('/api/v1', '');
          final thumbnailUrl = sermon.thumbnailUrl;
          final String imgUrl =
              (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
              ? (thumbnailUrl.startsWith('http')
                    ? thumbnailUrl
                    : '$hostUrl$thumbnailUrl')
              : 'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?q=80&w=200&auto=format&fit=crop';

          return Container(
            width: double.infinity,
            color: AppTheme.black,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: imgUrl,
                memCacheWidth: 800,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: AppTheme.primaryColor),
                errorWidget: (context, url, error) => CachedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?q=80&w=200&auto=format&fit=crop',
                  memCacheWidth: 800,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
