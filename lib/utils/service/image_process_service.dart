import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:quick_clip/provider/analysis_provider.dart';
import 'package:quick_clip/utils/stylesheet.dart';

class CropImageResponse {
  final String originPath;
  final String croppedPath;

  CropImageResponse({required this.originPath, required this.croppedPath});
}

class ImageProcessService {
  static final ImageProcessService _instance = ImageProcessService._internal();
  // private constructor
  ImageProcessService._internal();

  // Factory constructor로 외부에서 접근할 때 동일한 인스턴스를 반환
  factory ImageProcessService() {
    return _instance;
  }

  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);

  Future<List<String>> analyzeText(String originPath, String croppedPath,) async {
    final RecognizedText recognizedText = await _textRecognizer.processImage(InputImage.fromFilePath(croppedPath));
    List<String> textlist = [];
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        for (TextElement element in line.elements) {
          // Same getters as TextBlock
          textlist.add(element.text);
        }
      }
    }
    return textlist;
  }


   Future<CropImageResponse?> pickImageFromCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    
    if (image == null) {
      return null;
    }
     CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: null,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '분석할 영역을 선택해 주세요',
          toolbarColor: Stylesheet.accentColor,
          toolbarWidgetColor: Colors.white,
          aspectRatioPresets: [CropAspectRatioPreset.ratio5x3],
          lockAspectRatio: false,
          hideBottomControls: true,
          initAspectRatio: CropAspectRatioPreset.ratio5x3,

        ),
        IOSUiSettings(
          title: '분석할 영역을 선택해 주세요',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
      ],
    );
    if (croppedFile == null) {
      return null;
    } else {
      return CropImageResponse(originPath: image.path, croppedPath: croppedFile.path);
      
    }
  }

  Future<CropImageResponse?> cropImage(String sourcePath) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: null,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '분석할 영역을 선택해 주세요',
          toolbarColor: Stylesheet.accentColor,
          toolbarWidgetColor: Colors.white,
          aspectRatioPresets: [CropAspectRatioPreset.ratio5x3],
          lockAspectRatio: false,
          hideBottomControls: true,
          initAspectRatio: CropAspectRatioPreset.ratio5x3,
        ),
        IOSUiSettings(
          title: '분석할 영역을 선택해 주세요',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
      ],
    );
    if (croppedFile == null) {
      return null;
    } else {
      return CropImageResponse(originPath: sourcePath, croppedPath: croppedFile.path);
    }
  }
}