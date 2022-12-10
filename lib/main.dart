import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Column(children: [
        Container(
          child: Card(
            child: Text('Card'),
          ),
        ),
        Card(
          child: Text('list of card'),
        )
      ]),
    );
  }
}
