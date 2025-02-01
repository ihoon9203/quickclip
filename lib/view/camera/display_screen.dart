import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quick_clip/provider/analysis_provider.dart';
import 'package:quick_clip/service/shared_preference_service.dart';
import 'package:quick_clip/view/analysis/analysis_screen.dart';

class DisplayScreen extends StatefulWidget {
  final String imagePath;
  final double width;
  final double height;

  const DisplayScreen({super.key, required this.imagePath, this.width = -1, this.height = -1});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  final _controller = CropController();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
  Uint8List? _croppedData;
  bool _isCropping = false;
  InputImage? _inputImage;
  File? _file;
  double width = 0;
  double height = 0;

  double widthToSave = 0;
  double heightToSave = 0;

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getImageSize();
  }

  void getImageSize() async {
    // 만약 크롭 영역이 지정되지 않았다면 기본 영역 지정, 아니면 주어진 영역 사용용
    if (widget.width > 0 && widget.height > 0) {
      setState(() {
        width = widget.width;
        height = widget.height;
        widthToSave = width;
        heightToSave = height;
      });
    } else {
      final File imageFile = File(widget.imagePath);
      final bytes = await imageFile.readAsBytes();
      final image = await decodeImageFromList(bytes);
      setState(() {
        width = image.width.toDouble() / 2;
        height = image.height.toDouble() / 2;
        widthToSave = width;
        heightToSave = height;
      });
    }
    
    print('initial width: $width, height: $height');
  } 

  void processImage(InputImage inputImage) async {
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    String text = recognizedText.text;
    List<String> textlist = [];
    for (TextBlock block in recognizedText.blocks) {
      final Rect rect = block.boundingBox;
      final List<Point<int>> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<String> languages = block.recognizedLanguages;
      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        for (TextElement element in line.elements) {
          // Same getters as TextBlock
          textlist.add(element.text);
        }
      }
    }
    var provider = Provider.of<AnalysisProvider>(context, listen: false);
    provider.setAnalyzedTexts(textlist);
    provider.getRecords();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisScreen(
          textlist: textlist, 
          image: _file!, 
          originImagePath: widget.imagePath, 
          croppedImagePath: _file!.path,
          cropWidth: widthToSave,
          cropHeight: heightToSave,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          isNotStored: true,
        ),
      ),
    );
  }

  Future<File> saveCroppedImage(Uint8List croppedData) async {
    // Get the directory where images can be stored
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/cropped_image.png';

    // Create a file and write the cropped data to it
    final file = File(filePath);
    await file.writeAsBytes(croppedData);

    return file;  // Return the path to the saved file
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body:Stack(
        children: [
          Crop(
            controller: _controller,
            image: File(widget.imagePath).readAsBytesSync(),
            initialRectBuilder: InitialRectBuilder.withArea(
              Rect.fromCenter(center: Offset(width, height), width: width, height: height),
            ),
            onCropped: (result) async {
            print('Cropped');
            switch (result) {
              case CropSuccess(:final croppedImage):
                _croppedData = croppedImage;
                _file = await saveCroppedImage(_croppedData!);
                print('Cropping...');
                if (_croppedData == null) return;
                setState(() {
                  _inputImage = InputImage.fromFile(_file!); // Cropped 파일이 아닌 원본 파일 사용
                });
                processImage(_inputImage!);
                break;
              case CropFailure(:final cause):
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error'),
                    content: Text('Failed to crop image: $cause'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK')
                      ),
                    ],
                  ),
                );
                break;
            }
            setState(() => _isCropping = false);
          },
          onMoved: (rect1, rect2) {
            
          },

          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  _controller.crop();
                },
                child: Container(
                  height: 40,
                  width: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 0,
                        spreadRadius: 2,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isCropping
                      ? const CircularProgressIndicator()
                      : const Text(
                          '텍스트 추출',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                      )
                  ),
                )
              )
            ),
          ),
        ]
      ),
    );
  }
}