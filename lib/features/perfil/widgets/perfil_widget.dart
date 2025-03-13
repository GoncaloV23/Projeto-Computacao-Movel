import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ips_link/firebase/firebase.dart';
import 'package:ips_link/manager.dart';
import 'package:ips_link/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../models/model.dart';

class PerfilWidget extends StatefulWidget {
  PerfilWidget({super.key, required this.manager, this.acountId});
  Manager manager;
  String? acountId;
  @override
  State<StatefulWidget> createState() => _PerfilState(manager);
}

class _PerfilState extends State<PerfilWidget> {
  _PerfilState(this.manager);
  Acount? _acount;
  Manager manager;
  File? img;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSubmitting = false;
  String? _fieldEmail;
  String? _fieldName;
  Image? perfilImg;
  @override
  void initState() {
    _loadData();

    super.initState();
  }

  void editProfille() {
    setState(() {
      _isEditing = true;
    });
    _requestPermission();
    _loadData();
  }

  void _onSubmit() async {
    setState(() {
      _isSubmitting = true;
    });
    _formKey.currentState?.save();
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _isSubmitting = false;
      });
      showSnackbar(
        context: context,
        message: 'Por-favor corrija os erros apresentados antes de avançar',
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    _acount!.email = _fieldEmail!;
    _acount!.name = _fieldName!;

    if (img != null) _acount!.imageUrl = await FileStorage.uploadFile(img!);

    await manager.updateAcount(_acount!);
    setState(() {
      _isSubmitting = false;
      _isEditing = false;
      img = null;
    });

    _loadData();
  }

  void _onCancel() async {
    setState(() {
      _isEditing = false;
      img = null;
    });
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    _acount = (widget.acountId == null)
        ? await manager.getAcount()
        : await manager.getAcountWithId(widget.acountId!);
    if (_acount == null) return;
    _fieldEmail = _acount!.email;
    _fieldName = _acount!.name;
    if (_acount!.imageUrl != null &&
        (await http.head(Uri.parse(_acount!.imageUrl!)))
                .headers['content-type']
                ?.startsWith('image/') ==
            true) {
      perfilImg = Image.network(
        _acount!.imageUrl!,
        height: 150,
        width: 150,
      );
    } else {
      perfilImg = Image.asset(
        'assets/images/Default-Profile-Picture-Transparent-Image.png',
        fit: BoxFit.fitWidth,
        width: 150,
        height: 150,
      );
    }
    setState(() {
      _isLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return (_isLoading)
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
            child: RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                    child: (!_isEditing)
                        ? Column(children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Image(
                                  image: perfilImg!.image,
                                  width: 150,
                                  height: 150,
                                ),
                                (widget.acountId == null)
                                    ? IconButton(
                                        onPressed: editProfille,
                                        icon: Icon(
                                          Icons.change_circle_outlined,
                                          color: Colors.white54,
                                        ))
                                    : Container()
                              ],
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  width: 280,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.white54,
                                        width: 3.0,
                                      ),
                                    ),
                                  ),
                                  child: Text('Email: ${_acount!.email}',
                                      style: TextStyle(color: Colors.blue)),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  width: 280,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.white54,
                                        width: 3.0,
                                      ),
                                    ),
                                  ),
                                  child: Text('Name: ${_acount!.name}',
                                      style: TextStyle(color: Colors.blue)),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  width: 280,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.white54,
                                        width: 3.0,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                      'Tipo de conta: ${userTypeToString(_acount!.type)}',
                                      style: TextStyle(color: Colors.blue)),
                                ),
                              ],
                            ),
                          ])
                        : Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Image(
                                        image: (img == null)
                                            ? perfilImg!.image
                                            : Image.file(img!).image,
                                        width: 100,
                                        height: 100,
                                      ),
                                      Column(children: [
                                        ElevatedButton(
                                          child: const Text('Galeria '),
                                          onPressed: () =>
                                              {pickImage(ImageSource.gallery)},
                                        ),
                                        ElevatedButton(
                                          child: const Text('Câmera'),
                                          onPressed: () =>
                                              {pickImage(ImageSource.camera)},
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
                                    labelText: 'E-mail',
                                  ),
                                  autofocus: true,
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
                                  decoration: const InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    labelText: 'Nome',
                                  ),
                                  initialValue: _fieldName,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.done,
                                  autocorrect: false,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Introduza um nome valido.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) => _fieldName = value,
                                  onFieldSubmitted: (_) => _onSubmit(),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ElevatedButton(
                                        onPressed: _onCancel,
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: _onSubmit,
                                        child: const Text('Confirmar'),
                                      ),
                                    ])
                              ],
                            ),
                          ))));
  }
}
