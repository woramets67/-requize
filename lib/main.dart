// lib/main.dart
// ✏️ ไฟล์เดิมของอาจารย์ แก้ทับ 3 จุด: import / MultiProvider / home
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/course_provider.dart'; // ✏️ import provider ของเรา
import 'screens/course_list_screen.dart'; // ✏️ import หน้าแรกของเรา (เดิม import transaction_list_screen ลบได้ เพราะไม่ใช้แล้ว)

void main() {
  runApp(
    // ✏️ ChangeNotifierProvider ตัวเดียว → MultiProvider (บทที่ 11.7) เพื่อมีได้หลาย provider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TransactionProvider()), // ของอาจารย์ เก็บไว้
        ChangeNotifierProvider(create: (context) => CourseProvider()), // ✏️ เพิ่มของเรา
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Expense Tracker',
      home: CourseListScreen(), // เปลี่ยนเป็นหน้าจอหลัก
    );
  }
}
