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
  @HiveField(3)
  String? rollId;
  @HiveField(4)
  String? dpt;
  @HiveField(5)
  String? session;

  StudentModel({
    this.name,
    this.img,
    this.faceData,
    this.rollId,
    this.dpt,
    this.session,
  });
}
