import 'user_model.dart';

class Student extends User {
  Student({
    required int? id,
    required String name,
    required String phone,
    required String email,
    required String password,
    bool isApproved = false,
  }) : super(
         id: id,
         name: name,
         email: email,
         password: password,
         phone: phone,
         type: 'student',
         isApproved: isApproved,
       );

  @override
  Map<String, dynamic> toMap() {
    return super.toMap();
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      password: map['password'],
      isApproved: map['isApproved'] == 1,
    );
  }
}
