import 'dart:convert';
import 'dart:typed_data';

import 'package:biometric_attendance/Model/student_model.dart';
import 'package:biometric_attendance/updatedappcode/new_face_attendance_check.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class StudentInfoScreen extends StatefulWidget {
  const StudentInfoScreen({super.key});

  @override
  State<StudentInfoScreen> createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  Box<StudentModel> studentBox = Hive.box<StudentModel>('studentbox');
  Uint8List? imgData;

  Uint8List? decodeImg(String img){
    var imgD = base64Decode(img);
   return imgD;

  }

  @override
  Widget build(BuildContext context) {
    final studentList = studentBox.values.toList();
    return Scaffold(

      appBar: AppBar(
        title: Text('student information'),
        actions: [
          TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => FaceAttendanceCheck(),));
          }, child: Text('att'))
        ],
      ),

      body: Column(
        children: [
          Expanded(child: ListView.builder(
            itemCount: studentList.length,
            itemBuilder: (context, index) {
              var item = studentList[index];
              return ListTile(
                leading: CircleAvatar(radius: 30,backgroundImage: MemoryImage(decodeImg(item.img!)!)),
                title: Text(item.name ?? ''),
              );
            },
          ))
        ],
      ),
    );
  }
}
