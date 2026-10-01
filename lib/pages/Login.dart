import 'dart:convert';

import 'package:flutter/material.dart';
import 'signUP.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';
import "newBatch.dart";
import 'package:jwt_decoder/jwt_decoder.dart';



class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  var _isLoading=false;
  final _host=dotenv.env["HOST"];
  static const token="token";
  static const userid="userid";




  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  Future<void>_handleLogin() async{

    _isLoading=true;


    try{
      final prefs = await SharedPreferences.getInstance();
      final response= await http.post(
        Uri.parse("$_host/auth/login"),
        headers:{'Content-type':"application/json"},
        body:jsonEncode({
          "email":_usernameController.text,
          "password":_passwordController.text
        }),
      ).timeout(const Duration(seconds: 5));

      final data = jsonDecode(response.body);
      if (!mounted) return;

          if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('login Successfully')),
      );

      final expiryDate = JwtDecoder.getExpirationDate(data["token"]); 
      await prefs.setString(token, data["token"]);
      await prefs.setInt(userid,data["userid"]);
        // Token expires in 30 minutes
   
      await prefs.setString("token_expiry", expiryDate.toIso8601String(),);

        Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Newbatch()),
                ); // back to login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? "login failed ${_usernameController.text} ,${_passwordController.text}")),
      );
    }
  } catch (e) {
    _showError('Error: $e');
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
  }



  void _showError(String msg) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Welcome',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: Color(0xFF1C1C1C),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Sign In to continue',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                  color: Color(0xFF1C1C1C),
                ),
              ),
              SizedBox(height: 26),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: 49,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3B62FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                   
                  ),
                ),
              ),
              SizedBox(height: 26),
              Center(
                  child: Text(
                    'Forgot Password?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF87879D),
                    ),
                  ),
              ),
              SizedBox(height: 10),
            Center(
            child: GestureDetector(
              onTap: () {
                _usernameController.clear();
                _passwordController.clear();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpPage()),
                );
              },
              child: const Text(
                "Don't have an account? Sign Up",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF87879D),
                ),
              ),
            ),
          )
            ],
          ),
        ),
      ),
    );
  }
}