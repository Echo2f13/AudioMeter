import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p; // Use an alias to avoid conflicts
import 'home.dart';
import '../main.dart';

class DatabaseHelper {
  Future<Database> get database async {
    final path = p.join(await getDatabasesPath(), 'database.db');
    return openDatabase(path);
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }
}

class LoginPage extends StatefulWidget {
  final String title;
  const LoginPage({super.key, required this.title});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final dbHelper = DatabaseHelper();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  void _loginUser() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    print("Email: $email, Password: $password");

    Map<String, dynamic>? user = await dbHelper.getUser(email, password);

    if (user != null) {
      print("Login successful: User ID = ${user['id']}");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePageMain(userId: user['id']),
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = "Invalid email or password";
      });
    }
  }

  void _goBack() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _loginUser, child: const Text('Login')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goBack,
        tooltip: 'Back',
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
