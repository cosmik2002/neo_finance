import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../database_provider.dart';

class AddLessonController extends GetxController {
  final Rx<String> _lessonType = ''.obs;
  final Rx<String> _selectedDate = DateFormat("dd.MM.yyyy").format(DateTime.now()).obs;
  final Rx<String> _selectedName = Rx<String>('');
  final Rx<String> _selectedTeacher = Rx<String>('');
  final Rx<String> _selectedStudent = ''.obs;
  // DateFormat('hh:mm a').format(DateTime.now()).obs;
  final Rx<String> _selectedImage = Rx<String>('');
  final Rx<List<String>> _lessonNames = Rx<List<String>>(["Вокал", "Керамика"]);
  final Rx<List<String>> _teachers = Rx<List<String>>([]);

  String get selectedDate => _selectedDate.value;
  String get selectedStudent => _selectedStudent.value;
  String get selectedName => _selectedName.value;
  String get selectedTeacher => _selectedTeacher.value;
  String get selectedImage => _selectedImage.value;

  String get lessonType => _lessonType.value;
  List<String> get lessonNames => _lessonNames.value;
  List<String> get teachers => _teachers.value;

  changeLessonType(String tt) => _lessonType.value = tt;
  updateSelectedName(String category) => _selectedName.value = category;
  updateSelectedTeacher(String from) => _selectedTeacher.value = from;

  updateSelectedDate(String date) => _selectedDate.value = date;
  updateSelectedStudent(String to) => _selectedStudent.value = to;

  updateTeachers() async {
    List<Map<String, dynamic>> teachers =
    await DatabaseProvider.queryTeachers();
    _teachers.value = List.generate(teachers.length, (index) {
      return teachers[index]['name'];
    });
  }

  updateLessonNames() async {
    List<Map<String, dynamic>> lessonNames =
    await DatabaseProvider.queryLessonNames();
    _lessonNames.value = List.generate(lessonNames.length, (index) {
      return lessonNames[index]['name'];
    });
  }

  updateSelectedImage(String path) {
    _selectedImage.value = path;

    Get.back();
  }
}
