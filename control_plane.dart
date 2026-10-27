
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ControlPlane {
  final String baseUrl;
  const ControlPlane(this.baseUrl);

  Future<Map<String, dynamic>> health() async {
    final r = await http.get(Uri.parse('$baseUrl/health'));
    if (r.statusCode != 200) throw Exception('Backend health check failed');
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getConfig(String deviceId) async {
    final r = await http.get(
      Uri.parse('$baseUrl/api/v1/config/$deviceId'),
      headers: {'Accept': 'application/json'},
    );
    if (r.statusCode != 200) throw Exception('Config request failed');
    return jsonDecode(r.body) as Map<String, dynamic>;
  }
}
