import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neo_finance/controllers/itog_controller.dart';
import 'package:neo_finance/widgets/detail_list.dart';

class ItogList extends StatelessWidget {
  final _itogController = Get.put(ItogController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.separated(
          itemCount: _itogController.itog.length,
          itemBuilder: (BuildContext context, int index) {
            var key = _itogController.itog.keys.elementAt(index);
            return ListTile(
                title: Row(children: [Container(
                 child: Text(key.$1+" "+key.$2),
                ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
                  Text(_itogController.itog[key]?['dt'].toString() ?? ''),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
                  Text(_itogController.itog[key]?['kt'].toString() ?? ''),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
                  Text(_itogController.itog[key]?['itog'].toString() ?? '')
                ]),
                onTap: () async {
                  await _itogController.getDetail(key);
                  _itogController.is_showing_detail = true;
                },
              dense: true,
            );
          },
          separatorBuilder: (c, i) => const Divider(height: 0),
        ));
  }
}