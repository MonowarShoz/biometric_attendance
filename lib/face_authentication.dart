import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer';
import 'dart:math' as math;
import 'package:biometric_attendance/Model/face_features_model.dart';
import 'package:biometric_attendance/extract_facefeatures.dart';
import 'package:biometric_attendance/new_camera_view.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter_face_api/face_api.dart' as regula;
import 'package:hive/hive.dart';

class FaceAuthentication extends StatefulWidget {
  const FaceAuthentication({super.key});

  @override
  State<FaceAuthentication> createState() => _FaceAuthenticationState();
}

class _FaceAuthenticationState extends State<FaceAuthentication> {
  Box? userBox = Hive.box('users');
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  FaceFeatures? _faceFeatures;
  var image1 = regula.MatchFacesImage();
  var image2 = regula.MatchFacesImage();
  final TextEditingController _nameController = TextEditingController();
  String _similarity = "";
  bool _canAuthenticate = false;
  List<dynamic> users = [];
  bool userExists = false;

  bool isMatching = false;
  int trialNumber = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Stack(
        children: [
          
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 600,
                    width: double.infinity,
                    // padding:
                    //     EdgeInsets.fromLTRB(0.05, 0.025, 0.05.sw, 0),
                    decoration: BoxDecoration(
                        //  color: overlayContainerClr,
                        // borderRadius: BorderRadius.only(
                        //   topLeft: Radius.circular(0.03.sh),
                        //   topRight: Radius.circular(0.03.sh),
                        // ),
                        ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            NewCameraView(
                              onImage: (image) {
                                _setImage(image);
                              },
                              onInputImage: (inputImage) async {
                                setState(() => isMatching = true);
                                _faceFeatures = await extractFaceFeatures(
                                    inputImage, _faceDetector);
                                setState(() => isMatching = false);
                              },
                            ),
                            if (isMatching)
                              Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: const AnimatedView(),
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),
                        if (_canAuthenticate)
                          ElevatedButton(
                            child: Text("Authenticate"),
                            onPressed: () {
                              setState(() => isMatching = true);

                              _fetchUsersAndMatchFace();
                            },
                          ),
                        //SizedBox(height: 0.038.sh),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future _setImage(Uint8List imageToAuthenticate) async {
    image2.bitmap = base64Encode(imageToAuthenticate);
    image2.imageType = regula.ImageType.PRINTED;

    setState(() {
      _canAuthenticate = true;
    });
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

    // CustomSnackBar.errorSnackBar("Something went wrong. Please try again.");
    Map<String,dynamic> b = userBox!.get(
      'user',
    );
    if (b['face'] != null) {
      FaceFeatures _faceFeatures = FaceFeatures();

      Map<String,dynamic> face = jsonDecode(b['face']);
      _faceFeatures = FaceFeatures.fromJson(face);
      double similarity = compareFaces(_faceFeatures, _faceFeatures);

      if (similarity >= 0.8 && similarity <= 1.5) {
        //log('succes');
        // users.add([user, similarity]);
      }
      _matchFaces();
    }

    // setState(() {
    //   //Sorts the users based on the similarity.
    //   //More similar face is put first.
    //   users.sort((a, b) => (((a.last as double) - 1).abs())
    //       .compareTo(((b.last as double) - 1).abs()));
    // });
  }

  _matchFaces() async {

    bool faceMatched = false;
     Map b = userBox!.get(
      'user',
    );
      if (b['image'] != null) {
        image1.bitmap = b['image'];
      image1.imageType = regula.ImageType.PRINTED;

      //Face comparing logic.
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
          // loggingUser = user.first;
        } else {
          faceMatched = false;
        }
      });
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

      }
      
  }
}




class AnimatedView extends StatefulWidget {
  const AnimatedView({super.key});

  @override
  State<AnimatedView> createState() => _AnimatedViewState();
}

