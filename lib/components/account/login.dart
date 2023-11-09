/**
 * @created 14/10/2023 - 17:17
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'dart:convert';
import 'package:aindia_auto_app/components/account/register.dart';
import 'package:aindia_auto_app/components/identity/identity.component.dart';
import 'package:aindia_auto_app/models/account.model.dart';
import 'package:aindia_auto_app/services/account.service.dart';
import 'package:aindia_auto_app/utils/permissions/permission.handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/account-type.enum.dart';
import '../../models/identity/identity.model.dart';
import '../../utils/shared-preferences.util.dart';
import '../drawers/nav.drawer.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  static const String _title = 'Connexion';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
          appBar: AppBar(
              centerTitle: true,
              title: const Text(_title),
              backgroundColor: Colors.green),
          body: const MyStatefulWidget(),
          backgroundColor: Colors.white),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  AccountType accountType = AccountType();

  AccountService accountService = AccountService();
  SharedPreferencesUtil sharedPreferencesUtil = SharedPreferencesUtil();
  late TextEditingController _phoneNumberController = TextEditingController();
  late TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _formIsValid = false;
  bool _requestIsRunning = false;

  Widget _buildPhoneNumber() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: TextFormField(
        controller: _phoneNumberController,
        onChanged: (value) {
          _phoneNumberController.text = value;
        },
        obscureText: false,
        style: TextStyle(fontSize: 17),
        decoration: const InputDecoration(
          labelText: 'N° Téléphone',
          hintText: 'Numéro Téléphone',
          labelStyle: TextStyle(
            fontSize: 17,
            color: Colors.black,
          ),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: TextInputType.number,
        validator: (value) => _phoneNumberFieldValidation(value),
        onSaved: (value) {
          _phoneNumberController = value! as TextEditingController;
        },
      ),
    );
  }

  Widget _buildPassword() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextFormField(
        onChanged: (value) => _passwordController.text = value,
        obscureText: true,
        style: TextStyle(fontSize: 17),
        decoration: const InputDecoration(
          labelText: 'Mot de passe',
          hintText: 'Mot de passe',
          labelStyle: TextStyle(
            fontSize: 17,
            color: Colors.black,
          ),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => _passwordFieldValidation(value),
      ),
    );
  }

  _phoneNumberFieldValidation(value) {
    value = value!.trim()!;
    if (value.isEmpty) {
      return 'Ce champ est requis';
    }
    if (value.length != 9) {
      return "Le numéro est composé de 9 chiffres";
    }
    return null;
  }

  _passwordFieldValidation(value) {
    value = value!.trim()!;
    if (value.isEmpty) {
      return 'Ce champ est requis';
    }
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    return null;
  }

  _resetValidations(bool requestIsRunning) {
    setState(() {
      _requestIsRunning = requestIsRunning;
    });
  }

  displayMessage(String messageContent, backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messageContent), backgroundColor: backgroundColor),
    );
  }

  void _loginAccount() async {
    var data = {
      'phoneNumber': _phoneNumberController.text,
      'password': _passwordController.text
    };
    await accountService.loginAccount(data).then((response) async {
      if (response.statusCode == 200) {
        var resData = jsonDecode(response.body);
        sharedPreferencesUtil.setLocalDataByKey("token", resData['token']);
        AccountModel accountModel = AccountModel(
          resData['_id'],
          accountId: resData['accountId'],
          accountType: resData['accountType'],
          phoneNumber: resData['phoneNumber'],
          status: resData['status'],
          token: resData['token'],
        );
        IdentityModel identityModel = IdentityModel('', accountModel, '', '');
        if (resData['identity'] != null) {
          identityModel = IdentityModel(
              resData['identity']['_id'],
              AccountModel(''),
              resData['identity']['firstname'],
              resData['identity']['lastname']);
        }
        accountModel.identity = identityModel;
        Provider.of<AccountModel>(context, listen: false)
            .updateAccountModel(accountModel);
        // Permissions handle
        PermissionHandler permissionHandler = PermissionHandler();
        final requestPermissionsRes =
            await permissionHandler.requestPermissions();
        if (requestPermissionsRes) {
          displayMessage('Bienvenue chez Aindia Auto !', Colors.green);
          if (resData['accountType'] ==
                  accountType.accountTypeValue(AccountTypeEnum.DRIVER) &&
              resData['identity']?['_id'] == null) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => IdentityComponent()));
          } else {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => NavDrawer()));
          }
        } else {
          displayMessage(
              "Vous devez accépter les autorisations demandées pour pouvoir utiliser notre application Aindia Auto",
              Colors.red);
          _logoutAccount();
        }
      } else {
        this._resetValidations(false);
        displayMessage('Identifiants incorrects !', Colors.red);
      }
    }).catchError((error) {
      print(error);
      this._resetValidations(false);
      displayMessage('Une erreur est survenue !', Colors.red);
    });
  }

  void _logoutAccount() {
    sharedPreferencesUtil.setLocalDataByKey('token', '');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _passwordController.dispose();
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
          _buildPhoneNumber(),
          const SizedBox(height: 8),
          _buildPassword(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              child: Text(
                "CONNEXION",
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              onPressed: _formIsValid && !_requestIsRunning
                  ? () {
                      _loginAccount();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {},
            child: const Text(
              'Mot de passe oublier ? cliquer ici',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              child: Text(
                "INSCRIPTION",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Register()));
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
            ),
          ),
          if (_requestIsRunning)
            Center(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [CircularProgressIndicator()],
            ))
        ],
      ),
      onChanged: () {
        setState(() {
          _formIsValid = _formKey.currentState!.validate();
        });
      },
    ))))));
  }
}