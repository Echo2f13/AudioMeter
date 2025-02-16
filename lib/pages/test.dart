import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/database.dart';
import 'dart:math';

class TestPage extends StatefulWidget {
  final int userId;

  const TestPage({super.key, required this.userId});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final dbHelper = DatabaseHelper();
  final AudioPlayer audioPlayer = AudioPlayer();
  int leftEarLow = 0;
  int leftEarHigh = 0;
  int rightEarLow = 0;
  int rightEarHigh = 0;
  int wordScore = 0;

  final List<List<String>> wordSets = [
    ["Apple", "Banana", "Orange", "Grapes"],
    ["Chair", "Table", "Sofa", "Bench"],
    ["Blue", "Red", "Green", "Yellow"],
    ["Car", "Bike", "Bus", "Train"],
    ["Lion", "Tiger", "Elephant", "Deer"],
    ["Laptop", "Phone", "Tablet", "Monitor"],
  ];

  final List<String> correctAnswers = [
    "Apple",
    "Chair",
    "Blue",
    "Car",
    "Lion",
    "Laptop",
  ];

  final List<List<String>> shuffledOptions = [];
  final List<String> userAnswers = List.filled(6, "");

  Set<String> _segmentedButtonSelectionLeftLow = {};
  Set<String> _segmentedButtonSelectionLeftHigh = {};
  Set<String> _segmentedButtonSelectionRightLow = {};
  Set<String> _segmentedButtonSelectionRightHigh = {};

  @override
  void initState() {
    super.initState();
    _ensureTableExists();
    _shuffleOptions();
  }

  void _shuffleOptions() {
    final random = Random();
    shuffledOptions.clear();
    for (var set in wordSets) {
      var shuffledSet = List<String>.from(set);
      shuffledSet.shuffle(random);
      shuffledOptions.add(shuffledSet);
    }
  }

