import 'package:flutter/material.dart';
import 'test.dart';

class SelectTestPage extends StatefulWidget {
  final int userId;
  final int age;

  const SelectTestPage({super.key, required this.userId, required this.age});

  @override
  _SelectTestPageState createState() => _SelectTestPageState();
}

class _SelectTestPageState extends State<SelectTestPage> {
  final List<String> categories = [
    "Child",
    "Teenage",
    "Young Adult",
    "Adult",
    "Old",
  ];

  late int selectedCategoryIndex;
  bool allowSelectionOverride = false;

  @override
  void initState() {
    super.initState();
    selectedCategoryIndex = _getCategoryIndex(widget.age);
  }

  int _getCategoryIndex(int age) {
    if (age <= 12) return 0; // Child
    if (age <= 18) return 1; // Teenage
    if (age <= 35) return 2; // Young Adult
    if (age <= 60) return 3; // Adult
    return 4; // Old
  }

  void _navigateToTest(int selectedCategory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TestPage(
              userId: widget.userId,
              cat: selectedCategory, // Pass the clicked category index
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Test Category"),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < categories.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed:
                      (!allowSelectionOverride && i != selectedCategoryIndex)
                          ? null
                          : () => _navigateToTest(
                            i,
                          ), // Now passes the clicked category
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        (i == selectedCategoryIndex)
                            ? Colors.blue
                            : const Color.fromARGB(255, 255, 255, 255),
                  ),
                  child: Text(categories[i]),
                ),
              ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  allowSelectionOverride = !allowSelectionOverride;
                });
              },
              child: Text(
                allowSelectionOverride
                    ? "Restrict to Age Category"
                    : "Select Different Category",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
