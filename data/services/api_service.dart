import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storageService = StorageService();

  // GET Request
  Future<Map<String, dynamic>> get(String endpoint, {bool requiresAuth = false}) async {
    try {
      final headers = requiresAuth
          ? await _getAuthHeaders()
          : ApiConstants.defaultHeaders;

      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST Request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = requiresAuth
          ? await _getAuthHeaders()
          : ApiConstants.defaultHeaders;

      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PUT Request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = requiresAuth
          ? await _getAuthHeaders()
          : ApiConstants.defaultHeaders;

      final response = await http.put(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PATCH Request
  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = requiresAuth
          ? await _getAuthHeaders()
          : ApiConstants.defaultHeaders;

      final response = await http.patch(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // DELETE Request
  Future<Map<String, dynamic>> delete(String endpoint, {bool requiresAuth = false}) async {
    try {
      final headers = requiresAuth
          ? await _getAuthHeaders()
          : ApiConstants.defaultHeaders;

      final response = await http.delete(
        Uri.parse(endpoint),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get Auth Headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storageService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }
    return ApiConstants.authHeaders(token);
  }

  // Handle Response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    Map<String, dynamic> jsonResponse;
    try {
      jsonResponse = jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Invalid response format');
    }

    if (statusCode >= 200 && statusCode < 300) {
      return jsonResponse;
    } else if (statusCode == 401) {
      throw Exception('Unauthorized: ${jsonResponse['message'] ?? 'Invalid credentials'}');
    } else if (statusCode == 404) {
      throw Exception('Not found: ${jsonResponse['message'] ?? 'Resource not found'}');
    } else if (statusCode == 400) {
      throw Exception(jsonResponse['message'] ?? 'Bad request');
    } else if (statusCode >= 500) {
      throw Exception('Server error: Please try again later');
    } else {
      throw Exception(jsonResponse['message'] ?? 'An error occurred');
    }
  }
}