/**
 * @created 16/11/2023 - 21:17
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:flutter/material.dart';
import '../../models/account.model.dart';
import '../../services/order/order.service.dart';

class ProcessOrder extends StatefulWidget {
  final Function(int) onDataReceived;
  var orderDriverSelected;

  ProcessOrder(
      {required this.orderDriverSelected,
      required this.onDataReceived,
      super.key});

  @override
  State<ProcessOrder> createState() => ProcessOrderState();
}

class ProcessOrderState extends State<ProcessOrder> {
  AccountModel accountModel = AccountModel('');

  OrderService orderService = OrderService();

  Widget _orderDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                  child: Text(
                'Svp, veuillez patienter pendant que nous vous mettons en relation avec le chauffeur.',
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
                'Informations du chauffeur',
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Text(
                'Numéro Téléphone : ',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              )),
              Flexible(
                  child: Text(
                widget.orderDriverSelected['identity']['account']['phoneNumber']
                    .toString(),
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
                'Chauffeur :',
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
                widget.orderDriverSelected['identity']?['firstname'] +
                    ' ' +
                    widget.orderDriverSelected['identity']?['lastname'],
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Text(
                'Distance entre vous',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              )),
              Flexible(
                  child: Text(
                widget.orderDriverSelected['dFOSourceLocation'].toString() +
                    ' KM',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ],
          ),
          SizedBox(height: 14),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                  child: Text(
                'Détails de la commande',
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Text(
                'Prix :',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              )),
              Flexible(
                  child: Text(
                widget.orderDriverSelected['order']['price'].toString() +
                    'F CFA',
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
                widget.orderDriverSelected['order']['sourceLocationText'],
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
                widget.orderDriverSelected['order']['destinationLocationText'],
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Text(
                'Distance du trajet :',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              )),
              Flexible(
                  child: Text(
                widget.orderDriverSelected['order']['distance'].toString() +
                    ' KM',
                style: TextStyle(
                  fontSize: 16.0,
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

  Widget _cancelOrderButton() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Container(
        color: Colors.transparent,
        width: MediaQuery.of(context).size.width,
        child: ElevatedButton(
          child: Text(
            "ANNULER",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            _cancelOrder();
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(12),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  void _sendOrderToDriver() async {
    await orderService
        .sendOrderToDriver(widget.orderDriverSelected)
        .then((response) {
      print(response.statusCode);
      if (response.statusCode == 200) {
        //widget.onDataReceived(4);
      } else {
        _displayMessage('Erreur lors du traitement de la requête', Colors.red);
      }
    }).catchError((error) {
      print("sendOrderToDriver : $error");
      _displayMessage('Une erreur du server est survenue', Colors.red);
    });
  }

  _cancelOrder() async {
    final orderJson = {
      '_id': widget.orderDriverSelected['order']['_id'],
      'order': widget.orderDriverSelected['order']['order'],
    };
    await orderService.cancelOrder(orderJson);
    widget.onDataReceived(1);
  }

  _displayMessage(String messageContent, backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messageContent), backgroundColor: backgroundColor),
    );
  }

  _initializeData() async {
    _sendOrderToDriver();
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
        children: <Widget>[_orderDetails(), _cancelOrderButton()],
      ),
    );
  }
}
