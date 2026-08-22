import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:handy/core/services/api_client.dart';
import 'package:handy/core/utils/helpers.dart';
import 'package:handy/config/constants/api_constants.dart';
import 'package:handy/data/models/watch_live_models.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class WatchLiveController extends GetxController {
  final ApiClient apiClient = Get.find<ApiClient>();

  final isLoading = false.obs;
  final youtubeStatus = Rxn<YoutubeStatusModel>();
  final recentVideos = <YoutubeRecentVideoModel>[].obs;
  final serviceInfo = Rxn<ServiceInfoModel>();
  final youtubeChannel = Rxn<YoutubeChannelModel>();
  final platforms = <PlatformModel>[].obs;

  // Video Player state
  final currentVideoId = RxnString();
  YoutubePlayerController? ytController;
  final isPlayingLive = false.obs;

  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  @override
  void onClose() {
    ytController?.close();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchYoutubeStatus(),
        fetchRecentVideos(),
        fetchServiceInfo(),
        fetchYoutubeChannel(),
        fetchPlatforms(),
      ]);
    } catch (e) {
      Helpers.showDebugLog('Error fetching watch live data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchYoutubeStatus() async {
    try {
      final response = await apiClient.getData(ApiConstants.youtubeStatus);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['data'] != null) {
          final status = YoutubeStatusModel.fromJson(response.data['data']);
          youtubeStatus.value = status;
          
          if (status.isLive == true && status.liveStream != null) {
            String? url;
            if (status.liveStream is Map) {
              url = status.liveStream['url'] ?? status.liveStream['watchUrl'];
            }
            if (url != null) {
              playYoutubeVideo(url, isLiveStream: true);
            }
          }
        }
      }
    } catch (e) {
      Helpers.showDebugLog('Error fetching youtube status: $e');
    }
  }

  Future<void> fetchRecentVideos() async {
    try {
      final response = await apiClient.getData(ApiConstants.youtubeRecent);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['data'] != null) {
          final List listData = response.data['data'];
          recentVideos.assignAll(listData.map((e) => YoutubeRecentVideoModel.fromJson(e)).toList());
        }
      }
    } catch (e) {
      Helpers.showDebugLog('Error fetching recent videos: $e');
    }
  }

  Future<void> fetchServiceInfo() async {
    try {
      final response = await apiClient.getData(ApiConstants.serviceInfo);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['data'] != null) {
          serviceInfo.value = ServiceInfoModel.fromJson(response.data['data']);
        }
      }
    } catch (e) {
      Helpers.showDebugLog('Error fetching service info: $e');
    }
  }

  Future<void> fetchYoutubeChannel() async {
    try {
      final response = await apiClient.getData(ApiConstants.youtubeChannel);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['data'] != null) {
          youtubeChannel.value = YoutubeChannelModel.fromJson(response.data['data']);
        }
      }
    } catch (e) {
      Helpers.showDebugLog('Error fetching youtube channel: $e');
    }
  }

  Future<void> fetchPlatforms() async {
    try {
      final response = await apiClient.getData(ApiConstants.watchLivePlatforms);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['data'] != null) {
          final List listData = response.data['data'];
          platforms.assignAll(listData.map((e) => PlatformModel.fromJson(e)).toList());
        }
      }
    } catch (e) {
      Helpers.showDebugLog('Error fetching platforms: $e');
    }
  }

  Future<void> refreshData() async {
    await fetchData();
  }

  String? extractYoutubeId(String url) {
    if (url.isEmpty) return null;
    
    if (url.length == 11 && !url.contains('/') && !url.contains('?')) {
      return url;
    }

    RegExp regExp = RegExp(
        r'^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*',
        caseSensitive: false,
        multiLine: false);
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 2 && match.group(2)!.length == 11) {
      return match.group(2);
    }
    return null;
  }

  void playYoutubeVideo(String url, {bool isLiveStream = false}) {
    final videoId = extractYoutubeId(url);
    if (videoId != null) {
      if (ytController == null) {
        ytController = YoutubePlayerController.fromVideoId(
          videoId: videoId,
          autoPlay: true,
          params: const YoutubePlayerParams(
            mute: false,
            showControls: true,
            showFullscreenButton: true,
          ),
        );
      } else {
        ytController!.loadVideoById(videoId: videoId);
      }
      currentVideoId.value = videoId;
      isPlayingLive.value = isLiveStream;
    } else {
      launchExternalUrl(url);
    }
  }

  void handlePlatformClick(PlatformModel platform) {
    if (platform.watchUrl != null && platform.watchUrl!.isNotEmpty) {
      if (platform.isYoutube == true) {
        playYoutubeVideo(platform.watchUrl!);
      } else {
        launchExternalUrl(platform.watchUrl!);
      }
    }
  }

  void handleRecentVideoClick(YoutubeRecentVideoModel video) {
    final url = video.url;
    final id = video.id;
    
    if (url != null && url.isNotEmpty) {
      launchExternalUrl(url);
    } else if (id != null && id.isNotEmpty) {
      final watchUrl = 'https://www.youtube.com/watch?v=$id';
      launchExternalUrl(watchUrl);
    } else {
      final keys = video.rawJson?.keys.join(', ') ?? 'None';
      Helpers.showCustomSnackBar('Failed: Keys available: $keys', title: 'Error', type: SnackBarType.error);
    }
  }

  void _scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!success) {
        Helpers.showDebugLog('Could not launch $url');
        Helpers.showCustomSnackBar('Could not open link: $url', title: 'Error', type: SnackBarType.error);
      }
    } catch (e) {
      Helpers.showDebugLog('Exception launching $url: $e');
      Helpers.showCustomSnackBar('Error launching link on this device', title: 'Error', type: SnackBarType.error);
    }
  }
}
