import 'package:flutter/material.dart';

import '../../features/perfil/perfil.dart';
import '../../manager.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  SearchAppBar(
      {super.key,
      required this.manager,
      required this.textFieldController,
      required this.searchCallback});
  Manager manager;
  TextEditingController textFieldController;
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  Function searchCallback;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      actions: [
        IconButton(
            onPressed: () => {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => PerfilView(manager: manager),
                  ))
                },
            icon: Icon(Icons.person)),
      ],
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => {Navigator.of(context).pop()},
      ),
      title: SizedBox(
          height: 35.0,
          child: TextField(
            controller: textFieldController,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              prefixIcon: IconButton(
                  icon: Icon(Icons.search, color: Colors.black),
                  onPressed: () => searchCallback()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100.0),
              ),
            ),
          )),
      bottom: PreferredSize(
          child: Container(
            color: Colors.white54,
            height: 3,
          ),
          preferredSize: preferredSize),
    );
  }
}
