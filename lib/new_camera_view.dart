import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

class NewCameraView extends StatefulWidget {
  const NewCameraView(
      {Key? key, required this.onImage, required this.onInputImage})
      : super(key: key);

  final Function(Uint8List image) onImage;
  final Function(InputImage inputImage) onInputImage;

  @override
  State<NewCameraView> createState() => _NewCameraViewState();
}

class _NewCameraViewState extends State<NewCameraView> {
  File? _image;
  ImagePicker? _imagePicker;

  @override
  void initState() {
    super.initState();

    _imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 330,
          width: 200,
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(height: 90),
              _image != null
                  ? CircleAvatar(
                      radius: 90,
                      backgroundColor: const Color(0xffD9D9D9),
                      backgroundImage: FileImage(_image!),
                    )
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xffD9D9D9),
                      child: Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: const Color(0xff2E2E2E),
                      ),
                    ),
            ],
          ),
        ),
        ElevatedButton.icon(
          label: Text('Take Picture'),
          onPressed: _getImage,
          icon: Icon(Icons.camera),
        ),
      ],
    );
  }

  Future _getImage() async {
    setState(() {
      _image = null;
    });
    final pickedFile = await _imagePicker?.pickImage(
      source: ImageSource.camera,
      maxWidth: 400,
      maxHeight: 400,
      // imageQuality: 50,
    );
    if (pickedFile != null) {
      _setPickedFile(pickedFile);
    }
    setState(() {});
  }

  Future _setPickedFile(XFile? pickedFile) async {
    final path = pickedFile?.path;
    if (path == null) {
      return;
    }
    setState(() {
      _image = File(path);
    });

    Uint8List imageBytes = _image!.readAsBytesSync();
    widget.onImage(imageBytes);

    InputImage inputImage = InputImage.fromFilePath(path);
    widget.onInputImage(inputImage);
  }
}
