import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DataMapKey {
  originImagePath('originImagePath'),
  croppedImagePath('croppedImagePath'),
  texts('texts'),
  cropWidth('cropWidth'),
  cropLength('cropLength'),
  timestamp('timestamp');

  final String key;
  const DataMapKey(this.key);
}
class SharedPreferenceService {
  SharedPreferenceService.internal();

  static final SharedPreferenceService _instance = SharedPreferenceService.internal();

  factory SharedPreferenceService() => _instance;

  // static 메서드들
  Future<Map<String, dynamic>> saveData({
    required String originImagePath, 
    required String croppedImagePath, 
    required List<String> texts, 
    required double cropWidth, 
    required double cropLength
    }) async {
    var pref = await SharedPreferences.getInstance();
    int now = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> data = {
      'originImagePath': originImagePath,
      'croppedImagePath': croppedImagePath,
      'texts': texts,
      'cropWidth': cropWidth,
      'cropLength': cropLength,
      'timestamp': now
    };
    var jsonData = jsonEncode(data);
    pref.setString(now.toString(), jsonData);
    return data;
    
  }

  Future<Map<String, dynamic>?> getData(String key) async {
    var pref = await SharedPreferences.getInstance();
    var data = pref.getString(key);
    if (data == null) {
      return null;
    } else { 
      Map<String, dynamic> map = jsonDecode(data);
      return map;
    }
  }

  Future<void> removeData(String key) async {
    var pref = await SharedPreferences.getInstance();
    var directory = await getApplicationDocumentsDirectory();
    Map<String, dynamic>? dataMap = await getData(key);
    if (dataMap == null) {
      return;
    } else { // 이미지 삭제
      await deleteFile(dataMap[DataMapKey.originImagePath.key]);
      await deleteFile(dataMap[DataMapKey.croppedImagePath.key]);
      // if (dataMap.containsKey(DataMapKey.originImagePath.key)) {
      //   await File('${directory.path}/${dataMap[DataMapKey.originImagePath.key]}').delete();
      // }
      // if (dataMap.containsKey(DataMapKey.croppedImagePath.key)) {
      //   await File('${directory.path}/${dataMap[DataMapKey.croppedImagePath.key]}').delete();
      // }
    }
    await pref.remove(key);
  }

  Future<List<String>> getKeys() async {
    var pref = await SharedPreferences.getInstance();
    return pref.getKeys().toList();
  }

  Future<void> clear() async {
    var pref = await SharedPreferences.getInstance();
    pref.clear();
  }

  Future<List<Map<String, dynamic>>> getAllData() async {
    var pref = await SharedPreferences.getInstance();
    var keys = pref.getKeys();
    List<Map<String, dynamic>> dataList = [];
    for (var key in pref.getKeys()) {
      var data = pref.getString(key);
      if (data != null) {
        Map<String, dynamic> map = jsonDecode(data);
        dataList.add(map);
      }
    }
    return dataList;
  }

   Future<void> deleteFile(String path) async {
    var directory = await getApplicationDocumentsDirectory();

    final fullPath = join(directory.path, path);
    final file = File(fullPath);

    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('[$path] 파일 삭제 실패: $e');
      throw e; // 필요 시 호출부에서 처리
    }
  }
}