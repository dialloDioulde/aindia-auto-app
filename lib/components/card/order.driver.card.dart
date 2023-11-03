/**
 * @created 01/11/2023 - 17:02
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class OrderDriver extends StatefulWidget {
  List data = [];

  OrderDriver({required this.data, Key? key}) : super(key: key);

  @override
  _OrderDriverState createState() => _OrderDriverState();
}

class _OrderDriverState extends State<OrderDriver> {
  List driverPositions = [];

  Constants constants = Constants();

  @override
  void initState() {
    super.initState();
    _datesConfiguration();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void _datesConfiguration() async {
    tz.initializeTimeZones();
    initializeDateFormatting("fr_FR", null);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget cardTemplate(element) {
    print(element);
    final order = element['order'];
    final driverPosition = element['driverPosition'];
    final driver = element['driverPosition']['driver'];

    return Card(
        margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        child: Text(
                      'Nom',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    )),
                    Flexible(
                        child: Text(
                      'DIALLO Mamadou',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        child: Text(
                      'Statut',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    )),
                    Flexible(
                        child: Text(
                      'Disponible',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.green,
                      ),
                    )),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        child: Text(
                      'Prix',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    )),
                    Flexible(
                        child: Text(
                      element['price'].toString() + ' F CFA',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    )),
                  ],
                ),
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
                      element['dFOSourceLocation'].toString() + ' KM',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    )),
                  ],
                ),
              ]),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: widget.data.length,
          itemBuilder: (BuildContext context, int index) {
            return cardTemplate(widget.data[index]);
          },
        )
      ],
    );
  }
}