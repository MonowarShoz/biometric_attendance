import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:biometric_attendance/Model/student_model.dart';
import 'package:biometric_attendance/extract_facefeatures.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter_face_api/face_api.dart' as regula;
import 'package:hive/hive.dart';
import '../Model/face_features_model.dart';

class FaceAttendanceCheck extends StatefulWidget {
  const FaceAttendanceCheck({super.key});

  @override
  State<FaceAttendanceCheck> createState() => _FaceAttendanceCheckState();
}

class _FaceAttendanceCheckState extends State<FaceAttendanceCheck>
    with WidgetsBindingObserver {
  Box<StudentModel> studentBox = Hive.box<StudentModel>('studentbox');
  List<dynamic> newstList = [];
  String _similarity = "";
  int trialNumber = 1;
  StudentModel? studentModel;
  CameraController? _cameraController;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  FaceFeatures? _faceFeatures;
  var image1 = regula.MatchFacesImage();
  var image2 = regula.MatchFacesImage();
  bool isMatching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(camera, ResolutionPreset.max);
    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(FlashMode.off);

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    // Select the first rear camera.
    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.front) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }
  bool isLoading = false;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          FutureBuilder<List<CameraDescription>>(
              future: availableCameras(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _initCameraController(snapshot.data!);
                  return Stack(
                    children: [
                      CameraPreview(
                        _cameraController!,
                      ),
                      // Container(
                      //   width: 200,
                      //   height: 90,
                      //   color: Colors.white24,
                      // ),
                    ],
                  );
                } else {
                  return const LinearProgressIndicator();
                }
              }),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Material(
              child: Container(
                height: 250,
                color: Colors.white,
                child: Column(
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: studentModel == null
                                  ? null
                                  : MemoryImage(base64Decode(
                                      studentModel!.img ?? '',
                                    ))),
                          title:     Text('Name : ${studentModel?.name ?? ''}'),
                        ),


                      ],
                    )),
                  isLoading ? CircularProgressIndicator() :  ElevatedButton(
                        onPressed: () {
                          _setImage();
                        },
                        child: Text('Check Attendance')),
                  ],
                ),
              ),
            ),
          ),

          // Scaffold(
          //     backgroundColor: Colors.transparent,
          //     body: Column(
          //       children: [
          //         Container(
          //           height: 90,
          //           color: Colors.white,
          //
          //
          //         ),
          //
          //         Container(
          //           padding: const EdgeInsets.only(bottom: 30.0),
          //           child: Center(
          //             child: ElevatedButton(
          //               onPressed: (){
          //
          //               },
          //               child: const Text('Scan text'),
          //             ),
          //           ),
          //         ),
          //       ],
          //     ))
        ],
      ),
    );
  }

  Future _setImage() async {
    if (_cameraController == null) return;
    final navigator = Navigator.of(context);
    setState(() {
      isLoading = true;
    });
    final pictureFile = await _cameraController!.takePicture();

    final imgfile = File(pictureFile.path);
    InputImage inputImage = InputImage.fromFile(imgfile);

    _faceFeatures = await extractFaceFeatures(inputImage, _faceDetector);
    Uint8List imageBytes = imgfile.readAsBytesSync();

    final imgStr = base64Encode(imageBytes);
    image2.bitmap = imgStr;
    image2.imageType = regula.ImageType.LIVE;

    _fetchUsersAndMatchFace();
    setState(() {
      isLoading = false;
    });

    // setState(() {
    //   _canAuthenticate = true;
    // });
  }

  double compareFaces(FaceFeatures face1, FaceFeatures face2) {
    double distEar1 = euclideanDistance(face1.rightEar!, face1.leftEar!);
    double distEar2 = euclideanDistance(face2.rightEar!, face2.leftEar!);

    double ratioEar = distEar1 / distEar2;

    double distEye1 = euclideanDistance(face1.rightEye!, face1.leftEye!);
    double distEye2 = euclideanDistance(face2.rightEye!, face2.leftEye!);

    double ratioEye = distEye1 / distEye2;

    double distCheek1 = euclideanDistance(face1.rightCheek!, face1.leftCheek!);
    double distCheek2 = euclideanDistance(face2.rightCheek!, face2.leftCheek!);

    double ratioCheek = distCheek1 / distCheek2;

    double distMouth1 = euclideanDistance(face1.rightMouth!, face1.leftMouth!);
    double distMouth2 = euclideanDistance(face2.rightMouth!, face2.leftMouth!);

    double ratioMouth = distMouth1 / distMouth2;

    double distNoseToMouth1 =
        euclideanDistance(face1.noseBase!, face1.bottomMouth!);
    double distNoseToMouth2 =
        euclideanDistance(face2.noseBase!, face2.bottomMouth!);

    double ratioNoseToMouth = distNoseToMouth1 / distNoseToMouth2;

    double ratio =
        (ratioEye + ratioEar + ratioCheek + ratioMouth + ratioNoseToMouth) / 5;
    log(ratio.toString(), name: "Ratio");

    return ratio;
  }

  double euclideanDistance(Points p1, Points p2) {
    final sqr =
        math.sqrt(math.pow((p1.x! - p2.x!), 2) + math.pow((p1.y! - p2.y!), 2));
    return sqr;
  }

  _fetchUsersAndMatchFace() {
    setState(() => isMatching = false);
    final studentList = studentBox.values.toList();
    // CustomSnackBar.errorSnackBar("Something went wrong. Please try again.");
    // Map<String,dynamic> b = userBox!.get(
    //   'user',
    // );
    //if (b['face'] != null) {
    if (studentList.isNotEmpty) {
      for (var student in studentList) {
        FaceFeatures _faceFeaturesFromDB = FaceFeatures();
        Map<String, dynamic> face = jsonDecode(student.faceData!);
        _faceFeaturesFromDB = FaceFeatures.fromJson(face);
        double similarity = compareFaces(_faceFeatures!, _faceFeaturesFromDB);
        if (similarity >= 0.8 && similarity <= 1.5) {
          //log('succes');
          newstList.add([student, similarity]);
        }
      }
      log(newstList.length.toString(), name: "Filtered Users");
      setState(() {
        //Sorts the users based on the similarity.
        //More similar face is put first.
        newstList.sort((a, b) => (((a.last as double) - 1).abs())
            .compareTo(((b.last as double) - 1).abs()));
      });

      _matchFaces();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No User is Registered')));
    }
  }

  _matchFaces() async {
    bool faceMatched = false;
    // Map b = userBox!.get(
    //   'user',
    // );
    for (List student in newstList) {
      image1.bitmap = (student.first as StudentModel).img;
      image1.imageType = regula.ImageType.PRINTED;

      var request = regula.MatchFacesRequest();
      request.images = [image1, image2];
      dynamic value = await regula.FaceSDK.matchFaces(jsonEncode(request));

      var response = regula.MatchFacesResponse.fromJson(json.decode(value));
      dynamic str = await regula.FaceSDK.matchFacesSimilarityThresholdSplit(
          jsonEncode(response!.results), 0.75);
      var split =
          regula.MatchFacesSimilarityThresholdSplit.fromJson(json.decode(str));

      setState(() {
        _similarity = split!.matchedFaces.isNotEmpty
            ? (split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2)
            : "error";
        log("similarity: $_similarity");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Similarity $_similarity')));

        if (_similarity != "error" && double.parse(_similarity) > 90.00) {
          faceMatched = true;
          studentModel = student.first;
          // loggingUser = user.first;
        } else {
          faceMatched = false;
        }
      });
    }

    if (faceMatched) {
      setState(() {
        trialNumber = 1;
        isMatching = false;
      });
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Successfully matched')));

      // if (mounted) {
      //   Navigator.of(context).push(
      //     MaterialPageRoute(
      //       builder: (context) => UserDetailsView(user: loggingUser!),
      //     ),
      //   );
      // }
    }

    if (!faceMatched) {
      if (trialNumber == 4) {
        setState(() => trialNumber = 1);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed matched')));
      } else if (trialNumber == 3) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed matched')));

        setState(() {
          isMatching = false;
          trialNumber++;
        });
      } else {
        setState(() => trialNumber++);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed matched')));
      }
    }

    //}
  }
}
