import 'package:flutter/material.dart';
import 'package:ips_link/base/base.dart';
import 'package:ips_link/manager.dart';

class NotificationPage extends StatefulWidget {
  List<NotificationData> notifications = [];
  final Manager manager;

  NotificationPage({
    required this.notifications,
    required this.manager,
  });

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void dispose() {
    super.dispose();
    widget.manager.resetNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
        appBar: PageAppBar(manager: widget.manager),
        manager: widget.manager,
        body: NotificationWidget(
          manager: widget.manager,
          notifications: widget.notifications,
        ));
  }
}

class NotificationData {
  final String title;
  final String message;
  final IconData? icon;

  NotificationData({
    required this.title,
    required this.message,
    this.icon,
  });
}

class NotificationWidget extends StatefulWidget {
  final List<NotificationData> notifications;
  final Manager manager;

  NotificationWidget({
    required this.notifications,
    required this.manager,
  });

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.notifications.length,
      itemBuilder: (context, index) {
        final notification = widget.notifications[index];
        return Card(
          elevation: 2,
          child: ListTile(
            leading: Icon(notification.icon),
            title: Text(notification.title),
            subtitle: Text(notification.message),
          ),
        );
      },
    );
  }
}
