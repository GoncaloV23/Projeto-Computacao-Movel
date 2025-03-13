import 'package:flutter/material.dart';
import 'package:ips_link/base/base.dart';

import '../../../manager.dart';
import '../widgets/perfil_widget.dart';

class PerfilView extends StatefulWidget {
  PerfilView({super.key, required this.manager, this.acountId});
  String? acountId;
  Manager manager;
  @override
  State<StatefulWidget> createState() => _PerfilState(manager);
}

class _PerfilState extends State<PerfilView> {
  _PerfilState(this.manager);
  Manager manager;
  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      manager: manager,
      body: PerfilWidget(manager: manager, acountId: widget.acountId),
      appBar: PageAppBar(
        isPerfilView: (widget.acountId == null),
        manager: manager,
      ),
      pageIndex: null,
    );
  }
}
