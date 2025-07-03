import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/teacher_model.dart';
import '../models/student_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'english_school.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'alter table users add coloumn email text not null default""',
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            'alter table users add column phone text not null default ""',
          );
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      phone TEXT NOT NULL,
      type TEXT NOT NULL,
      isApproved INTEGER NOT NULL DEFAULT 0
    )
  ''');

    await db.execute('''
    CREATE TABLE teachers(
      userId INTEGER PRIMARY KEY,
      FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE TABLE students(
      userId INTEGER PRIMARY KEY,
      level TEXT NOT NULL,
      registrationDate TEXT,
      FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
    )
  ''');
  }
}
