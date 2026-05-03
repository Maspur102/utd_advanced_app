import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiClient {
  final Dio dio;
  final Logger logger = Logger();

  ApiClient() : dio = Dio() {
    dio.options.baseUrl = 'https://fakestoreapi.com';
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          logger.i('=> MENGIRIM REQUEST: [${options.method}] ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
  // Ubah .s menjadi .i
  logger.i('<= BERHASIL [${response.statusCode}]: ${response.requestOptions.uri}');
  return handler.next(response);
},
        onError: (DioException e, handler) {
          logger.e('X ERROR [${e.response?.statusCode}]: ${e.requestOptions.uri}\nPESAN: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }
}