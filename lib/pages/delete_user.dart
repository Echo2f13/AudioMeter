import 'package:flutter/material.dart';
import '../services/database.dart';
import '../main.dart';

class DeleteUserPage extends StatefulWidget {
  const DeleteUserPage({super.key});

  @override
  State<DeleteUserPage> createState() => _DeleteUserPageState();
}

class _DeleteUserPageState extends State<DeleteUserPage> {
  final dbHelper = DatabaseHelper();
  final TextEditingController _emailController = TextEditingController();
  String _statusMessage = "";

  void _deleteUser() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _statusMessage = "❌ Email is required!";
      });
      return;
    }

    try {
      final db = await dbHelper.database;
      int deletedRows = await db.delete(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (deletedRows > 0) {
        print("✅ User deleted successfully!");
        setState(() {
          _statusMessage = "✅ User deleted successfully!";
        });
      } else {
        print("❌ No user found with this email.");
        setState(() {
          _statusMessage = "❌ No user found with this email.";
        });
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    } catch (e) {
      print("❌ Error: $e");
      setState(() {
        _statusMessage = "❌ Error: $e";
      });
    }
  }

  void _back() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Delete User"),
        backgroundColor: Colors.blue,
        actions: [IconButton(onPressed: _back, icon: Icon(Icons.arrow_back))],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Enter Email to Delete"),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _deleteUser, child: Text("Delete User")),
            SizedBox(height: 10),
            Text(
              _statusMessage,
              style: TextStyle(
                color: _statusMessage.contains("✅") ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