  Future<void> _ensureTableExists() async {
    final db = await dbHelper.database;
    await db.execute('''
          CREATE TABLE IF NOT EXISTS test_results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            test_number INTEGER NOT NULL,
            user_id INTEGER NOT NULL,
            left_ear INTEGER CHECK(left_ear BETWEEN 0 AND 100),
            right_ear INTEGER CHECK(right_ear BETWEEN 0 AND 100),
            total INTEGER NOT NULL,
            current_date TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
  }

  void _submitTest() async {
    // Check if all ear-related questions are answered
    if (_segmentedButtonSelectionLeftLow.isEmpty ||
        _segmentedButtonSelectionLeftHigh.isEmpty ||
        _segmentedButtonSelectionRightLow.isEmpty ||
        _segmentedButtonSelectionRightHigh.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all ear-related questions.'),
        ),
      );
      return;
    }

    // Check if all word tests are answered
    if (userAnswers.any((answer) => answer.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all word tests.')),
      );
      return;
    }

    // Calculate word score
    _calculateWordScore();

    // Calculate total score
    int totalScore =
        leftEarLow + leftEarHigh + rightEarLow + rightEarHigh + wordScore;

    // final String currentDate = DateTime.now().toIso8601String();
    final db = await dbHelper.database;

    // Fetch the last test_number for this user
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
      final db = await dbHelper.database;
      await db.insert('test_results', {
        'user_id': widget.userId,
        'test_number': newTestNumber,
        'left_ear': leftEarLow + leftEarHigh,
        'right_ear': rightEarLow + rightEarHigh,
        'total': totalScore,
        'current_date': currentDate,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test submitted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print("❌ Error submitting test: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error submitting test: $e')));
    }
  }

  int _getSelectionScore(Set<String> selection) {
    return selection.contains("Poor") ? 0 : 1;
  }

  void _calculateWordScore() {
    wordScore = 0;
    for (int i = 0; i < 6; i++) {
      if (userAnswers[i] == correctAnswers[i]) {
        wordScore += 1;
      }
    }
  }

  Future<void> _playAudio(
    String assetPath, {
    double volume = 1.0,
    double balance = 0.0,
  }) async {
    await audioPlayer.setVolume(volume); // Set volume
    await audioPlayer.setBalance(balance); // Set balance (left/right channels)
    await audioPlayer.play(AssetSource(assetPath));
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
        title: const Text("Hearing Test"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "User ID: ${widget.userId}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            _buildQuestionWithAudio(
              "Left Ear (Low Volume)",
              _segmentedButtonSelectionLeftLow,
              (newSelection) {
                setState(() {
                  _segmentedButtonSelectionLeftLow = newSelection;
                  leftEarLow = _getSelectionScore(newSelection);
                });
              },
              "audio/left_ear_low.mp3",
              volume: 0.1, // Low volume
              balance: -1.0, // Left channel
            ),
            const Divider(color: Colors.black, height: 20),
            _buildQuestionWithAudio(
              "Left Ear (High Volume)",
              _segmentedButtonSelectionLeftHigh,
              (newSelection) {
                setState(() {
                  _segmentedButtonSelectionLeftHigh = newSelection;
                  leftEarHigh = _getSelectionScore(newSelection);
                });
              },
              "audio/left_ear_high.mp3",
              volume: 1.0, // High volume
              balance: -1.0, // Left channel
            ),
            const Divider(color: Colors.black, height: 20),
            _buildQuestionWithAudio(
              "Right Ear (Low Volume)",
              _segmentedButtonSelectionRightLow,
              (newSelection) {
                setState(() {
                  _segmentedButtonSelectionRightLow = newSelection;
                  rightEarLow = _getSelectionScore(newSelection);
                });
              },
              "audio/right_ear_low.mp3",
              volume: 0.1, // Low volume
              balance: 1.0, // Right channel
            ),
            const Divider(color: Colors.black, height: 20),
            _buildQuestionWithAudio(
              "Right Ear (High Volume)",
              _segmentedButtonSelectionRightHigh,
              (newSelection) {
                setState(() {
                  _segmentedButtonSelectionRightHigh = newSelection;
                  rightEarHigh = _getSelectionScore(newSelection);
                });
              },
              "audio/right_ear_high.mp3",
              volume: 1.0, // High volume
              balance: 1.0, // Right channel
            ),
            const Divider(color: Colors.black, height: 20),
            for (int i = 0; i < 6; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text("Word Test ${i + 1}: Select what you heard"),
                  ElevatedButton(
                    onPressed:
                        () => _playAudio(
                          "audio/word_test_${i + 1}.mp3",
                          volume: 0.1, // Low volume
                          balance: 0.0, // Balanced (both channels)
                        ),
                    child: const Text("Play Audio"),
                  ),
                  SegmentedButton<String>(
                    multiSelectionEnabled: false,
                    emptySelectionAllowed: true,
                    showSelectedIcon: false,
                    selected: Set.from([userAnswers[i]]),
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        userAnswers[i] = newSelection.first;
                      });
                    },
                    segments:
                        shuffledOptions[i]
                            .map(
                              (word) => ButtonSegment<String>(
                                value: word,
                                label: Text(word),
                              ),
                            )
                            .toList(),
                  ),
                  const Divider(color: Colors.black, height: 20),
                ],
              ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitTest,
                child: const Text("Submit Test"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionWithAudio(
    String label,
    Set<String> currentSelection,
    ValueChanged<Set<String>> onChanged,
    String audioAssetPath, {
    double volume = 1.0,
    double balance = 0.0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ElevatedButton(
          onPressed:
              () =>
                  _playAudio(audioAssetPath, volume: volume, balance: balance),
          child: const Text("Play Audio"),
        ),
        SegmentedButton<String>(
          multiSelectionEnabled: false,
          emptySelectionAllowed: true,
          showSelectedIcon: false,
          selected: currentSelection,
          onSelectionChanged: onChanged,
          segments: [
            ButtonSegment<String>(value: "Poor", label: const Text("Poor")),
            ButtonSegment<String>(value: "Normal", label: const Text("Normal")),
            ButtonSegment<String>(value: "Good", label: const Text("Good")),
          ],
        ),
      ],
    );
  }
}
