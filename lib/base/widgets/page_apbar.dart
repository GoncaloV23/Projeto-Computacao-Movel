import 'package:flutter/material.dart';
import 'package:ips_link/manager.dart';

import '../../features/perfil/perfil.dart';

class PageAppBar extends StatelessWidget implements PreferredSizeWidget {
  PageAppBar({super.key, required this.manager, this.isPerfilView = false});
  bool isPerfilView;
  Manager manager;
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      actions: [
        IconButton(
            onPressed: () => {
                  if (!isPerfilView)
                    {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => PerfilView(manager: manager),
                      ))
                    }
                },
            icon: Icon(Icons.person)),
      ],
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => {Navigator.of(context).pop()},
      ),
      bottom: PreferredSize(
          child: Container(
            color: Colors.white54,
            height: 3,
          ),
          preferredSize: preferredSize),
    );
  }
}
