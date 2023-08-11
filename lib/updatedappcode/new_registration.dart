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
  File? imgFile;
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
      body: Column(
        children: [
          InkWell(
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
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              backgroundImage: imgFile != null ? FileImage(imgFile!) : null,
              radius: 70,
              child: imgFile != null
                  ? SizedBox.shrink()
                  : Icon(
                      Icons.camera_alt,
                      size: 40,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
          ),
          SizedBox(
            width: 150,
            child: ElevatedButton(
              onPressed: () async {
                if (imgFile != null || _nameController.text.isNotEmpty) {
                  InputImage inputImage = InputImage.fromFile(imgFile!);
                  _faceFeatures =
                      await extractFaceFeatures(inputImage, _faceDetector);
                  Uint8List imageBytes = imgFile!.readAsBytesSync();
                  final imgStr = base64Encode(imageBytes);
                  final student = StudentModel(
                      name: _nameController.text,
                      img: imgStr,
                      faceData: jsonEncode(_faceFeatures));
                  studentBox.add(student);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('successfully added to database')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('image must not be empty')));
                }
              },
              child: Text('Save'),
            ),
          ),
          ElevatedButton(onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => StudentInfoScreen(),));
          }, child: Text('Check Data'))
        ],
      ),
    );
  }
}
