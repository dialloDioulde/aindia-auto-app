/**
 * @created 14/10/2023 - 17:17
 * @project door_war_app
 * @author mamadoudiallo
 */

import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late TextEditingController _emailController = TextEditingController();
  late TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _formIsValid = false;
  bool _requestIsRunning = false;

  Widget _buildEmail() {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: TextFormField(
            onChanged: (value) => _emailController.text = value,
            decoration: const InputDecoration(
              labelText: 'N° Téléphone',
              hintText: 'Tapez votre numéro de tél...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => _emailFieldValidation(value)));
  }

  _emailFieldValidation(value) {
    /*value = value!.trim()!;
    if (!EmailValidator.validate(value!.toString().trim())) {
      return 'Adresse email incorrecte';
    }*/
    return null;
  }

  Widget _buildPassword() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextFormField(
        onChanged: (value) => _passwordController.text = value,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Mot de passe',
          hintText: 'Tapez votre mot de passe...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => _passwordFieldValidation(value),
      ),
    );
  }

  _passwordFieldValidation(value) {
    /*value = value!.trim()!;
    if (value.isEmpty) {
      return 'Ce champ est requis';
    }
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }*/
    return null;
  }

  late SharedPreferences preferences;

  void userLoginAccount() async {
    //
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MapComponent()));
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

  void initSharedPreferences() async {
    preferences = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
  }

  @override
  void dispose() {
    _emailController.dispose();
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
          _buildEmail(),
          const SizedBox(height: 8),
          _buildPassword(),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              userLoginAccount();
            },
            /*onPressed: _formIsValid && !_requestIsRunning
                ? () {
                    this._resetValidations(true);
                    userLoginAccount();
                  }
                : null,*/
            child: const Text(
              'Se Connecter',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF223366),
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
