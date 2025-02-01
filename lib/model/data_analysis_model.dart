import 'package:objectbox/objectbox.dart';

@Entity()
class DataAnalysisModel {
  @Id()
  int id;
  String originImagePath;
  String croppedImagePath;
  List<String> texts;
  
  DataAnalysisModel({
    this.id = 0,
    required this.originImagePath,
    required this.croppedImagePath,
    required this.texts,
  });
}