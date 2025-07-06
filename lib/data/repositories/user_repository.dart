import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/exceptions.dart';
import '../models/user.dart';

class UserRepository {

  Future<User> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final refreshToken = prefs.getString('refreshToken');

      if (accessToken == null) {
        throw ServerException(message: 'Access token is missing');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'X-Refresh-Token': refreshToken ?? '',
        },
      );

      if (response.statusCode != 200) {
        throw ServerException(message: 'HTTP error ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      print("Lấy thông tin người dùng: $data");
      if (data['success'] == true) {
        return User.fromJson(data['data']);
      } else {
        throw ServerException(message: data['message'] ?? 'Get user profile failed');
      }
    } on FormatException {
      throw ServerException(message: 'Invalid response format');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }
}
