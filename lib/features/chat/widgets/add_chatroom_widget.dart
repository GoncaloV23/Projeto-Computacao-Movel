import 'package:flutter/material.dart';
import 'package:ips_link/features/chat/views/add_chatroom.dart';

import '../../../manager.dart';
import '../../../models/model.dart';
import '../views/chatroom_view.dart';

class AddChatroomWidget extends StatefulWidget {
  Manager manager;

  AddChatroomWidget(
      {super.key, required this.manager, required this.controller});

  final ChatroomSearchWidgetController controller;
  @override
  State<AddChatroomWidget> createState() => _AddChatroomState();
}

class _AddChatroomState extends State<AddChatroomWidget> {
  bool _isLoading = false;
  List<Acount> chattingAcounts = [];

  String _searchString = '';
  @override
  void initState() {
    _loadData();
    widget.controller.addListener(_update);
    super.initState();
  }

  void _update() {
    if (!mounted) return;
    setState(() {
      _searchString = widget.controller.searchString;
    });
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    List<Acount> allChattingAcounts = [];
    chattingAcounts.clear();
    await widget.manager.getAllAcount(allChattingAcounts);

    allChattingAcounts.forEach((element) => {
          if (element.name.toLowerCase().contains(_searchString.toLowerCase()))
            {chattingAcounts.add(element)}
        });
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return AddChatroomsListTile(
          manager: widget.manager,
          acount: chattingAcounts[index],
        );
      },
      itemCount: chattingAcounts.length,
    );
  }
}

class AddChatroomsListTile extends StatelessWidget {
  AddChatroomsListTile(
      {super.key, required this.acount, required this.manager});
  Acount acount;
  Manager manager;
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
          title: Text(acount.name),
          leading: (acount.imageUrl == null)
              ? img
              : Image.network(
                  acount.imageUrl!,
                  height: 30,
                  width: 30,
                ),
        ));
  }
}
