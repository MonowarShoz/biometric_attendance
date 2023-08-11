import 'dart:convert';

import 'dart:developer';
import 'package:biometric_attendance/Model/face_features_model.dart';
import 'package:biometric_attendance/enter_details_p.dart';
import 'package:biometric_attendance/extract_facefeatures.dart';
import 'package:biometric_attendance/new_camera_view.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class RegisterFaceView extends StatefulWidget {
  const RegisterFaceView({Key? key}) : super(key: key);

  @override
  State<RegisterFaceView> createState() => _RegisterFaceViewState();
}

class _RegisterFaceViewState extends State<RegisterFaceView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  String? _image;
  FaceFeatures? _faceFeatures;

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
      //  backgroundColor: appBarColor,
        title: const Text("Register User"),
        elevation: 0,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration:  BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [
          //     // scaffoldTopGradientClr,
          //     // scaffoldBottomGradientClr,
          //   ],
          // ),
        ),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.end,
          children: [
            NewCameraView(
              onImage: (image) {
                setState(() {
                  _image = base64Encode(image);
                });
              },
              onInputImage: (inputImage) async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(
                    //  color: accentColor,
                    ),
                  ),
                );
                _faceFeatures =
                    await extractFaceFeatures(inputImage, _faceDetector);
                setState(() {});
                if (mounted) Navigator.of(context).pop();
              },
            ),
            const Spacer(),
            if (_image != null)
              ElevatedButton(
                child: Text("Start Registering"),
                onPressed: () {
                  log('data ${jsonEncode(_faceFeatures)}');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FormScreen(
                        imageD: _image!,
                        facestr: jsonEncode(_faceFeatures),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}