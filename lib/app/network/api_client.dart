import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Base URL for Flask backend. Update as needed.
// Gunakan URL ngrok jika test via HP agar tidak diblokir firewall/AP isolation laptop
// const String baseUrl = 'https://hemicranic-justus-jauntily.ngrok-free.dev';

const String baseUrl =
    'https://apollo-unabducted-linus.ngrok-free.dev'; // URL Local IP (jika hp & laptop satu wifi)

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

  Future<http.Response> authorizedPost(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await _secureStorage.read(key: 'jwt_token');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.post(uri, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> authorizedDelete(String endpoint) async {
    final token = await _secureStorage.read(key: 'jwt_token');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.delete(uri, headers: headers);
  }

  Future<http.Response> authorizedPut(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await _secureStorage.read(key: 'jwt_token');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.put(uri, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> authorizedMultipartPost({
    required String endpoint,
    required Map<String, String> fields,
    String? fileKey,
    String? filePath,
  }) async {
    final token = await _secureStorage.read(key: 'jwt_token');
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields.addAll(fields);

    if (fileKey != null && filePath != null && filePath.isNotEmpty) {
      if (!filePath.startsWith('http://') && !filePath.startsWith('https://')) {
        request.files.add(await http.MultipartFile.fromPath(fileKey, filePath));
      }
    }

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}

// Singleton for easy access
final ApiClient _apiClient = ApiClient();

Future<http.Response> authorizedGet(String endpoint) =>
    _apiClient.authorizedGet(endpoint);
Future<http.Response> authorizedPost(
  String endpoint,
  Map<String, dynamic> body,
) => _apiClient.authorizedPost(endpoint, body);
Future<http.Response> authorizedPut(
  String endpoint,
  Map<String, dynamic> body,
) => _apiClient.authorizedPut(endpoint, body);
Future<http.Response> authorizedDelete(String endpoint) =>
    _apiClient.authorizedDelete(endpoint);
Future<http.Response> authorizedMultipartPost({
  required String endpoint,
  required Map<String, String> fields,
  String? fileKey,
  String? filePath,
}) => _apiClient.authorizedMultipartPost(
  endpoint: endpoint,
  fields: fields,
  fileKey: fileKey,
  filePath: filePath,
);
