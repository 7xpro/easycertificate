

import 'package:flutter/material.dart';
import '../widgets/primaryButton.dart';
import "../widgets/filePicker.dart";
import "../widgets/xlFilePicker.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "../widgets/canva.dart";
import "package:shared_preferences/shared_preferences.dart";



class Newbatch  extends StatelessWidget{
  Newbatch ({super.key});
  final _host = dotenv.env["HOST"];

Future<Map<String,dynamic>> myApiCall(BuildContext context) async {
  try {
    final prefs=await SharedPreferences.getInstance();
    final token=prefs.getString("token");

    final uri = Uri.parse('$_host/upload/test');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
        body: jsonEncode({
        'body': 'testing',
        'subject': 'batch 1 ',
      }),
      );
    
    

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {"success":true};
    } else {
      return {"success":false};
    }
  } catch (e) {
    print('Error: $e');
    return {"success":false};
  }
}

  @override
  Widget build(BuildContext context) {

   
    return Scaffold(
      appBar: AppBar(title:const Text("New Batch")),
      body: Column(
        children: [
            Text("upload certificate here. "),
            
            PdfUploadWidget(),

            SizedBox(height: 10),

           XlUploadWidget(),


           SizedBox(height: 10),
           FloatingActionButton(onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CertificateCanvas(templateImageUrl: "https://rukminim2.flixcart.com/image/958/958/xif0q/tablet/8/h/h/-original-imahpxffgkrxxqy3.jpeg?q=90",)),
            );
          }, child: Text("Place Fields")),
           
           SizedBox(height: 10),

            Primarybutton(
              onSend: () async {
            final response = await myApiCall(context);
              if (response['success']==true){
                return true;
              }else{
                return false;
              }
              },
            
            ),
            

            

            
        ],
      ),
    );
  }
}




