/**
 * @created 26/12/2023 - 18:02
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'dart:convert';

import 'package:aindia_auto_app/services/order-data/order-data.service.dart';
import 'package:flutter/material.dart';

import '../../models/account.model.dart';
import '../../services/order/order.service.dart';

class DriverOrder extends StatefulWidget {
  var orderId = "";

  DriverOrder({required this.orderId, super.key});

  @override
  State<DriverOrder> createState() => DriverOrderState();
}

class DriverOrderState extends State<DriverOrder> {
  AccountModel accountModel = AccountModel('');

  OrderDataService orderDataService = OrderDataService();
  OrderService orderService = OrderService();

  var orderData = null;
  var order = {};

  Widget _orderDetailsWidget() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                  child: Text(
                'Vous avez 45 secondes pour accepter la commande.',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ],
          ),
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
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              )),
            ],
          ),
          Row(
            children: [
              Flexible(
                  child: Text(
                order['sourceLocationText'],
                style: TextStyle(
                  fontSize: 18.0,
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
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              )),
            ],
          ),
          Row(
            children: [
              Flexible(
                  child: Text(
                order['destinationLocationText'],
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ],
          ),
          SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Text(
                'Distance du trajet :',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              )),
              Flexible(
                  child: Text(
                order['distance'].toString() + ' KM',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ],
          ),
          SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Text(
                'Prix :',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              )),
              Flexible(
                  child: Text(
                orderData['price'].toString() + ' F CFA',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _acceptOrderButtonWidget() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: ElevatedButton(
        child: Text(
          "ACCEPTER",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          _acceptOrder();
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(12),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _refuseOrderButtonWidget() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: ElevatedButton(
        child: Text(
          "REFUSER",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          _rejectOrder();
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(12),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buttonsWidget() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _acceptOrderButtonWidget(),
          _refuseOrderButtonWidget(),
        ],
      ),
    );
  }

  void _getOrderData() async {
    await orderDataService.getOrderData(widget.orderId).then((response) {
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        print('body = ${body}');
        setState(() {
          orderData = body;
          order = orderData?["order"];
          var driverPosition = orderData?["driverPosition"];
        });
      } else {
        _displayMessage('Erreur lors du traitement de la requête', Colors.red);
      }
    }).catchError((error) {
      _displayMessage('Une erreur du server est survenue', Colors.red);
    });
  }

  void _acceptOrder() async {
    await orderService
        .acceptOrder({'orderDataId': widget.orderId}).then((response) {
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        print("--------------------------------------------------------------");
        print("acceptOrder === ${body}");
        print("--------------------------------------------------------------");
      } else {
        _displayMessage('Erreur lors du traitement de la requête', Colors.red);
      }
    }).catchError((error) {
      _displayMessage('Une erreur du server est survenue', Colors.red);
    });
  }

  _rejectOrder() async {
    await orderService.rejectOrder(widget.orderId).then((response) {
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        print("--------------------------------------------------------------");
        print("rejectOrder === ${body}");
        print("--------------------------------------------------------------");
      } else {
        _displayMessage('Erreur lors du traitement de la requête', Colors.red);
      }
    }).catchError((error) {
      _displayMessage('Une erreur du server est survenue', Colors.red);
    });
  }

  _displayMessage(String messageContent, backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messageContent), backgroundColor: backgroundColor),
    );
  }

  _initializeData() async {
    if (widget.orderId != '') {
      _getOrderData();
    }
  }

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
        children: order["_id"] != null
            ? <Widget>[
                _orderDetailsWidget(),
                _buttonsWidget(),
              ]
            : [CircularProgressIndicator()],
      ),
    );
  }
}
