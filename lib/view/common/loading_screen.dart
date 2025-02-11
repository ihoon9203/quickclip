import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quick_clip/utils/service/image_process_service.dart';
import 'package:quick_clip/utils/stylesheet.dart';
import 'package:quick_clip/view/analysis/analysis_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String originImagePath;
  final String croppedImagePath;

  const LoadingScreen({super.key, required this.originImagePath, required this.croppedImagePath});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {

  @override
  void initState() {
    super.initState();
    analyzeText();
    
  }

  void analyzeText() async {
    List<String> analyzedTexts = await ImageProcessService().analyzeText(widget.originImagePath, widget.croppedImagePath);
    if (!mounted) return;
    Navigator.pushReplacement(
      context, 
      CupertinoPageRoute(
        builder: (context) => 
          AnalysisScreen(
            textlist: analyzedTexts, 
            image: File(widget.croppedImagePath), 
            originImagePath: widget.originImagePath,
            croppedImagePath: widget.croppedImagePath,
            cropWidth: 0, 
            cropHeight: 0, 
            timestamp: DateTime.now().millisecondsSinceEpoch, 
            isNotStored: true
          )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Stylesheet.accentColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('analyzing_text'.tr(), style: const TextStyle(fontSize: 24, color: Colors.white),),
            const SizedBox(height: 20),
            LoadingAnimationWidget.staggeredDotsWave(
              color: Stylesheet.labelPrimaryColor, 
              size: 80
            )
          ],
        )
      
    ));
  }
}