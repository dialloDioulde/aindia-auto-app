/**
 * @created 10/11/2023 - 14:24
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:flutter/cupertino.dart';

class OrderDataModel extends ChangeNotifier {
  List _orderDataList = [];

  List get orderDataList => _orderDataList;

  setOrderDataList(List list, {bool notify = true}) {
    _orderDataList = list;
    if (notify) notifyListeners();
  }

  OrderDataModel getOrderDataByIndex(int index) => _orderDataList[index];

  int get orderDataListLength => _orderDataList.length;
}
