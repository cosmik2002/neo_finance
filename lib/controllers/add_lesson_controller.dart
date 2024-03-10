import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:neo_finance/models/lesson.dart';
import '../database_provider.dart';

class AddLessonController extends GetxController {
  int id = -1;
  int idx = -1;
  int? row_number;
  List<String> _origLessonNames = [];
  List<String> _origTeachers = [];
  final Rx<String> _lessonType = ''.obs;
  final Rx<String> _selectedDate =
      DateFormat("dd.MM.yyyy").format(DateTime.now()).obs;
  final Rx<String> _selectedName = Rx<String>('');
  final Rx<String> _selectedTeacher = Rx<String>('');
  final Rx<String> _selectedStudent = ''.obs;
  final Rx<String> _comment = ''.obs;
  final Rx<int> _hour = 1.obs;
  final Rx<double> _amount = 0.0.obs;

  // DateFormat('hh:mm a').format(DateTime.now()).obs;
  final Rx<String> _selectedImage = Rx<String>('');
  final Rx<List<String>> _lessonNames = Rx<List<String>>(["Вокал", "Керамика"]);
  final Rx<List<String>> _teachers = Rx<List<String>>([]);

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    updateLessonNames();
    updateTeachers();
    if (Get.arguments != null) {
      loadLesson(Get.arguments['lesson'], Get.arguments['idx']);
    } else {
      loadLesson();
    }
  }

  filerLessonNames(filter) {
    _lessonNames.value = _origLessonNames.where((element) => element.toLowerCase().contains(filter.toLowerCase())).toList();
  }

  filerTeachers(filter) {
    _teachers.value = _origTeachers.where((element) => element.toLowerCase().contains(filter.toLowerCase())).toList();
  }

  String get comment => _comment.value;
  set comment(v) => _comment(v);
  String get selectedDate => _selectedDate.value;
  set selectedDate(date) => _selectedDate.value = date;

  String get selectedStudent => _selectedStudent.value;
  set selectedStudent(val) => _selectedStudent.value = val;
  String get selectedName => _selectedName.value;
  set selectedName(val) => _selectedName.value = val;

  String get selectedTeacher => _selectedTeacher.value;
  set selectedTeacher(val) => _selectedTeacher.value = val;

  int get hour => _hour.value;
  set hour(v) => _hour.value = v;

  double get amount => _amount.value;

  set amount(double val) => _amount.value = val;

  String get lessonType => _lessonType.value;
  set lessonType(v) => _lessonType.value = v;

  List<String> get lessonNames => _lessonNames.value;

  List<String> get teachers => _teachers.value;

  updateTeachers() async {
    List<Map<String, dynamic>> teachers =
        await DatabaseProvider.queryTeachers();
    _origTeachers = List.generate(teachers.length, (index) {
      return teachers[index]['name'];
    });
    _teachers.value = _origTeachers;
  }

  updateLessonNames() async {
    List<Map<String, dynamic>> lessonNames =
        await DatabaseProvider.queryLessonNames();
    _origLessonNames = List.generate(lessonNames.length, (index) {
      return lessonNames[index]['name'];
    });
    _lessonNames.value = _origLessonNames;
  }

  loadLesson([LessonModel? lesson, int idx = -1]) {
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
