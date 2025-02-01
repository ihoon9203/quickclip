
// import 'dart:io';

// import 'package:objectbox/objectbox.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:quick_clip/model/data_analysis_model.dart';

// class PersistentDataService {
//   late final Store _store;
//   late final Box<DataAnalysisModel> _box;

//   static late PersistentDataService _instance;

//   PersistentDataService._internal();

//   static Future<PersistentDataService> getInstance() async {
//     if (_instance == null) {
//       final appDocDir = await getApplicationDocumentsDirectory();
//       final storeDirectory = Directory('${appDocDir.path}/objectbox');
//       _instance = PersistentDataService._internal();
//       _instance._store = await openStore(directory: storeDirectory.path);
//       _instance._box = _instance._store.box<DataAnalysisModel>();
//     }
//     return _instance;
//   }
// }