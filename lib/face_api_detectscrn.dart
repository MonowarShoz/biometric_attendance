import 'dart:convert';
import 'dart:typed_data';

import 'package:biometric_attendance/Model/face_features_model.dart';
import 'package:biometric_attendance/camera_view.dart';
import 'package:biometric_attendance/extract_facefeatures.dart';
import 'package:biometric_attendance/face_detect_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter_face_api/face_api.dart' as regula;

class FaceApiAuth extends StatefulWidget {
  const FaceApiAuth({super.key});

  @override
  State<FaceApiAuth> createState() => _FaceApiAuthState();
}

class _FaceApiAuthState extends State<FaceApiAuth> {
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String _similarity = "";
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;
  
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  FaceFeatures? _faceFeatures;
  var image1 = regula.MatchFacesImage();
  var image2 = regula.MatchFacesImage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Api'),
      ),
      body: Container(
        child: Column(
          children: [
             TextButton(
                child: Text("Use camera"),
                onPressed: () {
                  regula.FaceSDK.presentFaceCaptureActivity().then((result) {
                    var response = regula.FaceCaptureResponse.fromJson(
                        json.decode(result))!;
                    if (response.image != null &&
                        response.image!.bitmap != null){
                            setImage(
                          first: true,
                         imageFile:  base64Decode(
                              response.image!.bitmap!.replaceAll("\n", "")),
                        type:   regula.ImageType.LIVE);
                        }
                    
                  });
                  Navigator.pop(context);
                })
          ],
        ),
      ),
    );
  }
  Future<void> initPlatformState() async {
    regula.FaceSDK.init().then((json) {
      var response = jsonDecode(json);
      if (!response["success"]) {
        print("Init failed: ");
        print(json);
      }
    });
  }

  setImage({bool first = false, Uint8List? imageFile, int? type}) {
    if (imageFile == null) return;
    setState(() => _similarity = "nil");
    if (first) {
      image1.bitmap = base64Encode(imageFile);
      image1.imageType = type;
      // setState(() {
      //   img1 = Image.memory(imageFile);
      //   _liveness = "nil";
      // });
    } else {
      image2.bitmap = base64Encode(imageFile);
      image2.imageType = type;
     // setState(() => img2 = Image.memory(imageFile));
    }
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final faces = await _faceDetector.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      _faceFeatures = await extractFaceFeatures(inputImage, _faceDetector);
      final painter = FaceDetectorPainter(
        faces,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
      for (final face in faces) {
        debugPrint('Faces found: ${face.contours}');
      }
    } else {
      String text = 'Faces found: ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
