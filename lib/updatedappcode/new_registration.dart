import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:biometric_attendance/Model/face_features_model.dart';
import 'package:biometric_attendance/Model/student_model.dart';
import 'package:biometric_attendance/extract_facefeatures.dart';
import 'package:biometric_attendance/updatedappcode/new_camera_screen.dart';
import 'package:biometric_attendance/updatedappcode/student_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:hive/hive.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final _nameController = TextEditingController();
  final _idRollController = TextEditingController();
  final _departmentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? imgFile;
  String dropdownValue = 'CSE';
  String dropdownSessionValue = '2015-16';
  FaceFeatures? _faceFeatures;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  Box<StudentModel> studentBox = Hive.box<StudentModel>('studentbox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student registration'),
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
            // ListTile(
            //   title: const Text('Registration'),
            //   onTap: () {
            //     Navigator.push(context, MaterialPageRoute(
            //       builder: (context) {
            //         return const RegScreen();
            //       },
            //     ));
            //   },
            // ),
            ListTile(
              title: const Text('Show Student'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const ShowStudentPage();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Column(mainAxisSize: MainAxisSize.min, children: [
                  InkWell(
                    onTap: () {},
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.black,
                            border: Border.all(width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            // child: imgFile != null
                            //     ? SizedBox.shrink()
                            //     : Icon(
                            //         Icons.camera_alt,
                            //         size: 40,
                            //       ),
                            child: imgFile == null
                                ? Icon(
                                    Icons.person,
                                  )
                                : Image.file(
                                    imgFile!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () async {
                              final img = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CameraScreen(),
                                  ));
                              if (img is File) {
                                setState(() {
                                  imgFile = img;
                                });
                              }
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Colors.white),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ]),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Student Name';
                                  }
                                  return null;
                                },
                                controller: _nameController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 18),
                                  hintText: 'Enter Student Name',
                                  fillColor: Colors.white,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              )),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Student ID/Roll';
                                }
                                return null;
                              },
                              controller: _idRollController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 18),
                                hintText: 'Enter Student ID/Roll',
                                fillColor: Colors.white,
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                border: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 5),
                              child: Text(
                                'Select Department',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          DropdownButtonFormField(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              border: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Student ID/Roll';
                              }
                              return null;
                            },
                            value: dropdownValue,
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                              });
                            },
                            items: <String>['CSE', 'BBA', 'EEE', 'CIVIL']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 5),
                              child: Text(
                                'Select Session',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          DropdownButtonFormField(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              border: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Select Session';
                              }
                              return null;
                            },
                            value: dropdownSessionValue,
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownSessionValue = newValue!;
                              });
                            },
                            items: <String>[
                              '2015-16',
                              '2016-17',
                              '2017-18',
                              '2018-19',
                              '2019-20',
                              '2020-21',
                              '2021-22',
                              '2022-23',
                              '2023-24'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 32),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(250, 45),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  backgroundColor: Colors.deepPurple),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  InputImage inputImage =
                                      InputImage.fromFile(imgFile!);
                                  _faceFeatures = await extractFaceFeatures(
                                      inputImage, _faceDetector);
                                  Uint8List imageBytes =
                                      imgFile!.readAsBytesSync();
                                  final imgStr = base64Encode(imageBytes);
                                  final student = StudentModel(
                                      name: _nameController.text,
                                      img: imgStr,
                                      faceData: jsonEncode(_faceFeatures),
                                      rollId: _idRollController.text,
                                      dpt: dropdownValue,
                                      session: dropdownSessionValue);
                                  studentBox.add(student);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'successfully added to database')));
                                  //     ElevatedButton(onPressed: (){
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ShowStudentPage(),
                                  ));
                                  //     }, child: Text('Check Data'))
                                  //   ],
                                  // ),
                                }
                              },
                              child: const Text(
                                'SUBMIT',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      // body: Column(
      //   children: [
      //     InkWell(
      //       onTap: () async {
      //         final img = await Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => CameraScreen(),
      //             ));
      //         if (img is File) {
      //           setState(() {
      //             imgFile = img;
      //           });
      //         }
      //       },
      //       child: CircleAvatar(
      //         backgroundColor: Colors.grey.shade300,
      //         backgroundImage: imgFile != null ? FileImage(imgFile!) : null,
      //         radius: 70,
      //         child: imgFile != null
      //             ? SizedBox.shrink()
      //             : Icon(
      //                 Icons.camera_alt,
      //                 size: 40,
      //               ),
      //       ),
      //     ),
      //     Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: TextField(
      //         controller: _nameController,
      //         decoration: InputDecoration(border: OutlineInputBorder()),
      //       ),
      //     ),
      //     SizedBox(
      //       width: 150,
      //       child: ElevatedButton(
      //         onPressed: () async {
      //           if (imgFile != null || _nameController.text.isNotEmpty) {
      //             InputImage inputImage = InputImage.fromFile(imgFile!);
      //             _faceFeatures =
      //                 await extractFaceFeatures(inputImage, _faceDetector);
      //             Uint8List imageBytes = imgFile!.readAsBytesSync();
      //             final imgStr = base64Encode(imageBytes);
      //             final student = StudentModel(
      //                 name: _nameController.text,
      //                 img: imgStr,
      //                 faceData: jsonEncode(_faceFeatures));
      //             studentBox.add(student);
      //             ScaffoldMessenger.of(context).showSnackBar(
      //                 SnackBar(content: Text('successfully added to database')));
      //           } else {
      //             ScaffoldMessenger.of(context).showSnackBar(
      //                 SnackBar(content: Text('image must not be empty')));
      //           }
      //         },
      //         child: Text('Save'),
      //       ),
      //     ),
      //     ElevatedButton(onPressed: (){
      //       Navigator.of(context).push(MaterialPageRoute(builder: (context) => StudentInfoScreen(),));
      //     }, child: Text('Check Data'))
      //   ],
      // ),
    );
  }
}
