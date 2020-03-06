import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'home_view.dart';


void main() => runApp(new App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(primarySwatch: Colors.blue),
      home: new HomeView(),
    );
  }
}


