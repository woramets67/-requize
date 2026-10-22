// lib/models/course.dart
// copy จาก my_transaction.dart
// ✏️ = จุดที่เปลี่ยนจากของอาจารย์   💡 = ควรจำ
// ✏️ ลบ enum ทิ้ง เพราะโจทย์ไม่มีฟิลด์ตัวเลือก (ถ้ามี เช่น level: เก็บไว้ แล้วตั้ง enum CourseLevel { ... })

class Course {
  final int? id; // 💡 ทุก entity มี id แบบ int? (DB สร้างให้เอง)
  final String courseCode; // ✏️ ฟิลด์ทั้งหมดเอามาจากโจทย์: final ชนิด ชื่อ;
  final String courseName;
  final int credits;
  final DateTime startDate;
  final bool isElective;

  Course({
    this.id, // 💡 id ไม่ required
    required this.courseCode, // ✏️ required this.ชื่อฟิลด์ ให้ครบทุกตัว
    required this.courseName,
    required this.credits,
    required this.startDate,
    required this.isElective,
  });

  // 💡 toMap = Course → แถวในตาราง (ตอนเขียนลง DB)
  //    ซ้าย 'ชื่อคอลัมน์' ต้องสะกดตรงกับ CREATE TABLE ใน provider และ map['...'] ข้างล่าง
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id, // ห้ามส่ง id ที่เป็น null เข้าไปใน UPDATE
      'courseCode': courseCode, // String / int / double ใส่ตรงๆ
      'courseName': courseName,
      'credits': credits,
      'startDate': startDate.toIso8601String(), // 💡 DateTime → ข้อความ (TEXT)
      'isElective': isElective ? 1 : 0, // 💡 bool → 1/0 (INTEGER) เพราะ SQLite ไม่มี true/false
      // 💡 ถ้ามี enum: 'level': level.name,  (เก็บเป็นข้อความ TEXT)
    };
  }

  // 💡 fromMap = แถวในตาราง → Course (ตอนอ่านจาก DB) ทำกลับด้านกับ toMap
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as int, // 💡 ห้ามลืมบรรทัดนี้ ไม่งั้นแก้/ลบไม่ได้
      courseCode: map['courseCode'] as String,
      courseName: map['courseName'] as String,
      credits: map['credits'] as int,
      startDate: DateTime.parse(map['startDate'] as String), // 💡 ข้อความ → DateTime
      isElective: map['isElective'] == 1, // 💡 1 → true, 0 → false
      // 💡 ถ้ามี double: (map['price'] as num).toDouble()
      // 💡 ถ้ามี enum:   CourseLevel.values.byName(map['level'] as String)
    );
  }
}
