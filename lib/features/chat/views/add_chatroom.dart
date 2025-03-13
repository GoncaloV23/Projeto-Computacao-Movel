import 'package:flutter/material.dart';
import 'package:ips_link/base/base.dart';
import 'package:ips_link/features/chat/widgets/add_chatroom_widget.dart';
import 'package:ips_link/manager.dart';

import '../../../models/model.dart';

class AddChatroomView extends StatelessWidget {
  AddChatroomView({super.key, required this.manager});
  Manager manager;
  final TextEditingController _textFieldController = TextEditingController();
  late final ChatroomSearchWidgetController _chatroomSearchWidgetController =
      ChatroomSearchWidgetController();

  void _search() {
    final searchString = _textFieldController.text;
    _chatroomSearchWidgetController.updateSearchString(searchString);
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      body: AddChatroomWidget(
          manager: manager, controller: _chatroomSearchWidgetController),
      manager: manager,
      pageIndex: 0,
      appBar: SearchAppBar(
          manager: manager,
          textFieldController: _textFieldController,
          searchCallback: _search),
    );
  }
}

class ChatroomSearchWidgetController extends ChangeNotifier {
  String _searchString = '';

  String get searchString => _searchString;

  void updateSearchString(String searchString) {
    if (_searchString != searchString) {
      _searchString = searchString;
      notifyListeners();
    }
  }
}
