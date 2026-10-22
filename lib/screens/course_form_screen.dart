// lib/screens/course_form_screen.dart
// 💡 ไฟล์ใหม่ อาจารย์ไม่มีให้ ประกอบจาก: บทที่ 8.5–8.9 (Form, validator, Checkbox, Dropdown)
//    บทที่ 9.4 (รับข้อมูลผ่าน constructor), ปฏิบัติการบทที่ 11 (EditItemScreen / _saveForm),
//    README อาจารย์ (showDatePicker, int.parse / int.tryParse)
// 💡 หน้าเดียวใช้ 2 แบบ: course == null → เพิ่มใหม่,  course มีค่า → แก้ไข
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';

class CourseFormScreen extends StatefulWidget {
  final Course? course; // null = เพิ่มใหม่, มีค่า = แก้ไข

  const CourseFormScreen({super.key, this.course});

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>(); // 💡 ใช้สั่ง validate() ทั้งฟอร์ม
  // 💡 ฟิลด์ที่พิมพ์ (String/int/double) → 1 ฟิลด์ 1 controller
  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _creditsController = TextEditingController();
  // 💡 ฟิลด์ที่ไม่ได้พิมพ์ (bool / DateTime / enum) → เก็บเป็นตัวแปรธรรมดา + setState
  bool _isElective = false;
  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // โหมดแก้ไข: เติมค่าเดิมลงในฟอร์ม
    if (widget.course != null) {
      _courseCodeController.text = widget.course!.courseCode;
      _courseNameController.text = widget.course!.courseName;
      _creditsController.text = widget.course!.credits.toString(); // 💡 int → ข้อความ ต้อง toString()
      _isElective = widget.course!.isElective;
      _startDate = widget.course!.startDate;
    }
  }

  @override
  void dispose() {
    // 💡 controller ทุกตัวต้อง dispose
    _courseCodeController.dispose();
    _courseNameController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  // เลือกวันที่จากปฏิทิน (README หัวข้อ 1 วิธี ค.)
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _saveForm() {
    final isValid = _formKey.currentState!.validate(); // 💡 เรียก validator ทุกช่อง
    if (!isValid) {
      return;
    }
    final courseCode = _courseCodeController.text;
    final courseName = _courseNameController.text;
    final credits = int.parse(_creditsController.text); // 💡 ข้อความ → int (double ใช้ double.parse)

    if (widget.course == null) {
      // เพิ่มใหม่: ส่งทีละฟิลด์ ตามลำดับ addCourse ใน provider
      context.read<CourseProvider>().addCourse(courseCode, courseName, credits, _startDate, _isElective);
    } else {
      // แก้ไข: สร้าง Course ใหม่ใส่ id เดิม แล้วส่งให้ updateCourse
      final updated = Course(
        id: widget.course!.id,
        courseCode: courseCode,
        courseName: courseName,
        credits: credits,
        startDate: _startDate,
        isElective: _isElective,
      );
      context.read<CourseProvider>().updateCourse(widget.course!.id!, updated);
    }
    Navigator.of(context).pop(); // 💡 กลับหน้ารายการ
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course == null ? 'เพิ่มรายวิชา' : 'แก้ไขรายวิชา'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // 💡 String → TextFormField + validator เช็กว่าง
              TextFormField(
                controller: _courseCodeController,
                decoration: const InputDecoration(labelText: 'รหัสวิชา'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'กรุณาป้อนรหัสวิชา';
                  return null; // 💡 return null = ผ่าน
                },
              ),
              TextFormField(
                controller: _courseNameController,
                decoration: const InputDecoration(labelText: 'ชื่อวิชา'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'กรุณาป้อนชื่อวิชา';
                  return null;
                },
              ),
              // 💡 int → TextFormField + keyboard ตัวเลข + เช็กด้วย int.tryParse (double ใช้ double.tryParse)
              TextFormField(
                controller: _creditsController,
                decoration: const InputDecoration(labelText: 'หน่วยกิต'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'กรุณาป้อนหน่วยกิต';
                  if (int.tryParse(value) == null) return 'กรุณาป้อนจำนวนเต็ม';
                  return null;
                },
              ),
              // 💡 bool → CheckboxListTile (บทที่ 8.9)
              CheckboxListTile(
                title: const Text('วิชาเลือก'),
                value: _isElective,
                onChanged: (value) => setState(() => _isElective = value ?? false),
              ),
              // 💡 ถ้ามี enum → DropdownButtonFormField (บทที่ 8.9):
              // DropdownButtonFormField<CourseLevel>(
              //   initialValue: _level,
              //   decoration: const InputDecoration(labelText: 'ระดับ'),
              //   items: CourseLevel.values
              //       .map((l) => DropdownMenuItem(value: l, child: Text(l.name)))
              //       .toList(),
              //   onChanged: (value) => setState(() => _level = value!),
              // ),
              // 💡 DateTime → ข้อความโชว์วันที่ + ปุ่มเปิดปฏิทิน
              Row(
                children: [
                  Expanded(child: Text('วันเปิดเรียน: ${DateFormat.yMMMd().format(_startDate)}')),
                  TextButton(onPressed: _pickDate, child: const Text('เลือกวันที่')),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('บันทึก'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
