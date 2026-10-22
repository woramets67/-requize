// lib/providers/course_provider.dart
// copy จาก transaction_provider.dart แล้ว Ctrl+H (เปิด Aa) 3 รอบตามลำดับ:
//   MyTransaction → Course,  Transaction → Course,  transaction → course
// แล้วแก้มือ 5 จุด: ✏️A import  ✏️B ชื่อ DB/ตาราง  ✏️C CREATE TABLE  ✏️D addCourse  ✏️E orderBy
// 💡 provider = พ่อครัว: หน้าจอสั่ง → provider ไปทำกับ DB → notifyListeners() บอกหน้าจอให้วาดใหม่
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/course.dart'; // ✏️A ชี้ไปไฟล์ model ของเรา

class CourseProvider with ChangeNotifier {
  static const String _dbName = 'courses.db'; // ✏️B ใช้ชื่อไฟล์ DB ใหม่ ไม่ชนกับ expenses.db ของอาจารย์
  static const String _tableName = 'courses'; // ✏️B ชื่อตารางตามโจทย์
  Database? _database;
  List<Course> _courses = [];

  CourseProvider() {
    fetchAndSetCourses(); // โหลดข้อมูลเมื่อ Provider ถูกสร้าง
  }

  List<Course> get courses => [..._courses]; // 💡 หน้าจอเรียก provider.courses เพื่อเอารายการไปโชว์

  // กระบวนการที่ 2: การสร้างฐานข้อมูล
  Future<void> _initDatabase() async {
    if (_database != null) return;
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) {
          print('Creating table $_tableName...');
          // ✏️C คอลัมน์ = ชื่อซ้ายใน toMap ทุกตัว
          // 💡 ชนิด: String/DateTime/enum → TEXT,  int/bool → INTEGER,  double → REAL
          return db.execute(
            'CREATE TABLE $_tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, courseCode TEXT, courseName TEXT, credits INTEGER, startDate TEXT, isElective INTEGER)',
          );
        },
      );
      print('Database initialized at $path');
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  // กระบวนการที่ 3: การ Insert
  // ✏️D รับค่าทีละฟิลด์ (ไม่มี id) ตามลำดับที่โจทย์ให้
  Future<void> addCourse(
    String courseCode,
    String courseName,
    int credits,
    DateTime startDate,
    bool isElective,
  ) async {
    await _initDatabase(); // ตรวจสอบว่า DB พร้อมใช้งาน
    if (_database == null) return;

    final newCourse = Course(
      courseCode: courseCode, // ✏️D ใส่ครบทุกฟิลด์
      courseName: courseName,
      credits: credits,
      startDate: startDate,
      isElective: isElective,
    );

    final id = await _database!.insert(_tableName, newCourse.toMap());
    print('Inserted course with id: $id');
    await fetchAndSetCourses();
  }

  // กระบวนการที่ 4: การ Read
  Future<void> fetchAndSetCourses() async {
    await _initDatabase();
    if (_database == null) return;

    // ✏️E orderBy ต้องเป็นคอลัมน์ที่มีจริงในตาราง (ของอาจารย์ใช้ 'date DESC' ตารางเราไม่มี date)
    final dataList = await _database!.query(_tableName, orderBy: 'startDate DESC');
    _courses = dataList.map((item) => Course.fromMap(item)).toList();
    print('Fetched ${_courses.length} courses.');
    notifyListeners(); // แจ้ง UI ให้วาดใหม่
  }

  // กระบวนการที่ 5: การ Update (เปลี่ยนแค่ชื่อ)
  Future<void> updateCourse(int id, Course newCourse) async {
    await _initDatabase();
    if (_database == null) return;
    await _database!.update(
      _tableName,
      newCourse.toMap(), // toMap() ไม่ส่ง id ที่เป็น null จึงไม่ไปเปลี่ยนคีย์หลัก
      where: 'id = ?', // 💡 แก้เฉพาะแถวที่ id ตรง
      whereArgs: [id],
    );
    await fetchAndSetCourses();
  }

  // กระบวนการที่ 6: การ Delete (เปลี่ยนแค่ชื่อ)
  Future<void> deleteCourse(int id) async {
    await _initDatabase();
    if (_database == null) return;
    await _database!.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    await fetchAndSetCourses();
  }
}
