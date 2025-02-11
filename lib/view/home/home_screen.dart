import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:quick_clip/provider/analysis_provider.dart';
import 'package:quick_clip/utils/service/image_process_service.dart';
import 'package:quick_clip/utils/service/shared_preference_service.dart';
import 'package:quick_clip/utils/stylesheet.dart';
import 'package:quick_clip/view/analysis/analysis_screen.dart';
import 'package:quick_clip/view/camera/crop_screen.dart';
import 'package:quick_clip/view/common/loading_screen.dart';
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
    CropImageResponse? response = await ImageProcessService().pickImageFromCamera();
    if (response == null) {
      return;
    } else {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => LoadingScreen(originImagePath: response.originPath, croppedImagePath: response.croppedPath)
        )
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
                'Quick Clip',
                style: TextStyle(
                  fontSize: 50,
                  color: Colors.white
                ),
                textAlign: TextAlign.center,
              ),
            ),TextButton(
                onPressed: () => throw Exception(),
                child: const Text("Throw Test Exception"),
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
                  Text('recent_records'.tr(), style: TextStyle(color: Colors.white, fontSize: 20)),
                  const Spacer(),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () { 
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const ClipRecordListScreen()
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text('see_more'.tr(), style: const TextStyle(color: Colors.white, fontSize: 20)),
                        const Icon(CupertinoIcons.chevron_right, color: Colors.white)
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
                  imagePath: provider.records[index]['originImagePath'] ?? '', 
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
