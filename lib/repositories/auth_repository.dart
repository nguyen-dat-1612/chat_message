import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../core/exceptions.dart';
import '../models/auth_model.dart';

class AuthRepository {
  final http.Client client;

  AuthRepository({required this.client});

  Future<AuthModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      print('Response body: ${response.body}');
      print('Data body: ${data}');

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
          await prefs.setString('username', data['username']);
          return AuthModel.fromJson(data);
        } else {
          throw ServerException(message: data['message'] ?? 'Login failed');
        }
      } else {
        throw ServerException(
          message: data['message'] ?? 'HTTP status ${response.statusCode}',
        );
      }
    } on FormatException {
      throw const ServerException(message: 'Invalid response format');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }
}