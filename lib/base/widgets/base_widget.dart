import 'package:flutter/material.dart';
import 'package:ips_link/base/base.dart';
import 'package:ips_link/features/chat/chat.dart';
import 'package:ips_link/features/main_page/main_page.dart';
import 'package:ips_link/manager.dart';

import '../../features/library/library_widgets.dart';
import '../../features/map/widgets/map_widget.dart';

class BaseWidget extends StatefulWidget {
  BaseWidget(
      {this.appBar,
      required this.body,
      this.pageIndex,
      super.key,
      required this.manager});
  final PreferredSizeWidget? appBar;
  final Widget body;
  final int? pageIndex;
  Manager manager;
  @override
  State<StatefulWidget> createState() =>
      _BaseState(appBar, body, pageIndex, manager);
}

class _BaseState extends State<BaseWidget> {
  _BaseState(this.appBar, this.body, this.pageIndex, this.manager);
  Manager manager;
  PreferredSizeWidget? appBar;
  Widget body;
  int? pageIndex;

  void onTap(int value) {
    Widget body = Container();
    if (value == 0) {
      body = MainPage(
        manager: manager,
      );
    }
    if (value == 1) {
      body = MapWidget(
        manager: manager,
      );
    }
    if (value == 2) {
      body = LibraryList(
        manager: manager,
      );
    }
    if (value == 3) {
      body = ChatroomsView(
        manager: manager,
      );
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BaseWidget(
            manager: manager,
            appBar: BaseAppBar(
              manager: manager,
            ),
            body: body,
            pageIndex: value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar,
        backgroundColor: Colors.black,
        body: body,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.white54,
                width: 3.0,
              ),
            ),
          ),
          child: (pageIndex != null)
              ? BottomNavigationBar(
                  onTap: onTap,
                  currentIndex: pageIndex!,
                  fixedColor: Colors.white,
                  unselectedItemColor: Colors.white54,
                  items: [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                        backgroundColor: Colors.black),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.map_outlined),
                        label: 'Map',
                        backgroundColor: Colors.black),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.menu_book_sharp),
                        label: 'Library',
                        backgroundColor: Colors.black),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.chat_bubble_outline),
                        label: 'Chat',
                        backgroundColor: Colors.black),
                  ],
                )
              : BottomNavigationBar(
                  onTap: onTap,
                  currentIndex: 0,
                  fixedColor: Colors.white54,
                  unselectedItemColor: Colors.white54,
                  items: [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: '',
                        backgroundColor: Colors.black),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.map_outlined),
                        label: '',
                        backgroundColor: Colors.black),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.menu_book_sharp),
                        label: '',
                        backgroundColor: Colors.black),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.chat_bubble_outline),
                        label: '',
                        backgroundColor: Colors.black),
                  ],
                ),
        ));
  }
}
