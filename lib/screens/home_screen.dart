import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:neo_finance/controllers/add_lesson_controller.dart';
import 'package:neo_finance/screens/add_lesson_screen.dart';
import 'package:neo_finance/screens/itog_screen.dart';
import 'package:neo_finance/widgets/lessons_list.dart';
import 'package:neo_finance/widgets/settings_tab.dart';
import '../constants/colors.dart';
import '../constants/entity_interface.dart';
import '../controllers/home_controller.dart';
import '../widgets/expense_list.dart';
import 'add_transaction_screen2.dart';

class HomeScreen extends StatelessWidget {
  final HomeController _homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    _homeController.errMsg.listen((p0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка получения из Google: $p0')));
    });
    return DefaultTabController(
      length: 5,
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context);
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            _homeController.tabIndexSet(tabController.index);
          }
        });
        return Obx(() {
          return Scaffold(
            appBar: _appBar(context),
              bottomNavigationBar: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.money)),
                  Tab(icon: Icon(Icons.play_lesson)),
                  Tab(icon: Icon(Icons.money)),
                  Tab(icon: Icon(Icons.ac_unit)),
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
              Center(child: ExpenseList(TransactionPreferences())),
              Center(child: LessonsList()),
              Center(child: ExpenseList(TransactionPreferences2())),
              Center(child: ItogScreen()),
              Center(child: SettingsTab())
            ]),
            floatingActionButton: _bottomButtons(_homeController.tabIndex),
          );
        });
      }),
    );
  }
  _appBar(context){
   return AppBar(
       systemOverlayStyle: SystemUiOverlayStyle.dark,
     title: const Text('NEO Finance'),
     actions: <Widget>[
       IconButton(
         icon: const Icon(Icons.add_alert),
         tooltip: 'Show Snackbar',
         onPressed: () {
           ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('This is a snackbar')));
         },
       ),
       IconButton(
         icon: const Icon(Icons.navigate_next),
         tooltip: 'Go to the next page',
         onPressed: () {
           Get.to(()=>
               Scaffold(
                 appBar: AppBar(
                   title: const Text('Next page'),
                 ),
                 body: const Center(
                   child: Text(
                     'This is the next page',
                     style: TextStyle(fontSize: 24),
                   ),
                 ),
               )
           );
         },
       ),
     ],
   );
  }

  Widget _bottomButtons(idx) {
    switch (idx){
      case 0:
        return FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () async {
            // await _addTransactionController.updateOperations();
            // await _addTransactionController.updateContragents();
            // _addTransactionController.loadTransaction();
            await Get.to(() => AddTransactionScreen2(TransactionPreferences()));
            // _homeController.getTransactions();
          },
          child: const Icon(
            Icons.add,
          ),
        );
      case 1:
        return FloatingActionButton(
          shape: StadiumBorder(),
          onPressed: () async {
            // await _addLessonController.updateTeachers();
            // await _addLessonController.updateLessonNames();
            // _addLessonController.loadLesson();
            await Get.to(() => AddLessonScreen());
            // _homeController.getLessons();
          },
          backgroundColor: Colors.redAccent,
          child: Icon(
            Icons.edit,
            size: 20.0,
          ),
        );
      case 2:
        return FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () async {
            // await _addTransactionController.updateOperations();
            // await _addTransactionController.updateContragents();
            // _addTransactionController.loadTransaction();
            await Get.to(() => AddTransactionScreen2(TransactionPreferences2()));
            // _homeController.getTransactions();
          },
          child: const Icon(
            Icons.add,
          ),
        );
      default:
        //заглушка
        return const Icon(
          Icons.add,
        );
    }
  }
}
