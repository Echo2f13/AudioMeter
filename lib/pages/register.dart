import 'package:flutter/material.dart';
import '../main.dart';
import '../services/database.dart';

class RegisterPageMain extends StatelessWidget {
  const RegisterPageMain({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Register',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const RegisterPage(title: 'Register new account'),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.title});
  final String title;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final dbHelper = DatabaseHelper();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String _statusMessage = '';

  DateTime? pickedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selected != null && selected != pickedDate) {
      setState(() {
        pickedDate = selected;
        _dobController.text =
            "${pickedDate!.year}-${pickedDate!.month}-${pickedDate!.day}";
      });
    }
  }

  void _registerUser() async {
    try {
      final db = await dbHelper.database; // Ensure DB is created
      print("✅ Database created successfully!");

      int userId = await dbHelper.insertUser(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
        _dobController.text,
      );

      if (_usernameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _dobController.text.isEmpty) {
        setState(() {
          _statusMessage = "❌ All fields are required!";
        });
        return;
      }

      if (userId > 0) {
        print("✅ User registered with ID: $userId");
        setState(() {
          _statusMessage = "User registered successfully! ID: $userId";
        });
      } else {
        print("❌ Failed to register user.");
        setState(() {
          _statusMessage = "Failed to register user. Try again.";
        });
      }
    } catch (e) {
      print("❌ Error: $e");
      setState(() {
        _statusMessage = "Error: $e";
      });
    }
  }

  void _back() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register'), backgroundColor: Colors.blue),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _dobController,
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
              readOnly: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _registerUser, child: Text('Register')),
            SizedBox(height: 20),
            Text(
              _statusMessage,
              style: TextStyle(
                color:
                    _statusMessage.contains("Error")
                        ? Colors.red
                        : Colors.green,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _back,
        tooltip: 'Back',
        child: const Icon(Icons.arrow_back),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
