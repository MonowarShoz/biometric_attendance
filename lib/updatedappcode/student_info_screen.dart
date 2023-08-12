import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:biometric_attendance/Model/student_model.dart';
import 'package:biometric_attendance/updatedappcode/attendance_screen.dart';
import 'package:biometric_attendance/updatedappcode/new_face_attendance_check.dart';
import 'package:biometric_attendance/updatedappcode/new_registration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

Uint8List? decodeImg(String img) {
    var imgD = base64Decode(img);
    return imgD;
  }

class StudentInfoScreen extends StatefulWidget {
  const StudentInfoScreen({super.key});

  @override
  State<StudentInfoScreen> createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  Box<StudentModel> studentBox = Hive.box<StudentModel>('studentbox');
  Uint8List? imgData;

  

  @override
  Widget build(BuildContext context) {
    var studentList = studentBox.values.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('student information'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FaceAttendanceCheck(),
                    ));
              },
              child: Text('att'))
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
            itemCount: studentList.length,
            itemBuilder: (context, index) {
              var item = studentList[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  tileColor: const Color.fromARGB(255, 218, 240, 219),
                  leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: MemoryImage(decodeImg(item.img!)!)),
                  title: Text(item.name ?? ''),
                  trailing: IconButton(
                    onPressed: () {
                      studentBox.deleteAt(index);
                      setState(() {
                        studentList = studentBox.values.toList();
                      });
                    },
                    icon: Icon(Icons.delete),
                  ),
                ),
              );
            },
          ))
        ],
      ),
    );
  }
}

class ShowStudentPage extends StatefulWidget {
  const ShowStudentPage({super.key});

  @override
  State<ShowStudentPage> createState() => _HomePageState();
}

class _HomePageState extends State<ShowStudentPage> {
  Box<StudentModel> studentBox = Hive.box<StudentModel>('studentbox');
  Uint8List? imgData;

  Uint8List? decodeImg(String img) {
    var imgD = base64Decode(img);
    return imgD;
  }

  @override
  Widget build(BuildContext context) {
    var studentList = studentBox.values.toList();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        //title: MarqueeText(text: 'সরকারী তিতুমীর কলেজ, ঢাকা'),
        title: Text('ABC College, Dhaka',style: TextStyle(color: Colors.white)),
        iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Text('ABC College Dhaka',style: TextStyle(color: Colors.white),),
            ),
            ListTile(
              title: const Text('Registration'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return const StudentRegistrationScreen();
                  },
                ));
              },
            ),
            ListTile(
              title: const Text('Show Student'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return const ShowStudentPage();
                  },
                ));
              },
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              SizedBox(
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1)),
                  onPressed: () {
                     Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FaceAttendanceCheck(),
                    ));
                    // Navigator.push(context, MaterialPageRoute(
                    //   builder: (context) {
                    //     return const StudentRegistrationScreen();
                    //   },
                    // ));
                  },
                  child: const Text('Give Attendance'),
                ),
              ),
               SizedBox(
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1)),
                  onPressed: () {
                     Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentAttendanceListScreen(),
                    ));
                    // Navigator.push(context, MaterialPageRoute(
                    //   builder: (context) {
                    //     return const StudentRegistrationScreen();
                    //   },
                    // ));
                  },
                  child: const Text('Check Attendance'),
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 1.2,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: studentList.length,
              itemBuilder: (context, index) {
                final item = studentList[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: InkWell(
                    onTap: (){
                      //   studentBox.deleteAt(index);
                      // setState(() {
                      //   studentList = studentBox.values.toList();
                      // });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(width: 2, color: Colors.deepPurple)),
                      child: Column(
                        children: [
                          Text(
                            'Department : ${item.dpt ?? ''}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Divider(thickness: 2),
                          ),
                          ListTile(
                            title: Row(
                              children: [
                                const Text(
                                  'Student Name : ',
                                  style: TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                Text(item.name ?? ''),
                              ],
                            ),
                            subtitle: Column(
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Student ID : ',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(item.rollId ?? ''),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Session : ',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(item.session!),
                                  ],
                                ),
                              ],
                            ),
                            trailing: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.memory(
                                decodeImg(item.img!)!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// class MarqueeText extends StatelessWidget {
//   String? text;
//   MarqueeText({super.key, this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 30,
//       //color: Colors.white,
//       child: Marquee(
//         text: text.toString(),
//         style: const TextStyle(
//             fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
//         scrollAxis: Axis.horizontal,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         blankSpace: 20.0,
//         velocity: 80.0,
//         pauseAfterRound: const Duration(seconds: 1),
//         startPadding: 10.0,
//         accelerationDuration: const Duration(seconds: 1),
//         accelerationCurve: Curves.linear,
//         decelerationDuration: const Duration(milliseconds: 500),
//         decelerationCurve: Curves.easeOut,
//       ),
//     );
//   }
// }

