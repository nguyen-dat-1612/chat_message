import 'dart:convert';
import 'package:chat_message_websocket/core/utils/exceptions.dart';
import 'package:chat_message_websocket/data/models/conversation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/constants.dart';

class ConversationRepository {

  Future<List<Conversation>> fetchConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      final response = await http.get(
        Uri.parse('$baseUrl/conversations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> list = data['data'];
        return list.map((e) => Conversation.fromJson(e)).toList();
      } else {
        throw ServerException(
            message: data['message'] ?? 'Failed to load conversations');
      }
    } on FormatException {
      throw ServerException(message: 'Invalid response format');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  Future<Conversation> createConversation({required String username}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final response = await http.post(
          Uri.parse('$baseUrl/conversations'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken'
          },
          body: jsonEncode({'receiver': username})
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data.map((conversation) => Conversation.fromJson(conversation)).toList();
      } else {
        throw ServerException(message: 'Failed to create conversation');
      }
    } on FormatException {
      throw ServerException(message: 'Invalid response format');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }
}