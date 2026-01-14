import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storageService = StorageService();

  Future<Map<String, dynamic>> get(String endpoint, {bool requiresAuth = false}) async {
    try {
      final headers = requiresAuth
          ? await _getAuthHeaders()
          : ApiConstants.defaultHeaders;

      debugPrint('GET Request to: $endpoint');
      debugPrint('Headers: $headers');

      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('GET Error: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = requiresAuth
          ? await _getAuthHeaders()
          : ApiConstants.defaultHeaders;

      debugPrint('POST Request to: $endpoint');
      debugPrint('Headers: $headers');
      debugPrint('Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('POST Error: $e');
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

      debugPrint('PUT Request to: $endpoint');

      final response = await http.put(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint('Response status: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('PUT Error: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = requiresAuth
          ? await _getAuthHeaders()
          : ApiConstants.defaultHeaders;

      debugPrint('PATCH Request to: $endpoint');

      final response = await http.patch(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint('Response status: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('PATCH Error: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint, {bool requiresAuth = false}) async {
    try {
      final headers = requiresAuth
          ? await _getAuthHeaders()
          : ApiConstants.defaultHeaders;

      debugPrint('DELETE Request to: $endpoint');

      final response = await http.delete(
        Uri.parse(endpoint),
        headers: headers,
      );

      debugPrint('Response status: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('DELETE Error: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storageService.getToken();
    
    if (token == null || token.isEmpty) {
      debugPrint('Warning: No token found for authenticated request');
      throw Exception('No authentication token found');
    }

    debugPrint('Using token: ${token.substring(0, 20)}...');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'x-auth-token': token,
    };
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    debugPrint('Handling response with status: $statusCode');

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
      debugPrint('JSON decode error: $e');
      throw Exception('Invalid response format: $body');
    }

    if (statusCode >= 200 && statusCode < 300) {
      return jsonResponse;
    }

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

    debugPrint('API Error: $errorMessage');
    throw Exception(errorMessage);
  }
}