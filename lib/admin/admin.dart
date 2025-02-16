import 'package:flutter/material.dart';
import '../services/database.dart';
import '../main.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> testResults = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final userResults = await dbHelper.getUsers();
      final testResultsData = await dbHelper.getTestResults();

      setState(() {
        users = userResults;
        testResults = testResultsData;
      });

      print("✅ Users fetched: ${users.length}");
      print("✅ Test Results fetched: ${testResults.length}");
    } catch (e) {
      print("❌ Error fetching data: $e");
    }
  }

  void _deleteDB() {
    final dbHelper = DatabaseHelper();
    dbHelper.deleteDatabaseFile(); // Deletes old database
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
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Users Table',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              users.isNotEmpty
                  ? _buildTable(users, [
                    'id',
                    'username',
                    'name',
                    'gender',
                    'email',
                    'dob',
                  ])
                  : const Text("No users found"),
              const SizedBox(height: 20),
              const Text(
                'Test Results Table',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              testResults.isNotEmpty
                  ? _buildTable(testResults, [
                    'id',
                    'test_number',
                    'user_id',
                    'left_ear',
                    'right_ear',
                    'total',
                    'current_date',
                  ])
                  : const Text("No test results available"),
            ],
          ),
        ),
      ),

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _deleteDB,
            tooltip: 'Delete Database',
            child: const Icon(Icons.delete),
            backgroundColor: Colors.red,
          ),
          const SizedBox(width: 16), // Space between buttons
          FloatingActionButton(
            onPressed: _back,
            tooltip: 'Back',
            child: const Icon(Icons.arrow_back),
            backgroundColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<Map<String, dynamic>> data, List<String> columns) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns:
            columns.map((column) => DataColumn(label: Text(column))).toList(),
        rows:
            data.map((row) {
              return DataRow(
                cells:
                    columns
                        .map(
                          (column) =>
                              DataCell(Text(row[column]?.toString() ?? '')),
                        )
                        .toList(),
              );
            }).toList(),
      ),
    );
  }
}
