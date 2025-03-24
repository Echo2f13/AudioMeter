import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/database.dart';

class TestPage extends StatefulWidget {
  final int userId;
  final int cat;

  const TestPage({super.key, required this.userId, required this.cat});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final dbHelper = DatabaseHelper();
  final AudioPlayer audioPlayer = AudioPlayer();

  final List<String> options = ["Poor", "Normal", "Good"];
  final Map<String, int> scores = {"Poor": 1, "Normal": 2, "Good": 3};

  // Store user-selected scores
  Map<String, String> selectedScores = {
    "Audio 1": "",
    "Audio 2": "",
    "Audio 3": "",
  };

  @override
  void initState() {
    super.initState();
    _ensureTableExists();
  }

  // Ensure database table exists
  Future<void> _ensureTableExists() async {
    final db = await dbHelper.database;
    await db.execute('''
          CREATE TABLE IF NOT EXISTS test_results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            test_number INTEGER NOT NULL,
            user_id INTEGER NOT NULL,
            total INTEGER NOT NULL,
            current_date TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
  }

  Future<void> _playAudio(int audioNumber) async {
    try {
      String filename = "$audioNumber.mp3";
      String path = "audio/${widget.cat}/$filename"; // Corrected path

      await audioPlayer.play(AssetSource(path));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Playing: $path')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error playing audio: $e')));
    }
  }

  // Submit test results
  void _submitTest() async {
    if (selectedScores.values.any((value) => value.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an option for all audios.'),
        ),
      );
      return;
    }

    int totalScore = selectedScores.values.fold(
      0,
      (sum, value) => sum + scores[value]!,
    );

    final db = await dbHelper.database;
    final List<Map<String, dynamic>> lastTest = await db.query(
      'test_results',
      columns: ['test_number'],
      where: 'user_id = ?',
      whereArgs: [widget.userId],
      orderBy: 'test_number DESC',
      limit: 1,
    );

    final int newTestNumber =
        (lastTest.isNotEmpty ? lastTest.first['test_number'] + 1 : 1);

    try {
      final String currentDate = DateTime.now().toIso8601String();
      await db.insert('test_results', {
        'user_id': widget.userId,
        'test_number': newTestNumber,
        'total': totalScore,
        'current_date': currentDate,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test submitted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error submitting test: $e')));
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hearing Test - Category ${widget.cat}"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (int i = 1; i <= 3; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Audio Test $i",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _playAudio(i),
                    child: Text("Play Audio $i"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:
                        options.map((option) {
                          return ChoiceChip(
                            label: Text(option),
                            selected: selectedScores["Audio $i"] == option,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  selectedScores["Audio $i"] = option;
                                });
                              }
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ElevatedButton(
              onPressed: _submitTest,
              child: const Text("Submit Test"),
            ),
          ],
        ),
      ),
    );
  }
}
