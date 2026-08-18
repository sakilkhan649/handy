import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import '../../config/routes/app_pages.dart';
import '../utils/logger.dart';

/// ===================== DEEP LINK SERVICE =====================
/// Handles App Links and Custom URL Schemes (Universal Links / Deep Links)
class DeepLinkService extends GetxService {
  static DeepLinkService get to => Get.find();

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  Uri? _pendingDeepLink;
  bool _isAppReady = false;

  Future<DeepLinkService> init() async {
    _appLinks = AppLinks();
    await _initDeepLinks();
    return this;
  }

  Future<void> _initDeepLinks() async {
    try {
      // 1. Check for initial link when app is launched from terminated state
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        AppLogger.debug('Initial deep link detected: $initialUri');
        _pendingDeepLink = initialUri;
      }
    } catch (e) {
      AppLogger.warning('Error getting initial deep link: $e');
    }

    // 2. Listen to incoming links while app is in background/foreground
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        AppLogger.debug('Incoming stream deep link detected: $uri');
        if (_isAppReady) {
          _handleDeepLink(uri);
        } else {
          _pendingDeepLink = uri;
        }
      },
      onError: (err) {
        AppLogger.warning('Deep link stream error: $err');
      },
    );
  }

  /// Call this when the splash screen has finished navigating to the main UI
  void handlePendingDeepLinkOnAppReady() {
    _isAppReady = true;
    if (_pendingDeepLink != null) {
      final uri = _pendingDeepLink!;
      _pendingDeepLink = null;
      Future.delayed(const Duration(milliseconds: 400), () {
        _handleDeepLink(uri);
      });
    }
  }

  /// Parse and route the deep link to the appropriate screen
  void _handleDeepLink(Uri uri) {
    try {
      AppLogger.debug('Processing deep link: $uri (path: ${uri.path}, host: ${uri.host}, query: ${uri.queryParameters})');

      final host = uri.host.toLowerCase();
      final path = uri.path.toLowerCase();
      final queryParams = uri.queryParameters;

      // Check for Sermon routing
      // Examples:
      // - https://deepskyblue-shark-606490.hostingersite.com/sermon?id=123
      // - https://deepskyblue-shark-606490.hostingersite.com/sermon-details?id=123
      // - https://deepskyblue-shark-606490.hostingersite.com/sermon/123
      // - piwc://sermon?id=123
      // - piwc://sermon/123
      if (host == 'sermon' ||
          path.contains('sermon') ||
          path.contains('sermon-details')) {
        String? sermonId = queryParams['id'] ?? queryParams['sermonId'];

        if (sermonId == null || sermonId.isEmpty) {
          final segments = uri.pathSegments;
          if (segments.isNotEmpty && segments.last != 'sermon' && segments.last != 'sermon-details') {
            sermonId = segments.last;
          }
        }

        if (sermonId != null && sermonId.isNotEmpty) {
          AppLogger.debug('Navigating to Sermon Details for ID: $sermonId');
          Get.toNamed(AppRoutes.SERMON_DETAILS, arguments: {'id': sermonId});
          return;
        }
      }

      // Check for Event routing
      if (host == 'event' || path.contains('event')) {
        String? eventId = queryParams['id'] ?? queryParams['eventId'];
        if (eventId == null || eventId.isEmpty) {
          final segments = uri.pathSegments;
          if (segments.isNotEmpty && segments.last != 'event' && segments.last != 'event-details') {
            eventId = segments.last;
          }
        }

        if (eventId != null && eventId.isNotEmpty) {
          AppLogger.debug('Navigating to Event Details for ID: $eventId');
          Get.toNamed(AppRoutes.EVENT_DETAILS, arguments: {'id': eventId});
          return;
        }
      }

      // Check for Devotionals routing
      if (host == 'devotional' || path.contains('devotional')) {
        String? devId = queryParams['id'];
        if (devId != null && devId.isNotEmpty) {
          Get.toNamed(AppRoutes.DEVOTIONALS_DETAILS, arguments: {'id': devId});
          return;
        }
      }

      // Default fallback: Go to Home / Bottom Nav
      Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR);
    } catch (e) {
      AppLogger.warning('Failed to handle deep link: $e');
    }
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }
}
