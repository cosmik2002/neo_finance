import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neo_finance/controllers/add_lesson_controller.dart';
import 'package:neo_finance/screens/add_lesson_screen.dart';
import 'package:neo_finance/widgets/lessons_list.dart';
import '../constants/colors.dart';
import '../controllers/add_transaction_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/theme_controller.dart';
import '../widgets/expense_list.dart';
import 'add_transaction_screen.dart';
import 'add_transaction_screen2.dart';

class HomeScreen extends StatelessWidget {
  final HomeController _homeController = Get.put(HomeController());
  final AddTransactionController _addTransactionController =
      Get.put(AddTransactionController());
  final AddLessonController _addLessonController = Get.put(AddLessonController());
  // final _themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context);
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            _homeController.tabIndexSet(tabController.index);
          }
        });
        return Obx(() {
          return Scaffold(
              bottomNavigationBar: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.money)),
                  Tab(icon: Icon(Icons.play_lesson)),
                  Tab(icon: Icon(Icons.directions_bike)),
                ],
              ),
/*
            appBar: AppBar(
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.money)),
                  Tab(icon: Icon(Icons.play_lesson)),
                  Tab(icon: Icon(Icons.directions_bike)),
                ],
              ),
            ),
*/
            body: TabBarView(children: [
              Center(child: ExpenseList()),
              Center(child: LessonsList()),
              Center(child: Text("bike"))
            ]),
            floatingActionButton: _bottomButtons(_homeController.tabIndex),
          );
        });
      }),
    );
  }

  Widget _bottomButtons(idx) {
    return idx == 0
        ? FloatingActionButton(
            backgroundColor: primaryColor,
            onPressed: () async {
              await _addTransactionController.updateOperationsButtons();
              await _addTransactionController.updateContragents();
              await Get.to(() => AddTransactionScreen2());
              _homeController.getTransactions();
            },
            child: const Icon(
              Icons.add,
            ),
          )
        : FloatingActionButton(
            shape: StadiumBorder(),
            onPressed: () async {
              await _addLessonController.updateTeachers();
              await _addLessonController.updateLessonNames();
              await Get.to(() => AddLessonScreen());
              _homeController.getLessons();
            },
            backgroundColor: Colors.redAccent,
            child: Icon(
              Icons.edit,
              size: 20.0,
            ),
          );
  }
}
