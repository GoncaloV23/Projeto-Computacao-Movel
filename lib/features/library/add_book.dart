import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ips_link/manager.dart';

import '../../utils/utils.dart';

class AddbookWidget extends StatefulWidget {
  Manager manager;

  AddbookWidget({super.key, required this.manager});
  @override
  State<AddbookWidget> createState() => _AddbookWidgetState();
}

class _AddbookWidgetState extends State<AddbookWidget> {
  String? _bookTitle;
  final _formKey = GlobalKey<FormState>();
  String? _numberOfBooks;

  void _onSubmit() async {
    _formKey.currentState?.save();

    if (!(_formKey.currentState?.validate() ?? false)) {
      showSnackbar(
        context: context,
        message: 'Por-favor corrija os erros apresentados antes de avançar',
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }
    widget.manager.addBook(_bookTitle!, int.parse(_numberOfBooks!));

    Navigator.of(context).pop();
  }

  void _onCancel() async {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(children: [
        SizedBox(height: 50),
        Text(
          'Book',
          style: TextStyle(
            color: Colors.white,
            fontSize: 46,
            decoration: TextDecoration.none,
          ),
        ),
        SizedBox(height: 50),
        Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    labelText: 'Title',
                  ),
                  initialValue: _bookTitle,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    print(value);
                    if (value?.isEmpty ?? true) {
                      return 'Introduza um titulo';
                    }
                    return null;
                  },
                  onSaved: (value) => _bookTitle = value,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  onSaved: (value) => _numberOfBooks = value,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    labelText: 'Number of books',
                  ),
                  initialValue: _numberOfBooks,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  validator: (value) {
                    print(value);
                    if (value == null) return 'Introduza o número de livros';
                    final number = int.tryParse(value);
                    if (number != null && number > 0) {
                      return null;
                    } else {
                      return 'O número não pode ser menor ou igual a 0';
                    }
                  },
                  onFieldSubmitted: (_) => _onSubmit(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: _onCancel, child: Text('Cancelar')),
                    ElevatedButton(
                        onPressed: _onSubmit, child: Text('Confirmar'))
                  ],
                )
              ],
            ))
      ])),
      backgroundColor: Colors.black,
    );
  }
}
