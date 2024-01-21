import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:neo_finance/controllers/add_lesson_controller.dart';
import 'package:neo_finance/google_sheet_provider.dart';
import 'package:neo_finance/models/lesson.dart';

import 'package:get/get.dart';

import '../constants/colors.dart';
import '../controllers/home_controller.dart';
import '../controllers/theme_controller.dart';
import '../database_provider.dart';
import '../widgets/input_field.dart';

class AddLessonScreen extends StatelessWidget {
  AddLessonScreen({Key? key}) : super(key: key);

  final AddLessonController _addLessonController =
      Get.find<AddLessonController>();
  final HomeController _homeController = Get.find<HomeController>();

  final _themeController = Get.find<ThemeController>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _hourController = TextEditingController(text: '1');
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _teacherController = TextEditingController();
  final TextEditingController _lessonController = TextEditingController();

  final DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    _addLessonController.changeLessonType(LessonModel.TYPE_TEACHER);
    return Obx(() {
      _teacherController.text = _addLessonController.selectedTeacher;
      _lessonController.text = _addLessonController.selectedName;
      _dateController.text = _addLessonController.selectedDate.isNotEmpty
          ? _addLessonController.selectedDate
          : DateFormat("dd.MM.yyyy").format(now);
      _amountController.text = _addLessonController.amount.toString();
      _hourController.text = _addLessonController.hour.toString();

      return Scaffold(
        appBar: _appBar(),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              InputField(
                controller: _dateController ,
                label: 'Дата',
                widget: IconButton(
                  onPressed: () => _getDateFromUser(context),
                  icon: Icon(
                    Icons.calendar_month_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
              InputField(
                controller: _teacherController,
                label: 'Учитель',
                widget: IconButton(
                    onPressed: () => _showDialog(context, true),
                    icon: Icon(
                      Icons.keyboard_arrow_down_sharp,
                    )),
                onChanged: (data){
                  _addLessonController.updateSelectedTeacher(data);
                },
              ),
              InputField(
                controller: _lessonController,
                label: 'Предмет',
                widget: IconButton(
                    onPressed: () => _showDialog(context, false),
                    icon: Icon(
                      Icons.keyboard_arrow_down_sharp,
                    )),
                onChanged: (data){
                  _addLessonController.updateSelectedName(data);
                },
              ),
              InputField(
                label: 'Часы',
                controller: _hourController,
                isAmount: true,
                onChanged: (data){
                  _addLessonController.updateHour(int.parse(data));
                },

              ),
              InputField(
                controller: _amountController,
                isAmount: true,
                label: 'Стоимость',
                onChanged: (data){
                  _addLessonController.updateAmount(double.parse(data));
                },
              ),
            ])),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () => _addLesson(),
          child: Icon(
            _addLessonController.id>=0 ? Icons.edit : Icons.add,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    });
  }

  _showDialog(BuildContext context, bool isTeachers) {
    Get.defaultDialog(
      title: isTeachers ? "Преподаватель" : "Предмет",
      content: SizedBox(
        width: MediaQuery.of(context).size.width * .7,
        height: MediaQuery.of(context).size.height * .4,
        child: ListView.builder(
          itemCount:
              isTeachers ? _addLessonController.teachers.length : _addLessonController.lessonNames.length,
          itemBuilder: (context, i) {
            final data = isTeachers ? _addLessonController.teachers[i] : _addLessonController.lessonNames[i];
            return ListTile(
              onTap: () {
                isTeachers
                    ? _addLessonController.updateSelectedTeacher(data)
                    : _addLessonController.updateSelectedName(data);
                if(isTeachers){
                  // _amountController.text = (1000*i).toString();
                }
                Get.back();
              },
              title: Text(data),
            );
          },
        ),
      ),
    );
  }

  _getDateFromUser(BuildContext context) async {
    DateTime? pickerDate = await showDatePicker(
        context: context,
        firstDate: DateTime(2012),
        initialDate: DateTime.now(),
        lastDate: DateTime(2122));

    if (pickerDate != null) {
      _addLessonController
          .updateSelectedDate(DateFormat("dd.MM.yyyy").format(pickerDate));
    }
  }

  _addLesson() async {
    final LessonModel lessonModel = LessonModel(
      amount: _amountController.text.isEmpty
          ? null
          : double.parse(_amountController.text),
      date: _addLessonController.selectedDate,
      name: _lessonController.text,
      teacher: _teacherController.text,
      student: _addLessonController.selectedStudent,
      type: _addLessonController.lessonType,
      hours: int.tryParse(_hourController.text),
      comment: '',
    );

    if(_addLessonController.id >=0) {
      lessonModel.status = null;
      lessonModel.id = _addLessonController.id;
      await DatabaseProvider.updateLesson(lessonModel, _addLessonController.id);
      GoogleSheetsIntegration.updateLessonToGoogleSheets(lessonModel, _addLessonController.row_number).then(
          (value) {
            if(value==0) {
              lessonModel.status = '1';
              _homeController.updateLesson(_addLessonController.idx, lessonModel);
            }
          }
      );
    } else {
      await DatabaseProvider.insertLesson(lessonModel);
      var id = await DatabaseProvider.getInsrtedId();
      lessonModel.id = id;
      _homeController.lessons.add(lessonModel);
      int idx = _homeController.lessons.length - 1;
      GoogleSheetsIntegration.addLessonToGoogleSheets(
          lessonModel).then((value) {
        lessonModel.status = '1';
        lessonModel.row_number = value;
        _homeController.updateLesson(idx, lessonModel);
      });
    }
    Get.back();
  }

  _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text(
        'Add Lesson',
        style: TextStyle(color: _themeController.color),
      ),
      leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: _themeController.color)),
    );
  }
}
