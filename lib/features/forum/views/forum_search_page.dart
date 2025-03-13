import 'package:flutter/material.dart';
import 'package:ips_link/base/base.dart';
import 'package:ips_link/features/forum/widgets/forum_tile_list.dart';
import 'package:ips_link/manager.dart';

import '../../../models/model.dart';

class ForumSearchPage extends StatefulWidget {
  ForumSearchPage({super.key, required this.manager});
  Manager manager;
  @override
  State<ForumSearchPage> createState() =>
      _ForumSearchPageState(manager: manager);
}

class _ForumSearchPageState extends State<ForumSearchPage> {
  _ForumSearchPageState({required this.manager});
  Manager manager;
  final TextEditingController _textFieldController = TextEditingController();
  late final ForumSearchWidgetController _forumSearchWidgetController =
      ForumSearchWidgetController();

  void _search() {
    final searchString = _textFieldController.text;
    _forumSearchWidgetController.updateSearchString(searchString);
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
        manager: manager,
        appBar: SearchAppBar(
            searchCallback: _search,
            manager: manager,
            textFieldController: _textFieldController),
        body: ForumSearchWidget(
          manager: manager,
          controller: _forumSearchWidgetController,
        ));
  }
}

class ForumSearchWidget extends StatefulWidget {
  Manager manager;
  ForumSearchWidget(
      {super.key, required this.manager, required this.controller});

  final ForumSearchWidgetController controller;
  @override
  State<ForumSearchWidget> createState() => _ForumSearchWidgetState(
        manager: manager,
      );
}

class _ForumSearchWidgetState extends State<ForumSearchWidget> {
  _ForumSearchWidgetState({required this.manager});
  String _searchString = '';
  bool _isLoading = false;
  @override
  void initState() {
    _loadData();
    widget.controller.addListener(_update);
    super.initState();
  }

  void _update() {
    if (!mounted) return;
    setState(() {
      _searchString = widget.controller.searchString;
    });
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    print(_searchString);
    forums.clear();
    List<Forum> allForums = [];
    await manager.getForums(allForums);

    allForums.forEach((element) => {
          if (element.title.toLowerCase().contains(_searchString.toLowerCase()))
            {forums.add(element)}
        });
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Manager manager;
  List<Forum> forums = [];
  @override
  Widget build(BuildContext context) {
    return (_isLoading)
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
            child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              itemBuilder: (context, index) {
                return ForumTileList(forum: forums[index], manager: manager);
              },
              itemCount: forums.length,
            ),
          ));
  }
}

class ForumSearchWidgetController extends ChangeNotifier {
  String _searchString = '';

  String get searchString => _searchString;

  void updateSearchString(String searchString) {
    if (_searchString != searchString) {
      _searchString = searchString;
      notifyListeners();
    }
  }
}
