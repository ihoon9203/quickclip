import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quick_clip/provider/analysis_provider.dart';
import 'package:quick_clip/utils/format.dart';
import 'package:quick_clip/utils/stylesheet.dart';
import 'package:quick_clip/view/analysis/analysis_screen.dart';

class ClipRecordCard extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> record;
  final Function onDelete;
  const ClipRecordCard({super.key, required this.imagePath, required this.record, required this.onDelete});

  @override
  State<ClipRecordCard> createState() => _ClipRecordCardState();
}

class _ClipRecordCardState extends State<ClipRecordCard> {
  String path = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setPath();
    });
  }

  void setPath() async {
    Directory directory = await getApplicationDocumentsDirectory();
    setState(() {
      path = directory.path;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    String originImage = widget.record['originImagePath'].toString();
    String croppedImage = widget.record['croppedImagePath'].toString();
    String texts = widget.record['texts'].join(' ');
    double cropWidth = widget.record.containsKey('cropWidth') ? widget.record['cropWidth'] : -1;
    double cropLength = widget.record.containsKey('cropLength') ? widget.record['cropLength'] : -1;
    int timestamp = widget.record['timestamp'];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            // builder: (context) => AnalysisScreen(image: File(croppedImage), textlist: texts.split(' '), originImagePath: record['originImagePath'].toString(), croppedImagePath: croppedImage,),
            builder: (context) => AnalysisScreen(
              image: File('$path/$croppedImage'), 
              textlist: texts.split(' '),
              originImagePath: originImage,
              croppedImagePath: croppedImage, 
              cropWidth: cropWidth, 
              cropHeight: cropLength, 
              timestamp: timestamp,
              isNotStored: false,
            ),
          ),
        );
      },
      child: Card(
        color: Stylesheet.accentColor2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12), 
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.file(
                  File('$path/$croppedImage'),
                  fit: BoxFit.cover, // 이미지의 비율을 유지하면서 컨테이너에 맞게 조정
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        CupertinoIcons.photo,
                        color: Colors.white70,
                        size: 50,
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timestamp.toString().toFormattedDate(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      texts,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                onTap: () {
                  widget.onDelete();
                },
                child: const Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: Colors.redAccent,
                ),
              )
            )
          ],
        )
      )
    );
  }
}