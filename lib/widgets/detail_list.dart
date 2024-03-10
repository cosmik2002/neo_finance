import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/itog_controller.dart';

class DetailList extends StatelessWidget {
  final _itogController = Get.find<ItogController>();

  // (String, String) itog_key;

  // DetailList((String, String) this.itog_key, {Key? key}):super(key:key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.separated(
          itemCount: _itogController.detail.length,
          itemBuilder: (BuildContext context, int index) {
            // var key = _itogController.itog.keys.elementAt(index);
            return ListTile(
                title: Row(children: [
                  Text(_itogController.detail[index]['date']+" "+_itogController.detail[index]['from']+" "+_itogController.detail[index]['to']+" "+_itogController.detail[index]['amount'].toString()),
                ]),
              subtitle: Row(children: [
                Text(_itogController.detail[index]['operation']+" "+_itogController.detail[index]['comment']),
              ]),
              onTap: ()=> _itogController.is_showing_detail=false,
            dense: true,);
          },
          separatorBuilder: (c, i) => const Divider(height: 0),
        ));
  }
}