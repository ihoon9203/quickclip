import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_clip/provider/analysis_provider.dart';
import 'package:quick_clip/service/shared_preference_service.dart';
import 'package:quick_clip/utils/stylesheet.dart';
import 'package:quick_clip/view/home/clip_record_card.dart';

class ClipRecordListScreen extends StatefulWidget {
  const ClipRecordListScreen({super.key});

  @override
  State<ClipRecordListScreen> createState() => _ClipRecordListScreenState();
}

class _ClipRecordListScreenState extends State<ClipRecordListScreen> {
  late AnalysisProvider provider;
  @override
  void initState() {
    super.initState();
    provider = Provider.of<AnalysisProvider>(context, listen: false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Stylesheet.accentColor,
      appBar: AppBar(
        backgroundColor: Stylesheet.accentColor2,
        actions: [
          IconButton(
            onPressed: () {
              provider.clearAllData();
            },
            icon: Icon(Icons.delete_sweep),
          )
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return ClipRecordCard(
            imagePath: provider.records[index][DataMapKey.croppedImagePath.key], 
            record: provider.records[index], 
            onDelete: () {
              provider.removeDataByTimestamp(provider.records[index][DataMapKey.timestamp.key]);
            }
          );
        },
        itemCount: Provider.of<AnalysisProvider>(context).records.length,
      )
    );
  }
}