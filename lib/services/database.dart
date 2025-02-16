import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create users table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            name TEXT NOT NULL,
            gender TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            dob TEXT NOT NULL
          )
        ''');

        // Create hearing test table
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
      },
    );
  }

  Future<List<Map<String, dynamic>>> getTestResultsByUserId(int userId) async {
    final db = await database;
    return await db.query(
      'test_results',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'current_date DESC', // Show latest tests first
    );
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<List<Map<String, dynamic>>> getTestResults() async {
    final db = await database;
    return await db.query('test_results');
  }

  Future<int> insertUser(
    String username,
    String name,
    String gender,
    String email,
    String password,
    String dob,
  ) async {
    final db = await database;
    return await db.insert('users', {
      'username': username,
      'name': name,
      'gender': gender,
      'email': email,
      'password': password,
      'dob': dob,
    });
  }

  // Future<Map<String, dynamic>?> getUserById(int userId) async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> result = await db.query(
  //     'users',
  //     where: 'id = ?',
  //     whereArgs: [userId],
  //   );
  //   return result.isNotEmpty ? result.first : null;
  // }

  Future<int> insertTestResult(
    int userId,
    int test_number,
    int leftEar,
    int rightEar,
    int total,
    String currentDate,
  ) async {
    final db = await database;
    return await db.insert('test_results', {
      'user_id': userId,
      'test_number': test_number,
      'left_ear': leftEar,
      'right_ear': rightEar,
      'total': total,
      'current_date': currentDate,
    });
  }

  Future<void> deleteDatabaseFile() async {
    final path = await getDatabasesPath();
    await deleteDatabase(join(path, 'database.db'));
    print("✅ Database deleted successfully!");
  }
}
