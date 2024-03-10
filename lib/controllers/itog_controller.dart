import 'package:get/get.dart';
import 'package:neo_finance/models/itog.dart';

class ItogController extends GetxController {

  final Rx<Map<(String, String),Map<String, dynamic>>> _itog = Rx<Map<(String, String), Map<String, dynamic>>>({});
  final Rx<List<dynamic>> _detail = Rx<List<dynamic>>([]);
  final Rx<bool> _is_show_detail = false.obs;


  Map<(String, String),Map<String, dynamic>> get itog => _itog.value;
  List<dynamic> get detail => _detail.value;
  bool get is_showing_detail => _is_show_detail.value;
  set is_showing_detail(bool v) => _is_show_detail.value = v;
  @override
  Future<void> onInit() async {
    super.onInit();
    this._itog.value = await ItogDbModel().getItog();
  }

  getDetail(key) async {
    _detail.value = await ItogDbModel().getDetail(key);
  }
}