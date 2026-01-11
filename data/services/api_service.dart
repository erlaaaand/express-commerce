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

      print('GET Request to: $endpoint');
      print('Headers: $headers');

      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('GET Error: $e');
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

      print('POST Request to: $endpoint');
      print('Headers: $headers');
      print('Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('POST Error: $e');
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

      print('PUT Request to: $endpoint');

      final response = await http.put(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      print('PUT Error: $e');
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

      print('PATCH Request to: $endpoint');

      final response = await http.patch(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      print('PATCH Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // DELETE Request
  Future<Map<String, dynamic>> delete(String endpoint, {bool requiresAuth = false}) async {
    try {
      final headers = requiresAuth
          ? await _getAuthHeaders()
          : ApiConstants.defaultHeaders;

      print('DELETE Request to: $endpoint');

      final response = await http.delete(
        Uri.parse(endpoint),
        headers: headers,
      );

      print('Response status: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      print('DELETE Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get Auth Headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storageService.getToken();
    
    if (token == null || token.isEmpty) {
      print('Warning: No token found for authenticated request');
      throw Exception('No authentication token found');
    }

    print('Using token: ${token.substring(0, 20)}...');

    // Try different authorization header formats
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Most common format
      'x-auth-token': token, // Alternative format
    };
  }

  // Handle Response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    print('Handling response with status: $statusCode');

    // Handle empty response
    if (body.isEmpty) {
      if (statusCode >= 200 && statusCode < 300) {
        return {'success': true, 'data': {}};
      } else {
        throw Exception('Request failed with status $statusCode');
      }
    }

    Map<String, dynamic> jsonResponse;
    try {
      jsonResponse = jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
      print('JSON decode error: $e');
      throw Exception('Invalid response format: $body');
    }

    // Success responses (200-299)
    if (statusCode >= 200 && statusCode < 300) {
      return jsonResponse;
    }

    // Error responses
    String errorMessage;

    switch (statusCode) {
      case 400:
        errorMessage = jsonResponse['message'] ?? 
                      jsonResponse['error'] ?? 
                      'Bad request';
        break;
      case 401:
        errorMessage = jsonResponse['message'] ?? 
                      jsonResponse['error'] ?? 
                      'Email atau password salah';
        // Clear token on 401
        _storageService.removeToken();
        break;
      case 403:
        errorMessage = jsonResponse['message'] ?? 
                      jsonResponse['error'] ?? 
                      'Access forbidden';
        break;
      case 404:
        errorMessage = jsonResponse['message'] ?? 
                      jsonResponse['error'] ?? 
                      'Resource not found';
        break;
      case 422:
        errorMessage = jsonResponse['message'] ?? 
                      jsonResponse['error'] ?? 
                      'Validation error';
        break;
      case 500:
      case 502:
      case 503:
        errorMessage = 'Server error. Please try again later';
        break;
      default:
        errorMessage = jsonResponse['message'] ?? 
                      jsonResponse['error'] ?? 
                      'An error occurred';
    }

    print('API Error: $errorMessage');
    throw Exception(errorMessage);
  }
}