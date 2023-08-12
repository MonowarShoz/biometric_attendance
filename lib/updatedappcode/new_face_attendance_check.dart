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

 List<StudentModel> attstudentList = [];
class FaceAttendanceCheck extends StatefulWidget {
  const FaceAttendanceCheck({super.key});

  @override
  State<FaceAttendanceCheck> createState() => _FaceAttendanceCheckState();
}

class _FaceAttendanceCheckState extends State<FaceAttendanceCheck>
    with WidgetsBindingObserver {
  Box<StudentModel> studentBox = Hive.box<StudentModel>('studentbox');
  List<dynamic> newstList = [];
 // List<StudentModel> attstudentList = [];
  String _similarity = "";
  int trialNumber = 1;
   bool faceMatched = false;
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

  String failedMessage = '';
  String status = '';

  


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
      _faceDetector.close();
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
                        // SizedBox(
                        //   height: 40,
                        // ),
                        // failedMessage.isNotEmpty
                        //     ? Text(failedMessage)
                        //     :
                        studentModel == null
                            ? SizedBox.shrink()
                            : Container(
                                margin: const EdgeInsets.all(9),
                                width: double.infinity,
                                height: 90,
                                decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 233, 242, 233),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: CircleAvatar(
                                            radius: 30,
                                            backgroundImage:
                                                studentModel != null
                                                    ? MemoryImage(
                                                        base64Decode(
                                                          studentModel!.img!,
                                                        ),
                                                      )
                                                    : null,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 9),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                ' ${studentModel?.name ?? 'Name'}',
                                              ),
                                              Text(
                                                  ' ${studentModel?.rollId ?? 'Name'}'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Icon(
                                        Icons.check_circle,
                                        size: 30,
                                        color: Colors.green,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                        Text('Status : $failedMessage'),
                        // failedMessage.isNotEmpty
                        //     ? Text(failedMessage)
                        //     : ListTile(
                        //         shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(10)),
                        //         tileColor: Colors.black,
                        //         leading: CircleAvatar(
                        //           radius: 30,
                        //           backgroundImage: studentModel != null
                        //               ? MemoryImage(
                        //                   base64Decode(
                        //                     studentModel!.img!,
                        //                   ),
                        //                 )
                        //               : null,
                        //         ),
                        //         trailing: Icon(
                        //           Icons.check,
                        //           color: Colors.green,
                        //         ),
                        //         title:
                        //             Text('Name : ${studentModel?.name ?? ''}'),
                        //       )
                        // : SizedBox.shrink(),
                      ],
                    )),
                    isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () {
                              _setImage();
                            },
                            child: Text('Give Attendance'),
                          ),
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

    setState(() {
      newstList.clear();
      newstList = [];
      studentModel = null;
      failedMessage = '';
      status = 'Clear';
      isLoading = true;
    });
    // setState(() => isMatching = true);
    final pictureFile = await _cameraController!.takePicture();

    final imgfile = File(pictureFile.path);
    //setState(() => isMatching = true);
    InputImage inputImage = InputImage.fromFile(imgfile);
    //  setState(() => isMatching = true);

    _faceFeatures = await extractFaceFeatures(inputImage, _faceDetector);
    if (_faceFeatures == null) {
      setState(() {
        failedMessage = 'No Face Found';
        isLoading = false;
      });
    } else {
      Uint8List imageBytes = imgfile.readAsBytesSync();

      final imgStr = base64Encode(imageBytes);
      image2.bitmap = imgStr;
      image2.imageType = regula.ImageType.LIVE;

      // setState(() => isMatching = true);
      _fetchUsersAndMatchFace();
    }
    //  setState(() => isMatching = false);
    // Uint8List imageBytes = imgfile.readAsBytesSync();

    // final imgStr = base64Encode(imageBytes);
    // image2.bitmap = imgStr;
    // image2.imageType = regula.ImageType.LIVE;

    // // setState(() => isMatching = true);
    // _fetchUsersAndMatchFace();
    // setState(() {
    //   isLoading = false;
    // });

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

  _fetchUsersAndMatchFace() async {
    //setState(() => isMatching = false);
    final studentList = studentBox.values.toList();

    if (studentList.isNotEmpty) {
      newstList.clear();
      for (var student in studentList) {
        FaceFeatures faceFeaturesFromDB = FaceFeatures();
        Map<String, dynamic> face = jsonDecode(student.faceData!);
        faceFeaturesFromDB = FaceFeatures.fromJson(face);
        double similarity = compareFaces(_faceFeatures!, faceFeaturesFromDB);
        log('fetchUserAndMatchFace $similarity');
        if (similarity >= 0.8 && similarity <= 1.5) {
          //log('succes');
          newstList.add([student, similarity]);
        } else {
          newstList.clear();
        }
      }
      log(newstList.length.toString(), name: "Filtered Users");
      setState(() {
        //Sorts the users based on the similarity.
        //More similar face is put first.
        newstList.sort((a, b) => (((a.last as double) - 1).abs())
            .compareTo(((b.last as double) - 1).abs()));
      });

    await  _matchFaces();
    } else {
      setState(() {
        failedMessage = 'User list is Empty';
      });
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text('No User is Registered')));
    }
  }

  _matchFaces() async {
    if (newstList.isEmpty) {
      setState(() {
        status = 'NoUser';
        failedMessage = 'No Matched User';
        isLoading = false;
      });
    } else {
     
      for (List student in newstList) {
        image1.bitmap = (student.first as StudentModel).img;
        image1.imageType = regula.ImageType.PRINTED;

        var request = regula.MatchFacesRequest();
        request.images = [image1, image2];
        dynamic value = await regula.FaceSDK.matchFaces(jsonEncode(request));

        var response = regula.MatchFacesResponse.fromJson(json.decode(value));
        dynamic str = await regula.FaceSDK.matchFacesSimilarityThresholdSplit(
            jsonEncode(response!.results), 0.75);
        var split = regula.MatchFacesSimilarityThresholdSplit.fromJson(
            json.decode(str));

        setState(() {
          _similarity = split!.matchedFaces.isNotEmpty
              ? (split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2)
              : "error";
          log("similarity: $_similarity");
          //  });

          // ScaffoldMessenger.of(context)
          //     .showSnackBar(SnackBar(content: Text('Similarity $_similarity')));

          if (_similarity != "error" && double.parse(_similarity) > 90.00) {
            faceMatched = true;
            log('faceMatched 1 $faceMatched');
            // log('Face  matching');
            // setState(() {
            //   failedMessage = 'Face Matched';
            //   studentModel = student.first;
            //   isLoading = false;
            // });

            // loggingUser = user.first;
          } else {
            faceMatched = false;
      log('faceMatched 2 $faceMatched');
            // setState(() {
            //   isLoading = false;

            //   failedMessage = 'Face not matching';
            // });
          }
        });
        if (faceMatched) {
          setState(() {
            isLoading = false;
            studentModel = student.first;
            if (attstudentList.contains(studentModel)) {
              status = 'Attendance Already Exist';
            }else {
               attstudentList.add(studentModel!);
            }
           
            failedMessage = 'Face Matched Succesfully';
          });
          
        } else  {
          setState(() {
            isLoading = false;
            status = 'face not matching';
            failedMessage = 'face not matching,try again';
          });
          log('Face check status $status');
        }
      }
    }

    // if (faceMatched) {
    //   setState(() {
    //     trialNumber = 1;
    //     isMatching = false;
    //     isLoading = false;
    //   });
    //   if (!mounted) {
    //     return;
    //   }

    //   // ScaffoldMessenger.of(context)
    //   //     .showSnackBar(SnackBar(content: Text('Successfully matched')));

    //   // if (mounted) {
    //   //   Navigator.of(context).push(
    //   //     MaterialPageRoute(
    //   //       builder: (context) => UserDetailsView(user: loggingUser!),
    //   //     ),
    //   //   );
    //   // }
    // }

    // if (!faceMatched) {
    //   setState(() {
    //     isLoading = false;
    //     studentModel = null;
    //     failedMessage = 'Face Not matching to this user';
    //   });

    //   // ScaffoldMessenger.of(context)
    //   //     .showSnackBar(SnackBar(content: Text('Failed matched')));
    // }

    //}
  }
}
