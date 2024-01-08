import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:neo_finance/controllers/add_lesson_controller.dart';
import 'package:neo_finance/google_sheet_provider.dart';
import 'package:neo_finance/models/lesson.dart';

import 'package:get/get.dart';

import '../constants/colors.dart';
import '../controllers/theme_controller.dart';
import '../database_provider.dart';
import '../widgets/input_field.dart';

class AddLessonScreen extends StatelessWidget {
  AddLessonScreen({Key? key}) : super(key: key);

  final AddLessonController _addLessonController =
      Get.put(AddLessonController());

  final _themeController = Get.find<ThemeController>();

  final TextEditingController _hourController = TextEditingController(text: '1');
  final TextEditingController _amountController = TextEditingController();

  final DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    _addLessonController.changeLessonType(LessonModel.TYPE_TEACHER);
    return Obx(() {
      return Scaffold(
        appBar: _appBar(),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              InputField(
                hint: _addLessonController.selectedDate.isNotEmpty
                    ? _addLessonController.selectedDate
                    : DateFormat("dd.MM.yyyy").format(now),
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
                hint: _addLessonController.selectedTeacher.isNotEmpty
                    ? _addLessonController.selectedTeacher
                    : _addLessonController.teachers[0],
                label: 'Учитель',
                widget: IconButton(
                    onPressed: () => _showDialog(context, true),
                    icon: Icon(
                      Icons.keyboard_arrow_down_sharp,
                    )),
              ),
              InputField(
                hint: _addLessonController.selectedName.isNotEmpty
                    ? _addLessonController.selectedName
                    : _addLessonController.lessonNames[0],
                label: 'Предмет',
                widget: IconButton(
                    onPressed: () => _showDialog(context, false),
                    icon: Icon(
                      Icons.keyboard_arrow_down_sharp,
                    )),
              ),
              InputField(
                hint: '1',
                label: 'Часы',
                controller: _hourController,
                isAmount: true,
              ),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Стоимость'),
              ),
            ])),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () => _addLesson(),
          child: Icon(
            Icons.add,
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
                  _amountController.text = (1000*i).toString();
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
          .updateSelectedDate(DateFormat.yMd().format(pickerDate));
    }
  }

  _addLesson() async {
    final LessonModel lessonModel = LessonModel(
      amount: _amountController.text.isEmpty
          ? null
          : double.parse(_amountController.text),
      date: DateFormat('dd.MM.yyyy').format(DateTime.now()),
      name: _addLessonController.selectedName.isNotEmpty ?
      _addLessonController.selectedName : _addLessonController.lessonNames[0],
      teacher: _addLessonController.selectedTeacher.isNotEmpty
          ? _addLessonController.selectedTeacher
          : _addLessonController.teachers[0],
      student: _addLessonController.selectedStudent,
      type: _addLessonController.lessonType,
      hours: int.tryParse(_hourController.text),
      comment: '',
      //date: _addTransactionController.selectedDate,
    );
    if (await GoogleSheetsIntegration.addLessonToGoogleSheets(lessonModel)) {
      lessonModel.status = '1';
    }
    await DatabaseProvider.insertLesson(lessonModel);
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
