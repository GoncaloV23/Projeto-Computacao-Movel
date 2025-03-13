import 'package:flutter/material.dart';
import 'package:ips_link/utils/show_snackbar.dart';

import '../../manager.dart';
import 'add_book.dart';

class LibraryList extends StatefulWidget {
  Manager manager;

  LibraryList({super.key, required this.manager});
  @override
  State<LibraryList> createState() => _LibraryListState();
}

class _LibraryListState extends State<LibraryList> {
  bool _isLoading = false;
  List<Book> books = [];
  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    books.clear();
    await widget.manager.getBooks(books);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (_isLoading)
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
            child: RefreshIndicator(
                onRefresh: _loadData,
                child: Stack(children: [
                  Expanded(
                      child: ListView.builder(
                    itemBuilder: (context, index) {
                      return LibraryListTile(
                        manager: widget.manager,
                        book: books[index],
                      );
                    },
                    itemCount: books.length,
                  )),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              AddbookWidget(manager: widget.manager),
                        ));
                      },
                      child: Icon(Icons.add),
                    ),
                  ),
                ])));
  }
}

class LibraryListTile extends StatefulWidget {
  Manager manager;
  Book book;

  LibraryListTile({super.key, required this.book, required this.manager});
  @override
  State<LibraryListTile> createState() => _LibraryListTileState();
}

class _LibraryListTileState extends State<LibraryListTile> {
  bool _isLoading = false;
  String acount = '';
  String button = 'Sem Stock';
  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    widget.book.acounts.clear();
    await widget.manager.getBookAcounts(widget.book);
    acount = (await widget.manager.getAcount())!.id;
    if (widget.book.acounts.contains(acount)) {
      button = 'Reservado';
    } else if (widget.book.acounts.length < widget.book.numberOfBooks) {
      button = 'Reservar';
    } else {
      button = 'Sem Stock';
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  void _onClick() {
    if (button == 'Reservado') {
      widget.manager.removetBookAcount(widget.book);
      _loadData();
      return;
    }
    if (button == 'Reservar') {
      widget.manager.addtBookAcount(widget.book);
      _loadData();
      return;
    }
    showSnackbar(
        context: context,
        message: 'Está sem stock',
        backgroundColor: Colors.red);
    _loadData();
    return;
  }

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
        contentPadding: const EdgeInsets.all(10),
        textColor: Colors.white,
        style: ListTileStyle.list,
        shape: BorderDirectional(bottom: BorderSide(color: Colors.white30)),
        child: ListTile(
          title: Text(widget.book.title),
          trailing: ElevatedButton(
            child: Container(
              width: 80,
              child: Text(button),
            ),
            onPressed: _onClick,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (widget.book.acounts.contains(acount)) return Colors.blue;
                  if (widget.book.acounts.length < widget.book.numberOfBooks)
                    return Colors.green;
                  return Colors.red;
                },
              ),
            ),
          ),
        ));
  }
}

class Book {
  String title;
  int numberOfBooks;
  List<String> acounts;

  Book({
    required this.acounts,
    required this.numberOfBooks,
    required this.title,
  });
}
