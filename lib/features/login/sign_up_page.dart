import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ips_link/manager.dart';
import 'package:ips_link/models/model.dart';

import '../../../utils/show_snackbar.dart';
import 'authentication_page.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({super.key, required this.manager});
  Manager manager;

  @override
  State<SignUpPage> createState() => _SignUpPageState(manager: manager);
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  _SignUpPageState({required this.manager});

  Manager manager;
  bool _submitting = false;
  String? _fieldName;
  String? _fieldEmail;
  String? _fieldPassword;

  Future<void> _firebaseSignUp(
      {required String displayName,
      required String email,
      required String password}) async {
    try {
      print(await manager.singIn(
          email: email,
          name: displayName,
          password: password,
          type: UserType.admin));

      // Mostrar mensagem de sucesso
      if (!mounted) return;
      showSnackbar(
        context: context,
        message: 'Conta criada com sucesso.',
        backgroundColor: Colors.green,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackbar(
          context: context,
          message: 'A palavra-passe introduzia é fraca.',
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      } else if (e.code == 'email-already-in-use') {
        showSnackbar(
          context: context,
          message: 'O e-mail introduzido já está a ser utilizado.',
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    } catch (e) {
      showSnackbar(
        context: context,
        message: 'Erro desconhecido.',
        backgroundColor: Theme.of(context).colorScheme.error,
      );
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
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: const Text(
                'Por-favor corrija os erros apresentados antes de avançar'),
          ),
        );
      return;
    }
    _firebaseSignUp(
      email: _fieldEmail!,
      displayName: _fieldName!,
      password: _fieldPassword!,
    );

    setState(() {
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: AppBar(title: const Text('Registo')),
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
                          "Sign Up",
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
                          style: TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                              labelText: 'Nome',
                              labelStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              )),
                          autofocus: true,
                          initialValue: _fieldName,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Introduza o seu nome';
                            }
                            return null;
                          },
                          onSaved: (value) => _fieldName = value,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                              labelText: 'E-mail',
                              labelStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              )),
                          initialValue: _fieldEmail,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
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
                        const SizedBox(height: 8),
                        TextFormField(
                          style: TextStyle(color: Colors.white),
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
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Introduction a sua palavra-passe';
                            }
                            return null;
                          },
                          onSaved: (value) => _fieldPassword = value,
                          onFieldSubmitted: (_) => _onSubmit(),
                        ),
                        const SizedBox(height: 70),
                        ElevatedButton(
                          onPressed: _onSubmit,
                          child: const Text(
                            'Criar conta',
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  AuthenticationPage(manager: manager),
                            ),
                          ),
                          child: const Text('Já tem uma conta?'),
                        )
                      ],
                    ),
                  ),
                ),
        ));
  }
}
