import 'package:flutter/material.dart';
import 'package:ips_link/base/base.dart';
import 'package:ips_link/features/forum/widgets/forum_widget.dart';
import 'package:ips_link/manager.dart';
import 'package:ips_link/models/forum/forum.dart';

class ForumPage extends StatelessWidget {
  ForumPage({super.key, required this.manager, required this.forum});
  Manager manager;
  Forum forum;
  @override
  Widget build(BuildContext context) {
    return BaseWidget(
        body: ForumWidget(
          manager: manager,
          forum: forum,
        ),
        manager: manager,
        appBar: BaseAppBar(manager: manager));
  }
}
