// lib/models/my_transaction.dart
class Course {
  final int? id;
  final String courseCode;
  final String courseName;
  final int credits;
  final DateTime startDate;
  final bool isElective;

  Course({
    this.id,
    required this.courseCode,
    required this.courseName,
    required this.credits,
    required this.startDate,
    required this.isElective,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id, // ห้ามส่ง id ที่เป็น null เข้าไปใน UPDATE
      'courseCode': courseCode,
      'courseName': courseName,
      'credits': credits,
      'startDate': startDate.toIso8601String(),
      'isElective': isElective ? 1 : 0,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as int,
      courseCode: map['courseCode'] as String,
      courseName: map['courseName'] as String,
      credits: map['credits'] as int,
      startDate: DateTime.parse(map['startDate'] as String),
      isElective: map['isElective'] == 1,
    );
  }
}
