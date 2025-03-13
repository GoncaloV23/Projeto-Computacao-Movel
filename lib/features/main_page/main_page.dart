import 'package:flutter/material.dart';

import '../../manager.dart';
import '../calendar/calendar.dart';
import '../notifications/notifications.dart';

class MainPage extends StatefulWidget {
  final Manager manager;

  const MainPage({super.key, required this.manager});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isLoading = false;
  List<NotificationData> notifications = [];

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    notifications.clear();

    await widget.manager.getNotifications(notifications);
    print(notifications);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  initState() {
    super.initState();

    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
      Row(children: [
        const Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        IconButton(
            icon: Icon(
              Icons.expand_circle_down_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => NotificationPage(
                    manager: widget.manager, notifications: notifications),
              ));
            })
      ]),
      Container(
        height: 200,
        child: Expanded(
          child: NotificationWidget(
              notifications: notifications, manager: widget.manager),
        ),
      ),
      Row(children: [
        const Text(
          "Calendar",
          style: TextStyle(color: Colors.white),
        ),
        IconButton(
            icon: Icon(
              Icons.expand_circle_down_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CalendarWidgetPage(
                  manager: widget.manager,
                ),
              ));
            })
      ]),
      Container(
        height: 200,
        child: CalendarWidget(),
      ),
    ]));
  }
}
