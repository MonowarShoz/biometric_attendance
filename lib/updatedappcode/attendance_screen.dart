import 'package:biometric_attendance/updatedappcode/new_face_attendance_check.dart';
import 'package:biometric_attendance/updatedappcode/student_info_screen.dart';
import 'package:flutter/material.dart';

class StudentAttendanceListScreen extends StatelessWidget {
  const StudentAttendanceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Total Attendance in Dept'),
      ),
      body: Column(
        children: [
       attstudentList.isEmpty ? SizedBox.shrink() :   Expanded(
            child: ListView.builder(
              itemCount: attstudentList.length,
              itemBuilder: (context, index) {
                var item = attstudentList[index];
                return ListTile(
                  tileColor: Colors.grey.shade200,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.memory(
                      decodeImg(item.img!)!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text('${item.name}'),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Roll: ${item.rollId}'),
                       Text('Dept: ${item.dpt}'),
                    ],
                  ),
                 
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
