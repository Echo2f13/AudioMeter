import 'package:flutter/material.dart';
import '../services/database.dart' as db_service;
import 'login.dart';
import 'delete_user.dart';
import 'test.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomePageMain extends StatefulWidget {
  final int userId;

  const HomePageMain({super.key, required this.userId});

  @override
  _HomePageMainState createState() => _HomePageMainState();
}

class _HomePageMainState extends State<HomePageMain> {
  final dbHelper = db_service.DatabaseHelper();
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _testResults = [];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchTestResults();
  }

  Future<void> _fetchUserDetails() async {
    final user = await dbHelper.getUserById(widget.userId);
    setState(() {
      _userData = user;
    });
  }

  Future<void> _fetchTestResults() async {
    final results = await dbHelper.getTestResultsByUserId(widget.userId);
    setState(() {
      _testResults = results.reversed.toList(); // ⬆️ Forces latest test on top
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage(title: 'Login')),
    );
  }

  void _navigateToDeleteUser() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DeleteUserPage()),
    );
  }

  void _startTest() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TestPage(userId: widget.userId)),
    ).then((_) => _fetchTestResults()); // Refresh test history after returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _navigateToDeleteUser,
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body:
          _userData == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Username: ${_userData!['username']}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      "Email: ${_userData!['email']}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      "Date of Birth: ${_userData!['dob']}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _startTest,
                        child: const Text("Take Hearing Test"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Test History",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 200, // Adjust the height as needed
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(isInversed: true),
                        series: <CartesianSeries>[
                          AreaSeries<Map<String, dynamic>, String>(
                            dataSource: _testResults,
                            xValueMapper:
                                (Map<String, dynamic> result, _) =>
                                    result['id'].toString(),
                            yValueMapper:
                                (Map<String, dynamic> result, _) =>
                                    result['total'],
                            color: Colors.blue.withOpacity(
                              0.3,
                            ), // Area fill color
                            borderColor:
                                Colors.blue, // Border color of the area
                            borderWidth: 2, // Border width
                          ),
                        ],
                      ),
                    ),
                    _testResults.isEmpty
                        ? const Text(
                          "No test data found",
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        )
                        : Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _testResults.length,
                                  itemBuilder: (context, index) {
                                    final result = _testResults[index];
                                    return Card(
                                      elevation: 3,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          "Test Date: ${result['current_date']}",
                                        ),
                                        subtitle: Text(
                                          "Left Ear: ${result['left_ear']}, Right Ear: ${result['right_ear']}, Total: ${result['total']}",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
    );
  }
}
