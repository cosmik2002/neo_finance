import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:neo_finance/controllers/add_lesson_controller.dart';
import 'package:neo_finance/database_provider.dart';
import 'package:neo_finance/models/lesson.dart';

import '../controllers/home_controller.dart';
import '../google_sheet_provider.dart';
import '../screens/add_lesson_screen.dart';

class LessonsList extends StatelessWidget {
  final _homeController = Get.find<HomeController>();
  // final _addLessonController = Get.find<AddLessonController>();
  // bool _isInAsyncCall = false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ModalProgressHUD(
        progressIndicator: const CircularProgressIndicator(),
        inAsyncCall: _homeController.isInAsyncCall,
        child: ListView.separated(
          itemCount: _homeController.lessons.length,
          separatorBuilder: (c, i) => const Divider(height: 0),
          itemBuilder: (context, i) {
            int idx = _homeController.lessons.length - i - 1;
            final lesson = _homeController.lessons[idx];
            final statusEmpty = lesson.status?.isEmpty ?? true;
            return ListTile(
              title: Row(
                children: [
                  Container(
                    width: 150.w,
                    child: Text('${lesson.name}'),
                  ),
                  Container(
                    width: 50.w,
                    child: Text(
                        '${lesson.type == LessonModel.TYPE_TEACHER ? lesson.teacher : lesson.student}'),
                  )
                ],
              ),
              subtitle: Row(
                children: [
                  Text('${lesson.date}'),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
                  Text('${lesson.hours}ч.'),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
                  Text(
                      '${lesson.amount ?? ''}${lesson.amount != null ? 'р.' : ''}'),
                ],
              ),
              dense: true,
              minLeadingWidth: 30,
              horizontalTitleGap: 0,
              leading: statusEmpty
                  ? const Icon(
                      Icons.cancel,
                      color: Colors.red,
                    )
                  : const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
              trailing: PopupMenuButton<int>(
                onSelected: (int? value) async {
                  if (value == 2) {
                    _homeController.deleteLesson(idx);
                  }
                  if (value == 3) {
                    _homeController.isInAsyncCall = true;
                    // await _addLessonController.updateTeachers();
                    // await _addLessonController.updateLessonNames();
                    var check = await GoogleSheetsIntegration.checkLessonToGoogleSheets(lesson, lesson.row_number!);
                    if(check) {
                      _homeController.isInAsyncCall = false;
                      // _addLessonController.loadLesson(lesson, idx);
                      await Get.to(() => AddLessonScreen(), arguments: {"lesson": lesson, 'idx': idx});
                      // _homeController.getLessons();
                    } else {
                      lesson.status = null;
                      _homeController.updateLesson(idx, lesson);
                      _homeController.isInAsyncCall = false;
                    }
                  }
                  if (value == 1) {
                    GoogleSheetsIntegration.addLessonToGoogleSheets(lesson)
                        .then((value) {
                      if (value>=0) {
                        lesson.status = '1';
                        lesson.row_number = value;
                        _homeController.updateLesson(idx, lesson);
                      }
                    });
                  }
                },
                itemBuilder: (BuildContext context) {
                  var items = <PopupMenuEntry<int>>[
                    const PopupMenuItem<int>(
                      value: 2,
                      child: Text('Удалить'),
                    ),
                  ];
                  if (statusEmpty) {
                    items.insert(
                        1,
                        const PopupMenuItem<int>(
                          value: 1,
                          child: Text('Синхронизировать'),
                        ));
                  }
                  if(lesson.row_number != null) {
                    items.insert(
                        1,
                        const PopupMenuItem<int>(
                          value: 3,
                          child: Text('Редактировать'),
                        ));
                  }
                  return items;
                },
              ),
            );
          },
        ),
      );
    });
  }
}
