import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Browser',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF6C39FF),
        accentColor: Color(0xFF6C39FF),
        fontFamily: 'Futura',
        textTheme: TextTheme(
          headline1: TextStyle(
            fontSize: 72.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C39FF),
          ),
          headline2: TextStyle(
            fontSize: 48.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C39FF),
          ),
          headline3: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C39FF),
          ),
          headline4: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C39FF),
          ),
          headline5: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C39FF),
          ),
          headline6: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C39FF),
          ),
          subtitle1: TextStyle(
            fontSize: 16.0,
            color: Color(0xFF6C39FF),
          ),
          subtitle2: TextStyle(
            fontSize: 14.0,
            color: Color(0xFF6C39FF),
          ),
          bodyText1: TextStyle(
            fontSize: 16.0,
            color: Color(0xFF6C39FF),
          ),
          bodyText2: TextStyle(
            fontSize: 14.0,
            color: Color(0xFF6C39FF),
          ),
          caption: TextStyle(
            fontSize: 12.0,
            color: Color(0xFF6C39FF),
          ),
          button: TextStyle(
            fontSize: 14.0,
            color: Color(0xFF6C39FF),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text('Nexus Browser'),
        ),
        body: FutureBuilder(
          future: fetchStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Center(child: Text('Status: ${snapshot.data}'));
            }
          },
        ),
      ),
    );
  }

  Future<String> fetchStatus() async {
    final response = await http.get(Uri.parse('http://localhost:4000/api/status'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['status'];
    } else {
      throw Exception('Failed to load status');
    }
  }
}