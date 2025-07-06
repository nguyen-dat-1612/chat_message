
import 'dart:convert';

import 'package:chat_message_websocket/core/utils/exceptions.dart';
import 'package:chat_message_websocket/data/models/message.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/constants.dart';

class MessageRepository {

  Future<List<Message>> fetchMessages({required String conversationId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      final response = await http.get(
        Uri.parse('$baseUrl/messages/$conversationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return (data['data'] as List).map((e) => Message.fromJson(e)).toList();
      } else {
        throw ServerException(message: 'Failed to load messages');
      }
    } on FormatException {
      throw ServerException(message: 'Invalid response format');
    } catch (e) {
      print('Error fetching messages: $e');
      throw ServerException(message: 'Error fetching messages: $e');
    }
  }

  Future<Message> sendMessage(String conversationId, String text, String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'conversationId': conversationId,
          'content': text,
          'type': type,
        })
      );

      print('Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return Message.fromJson(data['data']);
      } else {
        throw Exception('Failed to send message');
        }
    }
    on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
}