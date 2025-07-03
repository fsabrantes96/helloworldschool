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

    // Verifica se email já existe
    final existingUser = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (existingUser.isNotEmpty) {
      throw Exception('Email já cadastrado');
    }

    final hashedPassword = _hashPassword(password);

    // Inserir usuário base
    final userId = await db.insert('users', {
      'name': name,
      'email': email,
      'password': hashedPassword,
      'phone': phone,
      'type': type,
      'isApproved': type == 'student' ? 1 : 0, // Aprova automaticamente alunos
    });

    return await getUserById(userId);
  }

  Future<User?> login(String email, String password) async {
    final db = await _databaseService.database;
    final hashedPassword = _hashPassword(password);

    try {
      final result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, hashedPassword],
      );

      if (result.isNotEmpty) {
        return await getUserById(result.first['id'] as int);
      }
      return null;
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
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
