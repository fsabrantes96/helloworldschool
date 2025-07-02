import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/teacher_model.dart';
import '../models/student_model.dart';
import 'database_service.dart';

class AuthService {
  final DatabaseService _databaseService = DatabaseService();

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String type,
    Map<String, dynamic>? additionalData,
  }) async {
    final db = await _databaseService.database;

    final existingUser = await db.query(
      'users',
      where: 'email = ? OR phone = ?',
      whereArgs: [email, phone],
    );

    if (existingUser.isNotEmpty) {
      throw Exception('Email ou telefone já cadastrados');
    }

    final hashedPassword = _hashPassword(password);

    final userId = await db.insert('users', {
      'name': name,
      'email': email,
      'password': hashedPassword,
      'phone': phone,
      'type': type,
      'isApproved': 0,
    });

    if (type == 'teacher') {
      await db.insert('teachers', {'userId': userId});
    } else if (type == 'student' && additionalData != null) {
      await db.insert('students', {
        'userId': userId,
        'level': additionalData['level'],
        'registrationDate': DateTime.now().toIso8601String(),
      });
    }

    return await getUserById(userId);
  }

  Future<User?> login(String email, String password) async {
    final db = await _databaseService.database;
    final hashedPassword = _hashPassword(password);

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashedPassword],
    );

    if (result.isEmpty) return null;
    return await getUserById(result.first['id'] as int);
  }

  Future<User?> getUserById(int id) async {
    final db = await _databaseService.database;

    final userData = await db.query('users', where: 'id = ?', whereArgs: [id]);

    if (userData.isEmpty) return null;

    final userMap = userData.first;
    final type = userMap['type'] as String;

    if (type == 'teacher') {
      return Teacher.fromMap(userMap);
    } else if (type == 'student') {
      final studentData = await db.query(
        'students',
        where: 'userId = ?',
        whereArgs: [id],
      );

      if (studentData.isNotEmpty) {
        return Student.fromMap({...userMap, ...studentData.first});
      }
    }

    return User.fromMap(userMap);
  }
}
