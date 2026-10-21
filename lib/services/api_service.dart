import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/company.dart';
import '../models/service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _client;
  final String baseUrl;

  static const _timeout = Duration(seconds: 10);
  static const _jsonHeaders = {'Content-Type': 'application/json'};

  Future<List<Company>> getCompanies() async {
    final data = await _send(() => _client.get(_uri('/companies')));
    return (data as List)
        .map((c) => Company.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  Future<Company> createCompany({
    required String name,
    required String registrationNumber,
  }) async {
    final data = await _send(
      () => _client.post(
        _uri('/companies'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'name': name,
          'registrationNumber': registrationNumber,
        }),
      ),
    );
    return Company.fromJson(data as Map<String, dynamic>);
  }

  Future<Service> createService({
    required int companyId,
    required String name,
    required String description,
    required double price,
  }) async {
    final data = await _send(
      () => _client.post(
        _uri('/services'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'companyId': companyId,
          'name': name,
          'description': description,
          'price': price,
        }),
      ),
    );
    return Service.fromJson(data as Map<String, dynamic>);
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    final http.Response res;
    try {
      res = await request().timeout(_timeout);
    } on TimeoutException {
      throw ApiException('The server took too long to respond. Please try again.');
    } on http.ClientException {
      throw ApiException("Can't reach the server. Is the backend running at $baseUrl?");
    }

    final body = _tryDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;

    throw ApiException(_errorMessage(body, res.statusCode), statusCode: res.statusCode);
  }

  dynamic _tryDecode(String text) {
    if (text.isEmpty) return null;
    try {
      return jsonDecode(text);
    } on FormatException {
      return null;
    }
  }

  // Backend hantar { message, errors?: [{ field, message }] }. Kalau backend tukar format, sini kena tukar sekali
  String _errorMessage(dynamic body, int statusCode) {
    if (body is Map<String, dynamic>) {
      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.map((e) => (e as Map<String, dynamic>)['message']).join('\n');
      }
      final message = body['message'];
      if (message is String) return message;
    }
    return 'Something went wrong (HTTP $statusCode).';
  }
}
