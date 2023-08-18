import 'package:hive/hive.dart';
part 'student.g.dart';

@HiveType(typeId: 1)
class Student {
  @HiveField(0, defaultValue: 555)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final EyesColor eyesColor;
  Student({
    required this.id,
    required this.name,
    required this.eyesColor,
  });

  @override
  String toString() {
    return "$id - $name - $eyesColor";
  }
}

@HiveType(typeId: 2)
enum EyesColor {
  @HiveField(0, defaultValue: true)
  BLACK,
  @HiveField(1)
  BLUE,
  @HiveField(2)
  GREEN
}
