import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ips_link/manager.dart';

import '../../../utils/show_snackbar.dart';
import 'sign_up_page.dart';

class AuthenticationPage extends StatefulWidget {
  AuthenticationPage({super.key, required this.manager});
  Manager manager;

  @override
  State<AuthenticationPage> createState() =>
      _AuthenticationPageState(manager: manager);
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final _formKey = GlobalKey<FormState>();
  _AuthenticationPageState({required this.manager});

  Manager manager;
  bool _submitting = false;
  String? _fieldEmail;
  String? _fieldPassword;

  Future<void> _firebaseSignIn({
    required String email,
    required String password,
  }) async {
    try {
      await manager.logIn(email: email, password: password);
      if (!mounted) return;
      showSnackbar(
        context: context,
        message: 'Utilizado autenticado com sucesso.',
        backgroundColor: Colors.green,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackbar(
          context: context,
          message: 'Nenhum utilizador encontrado com o e-mail indicado.',
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      } else if (e.code == 'wrong-password') {
        showSnackbar(
          context: context,
          message: 'A palavra-passe introduzia está incorreta.',
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    }
  }

  void _onSubmit() async {
    setState(() {
      _submitting = true;
    });

    _formKey.currentState?.save();
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _submitting = false;
      });
      showSnackbar(
        context: context,
        message: 'Por-favor corrija os erros apresentados antes de avançar',
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    _firebaseSignIn(email: _fieldEmail!, password: _fieldPassword!);
    setState(() {
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: _submitting
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Login",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 70),
                    Row(children: [
                      Text(
                        "Hello!",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      )
                    ]),
                    const SizedBox(height: 30),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'E-mail',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          )),
                      autofocus: true,
                      initialValue: _fieldEmail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Introduza o seu e-mail';
                        }
                        if (!RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value!)) {
                          return 'Introduza um e-mail válido';
                        }
                        return null;
                      },
                      onSaved: (value) => _fieldEmail = value,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Palavra-passe',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          )),
                      initialValue: _fieldPassword,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      obscureText: true,
                      autocorrect: false,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Introduza a sua palavra-passe';
                        }
                        return null;
                      },
                      onSaved: (value) => _fieldPassword = value,
                      onFieldSubmitted: (_) => _onSubmit(),
                    ),
                    const SizedBox(height: 70),
                    ElevatedButton(
                      onPressed: _onSubmit,
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SignUpPage(manager: manager),
                        ),
                      ),
                      child: const Text('Criar nova conta'),
                    )
                  ],
                ),
              )),
      ),
    );
  }
}
