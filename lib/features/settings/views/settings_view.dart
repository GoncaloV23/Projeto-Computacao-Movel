import 'package:flutter/material.dart';
import 'package:ips_link/base/base.dart';
import 'package:ips_link/manager.dart';

class SettingsView extends StatelessWidget {
  SettingsView({super.key, required this.manager});
  Manager manager;
  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      manager: manager,
      body: SettingsWidget(manager: manager),
      appBar: PageAppBar(manager: manager),
    );
  }
}

class SettingsWidget extends StatefulWidget {
  SettingsWidget({super.key, required this.manager});
  Manager manager;
  @override
  State<StatefulWidget> createState() => _SettingsState(manager: manager);
}

class _SettingsState extends State<SettingsWidget> {
  _SettingsState({required this.manager});
  Manager manager;
  bool _isLoading = false;
  @override
  void initState() {
    _loadData();

    super.initState();
  }

  Map<String, bool> permissions = {
    "messages": true,
    "camera": true,
    "location": false,
    "microphone": true,
    "light": true
  };
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    await manager.getPermissions(permissions);
    setState(() {
      _isLoading = false;
    });
  }

  void _chagePermission(String permission, bool value) {
    manager.setPermissions({permission: value});

    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: (_isLoading)
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                        child: Column(
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          'Definições',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 80,
                        ),
                        Text(
                          'Notificações',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Mensagens',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                Switch(
                                  inactiveTrackColor: Colors.red,
                                  value: permissions['messages']!,
                                  onChanged: (val) =>
                                      {_chagePermission('messages', val)},
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.white54, width: 3)))),
                        SizedBox(
                          height: 80,
                        ),
                        Text(
                          'Permissões',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Localização',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                Switch(
                                  inactiveTrackColor: Colors.red,
                                  onChanged: (val) =>
                                      {_chagePermission('location', val)},
                                  value: permissions['location']!,
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.white54, width: 3)))),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Camara    ',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                Switch(
                                  inactiveTrackColor: Colors.red,
                                  onChanged: (val) =>
                                      {_chagePermission('camera', val)},
                                  value: permissions['camera']!,
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.white54, width: 3)))),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Microfone',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                Switch(
                                  inactiveTrackColor: Colors.red,
                                  onChanged: (val) =>
                                      {_chagePermission('microphone', val)},
                                  value: permissions['microphone']!,
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.white54, width: 3)))),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Claridade',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                Switch(
                                  inactiveTrackColor: Colors.red,
                                  onChanged: (val) =>
                                      {_chagePermission('light', val)},
                                  value: permissions['light']!,
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.white54, width: 3)))),
                        SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                            onPressed: () => {manager.endSession()},
                            child: Text('Terminar Sessão'),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color?>(
                                        Colors.red))),
                      ],
                    )))));
  }
}
