import 'package:flutter/material.dart';
import "pages/newBatch.dart";
import "pages/Login.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';
import "package:shared_preferences/shared_preferences.dart";
import "package:jwt_decoder/jwt_decoder.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    if (token == null) {
      return false;
    }

    if (JwtDecoder.isExpired(token)) {
      await prefs.remove("token");
      await prefs.remove("token_expiry");

      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: FutureBuilder<bool>(
        future: isTokenValid(),

        builder: (context, snapshot) {

          // Still checking token
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Token is valid
          if (snapshot.data == true) {
            return Newbatch();
          }

          // No token or expired token
          return  LoginPage();
        },
      ),
    );
  }
}