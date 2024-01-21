import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:neo_finance/models/lesson.dart';
import '../database_provider.dart';

class AddLessonController extends GetxController {
  int id = -1;
  int idx=-1;
  RxBool _isInAsyncCall = false.obs;
  int? row_number;
  final Rx<String> _lessonType = ''.obs;
  final Rx<String> _selectedDate = DateFormat("dd.MM.yyyy").format(DateTime.now()).obs;
  final Rx<String> _selectedName = Rx<String>('');
  final Rx<String> _selectedTeacher = Rx<String>('');
  final Rx<String> _selectedStudent = ''.obs;
  final Rx<int> _hour = 0.obs;
  final Rx<double> _amount = 0.0.obs;
  // DateFormat('hh:mm a').format(DateTime.now()).obs;
  final Rx<String> _selectedImage = Rx<String>('');
  final Rx<List<String>> _lessonNames = Rx<List<String>>(["Вокал", "Керамика"]);
  final Rx<List<String>> _teachers = Rx<List<String>>([]);

  bool get isInAsyncCall => _isInAsyncCall();
  set isInAsyncCall(bool v) => _isInAsyncCall(v);
  String get selectedDate => _selectedDate.value;
  String get selectedStudent => _selectedStudent.value;
  String get selectedName => _selectedName.value;
  String get selectedTeacher => _selectedTeacher.value;
  String get selectedImage => _selectedImage.value;
  int get hour => _hour.value;
  double get amount => _amount.value;

  String get lessonType => _lessonType.value;
  List<String> get lessonNames => _lessonNames.value;
  List<String> get teachers => _teachers.value;

  changeLessonType(String tt) => _lessonType.value = tt;
  updateSelectedName(String category) => _selectedName.value = category;
  updateSelectedTeacher(String from) => _selectedTeacher.value = from;
  updateHour(int from) => _hour.value = from;
  updateAmount(double from) => _amount.value = from;

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

  loadLesson([LessonModel? lesson, int idx=-1]) {
    if (lesson == null) {
      id = -1;
      this.idx = -1;
      _selectedDate.value = DateFormat("dd.MM.yyyy").format(DateTime.now());
      _selectedName.value = '';
      _selectedTeacher.value = '';
      _amount.value = 0;
      _hour.value = 0;
      return;
    }
    id = lesson.id!;
    this.idx = idx;
    _selectedDate.value = lesson.date ?? '';
    _selectedName.value = lesson.name ?? '';
    _selectedTeacher.value = lesson.teacher ?? '';
    _amount.value = lesson.amount ?? 0;
    _hour.value = lesson.hours ?? 0;
    row_number = lesson.row_number;
  }

  updateSelectedImage(String path) {
    _selectedImage.value = path;

    Get.back();
  }
}
