import 'package:flutter/material.dart';

class Primarybutton extends StatelessWidget {
 final Future<bool> Function() onSend;

  const Primarybutton({super.key, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: <Widget>[
          const Spacer(),
          ButtonTypesGroup(function: onSend),
          const Spacer(),
        ],
      ),
    );
  }
}

class ButtonTypesGroup extends StatelessWidget {
  final Future<bool> Function() function;

  const ButtonTypesGroup({super.key, required this.function});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
         onPressed: () async {
        final success = await function();
        
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Upload successful" : "Upload failed"),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      
      },
      child: const Text("Send"),
    );
  }
}