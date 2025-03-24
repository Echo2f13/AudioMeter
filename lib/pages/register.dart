import 'package:flutter/material.dart';
import '../main.dart';
import '../services/database.dart';

class RegisterPageMain extends StatelessWidget {
  const RegisterPageMain({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
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

    if (selected != null) {
      setState(() {
        pickedDate = selected;
        _dobController.text =
            "${pickedDate!.year}-${pickedDate!.month}-${pickedDate!.day}";
      });
    }
  }

  void _registerUser() async {
    if (_usernameController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _genderController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _dobController.text.isEmpty) {
      setState(() {
        _statusMessage = "❌ All fields are required!";
      });
      return;
    }

    try {
      final db = await dbHelper.database;
      int userId = await dbHelper.insertUser(
        _usernameController.text,
        _nameController.text,
        _genderController.text,
        _emailController.text,
        _passwordController.text,
        _dobController.text,
      );

      if (userId > 0) {
        setState(() {
          _statusMessage = "✅ User registered successfully! ID: $userId";
        });
      } else {
        setState(() {
          _statusMessage = "❌ Failed to register user. Try again.";
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "❌ Error: $e";
      });
    }
  }

  void _back() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
  }

  @override
  void initState() {
    super.initState();
    _genderController.text = "Male"; // Default gender
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),

            // Gender Selection
            const SizedBox(height: 16),
            const Text(
              "Gender",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Radio<String>(
                  value: "Male",
                  groupValue: _genderController.text,
                  onChanged: (value) {
                    setState(() {
                      _genderController.text = value!;
                    });
                  },
                ),
                const Text("Male"),
                Radio<String>(
                  value: "Female",
                  groupValue: _genderController.text,
                  onChanged: (value) {
                    setState(() {
                      _genderController.text = value!;
                    });
                  },
                ),
                const Text("Female"),
                Radio<String>(
                  value: "Other",
                  groupValue: _genderController.text,
                  onChanged: (value) {
                    setState(() {
                      _genderController.text = value!;
                    });
                  },
                ),
                const Text("Other"),
              ],
            ),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _dobController,
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
              readOnly: true,
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerUser,
              child: const Text('Register'),
            ),
            const SizedBox(height: 20),

            Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _statusMessage.contains("❌") ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _back,
        tooltip: 'Back',
        backgroundColor: Colors.blue,
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
