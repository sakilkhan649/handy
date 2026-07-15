import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:handy/core/services/storage_service.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../config/constants/api_constants.dart';
import '../../config/constants/storage_constants.dart';
import '../../config/routes/app_pages.dart';
import '../controllers/internet_controller.dart';
import '../utils/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'auth_service.dart';

/// ===================== API CLIENT =====================
/// Centralized HTTP client built on Dio with:
/// - Automatic token injection via interceptors
/// - Token refresh on 401 with retry
/// - Internet connectivity checks
/// - Structured request/response logging
/// - Multipart upload support with progress

class ApiClient extends GetxService {
  static late Dio _dio;
  static String _bearerToken = '';

  static const String _fallbackMessage =
      'Something went wrong, please try again';
  static const int _timeoutSeconds = 60;
  static const Duration _errorThrottleDuration = Duration(seconds: 3);

  static DateTime? _lastErrorTime;

  /// Expose dio only for edge-case direct usage (avoid if possible).
  Dio get dio => _dio;
  //
  // ─────────────────────────── LIFECYCLE ───────────────────────────

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: _timeoutSeconds),
        receiveTimeout: const Duration(seconds: _timeoutSeconds),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(_buildInterceptor());
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  // ──────────────────────── INTERCEPTOR ────────────────────────

  QueuedInterceptorsWrapper _buildInterceptor() {
    return QueuedInterceptorsWrapper(
      onRequest: _onRequest,
      onResponse: _onResponse,
      onError: _onError,
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    _bearerToken = await StorageService.getString(StorageConstants.bearerToken);

    if (_bearerToken.isNotEmpty &&
        !options.path.contains(ApiConstants.refreshToken)) {
      options.headers['Authorization'] = 'Bearer $_bearerToken';
    }

    try {
      final authService = Get.find<AuthService>();
      final deviceId = await authService.getOrCreateDeviceId();
      if (deviceId.isNotEmpty) {
        options.headers['device-id'] = deviceId;
      }
    } catch (_) {
      final deviceId = await StorageService.getString(StorageConstants.deviceId);
      if (deviceId.isNotEmpty) {
        options.headers['device-id'] = deviceId;
      }
    }

    AppLogger.request(options);
    return handler.next(options);
  }

  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.response(response);
    return handler.next(response);
  }

  Future<void> _onError(DioException e, ErrorInterceptorHandler handler) async {
    final internet = Get.find<InternetController>();

    // 1️⃣ Connection Error
    if (e.type == DioExceptionType.connectionError) {
      final hasInternet = await InternetConnection().hasInternetAccess;

      if (hasInternet) {
        _showThrottledError(
          'Unable to connect to server. Please try again later.',
        );
      } else if (!internet.isShowingNoInternet.value) {
        internet.setOffline();
      }
      return handler.next(e);
    }

    // 1.5️⃣ User doesn't exist (e.g. account deleted from DB but token remains)
    if (e.response?.statusCode == 400) {
      final data = e.response?.data;
      if (data is Map && data['message'] == "User doesn't exist!") {
        _forceLogout();
        return handler.next(e);
      }
    }

    // 2️⃣ Token expired → refresh & retry
    if (e.response?.statusCode == 401 &&
        !e.requestOptions.path.contains(ApiConstants.refreshToken) &&
        !e.requestOptions.path.contains(ApiConstants.logout)) {
      final refreshed = await _refreshToken();

      if (refreshed) {
        final retryResponse = await _retryRequest(e.requestOptions);
        return handler.resolve(retryResponse);
      } else {
        _forceLogout();
        return handler.next(e);
      }
    }

    // 3️⃣ Timeout
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      _showThrottledError('Request timeout. Please try again.');
    }

    AppLogger.error(e);
    return handler.next(e);
  }

  // ──────────────────────── HTTP METHODS ────────────────────────

  /// GET request
  Future<Response> getData(
    String uri, {
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get(
        uri,
        queryParameters: query,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      return _buildErrorResponse(e);
    }
  }

  /// POST request
  Future<Response> postData(
    String uri,
    dynamic body, {
    CancelToken? cancelToken,
    Map<String, dynamic>? extraHeaders,
  }) async {
    try {
      return await _dio.post(
        uri,
        data: body,
        cancelToken: cancelToken,
        options: extraHeaders != null ? Options(headers: extraHeaders) : null,
      );
    } on DioException catch (e) {
      return _buildErrorResponse(e);
    }
  }

  /// PUT request
  Future<Response> putData(
    String uri,
    dynamic body, {
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put(uri, data: body, cancelToken: cancelToken);
    } on DioException catch (e) {
      return _buildErrorResponse(e);
    }
  }

  /// PATCH request
  Future<Response> patchData(
    String uri,
    dynamic body, {
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch(uri, data: body, cancelToken: cancelToken);
    } on DioException catch (e) {
      return _buildErrorResponse(e);
    }
  }

  /// DELETE request
  Future<Response> deleteData(
    String uri, {
    dynamic body,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(uri, data: body, cancelToken: cancelToken);
    } on DioException catch (e) {
      return _buildErrorResponse(e);
    }
  }

  /// Multipart POST with progress tracking
  Future<Response> postMultipartData(
    String uri,
    Map<String, dynamic> body, {
    required List<MultipartBody> multipartBody,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = await _buildFormData(body, multipartBody);
      return await _dio.post(
        uri,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      return _buildErrorResponse(e);
    }
  }

  /// Multipart PATCH with progress tracking
  Future<Response> patchMultipartData(
    String uri,
    Map<String, dynamic> body, {
    required List<MultipartBody> multipartBody,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = await _buildFormData(body, multipartBody);
      return await _dio.patch(
        uri,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      return _buildErrorResponse(e);
    }
  }

  /// File download with progress tracking
  Future<Response> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      return _buildErrorResponse(e);
    }
  }

  // ──────────────────── PRIVATE HELPERS ────────────────────

  /// Build FormData from body map and multipart files
  Future<FormData> _buildFormData(
    Map<String, dynamic> body,
    List<MultipartBody> multipartBody,
  ) async {
    final formData = FormData.fromMap(body);
    for (final part in multipartBody) {
      formData.files.add(
        MapEntry(part.key, await MultipartFile.fromFile(part.file.path)),
      );
    }
    return formData;
  }

  /// Create a fallback Response from a DioException
  Response _buildErrorResponse(DioException e) {
    final String message;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timed out';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Server took too long to respond';
        break;
      case DioExceptionType.badResponse:
        message = 'Bad response: ${e.response?.statusMessage ?? 'Unknown'}';
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      default:
        message = _fallbackMessage;
    }

    return Response(
      requestOptions: e.requestOptions,
      statusCode: e.response?.statusCode ?? 0,
      statusMessage: message,
      data: e.response?.data,
    );
  }

  /// Refresh the access token using stored refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshTokenValue = await StorageService.getString(
        StorageConstants.refreshToken,
      );
      if (refreshTokenValue.isEmpty) return false;

      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {
          "refreshToken": refreshTokenValue,
        },
      );

      if (response.statusCode == 200) {
        final authData = response.data['data'] ?? response.data;
        final newAccessToken = authData['accessToken'] ?? authData['token'];
        final newRefreshToken = authData['refreshToken'];

        if (newAccessToken != null) {
          await StorageService.setString(
            StorageConstants.bearerToken,
            newAccessToken,
          );
        }
        if (newRefreshToken != null) {
          await StorageService.setString(
            StorageConstants.refreshToken,
            newRefreshToken,
          );
        }
        return true;
      }
    } catch (e) {
      AppLogger.debug('Error refreshing token: $e');
    }
    return false;
  }

  /// Retry the original failed request with new token
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final newToken = await StorageService.getString(
      StorageConstants.bearerToken,
    );
    requestOptions.headers['Authorization'] = 'Bearer $newToken';

    return await _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
    );
  }

  /// Force logout when refresh fails
  void _forceLogout() {
    try {
      final authService = Get.find<AuthService>();
      if (!authService.isLoggedIn.value) {
        // If already a guest, simply try to re-init device to recover session
        authService.initDevice();
        return;
      }
      
      // For registered users: wipe tokens, get new guest token, and redirect to login
      authService.clearLocalAuth().then((_) {
        authService.initDevice();
        Get.offAllNamed(AppRoutes.LOGIN);
      });
    } catch (_) {
      // Fallback if AuthService is not found
      StorageService.clearAll();
      Get.offAllNamed(AppRoutes.LOGIN);
    }

    Get.snackbar(
      'Session Expired',
      'Please login again.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Show error snackbar throttled to avoid spamming
  void _showThrottledError(String message) {
    final now = DateTime.now();
    if (_lastErrorTime == null ||
        now.difference(_lastErrorTime!) > _errorThrottleDuration) {
      _lastErrorTime = now;
      Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
    }
  }
}

/// ===================== MULTIPART BODY =====================
/// Wraps a file with its form-data key for multipart uploads.
class MultipartBody {
  final String key;
  final File file;

  const MultipartBody(this.key, this.file);
}

/// last modified: 2026/04/28
/// 06:14 AM
