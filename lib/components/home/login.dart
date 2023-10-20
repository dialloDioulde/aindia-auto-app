/**
 * @created 14/10/2023 - 17:17
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'dart:convert';
import 'package:aindia_auto_app/components/home/register.dart';
import 'package:aindia_auto_app/services/account.service.dart';
import 'package:flutter/material.dart';
import '../../utils/shared-preferences.util.dart';
import '../map/map.component.dart';

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

  void userLoginAccount() async {
    var data = {
      'phoneNumber': _phoneNumberController.text,
      'password': _passwordController.text
    };
    await accountService.loginAccount(data).then((response) async {
      if (response.statusCode == 200) {
        var resData = jsonDecode(response.body);
        sharedPreferencesUtil.setLocalDataByKey("token", resData['token']);
        displayMessage('Bienvenue chez Aindia Auto !', Colors.green);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MapComponent()));
      } else {
        this._resetValidations(false);
        displayMessage('Identifiants incorrects !', Colors.red);
      }
    }).catchError((error) {
      this._resetValidations(false);
      displayMessage('Une erreur est survenue !', Colors.red);
    });
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
          ElevatedButton(
            onPressed: _formIsValid && !_requestIsRunning
                ? () {
                    userLoginAccount();
                  }
                : null,
            child: const Text(
              'Se Connecter',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
          const SizedBox(height: 12),
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
          InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Register()));
            },
            child: const Text(
              "Pas encore inscrit ? Cliquer ici",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
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
