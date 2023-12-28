/**
 * @created 03/11/2023 - 00:40
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'dart:convert';

import 'package:aindia_auto_app/components/drawers/nav.drawer.dart';
import 'package:aindia_auto_app/models/identity/identity.model.dart';
import 'package:aindia_auto_app/services/identity/identity.service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';

import '../../models/account.model.dart';
import '../../services/socket/websocket.service.dart';

class IdentityComponent extends StatelessWidget {
  IOWebSocketChannel channel = WebSocketService().setupWebSocket();

  IdentityComponent({channel, Key? key}) : super(key: key);

  static const String _title = 'Profile';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
          appBar: AppBar(
              centerTitle: true,
              title: const Text(_title),
              backgroundColor: Colors.green),
          body: IdentityStatefulWidget(
            channel: channel,
          ),
          backgroundColor: Colors.white),
    );
  }
}

class IdentityStatefulWidget extends StatefulWidget {
  IOWebSocketChannel channel = WebSocketService().setupWebSocket();

  IdentityStatefulWidget({channel, Key? key}) : super(key: key);

  @override
  State<IdentityStatefulWidget> createState() => _IdentityStatefulWidgetState();
}

class _IdentityStatefulWidgetState extends State<IdentityStatefulWidget> {
  AccountModel accountModel = AccountModel('');

  late TextEditingController _firstnameController = TextEditingController();
  late TextEditingController _lastnameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _formIsValid = false;
  bool _requestIsRunning = false;

  Widget _buildLastname() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: TextFormField(
        controller: _lastnameController,
        onChanged: (value) {
          _lastnameController.text = value;
          this._formKeyState();
        },
        obscureText: false,
        style: TextStyle(fontSize: 17),
        decoration: const InputDecoration(
          labelText: 'Nom',
          hintText: 'Votre nom...',
          labelStyle: TextStyle(
            fontSize: 17,
            color: Colors.black,
          ),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: TextInputType.text,
        validator: (value) => _textFieldValidation(value),
        onSaved: (value) {
          _lastnameController = value! as TextEditingController;
        },
      ),
    );
  }

  Widget _buildFirstname() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: TextFormField(
        controller: _firstnameController,
        onChanged: (value) {
          _firstnameController.text = value;
          this._formKeyState();
        },
        obscureText: false,
        style: TextStyle(fontSize: 17),
        decoration: const InputDecoration(
          labelText: 'Prénom',
          hintText: 'Votre prénom',
          labelStyle: TextStyle(
            fontSize: 17,
            color: Colors.black,
          ),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: TextInputType.text,
        validator: (value) => _textFieldValidation(value),
        onSaved: (value) {
          _firstnameController = value! as TextEditingController;
        },
      ),
    );
  }

  _textFieldValidation(value) {
    value = value!.trim()!;
    if (value.isEmpty) {
      return 'Ce champ est requis';
    }
    if (value.length < 1) {
      return "Un minimum d'un caractère est requis";
    }
    return null;
  }

  _resetValidations(bool value) {
    setState(() {
      _requestIsRunning = value;
    });
  }

  _formKeyState() {
    setState(() {
      _formIsValid = _formKey.currentState!.validate();
    });
  }

  void _createIdentity() async {
    this._resetValidations(true);
    IdentityModel identityModel = IdentityModel(
        '', accountModel, _firstnameController.text, _lastnameController.text);
    await IdentityService().createIdentity(identityModel).then((response) {
      if (response.statusCode == 200) {
        displayMessage('Profile créé succès', Colors.green);
        var identityCreated = jsonDecode(response.body);
        IdentityModel identityModel = IdentityModel(
            identityCreated['_id'],
            accountModel,
            identityCreated['firstname'],
            identityCreated['lastname']);
        accountModel.identity = identityModel;
        Provider.of<AccountModel>(context, listen: false)
            .updateAccountModel(accountModel);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NavDrawer(channel: widget.channel)));
      } else if (response.statusCode == 422) {
        displayMessage('Erreur, les données sont invalides', Colors.red);
      } else {
        displayMessage('Action non autorisée', Colors.red);
      }
      this._resetValidations(false);
    }).catchError((error) {
      this._resetValidations(false);
      displayMessage('Une erreur du server est survenue', Colors.red);
    });
  }

  displayMessage(String messageContent, backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messageContent), backgroundColor: backgroundColor),
    );
  }

  _initializeData() {
    accountModel = Provider.of<AccountModel>(context, listen: false);
    accountModel = AccountModel(accountModel.id,
        accountId: accountModel.accountId,
        accountType: accountModel.accountType,
        phoneNumber: accountModel.phoneNumber,
        status: accountModel.status,
        token: accountModel.token);
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
            child: Center(
                child: Center(
                    child: Center(
                        child: Form(
      key: _formKey,
      child: Column(
        children: [
          _buildLastname(),
          const SizedBox(height: 4),
          _buildFirstname(),
          const SizedBox(height: 4),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _formIsValid && !_requestIsRunning
                ? () {
                    _createIdentity();
                  }
                : null,
            child: const Text(
              "Enrégistrer",
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ],
      ),
    ))))));
  }
}
