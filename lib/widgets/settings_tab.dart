import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class SettingsTab extends StatelessWidget {
  final _homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
      return Column(
        children: [
          ElevatedButton(
              child: Text("Очистка БД", style: TextStyle(fontSize: 22)),
              onPressed:(){
                _homeController.clearBase();
              }
          ),
          ElevatedButton(
              child: Text("Обновить БД", style: TextStyle(fontSize: 22)),
              onPressed:(){
                _homeController.updateBase();
              }
          ),
          Text("lessons " + _homeController.lessons.length.toString()),
          Padding(padding: EdgeInsets.symmetric(vertical: 15)),
          //Text("transactions " + _homeController.myTransactions.length.toString()),
        ],
      );
  }

}