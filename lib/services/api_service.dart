import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  // Generic GET request
  static Future<dynamic> get(String endpoint, {bool requiresAuth = false}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      Map<String, String> headers = ApiConfig.headers;

      if (requiresAuth) {
        final token = await StorageService.getToken();
        if (token != null) {
          headers = ApiConfig.headersWithToken(token);
        }
      }

      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  // Generic POST request
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      Map<String, String> headers = ApiConfig.headers;

      if (requiresAuth) {
        final token = await StorageService.getToken();
        if (token != null) {
          headers = ApiConfig.headersWithToken(token);
        }
      }

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  // Generic PUT request
  static Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      Map<String, String> headers = ApiConfig.headers;

      if (requiresAuth) {
        final token = await StorageService.getToken();
        if (token != null) {
          headers = ApiConfig.headersWithToken(token);
        }
      }

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  // Handle API response
  static dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    // Try to parse response body
    dynamic responseBody;
    try {
      responseBody = jsonDecode(response.body);
    } catch (e) {
      responseBody = {'message': response.body};
    }

    // Handle different status codes
    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    } else if (statusCode == 400) {
      final message = responseBody['error'] ?? responseBody['message'] ?? 'Bad request';
      throw ApiException(message, statusCode);
    } else if (statusCode == 401) {
      final message = responseBody['error'] ?? responseBody['message'] ?? 'Unauthorized';
      throw ApiException(message, statusCode);
    } else if (statusCode == 404) {
      final message = responseBody['error'] ?? responseBody['message'] ?? 'Not found';
      throw ApiException(message, statusCode);
    } else if (statusCode == 500) {
      final message = responseBody['error'] ?? responseBody['message'] ?? 'Server error';
      throw ApiException(message, statusCode);
    } else {
      final message = responseBody['error'] ?? responseBody['message'] ?? 'Unknown error';
      throw ApiException(message, statusCode);
    }
  }
}
