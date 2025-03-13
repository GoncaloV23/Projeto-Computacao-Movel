import 'package:flutter/material.dart';
import 'package:ips_link/manager.dart';

import '../widgets/chastrooms_list_widget.dart';
import 'add_chatroom.dart';

class ChatroomsView extends StatelessWidget {
  Manager manager;

  ChatroomsView({super.key, required this.manager});
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ChatroomListWidget(manager: manager),
      Positioned(
        bottom: 10,
        right: 10,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => AddChatroomView(
                      manager: manager,
                    )));
          },
          child: Icon(Icons.add),
        ),
      )
    ]);
  }
}
