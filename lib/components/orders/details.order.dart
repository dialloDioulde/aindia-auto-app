/**
 * @created 10/11/2023 - 15:36
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:aindia_auto_app/models/driver-position/driver-position.model.dart';
import 'package:aindia_auto_app/models/order/order.model.dart';
import 'package:flutter/material.dart';
import '../../models/account.model.dart';

class DetailsOrder extends StatefulWidget {
  final Function(List) onDataReceived;
  List orderDataList = [];

  DetailsOrder(
      {required this.onDataReceived, required this.orderDataList, super.key});

  @override
  State<DetailsOrder> createState() => DetailsOrderState();
}

class DetailsOrderState extends State<DetailsOrder> {
  AccountModel accountModel = AccountModel('');
  OrderModel orderModel = OrderModel('');
  DriverPositionModel? driverPositionModel;

  Widget _orderDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                  child: Text(
                'Détails de la commande',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Flexible(
                  child: Text(
                'Départ :',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              )),
            ],
          ),
          Row(
            children: [
              Flexible(
                  child: Text(
                widget.orderDataList[0]['order']['sourceLocationText'],
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Flexible(
                  child: Text(
                'Déstination :',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              )),
            ],
          ),
          Row(
            children: [
              Flexible(
                  child: Text(
                widget.orderDataList[0]['order']['destinationLocationText'],
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Flexible(
                  child: Text(
                'Distance du trajet :',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              )),
            ],
          ),
          Row(
            children: [
              Flexible(
                  child: Text(
                widget.orderDataList[0]['order']['distance'].toString() + ' KM',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ],
          )
        ],
      ),
    );
  }

  _initializeData() async {}

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[_orderDetails()],
      ),
    );
  }
}
