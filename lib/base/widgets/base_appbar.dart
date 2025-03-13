import 'package:flutter/material.dart';
import 'package:ips_link/base/base.dart';
import 'package:ips_link/features/forum/forum.dart';
import 'package:ips_link/features/forum/views/forum_page.dart';
import 'package:ips_link/features/perfil/perfil.dart';
import 'package:ips_link/features/settings/views/settings_view.dart';
import 'package:ips_link/manager.dart';
import 'package:ips_link/models/model.dart';

import '../../features/forum/widgets/add_forum.dart';

class BaseAppBar extends StatefulWidget implements PreferredSizeWidget {
  BaseAppBar({super.key, required this.manager, this.forumSelected});
  String? forumSelected;
  Manager manager;
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  @override
  State<BaseAppBar> createState() => _BaseAppBarState();
}

class _BaseAppBarState extends State<BaseAppBar> {
  bool _isLoading = false;
  UserType type = UserType.visitor;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  List<Forum> allForums = [];
  List<Forum> _folowedForums = [];
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    Acount? currentAcount = await widget.manager.getAcount();
    type = currentAcount!.type;
    currentAcount.forumsFolowing;

    allForums.clear();
    _folowedForums.clear();
    await widget.manager.getForums(allForums);

    allForums.forEach((element) {
      if (currentAcount.forumsFolowing!.contains(element.id)) {
        _folowedForums.add(element);
      }
    });
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  void dropDownAction(String? newValue) {
    if (newValue == null) return;
    Forum? forum;
    allForums.forEach((element) {
      if (element.id == int.parse(newValue)) forum = element;
    });
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ForumPage(manager: widget.manager, forum: forum!),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return (_isLoading)
        ? Center(
            child: LinearProgressIndicator(),
          )
        : AppBar(
            leading: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => SettingsView(manager: widget.manager),
                      ))
                    }),
            title: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                constraints: BoxConstraints(maxHeight: 30),
                child: OverflowBox(
                    maxWidth: double.infinity,
                    child: Wrap(
                      children: [
                        DropdownButton<String>(
                          value: widget.forumSelected,
                          onChanged: dropDownAction,
                          items: _folowedForums.map((Forum forum) {
                            return DropdownMenuItem<String>(
                              value: '${forum.id}',
                              child: Text(forum.title),
                            );
                          }).toList(),
                        )
                      ],
                    ))),
            actions: [
              (type == UserType.student || type == UserType.visitor)
                  ? Container()
                  : IconButton(
                      onPressed: () => {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => AddForumWidget(
                                      manager: widget.manager,
                                    )))
                          },
                      icon: Icon(Icons.add)),
              IconButton(
                  onPressed: () => {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              ForumSearchPage(manager: widget.manager),
                        ))
                      },
                  icon: Icon(Icons.search)),
              IconButton(
                  onPressed: () => {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => PerfilView(manager: widget.manager),
                        ))
                      },
                  icon: Icon(Icons.person)),
            ],
            backgroundColor: Colors.black,
            bottom: PreferredSize(
                child: Container(
                  color: Colors.white54,
                  height: 3,
                ),
                preferredSize: widget.preferredSize),
          );
  }
}
