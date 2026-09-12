import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CertificateApp extends StatelessWidget {
  const CertificateApp({super.key});

  Future<bool> _isUserLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EasyCertificate',
      theme: ThemeData(
        useMaterial3: true,

        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: FutureBuilder<bool>(
        future: _isUserLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return Text("hell world");
        }
      ),
    );
  }
}
