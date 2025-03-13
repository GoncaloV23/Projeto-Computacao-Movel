import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart' as sound;
import 'package:ips_link/base/base.dart';
import 'package:ips_link/manager.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../models/model.dart';
import '../widgets/chatroom_widget.dart';

class ChatroomView extends StatefulWidget {
  Manager manager;
  Acount acount;
  TextEditingController textFieldController = TextEditingController();
  ChatroomView({super.key, required this.acount, required this.manager});
  //final recorder = sound.FlutterSoundRecorder();
  @override
  State<ChatroomView> createState() => _ChatroomViewState();
}

class _ChatroomViewState extends State<ChatroomView> {
  @override
  Widget build(BuildContext context) {
    return BaseWidget(
        pageIndex: 3,
        appBar: PageAppBar(manager: widget.manager),
        manager: widget.manager,
        body: ChatroomWidget(
          acount: widget.acount,
          manager: widget.manager,
        ));
  }
  /*bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String? url;
  
  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
    await widget.recorder.openRecorder();
    _isRecorderReady = true;
  }
  @override
  void initState() {
    _loadData();
    super.initState();
    //initRecorder();
  }

  @override
  void dispose() {
    //widget.recorder.closeRecorder();
    super.dispose();
  }

  Image img = Image.asset(
    'assets/images/Default-Profile-Picture-Transparent-Image.png',
    height: 30,
    width: 30,
  );
  //File? audioFile;
  //bool _isRecorderReady = false;

  bool _isLoading = false;
  List<Message> messages = [];
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

/*
  Future<void> record() async {
    if (!_isRecorderReady) return;
    await widget.recorder.startRecorder(toFile: 'audio');
  }

  Future<void> stop() async {
    if (!_isRecorderReady) return;
    final path = await widget.recorder.stopRecorder();
    setState(() {
      audioFile = File(path!);
    });

    print(audioFile);
  }
*/
  @override
  Widget build(BuildContext context) {
    return BaseWidget(
        body: (_isLoading)
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: Column(
                      children: [
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
                        /*Expanded(
                            child: ListView.builder(
                          itemBuilder: (context, index) {
                            return MessageListTyle(
                              message: messages[index],
                            );
                          },
                          itemCount: messages.length,
                        )),*/
                        TextField(
                          controller: widget.textFieldController,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: IconButton(
                                onPressed: () async {
                                  /* if (widget.recorder.isRecording) {
                                    await stop();
                                  } else {
                                    await record();
                                  }*/
                                },
                                icon: Icon(
                                  Icons.mic,
                                  color: Colors.black,
                                )),
                            suffixIcon: IconButton(
                                icon: Icon(Icons.send, color: Colors.black),
                                onPressed: () {
                                  print(widget.textFieldController.text);
                                  widget.manager.sendMessage(
                                      acountId: widget.acount.id,
                                      message: widget.textFieldController.text);
                                }),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                          ),
                        )
                      ],
                    ))),
        pageIndex: 3,
        appBar: PageAppBar(manager: widget.manager),
        manager: widget.manager);
  }*/
}

class MessageListTyle extends StatefulWidget {
  Message message;
  MessageListTyle({super.key, required this.message});

  @override
  State<MessageListTyle> createState() => _MessageListTyleState();
}

class _MessageListTyleState extends State<MessageListTyle> {
  final audioPlayer = AudioPlayer();

  bool isCurrentUser = true;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: (isCurrentUser) ? Colors.green : Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              width: 200,
              child: Text(widget.message.message!),
            )
          ],
          mainAxisAlignment: (isCurrentUser)
              ? MainAxisAlignment.end
              : MainAxisAlignment.start),
    );

    /*

@override
  void initState() {
    super.initState();
    initRecorder();
    widget.audioPlayer.onPlayerStateChanged.listen((event) {
      print(
          '**************************************************************${event}************************************************');
      setState(() {
        isPlaying = event == PlayerState.playing;
      });
    });
    widget.audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    widget.audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  @override
  void dispose() {
    widget.recorder.closeRecorder();
    widget.audioPlayer.dispose();
    super.dispose();
  }

    Text(
              'audio',
              style: TextStyle(color: Colors.white),
            ),
            Slider(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: (value) async {
                  final position = Duration(seconds: value.toInt());
                  await widget.audioPlayer.seek(position);
                  await widget.audioPlayer.resume();
                }),
            Row(children: [
              Text(
                position.inSeconds.toInt().toString(),
                style: TextStyle(color: Colors.white),
              ),
              IconButton(
                onPressed: () async {
                  if (isPlaying) {
                    await widget.audioPlayer.pause();
                  } else {
                    await widget.audioPlayer.play(DeviceFileSource(
                        audioFile!.path)); //audio.UrlSource(url!));
                  }
                },
                icon: Icon((isPlaying) ? Icons.pause : Icons.play_arrow),
                color: Colors.white,
              ),
              Text(
                duration.inSeconds.toInt().toString(),
                style: TextStyle(color: Colors.white),
              )
            ], mainAxisAlignment: MainAxisAlignment.spaceAround),
    */
  }
}
