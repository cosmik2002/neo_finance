import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:neo_finance/controllers/itog_controller.dart';
import 'package:neo_finance/widgets/detail_list.dart';
import 'package:neo_finance/widgets/itog_list.dart';

class ItogScreen extends StatelessWidget {
  final _itogController = Get.put(ItogController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
    if (!_itogController.is_showing_detail) {
      return ItogList();
    } else {
      return DetailList();
    }
    });
  }
}
