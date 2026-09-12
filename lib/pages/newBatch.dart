

import 'package:flutter/material.dart';
import '../widgets/primaryButton.dart';
import "../widgets/filePicker.dart";
import "../widgets/xlFilePicker.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class Newbatch  extends StatelessWidget{
  Newbatch ({super.key});
  final _host = dotenv.env["HOST"];

Future<Map<String,dynamic>> myApiCall(BuildContext context) async {
  try {
    final uri = Uri.parse('$_host/upload/test');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
        body: jsonEncode({
        'key1': 'value1',
        'key2': 'value2',
      }),
      );
    
    

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {"succes":true};
    } else {
      return {"succes":false};
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




