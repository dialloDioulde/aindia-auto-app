/**
 * @created 17/10/2023 - 17:23
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:aindia_auto_app/components/home/login.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons_ns/grouped_buttons_ns.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/account.service.dart';

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

  static const String _title = 'Inscription';

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
  late SharedPreferences preferences;

  late TextEditingController _firstnameController = TextEditingController();
  late TextEditingController _lastnameController = TextEditingController();
  late TextEditingController _phoneNumberController = TextEditingController();
  late TextEditingController _passwordController = TextEditingController();
  late TextEditingController _passwordConfirmationController =
      TextEditingController();

  late int _accountType = 1;
  String _accountTypeLabel = 'Passager';

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
          this._formKeyState();
        },
        obscureText: false,
        style: TextStyle(fontSize: 17),
        decoration: const InputDecoration(
          labelText: 'Numéro Téléphone',
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
        onChanged: (value) {
          _passwordController.text = value;
          this._formKeyState();
        },
        obscureText: true,
        style: TextStyle(fontSize: 17),
        decoration: const InputDecoration(
          labelText: 'Mot de passe',
          hintText: 'Tapez votre mot de passe',
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

  Widget _buildPasswordConfirmation() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: TextFormField(
        onChanged: (value) {
          _passwordConfirmationController.text = value;
          this._formKeyState();
        },
        obscureText: true,
        style: TextStyle(fontSize: 17),
        decoration: const InputDecoration(
          labelText: 'Confirmation du mot de passe',
          hintText: "Tapez l'actuel mot de passe",
          labelStyle: TextStyle(
            fontSize: 17,
            color: Colors.black,
          ),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: TextInputType.visiblePassword,
        validator: (value) => _passwordConfirmationFieldValidation(value),
      ),
    );
  }

  Widget _buildGender() {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: RadioButtonGroup(
        activeColor: Colors.green,
        orientation: GroupedButtonsOrientation.HORIZONTAL,
        onSelected: (String selected) => setState(() {
          _accountTypeLabel = selected;
          _accountTypeLabel == 'Passager' ? _accountType = 1 : _accountType = 2;
        }),
        labels: <String>[
          "Passager",
          "       Chauffeur",
        ],
        picked: _accountTypeLabel,
        itemBuilder: (Radio rb, Text txt, int i) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              rb,
              txt,
            ],
          );
        },
      ),
    );
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

  _passwordConfirmationFieldValidation(value) {
    value = value!.trim()!;
    if (value.isEmpty) {
      return 'Ce champ est requis';
    }
    if (value != _passwordController.text) {
      return 'Les mots de passe doivent correspondre';
    }
    return null;
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

  _formKeyState() {
    setState(() {
      _formIsValid = _formKey.currentState!.validate();
    });
  }

  void _registerAccount() async {
    this._resetValidations(true);
    var data = {
      'phoneNumber': _phoneNumberController.value.text,
      'password': _passwordController.text,
      'passwordConfirmation': _passwordConfirmationController.text,
      'accountType': _accountType,
    };
    await AccountService().registerAccount(data).then((response) {
      if (response.statusCode == 200) {
        displayMessage('Compte créé avec succès', Colors.green);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Login()));
      }
      if (response.statusCode == 400) {
        displayMessage('Numéro déjà utilisé par un autre compte', Colors.red);
        this._resetValidations(false);
      }
      if (response.statusCode == 422) {
        displayMessage('Erreur, les données sont invalides', Colors.red);
        this._resetValidations(false);
      }
    }).catchError((error) {
      this._resetValidations(false);
      displayMessage('Une erreur du server est survenue', Colors.red);
    });
  }

  _resetValidations(bool value) {
    setState(() {
      _requestIsRunning = value;
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
    _firstnameController.dispose();
    _lastnameController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
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
          const SizedBox(height: 4),
          _buildPassword(),
          const SizedBox(height: 4),
          _buildPasswordConfirmation(),
          const SizedBox(height: 4),
          _buildGender(),
          const SizedBox(height: 4),
          ElevatedButton(
            onPressed: _formIsValid && !_requestIsRunning
                ? () {
                    _registerAccount();
                  }
                : null,
            child: const Text(
              "Je m'inscris",
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
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Login()));
            },
            child: const Text(
              'Déjà inscris ? Je me connecte',
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
    ))))));
  }
}
