import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart' as sound;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../manager.dart';
import '../../../models/model.dart';
import '../../../utils/utils.dart';

class ChatroomWidget extends StatefulWidget {
  Manager manager;
  Acount acount;
  TextEditingController textFieldController = TextEditingController();
  ChatroomWidget({super.key, required this.acount, required this.manager});
  @override
  State<ChatroomWidget> createState() => _ChatroomWidgetState();
}

class _ChatroomWidgetState extends State<ChatroomWidget> {
  bool _isLoading = false;
  bool _isRecording = false;
  bool _isRecorderReady = false;
  File? audioFile;
  final recorder = sound.FlutterSoundRecorder();
  List<Message> messages = [];
  File? fileImg;
  Image img = Image.asset(
    'assets/images/Default-Profile-Picture-Transparent-Image.png',
    height: 30,
    width: 30,
  );
  @override
  void initState() {
    _loadData();
    super.initState();
    _requestPermission();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
    await recorder.openRecorder();
    _isRecorderReady = true;
  }

  Future<void> record() async {
    if (!_isRecorderReady) return;
    await recorder.startRecorder(toFile: 'audio');
  }

  Future<void> stop() async {
    if (!_isRecorderReady) return;
    final path = await recorder.stopRecorder();
    setState(() {
      audioFile = File(path!);
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    messages.clear();
    await widget.manager.getMessages(messages, acountId: widget.acount.id);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _camera() async {
    if (!_hasCameraPermission) return;
    await pickImage(ImageSource.camera);

    if (fileImg == null) return;
    await widget.manager
        .sendMessage(acountId: widget.acount.id, imageFile: fileImg);
    widget.manager.sendNotification(
        widget.acount.id, 'Envioute-te uma imagem!', 'Recebeste uma imagem!');
    _loadData();
  }

  Future<void> _audio() async {
    if (!_hasMicrophonePermission) return;
    setState(() {
      _isRecording = true;
    });
  }

  bool _hasCameraPermission = false;
  bool _hasMicrophonePermission = false;
  Future<void> _requestPermission() async {
    _hasCameraPermission = await widget.manager.getPermission("camera");
    _hasMicrophonePermission = await widget.manager.getPermission("microphone");
    if (!_hasMicrophonePermission || !_hasCameraPermission) {
      showSnackbar(
          backgroundColor: Colors.red,
          context: context,
          message:
              'Necessita de Permitir o microfone e a camara nos Settings!');
    }
    if (_hasCameraPermission) await Permission.camera.request();
    if (_hasMicrophonePermission) await initRecorder();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      setState(() {
        fileImg = File(image.path);
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
                child: Column(children: [
                  Container(
                      height: 50,
                      decoration: BoxDecoration(color: Colors.blue),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          (widget.acount.imageUrl == null)
                              ? img
                              : Image.network(
                                  widget.acount.imageUrl!,
                                  height: 30,
                                  width: 30,
                                ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            widget.acount.name,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      )),
                  Expanded(
                      child: ListView.builder(
                    itemBuilder: (context, index) {
                      return MessageListTyle(
                        message: messages[index],
                      );
                    },
                    itemCount: messages.length,
                  )),
                  (!_isRecording)
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                                onPressed: () async {
                                  if (recorder.isRecording) {
                                    await stop();
                                  } else {
                                    await record();
                                  }
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.mic,
                                  color: Colors.white,
                                )),
                            Container(
                              child: (!recorder.isRecording)
                                  ? Container()
                                  : Center(
                                      child: LinearProgressIndicator(),
                                    ),
                              width: 100,
                            ),
                            IconButton(
                                onPressed: () async {
                                  if (audioFile == null) return;
                                  widget.manager.sendMessage(
                                      acountId: widget.acount.id,
                                      audioFile: audioFile);
                                  widget.manager.sendNotification(
                                      widget.acount.id,
                                      'Envioute-te um audio!',
                                      'Recebeste um audio!');
                                  setState(() {
                                    _isRecording = false;
                                  });
                                  _loadData();
                                },
                                icon: Icon(
                                  Icons.check_circle_outline_outlined,
                                  color: Colors.green,
                                )),
                            IconButton(
                                onPressed: () async {
                                  setState(() {
                                    _isRecording = false;
                                  });
                                },
                                icon: Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.red,
                                )),
                          ],
                        ),
                  TextField(
                    textAlign: TextAlign.left,
                    controller: widget.textFieldController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: Container(
                          width: 100,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                    iconSize: 20,
                                    onPressed: () async {
                                      print('Microphone');
                                      _audio();
                                    },
                                    icon: Icon(
                                      Icons.mic,
                                      color: Colors.black,
                                    )),
                                IconButton(
                                    iconSize: 20,
                                    onPressed: () async {
                                      _camera();
                                    },
                                    icon: Icon(
                                      Icons.camera_alt,
                                      color: Colors.black,
                                    ))
                              ])),
                      suffixIcon: IconButton(
                          icon: Icon(Icons.send, color: Colors.black),
                          onPressed: () {
                            if (widget.textFieldController.text == '') return;
                            print(widget.textFieldController.text);
                            widget.manager.sendMessage(
                                acountId: widget.acount.id,
                                message: widget.textFieldController.text);
                            widget.textFieldController.text = '';
                            widget.manager.sendNotification(
                                widget.acount.id,
                                'Envioute-te uma mensagem!',
                                'Recebeste uma mensagem!');
                            Future.delayed(Duration(seconds: 1), () {
                              _loadData();
                            });
                          }),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                  )
                ])));
  }
}

class MessageListTyle extends StatefulWidget {
  Message message;
  MessageListTyle({super.key, required this.message});

  @override
  State<MessageListTyle> createState() => _MessageListTyleState();
}

class _MessageListTyleState extends State<MessageListTyle> {
  final audioPlayer = AudioPlayer();
  bool _isPlayingAudio = false;
  void initState() {
    super.initState();
    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlayingAudio = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? content;
    if (widget.message.message != null) {
      content = Text(widget.message.message!);
    } else if (widget.message.imageUrl != null) {
      content = Image.network(
        widget.message.imageUrl!,
        width: 100,
        height: 100,
      );
    } else {
      content = Container(
        child: (!_isPlayingAudio)
            ? Row(children: [
                IconButton(
                    onPressed: () async {
                      await audioPlayer
                          .play(UrlSource(widget.message.audioUrl!));
                      setState(() {
                        _isPlayingAudio = true;
                      });
                    },
                    icon: Icon(Icons.play_circle_outline))
              ])
            : Row(children: [
                IconButton(
                    onPressed: () async {
                      await audioPlayer.pause();
                      setState(() {
                        _isPlayingAudio = false;
                      });
                    },
                    icon: Icon(Icons.pause_circle_outline)),
                Container(
                  width: 100,
                  child: Center(
                      child: LinearProgressIndicator(
                    color: (!widget.message.isRecieved)
                        ? Colors.green
                        : Colors.blue,
                    backgroundColor: (!widget.message.isRecieved)
                        ? Color.fromRGBO(6, 116, 9, 1)
                        : Color.fromARGB(255, 7, 84, 147),
                  )),
                )
              ], mainAxisAlignment: MainAxisAlignment.spaceAround),
      );
    }
    return ListTile(
      title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color:
                      (!widget.message.isRecieved) ? Colors.green : Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              width: 200,
              child: content,
            )
          ],
          mainAxisAlignment: (!widget.message.isRecieved)
              ? MainAxisAlignment.end
              : MainAxisAlignment.start),
    );
  }
}
