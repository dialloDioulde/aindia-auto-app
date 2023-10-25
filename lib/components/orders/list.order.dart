/**
 * @created 24/10/2023 - 20:15
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:flutter/cupertino.dart';

class ListOrder extends StatefulWidget {
  const ListOrder({super.key});

  @override
  State<ListOrder> createState() => OrderState();
}

class OrderState extends State<ListOrder> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
          child: Center(
              child: Center(
                child: Column(
                  children: <Widget>[
                    Text(
                      'Mes Commandes',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ],
                ),
              ))),
    );
  }
}
