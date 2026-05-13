import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../config/api_config.dart';
import 'storage_service.dart';
import 'settings_service.dart';

class ApiService extends GetxService {
  late Dio _dio;
  final StorageService _storage = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    final settings = Get.find<SettingsService>();
    _dio = Dio(BaseOptions(
      baseUrl: settings.getBaseUrl(),
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }

  void updateBaseUrl(String url) {
    _dio = Dio(BaseOptions(
      baseUrl: url,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }

  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  void _onError(DioException e, ErrorInterceptorHandler handler) {
    if (e.response?.statusCode == 401) {
      _storage.clearAll();
      Get.offAllNamed('/login');
    }
    handler.next(e);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
