import 'package:flutter/material.dart';
import 'package:ips_link/manager.dart';

import '../../../models/model.dart';
import '../views/chatroom_view.dart';

class ChatroomListWidget extends StatefulWidget {
  ChatroomListWidget({super.key, required this.manager});
  Manager manager;
  @override
  State<ChatroomListWidget> createState() => _ChatroomListWidgetState();
}

class _ChatroomListWidgetState extends State<ChatroomListWidget> {
  bool _isLoading = false;
  List<Acount> chattingAcounts = [];
  Map<String, MapEntry<String, int>> chats = {};
  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    chattingAcounts.clear();
    chats.clear();
    await widget.manager.getChattingAcounts(chattingAcounts, chats);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (_isLoading)
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
            child: RefreshIndicator(
                onRefresh: _loadData,
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return ChatroomsListTile(
                      numberOfMessages:
                          chats[chattingAcounts[index].id]!.value.toString(),
                      manager: widget.manager,
                      acount: chattingAcounts[index],
                      subtitle: chats[chattingAcounts[index].id]!.key,
                    );
                  },
                  itemCount: chattingAcounts.length,
                )));
  }
}

class ChatroomsListTile extends StatelessWidget {
  ChatroomsListTile(
      {super.key,
      required this.acount,
      required this.manager,
      required this.numberOfMessages,
      required this.subtitle});
  Acount acount;
  Manager manager;
  String subtitle;
  String numberOfMessages;
  Image img = Image.asset(
    'assets/images/Default-Profile-Picture-Transparent-Image.png',
    height: 30,
    width: 30,
  );
  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
        contentPadding: const EdgeInsets.all(15),
        textColor: Colors.white,
        tileColor: Colors.grey.shade900,
        style: ListTileStyle.list,
        shape: Border.all(color: Colors.white30),
        child: ListTile(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ChatroomView(
                      manager: manager,
                      acount: acount,
                    )));
          },
          title: Text(
            acount.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          leading: (acount.imageUrl == null)
              ? img
              : Image.network(
                  acount.imageUrl!,
                  height: 30,
                  width: 30,
                ),
          subtitle: Text((subtitle.length > 20)
              ? subtitle.substring(0, 20) + '  ...'
              : subtitle),
          trailing: Text(numberOfMessages),
        ));
  }
}
