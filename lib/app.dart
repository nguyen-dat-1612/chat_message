import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final username = prefs.getString('username');
  final token = prefs.getString('token');

  runApp(MyApp(initialUsername: username, initialToken: token));
}