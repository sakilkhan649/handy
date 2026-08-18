import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:handy/core/services/storage_service.dart';
import 'package:handy/core/services/notification_service.dart';
import 'package:handy/core/services/deep_link_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");

  // If this is a data-only payload, we need to show the notification manually
  if (message.notification == null && message.data.isNotEmpty) {
    final title =
        message.data['title'] ?? message.data['subject'] ?? 'New Notification';
    final body = message.data['body'] ?? message.data['message'] ?? '';

    String? imageUrl;
    if (message.data.containsKey('thumbnail_url') &&
        message.data['thumbnail_url']?.isNotEmpty == true) {
      imageUrl = message.data['thumbnail_url'];
    } else if (message.data.containsKey('image') &&
        message.data['image']?.isNotEmpty == true) {
      imageUrl = message.data['image'];
    }

    BigPictureStyleInformation? bigPictureStyleInformation;
    String? downloadedPath;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final dio = Dio();
        final Directory directory = await getTemporaryDirectory();
        downloadedPath =
            '${directory.path}/bg_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await dio.download(imageUrl, downloadedPath);

        bigPictureStyleInformation = BigPictureStyleInformation(
          FilePathAndroidBitmap(downloadedPath),
          largeIcon: FilePathAndroidBitmap(downloadedPath),
          hideExpandedLargeIcon: true,
          contentTitle: title,
          summaryText: body,
        );
      } catch (e) {
        debugPrint('Failed to download background notification image: $e');
      }
    }

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await plugin.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          largeIcon: downloadedPath == null
              ? const DrawableResourceAndroidBitmap('@mipmap/launcher_icon')
              : FilePathAndroidBitmap(downloadedPath),
          styleInformation: bigPictureStyleInformation,
        ),
        iOS: DarwinNotificationDetails(
          attachments: downloadedPath != null
              ? [DarwinNotificationAttachment(downloadedPath)]
              : null,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable screen rotation (Portrait only)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize services here
  await StorageService.init();
  await Get.putAsync<NotificationService>(
    () async => await NotificationService().init(),
  );
  await Get.putAsync<DeepLinkService>(
    () async => await DeepLinkService().init(),
  );

  runApp(const MyApp());
}
