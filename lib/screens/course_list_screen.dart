// lib/screens/course_list_screen.dart
// copy จาก transaction_list_screen.dart แล้ว Ctrl+H เปลี่ยนชื่อ
// ✏️ เปลี่ยน: ข้อความในแถว, เพิ่ม onTap (ไปหน้าแก้), ปุ่ม + (ไปหน้าเพิ่ม แทนการเพิ่มข้อมูลตัวอย่าง)
// 💡 หน้านี้ = "ดู" + "ลบ"   ส่วน "เพิ่ม" + "แก้" อยู่หน้าฟอร์ม
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/course_provider.dart';
import 'course_form_screen.dart'; // ✏️ import หน้าฟอร์ม (อยู่โฟลเดอร์เดียวกัน ไม่ต้องมี ../)

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายวิชา')),
      // 💡 Consumer = ฟัง provider ถ้ามี notifyListeners() หน้านี้วาดใหม่เอง
      body: Consumer<CourseProvider>(
        builder: (context, courseProvider, child) =>
            courseProvider.courses.isEmpty
                ? const Center(child: Text('ไม่มีรายการ'))
                : ListView.builder(
                    itemCount: courseProvider.courses.length,
                    itemBuilder: (ctx, i) {
                      final course = courseProvider.courses[i];
                      return ListTile(
                        // ✏️ เลือกฟิลด์มาโชว์ตามโจทย์
                        title: Text('${course.courseCode} ${course.courseName}'),
                        subtitle: Text(
                          '${course.credits} หน่วยกิต  '
                          '${course.isElective ? 'วิชาเลือก' : 'วิชาบังคับ'}  ' // 💡 bool โชว์ด้วย ? :
                          '${DateFormat.yMMMd().format(course.startDate)}', // 💡 DateTime โชว์ด้วย DateFormat
                        ),
                        // ✏️ แตะแถว = แก้ไข: ส่ง course ไปหน้าฟอร์มผ่าน constructor (บทที่ 9.4)
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseFormScreen(course: course),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          onPressed: () {
                            // เรียกเมธอด delete
                            // 💡 context.read = สั่ง provider ทำงาน (ไม่ต้องฟัง)   id! = มั่นใจว่าไม่ null
                            context.read<CourseProvider>().deleteCourse(course.id!);
                          },
                        ),
                      );
                    },
                  ),
      ),
      // ✏️ ปุ่ม + = เพิ่มใหม่: เปิดหน้าฟอร์มโดยไม่ส่ง course
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CourseFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
