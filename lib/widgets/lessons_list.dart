import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neo_finance/models/lesson.dart';

import '../controllers/home_controller.dart';

class LessonsList extends StatelessWidget {
  final _homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView.builder(
        itemCount: _homeController.lessons.length,
        itemBuilder: (context, i) {
          final lesson = _homeController.lessons[_homeController.lessons.length - i - 1];
          // final bool isIncome = lesson.type == 'Income' ? true : false;
          final text =
              '${lesson.date} ${lesson.type == LessonModel.TYPE_TEACHER ?  lesson.teacher : lesson.student} ${lesson.hours} ${lesson.amount}';
          // final formatAmount = '- $text';
          return Text(text);
/*        return lesson.date ==
            DateFormat.yMd().format(_homeController.selectedDate)
            ? GestureDetector(
          onTap: () async {
            await Get.to(() => EditTransactionScreen(tm: lesson));
            _homeController.getTransactions();
          },
          child: TransactionTile(
              lesson: lesson,
              formatAmount: formatAmount,
              isIncome: isIncome),
        )
            : SizedBox();*/
        },
      );
    });
  }
}
