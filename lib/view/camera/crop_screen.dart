import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:quick_clip/utils/stylesheet.dart';

class CropScreen extends StatefulWidget {
  final XFile pickedImage;
  const CropScreen({super.key, required this.pickedImage});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  CroppedFile? _croppedFile;

  @override
  void initState() {
    super.initState();
    _cropImage(); // 화면이 로드되면 바로 크롭 기능 실행
  }

  // 이미지 크롭 함수
  Future<void> _cropImage() async {
    final croppedFile = await ImageCropper().cropImage(
    sourcePath: widget.pickedImage.path,
    aspectRatio: null,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: '분석할 영역을 선택해 주세요',
        toolbarColor: Stylesheet.accentColor,
        toolbarWidgetColor: Colors.white,
      ),
      IOSUiSettings(
        title: 'Cropper',
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
        ],
      ),
      WebUiSettings(
        context: context,
      ),
    ],
  );

    if (croppedFile != null) {
      setState(() {
        _croppedFile = croppedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('이미지 크롭'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (_croppedFile != null) {
                // 크롭된 이미지를 반환하거나 다음 화면으로 전달
                Navigator.pop(context, _croppedFile);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: _croppedFile != null
            ? Image.file(File(_croppedFile!.path)) // 크롭된 이미지 표시
            : Image.file(File(widget.pickedImage.path)), // 원본 이미지 표시
      ),
    );
  }
}