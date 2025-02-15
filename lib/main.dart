import 'package:flutter/material.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'admin/admin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Meter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'Audio Meter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _loginButton() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage(title: 'Login')),
    );
  }

  void _registerButton() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RegisterPageMain()),
    );
  }

  void _crack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AdminPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _loginButton,
              style: ElevatedButton.styleFrom(
                elevation: 12.0,
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: _registerButton,
              style: ElevatedButton.styleFrom(
                elevation: 12.0,
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 255, 163, 110),
              ),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crack,
        tooltip: 'Back',
        child: const Icon(Icons.admin_panel_settings),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
