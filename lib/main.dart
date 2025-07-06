import 'package:chat_message_websocket/data/repositories/auth_repository.dart';
import 'package:chat_message_websocket/services/WebSocketService.dart';
import 'package:chat_message_websocket/presentation/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'logic/blocs/auth/auth_bloc.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => WebSocketService()),
      ],
      child: BlocProvider(
        create: (context) =>
            AuthBloc(authRepository: context.read<AuthRepository>()),
        child: MaterialApp.router(
          theme: ThemeData(
            textTheme: GoogleFonts.robotoTextTheme(),
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade800,
              secondary: Colors.blue.shade600,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            useMaterial3: true,
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 4),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          routerConfig: AppRouter.getRouter(context),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
