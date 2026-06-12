import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Base URL for Flask backend. Update as needed.
const String baseUrl = 'http://192.168.18.119:5000';

class ApiClient {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<http.Response> authorizedGet(String endpoint) async {
    final token = await _secureStorage.read(key: 'jwt_token');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.get(uri, headers: headers);
  }

  Future<http.Response> authorizedPost(String endpoint, Map<String, dynamic> body) async {
    final token = await _secureStorage.read(key: 'jwt_token');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.post(uri, headers: headers, body: jsonEncode(body));
  }
}

// Singleton for easy access
final ApiClient _apiClient = ApiClient();

Future<http.Response> authorizedGet(String endpoint) => _apiClient.authorizedGet(endpoint);
Future<http.Response> authorizedPost(String endpoint, Map<String, dynamic> body) => _apiClient.authorizedPost(endpoint, body);
