import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import '../../config/constants/api_constants.dart';
import 'api_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// ===================== NOTIFICATION SERVICE =====================
/// Service for Push Notifications (FCM) and Local Notifications (Downloads).
class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  int _notificationId = 0;

  // Android Notification Channels
  final AndroidNotificationChannel _fcmChannel =
      const AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

  final AndroidNotificationChannel _downloadChannel =
      const AndroidNotificationChannel(
        'download_channel',
        'Downloads',
        description: 'Notifications for downloaded files',
        importance: Importance.max,
      );

  RemoteMessage? _initialMessage;
  bool _hasHandledInitialMessage = false;

  Future<NotificationService> init() async {
    await _requestPermission();
    await _initLocalNotifications();
    await _setupFCMListeners();
    // Enable native iOS foreground notification banners
    try {
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      AppLogger.debug("Error setting foreground presentation options: $e");
    }
    _handleFCMToken(); // Run in background so ApiClient can initialize
    return this;
  }

  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }

    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.debug('User granted notification permission');
    } else {
      AppLogger.debug(
        'User declined or has not accepted notification permissions',
      );
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create channels on Android
    if (Platform.isAndroid) {
      final androidImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidImplementation?.createNotificationChannel(_fcmChannel);
      await androidImplementation?.createNotificationChannel(_downloadChannel);
    }
  }

  Future<void> _onNotificationTap(NotificationResponse response) async {
    if (response.payload == null || response.payload!.isEmpty) return;

    // Check if payload is JSON (from FCM routing)
    try {
      final data = jsonDecode(response.payload!);
      if (data is Map) {
        _handleRouting(Map<String, dynamic>.from(data));
        return;
      }
    } catch (_) {
      // If not JSON, it might be a file path from a download notification
      try {
        await OpenFile.open(response.payload);
      } catch (e) {
        AppLogger.debug('Error opening file from notification: $e');
      }
    }
  }

  Future<void> _setupFCMListeners() async {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.debug('Got a message whilst in the foreground!');
      if (message.notification != null) {
        _showFCMNotification(message);
      }
    });

    // Background/Terminated tapped messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleRoutingFromMessage(message);
    });

    // Terminated state initial message
    _initialMessage = await _fcm.getInitialMessage();
    // We do NOT route immediately. We wait for SplashController to finish and call handlePendingInitialMessage()
  }

  void handlePendingInitialMessage() {
    if (_initialMessage != null && !_hasHandledInitialMessage) {
      _hasHandledInitialMessage = true;
      _handleRoutingFromMessage(_initialMessage!);
    }
  }

  /// Helper method to download an image from a URL and save it to the device's temporary directory
  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getTemporaryDirectory();
    final String filePath = '${directory.path}/$fileName';

    final dio = Dio();
    await dio.download(url, filePath);

    return filePath;
  }

  Future<void> _showFCMNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      // 1. Determine if there's an image URL in the payload
      String? imageUrl;

      // Check the data payload for custom thumbnail/image fields
      if (message.data.containsKey('thumbnail_url') &&
          message.data['thumbnail_url']?.isNotEmpty == true) {
        imageUrl = message.data['thumbnail_url'];
      } else if (message.data.containsKey('image') &&
          message.data['image']?.isNotEmpty == true) {
        imageUrl = message.data['image'];
      } else {
        // Fallback to standard FCM notification image URL
        imageUrl =
            notification.android?.imageUrl ?? notification.apple?.imageUrl;
      }

      BigPictureStyleInformation? bigPictureStyleInformation;
      String? downloadedPath;

      // 2. Download the image if available
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          downloadedPath = await _downloadAndSaveFile(
            imageUrl,
            'notification_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );

          // 3. Configure BigPictureStyleInformation for Android
          bigPictureStyleInformation = BigPictureStyleInformation(
            FilePathAndroidBitmap(downloadedPath),
            largeIcon: FilePathAndroidBitmap(downloadedPath),
            hideExpandedLargeIcon: true,
            contentTitle: notification.title,
            summaryText: notification.body,
          );
        } catch (e) {
          AppLogger.warning('Failed to download notification image: $e');
        }
      }

      // 4. Show the notification
      _plugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _fcmChannel.id,
            _fcmChannel.name,
            channelDescription: _fcmChannel.description,
            icon: '@mipmap/launcher_icon',
            // Default large icon if no image is downloaded
            largeIcon: downloadedPath == null
                ? const DrawableResourceAndroidBitmap('@mipmap/launcher_icon')
                : FilePathAndroidBitmap(downloadedPath),
            importance: Importance.max,
            priority: Priority.high,
            styleInformation: bigPictureStyleInformation,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            presentBanner: true,
            presentList: true,
            // Attach image for iOS if downloaded
            attachments: downloadedPath != null
                ? [DarwinNotificationAttachment(downloadedPath)]
                : null,
          ),
        ),
        // Encode data map as payload for routing on tap
        payload: jsonEncode(message.data),
      );
    }
  }

  void _handleRoutingFromMessage(RemoteMessage message) {
    _handleRouting(message.data);
  }

  void _handleRouting(Map<String, dynamic> data) {
    AppLogger.debug("Handling notification routing with payload: $data");

    if (data.containsKey('type')) {
      final type = data['type'];
      if (type == 'sermon') {
        final id = data['id'];
        if (id != null) {
          Get.toNamed('/sermon-details', arguments: {'id': id});
        }
      } else if (type == 'service_reminder' || type == 'custom') {
        Get.offAllNamed('/bottom-nav-bar');
      }
    } else if (data.containsKey('route')) {
      final route = data['route'] as String?;
      if (route != null && route.isNotEmpty) {
        AppLogger.debug("Navigating to route from notification: $route");
        Get.toNamed(route);
      }
    }
  }

  Future<String?> getFcmTokenSafely() async {
    try {
      if (Platform.isIOS) {
        String? apnsToken;
        for (int i = 0; i < 10; i++) {
          apnsToken = await _fcm.getAPNSToken();
          if (apnsToken != null) {
            break;
          }
          await Future.delayed(const Duration(milliseconds: 500));
        }

        if (apnsToken == null) {
          AppLogger.warning("APNS token is not set. Skipping FCM token retrieval on iOS.");
          return null;
        }
      }
      return await _fcm.getToken();
    } catch (e) {
      AppLogger.warning("Failed to get FCM token safely: $e");
      return null;
    }
  }

  Future<void> _handleFCMToken() async {
    try {
      String? token = await getFcmTokenSafely();
      if (token != null) {
        AppLogger.debug("FCM Token: $token");
        await _sendTokenToBackend(token);
      }

      _fcm.onTokenRefresh.listen((newToken) {
        AppLogger.debug("FCM Token Refreshed: $newToken");
        _sendTokenToBackend(newToken);
      });
    } catch (e) {
      AppLogger.debug("Error in _handleFCMToken: $e");
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final platform = Platform.isIOS ? 'ios' : 'android';

      // Wait until ApiClient is registered by InitialBinding
      while (!Get.isRegistered<ApiClient>()) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final apiClient = Get.find<ApiClient>();

      final response = await apiClient.postData(ApiConstants.deviceToken, {
        "token": token,
        "platform": platform,
        "user": null, // Guest users included
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.debug('Token successfully saved to backend!');
        await prefs.setString('fcm_token', token);
      }
    } catch (e) {
      AppLogger.debug("Failed to send token to backend: $e");
    }
  }

  // ===================== LEGACY METHODS FOR DOWNLOADS =====================

  Future<void> showDownloadNotification({
    required String filePath,
    required String fileName,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _downloadChannel.id,
      _downloadChannel.name,
      channelDescription: _downloadChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    await _plugin.show(
      _notificationId++,
      'Download Complete',
      '$fileName has been downloaded.',
      NotificationDetails(android: androidDetails),
      payload: filePath,
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = 'general_channel',
    String channelName = 'General',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    await _plugin.show(
      _notificationId++,
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();
}