class _AnimatedViewState extends State<AnimatedView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late Animation animation;
  late Animation opacity;
  late AnimationController animationController;
  late int sAngle;
  late int mAngle;
  late int lAngle;
  math.Random random = math.Random();
  late Timer timer;

  @override
  void initState() {
    super.initState();
    sAngle = random.nextInt(360);
    mAngle = random.nextInt(360);
    lAngle = random.nextInt(360);
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      sAngle = random.nextInt(360);
      mAngle = random.nextInt(360);
      lAngle = random.nextInt(360);
    });
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    opacity = Tween<double>(begin: 0.8, end: 0.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeIn));
    animation = Tween<double>(begin: 0, end: 140).animate(CurvedAnimation(
        parent: animationController, curve: Curves.easeInOutQuad))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          animationController.repeat();
        }
      });
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SizedBox(
      height: 30,
      width: 66,
      child: CustomPaint(
        painter: AnimatedCircle(
            value: animation.value,
            sAngle: sAngle,
            mAngle: mAngle,
            lAngle: lAngle,
            opacity: opacity.value,
            showOnxSmallCircle: true,
            showOnLargeCircle: true,
            showOnMediumCircle: true),
      ),
    );
  }
}

class AnimatedCircle extends CustomPainter {
  final double value;
  final double opacity;
  final int sAngle;
  final int mAngle;
  final int lAngle;
  final bool showOnxSmallCircle;
  final bool showOnMediumCircle;
  final bool showOnLargeCircle;

  AnimatedCircle(
      {required this.mAngle,
      required this.lAngle,
      required this.value,
      required this.opacity,
      required this.sAngle,
      required this.showOnxSmallCircle,
      required this.showOnMediumCircle,
      required this.showOnLargeCircle});
  @override
  void paint(Canvas canvas, Size size) {
    var centerX = size.width / 2;
    var centerY = size.height / 2;
    var center = Offset(centerX, centerY);
    var radius = math.min(centerX, centerY);

    var fillBrush = Paint();
    fillBrush.color = const Color(0xff55bd94).withOpacity(opacity);

    var largeCircle = Paint();
    largeCircle.style = PaintingStyle.stroke;
    largeCircle.strokeWidth = 1.0;
    largeCircle.color =
        (value <= 140 && value > 125) ? Colors.white : Colors.grey;

    var mediumCircle = Paint();
    mediumCircle.style = PaintingStyle.stroke;
    mediumCircle.strokeWidth = 1.0;
    mediumCircle.color =
        (value > 90 && value < 110) ? Colors.white : Colors.grey;

    var xsmallCircle = Paint();
    xsmallCircle.style = PaintingStyle.stroke;
    xsmallCircle.strokeWidth = 1.0;
    xsmallCircle.color =
        (value > 40 && value < 60) ? Colors.white : Colors.grey;

    var childDot = Paint();
    childDot.color = Colors.white;

    var centerdot = Paint();
    centerdot.color = Colors.deepPurple;

    canvas.drawCircle(center, value, fillBrush);
    canvas.drawCircle(center, radius, largeCircle);
    canvas.drawCircle(center, radius - 40, mediumCircle);
    canvas.drawCircle(center, radius - 80, xsmallCircle);
    if (showOnxSmallCircle) {
      double valX = x(70, sAngle, centerX);
      double valY = y(70, sAngle, centerY);
      Offset offset = Offset(valX, valY);
      canvas.drawCircle(
          offset, (value * .13).clamp(1, 10).toDouble(), childDot);
    }
    if (showOnMediumCircle) {
      double valX = x(110, mAngle, centerX);
      double valY = y(110, mAngle, centerY);
      Offset offset = Offset(valX, valY);
      canvas.drawCircle(
          offset, (value * .13).clamp(1, 15).toDouble(), childDot);
    }
    if (showOnLargeCircle) {
      double valX = x(math.min(centerX, centerY), lAngle, centerX);
      double valY = y(math.min(centerX, centerY), lAngle, centerY);
      Offset offset = Offset(valX, valY);
      canvas.drawCircle(
          offset, (value * .15).clamp(1, 20).toDouble(), childDot);
    }
    canvas.drawCircle(center, 5.0, centerdot);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

double x(r, angle, centerX) => r * math.cos((angle - math.pi / 2)) + centerX;
double y(r, angle, centerY) => r * math.sin((angle - math.pi / 2)) + centerY;
