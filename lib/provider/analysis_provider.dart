import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quick_clip/service/shared_preference_service.dart';

// 여기다 저장하면서 
class AnalysisProvider extends ChangeNotifier {
  List<String> _analyzedTexts = [];
  List<Map<String, dynamic>> _records = [];
  List<String> get analyzedTexts => _analyzedTexts;
  List<Map<String, dynamic>> get records => _records;

  void getRecords() async {
    _records = await SharedPreferenceService().getAllData();
    notifyListeners();
  }

  void setAnalyzedTexts(List<String> texts) {
    _analyzedTexts = texts;
  }

  List<String> getAnalyzedTexts() {
    return analyzedTexts;
  }

  //타이틀 - 이미지 분석 결과 저장
  void setData({required String originImagePath, required String croppedImagePath, required List<String> texts, required double cropWidth, required double cropLength}) async {
    
    var originImage = File(originImagePath);
    var croppedImage = File(croppedImagePath);

    // 이미지가 존재하지 않으면 저장하지 않음
    if (!await originImage.exists() && !await croppedImage.exists()) {
      return;
    }
    var directory = await getApplicationDocumentsDirectory();
    final String originFileName = 'origin_${DateTime.now().millisecondsSinceEpoch}.png';
    final String originPermanentPath = '${directory.path}/$originFileName';

    final String croppedFileName = 'cropped_${DateTime.now().millisecondsSinceEpoch}.png';
    final String croppedPermanentPath = '${directory.path}/$croppedFileName';

    var data = await SharedPreferenceService().saveData(originImagePath: originPermanentPath, croppedImagePath: croppedPermanentPath, texts: texts, cropWidth: cropWidth, cropLength: cropLength);
    _records.add(data);
    
    notifyListeners();
  }

  void removeData(String key) async {
    var data = await SharedPreferenceService().getData(key);
    if (data == null) {
      return;
    }
    int timestamp = data[DataMapKey.timestamp.key];
    _records.removeWhere((element) => element[DataMapKey.timestamp.key] == timestamp);
    SharedPreferenceService().removeData(key);
    notifyListeners();
  }

  void removeDataByTimestamp(int timestamp) {

    var record = _records.where((element) => element[DataMapKey.timestamp.key] == timestamp).first;
    SharedPreferenceService().removeData(record[DataMapKey.timestamp.key].toString());
    _records.removeWhere((element) => element[DataMapKey.timestamp.key] == timestamp);
    notifyListeners();
  }

  void clearAllData() async {
    for (var record in _records) {
      SharedPreferenceService().removeData(record[DataMapKey.timestamp.key].toString());
    }
    _records.clear();
    notifyListeners();

  }
}