import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:quick_clip/provider/analysis_provider.dart';
import 'package:quick_clip/service/shared_preference_service.dart';
import 'package:quick_clip/utils/stylesheet.dart';
import 'package:quick_clip/view/camera/camera_screen.dart';
import 'package:quick_clip/view/camera/display_screen.dart';
import 'package:quick_clip/view/home/clip_record_card.dart';
import 'package:quick_clip/view/home/clip_record_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
  }
  


  Future _pickImageFromCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);

    if (image == null) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DisplayScreen(imageXfile: image.path),
      ),
    );
  }

  void _onCameraTap() async {
    var result = await Permission.camera.request();
    if (result.isGranted) {
      var cameras = await availableCameras();
      var camera = cameras.first;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CameraScreen(camera: camera),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('카메라 권한이 필요합니다.'),
            content: const Text('카메라 권한을 허용해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('확인'),
              )
            ],
          );
        }
      );
    }
    
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var provider = Provider.of<AnalysisProvider>(context);
    return Scaffold(
      backgroundColor: Stylesheet.accentColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, 
          children: [
            const SizedBox(
              height: 120,
            ),
            const Center(
              child: Text(
                'CLIP LENS',
                style: TextStyle(
                  fontSize: 50,
                  fontStyle: FontStyle.italic,
                  color: Colors.white
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            GestureDetector(
              onTap: () {
               _pickImageFromCamera();
              },
              child: Container(
                height: width * 0.7,
                width: width * 0.7,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Stylesheet.accentColor2,
                      Stylesheet.accentColor,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight
                  ),
                  borderRadius: BorderRadius.circular(width *0.5),
                  border: Border.all(
                    color: Stylesheet.accentColor3,
                    width: 5,
                  )
                ),
                child: const Icon(
                  CupertinoIcons.photo_camera,
                  size: 150,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  const Text('최근 기록', style: TextStyle(color: Colors.white, fontSize: 20)),
                  const Spacer(),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () { 
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => ClipRecordListScreen()
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Text('더 보기', style: TextStyle(color: Colors.white, fontSize: 20)),
                        Icon(CupertinoIcons.chevron_right, color: Colors.white)
                      ]
                    )
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.records.length > 3 ? 3 : provider.records.length,
              itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ClipRecordCard(
                  imagePath: provider.records[index]['originImagePath'], 
                  record: provider.records[index],
                  onDelete: () {
                    provider.removeDataByTimestamp(provider.records[index][DataMapKey.timestamp.key]);
                  },
                )
              );
            }),
          ]
        )
      ),
    );
  }
}
