import 'package:biometric_attendance/face_authentication.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class FormScreen extends StatefulWidget {
  final String imageD;
  final String facestr;
  const FormScreen({super.key, required this.imageD, required this.facestr});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  Box? userBox = Hive.box('users');
  final _nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Enter Data'),
        ),
        body: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter name',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final userData = {
                        'name': _nameController.text,
                        'image': widget.imageD,
                        'face': widget.facestr,
                      };
                      userBox!.put('user', userData);
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FaceAuthentication(),));

            }, child: Text('Check '))
          ],
        ));
  }
}
