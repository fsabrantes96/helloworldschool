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
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      create table users(
        id integer prymary key autoincrement,
        name text not null,
        phone text not null,
        type text not null,
        isApproved integer not null default 0
      )
''');

    await db.execute('''
      create table teachers(
        userId integer primary key,
        foreign key (userId) references users(id)
      )
''');

    await db.execute('''
      create table students(userId integer primary key,
      level text not null,
      foreign key (userId) references users(id)
      )
''');
  }
}
