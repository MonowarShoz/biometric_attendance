import 'package:hive/hive.dart';
part 'student_model.g.dart';

@HiveType(typeId: 1)
class StudentModel {
  @HiveField(0)
  String? name;
  @HiveField(1)
  String? img;
  @HiveField(2)
  String? faceData;

  StudentModel({this.name, this.img, this.faceData});
}
