import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ips_link/manager.dart';
import 'package:ips_link/models/model.dart';

import '../views/forum_page.dart';

class ForumTileList extends StatelessWidget {
  ForumTileList({super.key, required this.forum, required this.manager});
  Manager manager;
  Forum forum;

  @override
  Widget build(BuildContext context) {
    void _onTap() {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ForumPage(
          manager: manager,
          forum: forum,
        ),
      ));
    }

    return ListTileTheme(
        contentPadding: const EdgeInsets.all(15),
        textColor: Colors.white,
        tileColor: Colors.grey.shade900,
        style: ListTileStyle.list,
        shape: Border.all(color: Colors.white30),
        child: ListTile(
          onTap: _onTap,
          leading: Image(
            image: (forum.imageUrl != null)
                ? Image.network(forum.imageUrl!).image
                : Image.asset('assets/images/Ipslink_splashscreen.png').image,
          ),
          title: Center(child: Text(forum.title)),
        ));
  }
}
