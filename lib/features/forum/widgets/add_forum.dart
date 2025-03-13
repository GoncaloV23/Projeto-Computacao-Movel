import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../manager.dart';
import '../../../utils/utils.dart';

class AddForumWidget extends StatefulWidget {
  AddForumWidget({super.key, required this.manager});
  Manager manager;
  @override
  State<AddForumWidget> createState() => _AddForumState();
}

class _AddForumState extends State<AddForumWidget> {
  File? img;
  final _formKey = GlobalKey<FormState>();
  String? _title;
  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  bool _hasPermission = false;
  Future<void> _requestPermission() async {
    _hasPermission = await widget.manager.getPermission("camera");
    print(_hasPermission);
    if (!_hasPermission) {
      showSnackbar(
          backgroundColor: Colors.red,
          context: context,
          message: 'Necessita de Permitir a camara nos Settings!');
      return;
    }
    await Permission.camera.request();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> pickImage(ImageSource source) async {
    if (!_hasPermission) return;
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      setState(() {
        img = File(image.path);
      });
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Falhou a selecionar a imagem!'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

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

    widget.manager.createForum(title: _title!, img: img);

    Navigator.of(context).pop();
  }

  void _onCancel() async {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
            child: Column(children: [
          SizedBox(height: 50),
          Text(
            'Forum',
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        (img == null)
                            ? Container()
                            : Image(
                                image: Image.file(img!).image,
                                width: 100,
                                height: 100,
                              ),
                        Column(children: [
                          ElevatedButton(
                            child: const Text('Galeria '),
                            onPressed: () => {pickImage(ImageSource.gallery)},
                          ),
                          ElevatedButton(
                            child: const Text('Câmera'),
                            onPressed: () => {pickImage(ImageSource.camera)},
                          ),
                        ]),
                      ]),
                  SizedBox(
                    height: 60,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      labelText: 'Title',
                    ),
                    initialValue: _title,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Introduza um titulo';
                      }
                      return null;
                    },
                    onSaved: (value) => _title = value,
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
        ])));
  }
}
