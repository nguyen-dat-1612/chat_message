import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/exceptions.dart';
import '../../core/utils/logger.dart';
import '../models/login_response.dart';

class AuthRepository {

  Future<LoginResponse> login({required String username, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      print(response.body);

      final data = jsonDecode(response.body);

      print(data);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          final loginRes = LoginResponse.fromJson(data['data']);
          await prefs.setString('accessToken', loginRes.accessToken);
          await prefs.setString('refreshToken', loginRes.refreshToken);
          await prefs.setString('username', username);
          return loginRes;
        } else {
          throw ServerException(message: data['message'] ?? 'Login failed');
        }
      } else {
        throw ServerException(
          message: data['message'] ?? 'HTTP status ${response.statusCode}',
        );
      }
    } on FormatException {
      throw ServerException(message: 'Invalid response format');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  Future<LoginResponse> register({
    required String username,
    required String email,
    required String password,
    required String displayName,
  })  async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'displayName': displayName,
        })
      );
      final data = jsonDecode(response.body);

      logger.d("Data register response: $data");
      if (response.statusCode == 201) {
        if (data['success'] == true) {
          final loginRes = LoginResponse.fromJson(data['data']);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', loginRes.accessToken);
          await prefs.setString('refreshToken', loginRes.refreshToken);
          await prefs.setString('username', username);
          return loginRes;
        } else {
          throw ServerException(message: data['message'] ?? 'Register failed');
        }
      } else {
        throw ServerException(
          message: data['message'] ?? 'HTTP status ${response.statusCode}',
        );
      }
    }  on FormatException {
      throw ServerException(message: 'Invalid response format');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  Future<void> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken');
      final response = await http.post(
          Uri.parse('$baseUrl/refresh-token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refreshToken})
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', data['accessToken']);
        } else {
          throw ServerException(message: data['message'] ?? 'Login failed');
        }
      } else {
        throw ServerException(
          message: data['message'] ?? 'HTTP status ${response.statusCode}',
        );
      }
    } on FormatException {
      throw ServerException(message: 'Invalid response format');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (data['success'] == true) {
          await prefs.remove('accessToken');
          await prefs.remove('refreshToken');
          await prefs.remove('username');
        } else {
          throw ServerException(message: data['message'] ?? 'Logout failed');
        }
      } else {
        throw ServerException(
          message: data['message'] ?? 'HTTP status ${response.statusCode}',
        );
      }
    }
    on FormatException {
      throw ServerException(message: 'Invalid response format');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }
}