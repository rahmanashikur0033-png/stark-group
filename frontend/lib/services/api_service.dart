import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  // Change this if the backend runs on another host or port.
  static const String baseUrl = 'http://localhost:8080/api/vehicles';
  static const String authUrl = 'http://localhost:8080/api/auth';
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  /// Returns the signed-in username, or throws ApiException (401 for wrong credentials).
  Future<String> login(String username, String password) async {
    final res = await _send(() => http.post(
          Uri.parse('$authUrl/login'),
          headers: _headers,
          body: jsonEncode({'username': username, 'password': password}),
        ));
    final body =
        jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return body['username'] as String;
  }

  Future<List<Vehicle>> getVehicles() async {
    final res = await _send(() => http.get(Uri.parse(baseUrl)));
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
    return data
        .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    final res = await _send(() => http.post(
          Uri.parse(baseUrl),
          headers: _headers,
          body: jsonEncode(vehicle.toJson()),
        ));
    return Vehicle.fromJson(
        jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
  }

  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    final res = await _send(() => http.put(
          Uri.parse('$baseUrl/${vehicle.id}'),
          headers: _headers,
          body: jsonEncode(vehicle.toJson()),
        ));
    return Vehicle.fromJson(
        jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
  }

  Future<void> deleteVehicle(int id) async {
    await _send(() => http.delete(Uri.parse('$baseUrl/$id')));
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    http.Response res;
    try {
      res = await call().timeout(const Duration(seconds: 10));
    } catch (_) {
      throw ApiException(
          'Cannot reach the server. Check that the backend is running on port 8080.');
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return res;
    throw ApiException(_messageFrom(res), res.statusCode);
  }

  String _messageFrom(http.Response res) {
    try {
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      if (body is Map && body['message'] is String) {
        return body['message'] as String;
      }
    } catch (_) {}
    return 'Request failed (${res.statusCode}).';
  }
}
