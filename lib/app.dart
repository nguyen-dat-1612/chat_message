import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logic/blocs/bloc_observer.dart';
import 'main.dart';

void main() async {
  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp());
}