import 'package:flutter/material.dart';
import 'package:ips_link/features/forum/widgets/post_widget.dart';
import 'package:ips_link/manager.dart';
import 'package:http/http.dart' as http;
import '../../../models/model.dart';
import '../../perfil/perfil.dart';
import 'add_post.dart';

class ForumWidget extends StatefulWidget {
  ForumWidget({super.key, required this.manager, required this.forum});
  Manager manager;
  Forum forum;
  @override
  State<ForumWidget> createState() =>
      _ForumWidgetState(manager: manager, forum: forum);
}

class _ForumWidgetState extends State<ForumWidget> {
  _ForumWidgetState({required this.manager, required this.forum});
  Manager manager;
  Forum forum;
  Acount? userAcount;
  Acount? acount;
  Image? forumImg;
  Image? acountImg;
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    await manager.getPosts(posts: posts, forumId: forum.id);
    acount = await manager.getAcountWithId(forum.acountId);
    userAcount = await manager.getAcount();
    _acountIsFolowing = userAcount!.forumsFolowing!.contains(forum.id);
    forumImg = (forum != null &&
            forum!.imageUrl != null &&
            (await http.head(Uri.parse(forum!.imageUrl!)))
                    .headers['content-type']
                    ?.startsWith('image/') ==
                true)
        ? Image.network(forum!.imageUrl!)
        : Image.asset(
            'assets/images/Ipslink_splashscreen.png',
            height: 100,
            width: 100,
          );
    acountImg = (acount != null &&
            acount!.imageUrl != null &&
            (await http.head(Uri.parse(acount!.imageUrl!)))
                    .headers['content-type']
                    ?.startsWith('image/') ==
                true)
        ? Image.network(acount!.imageUrl!)
        : Image.asset(
            'assets/images/Default-Profile-Picture-Transparent-Image.png',
            height: 30,
            width: 30,
          );
    setState(() {
      _isLoading = false;
    });
  }

  @override
  initState() {
    super.initState();

    _loadData();
  }

  void _folowAcount() {
    (_acountIsFolowing)
        ? manager.unFolowForum(forum.id)
        : manager.folowForum(forum.id);
    _loadData();
  }

  List<Post> posts = [];
  bool _isLoading = false;
  bool _acountIsFolowing = false;

  void onPerfilPress() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PerfilView(
        manager: manager,
        acountId: acount!.id,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return (_isLoading)
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
            child: RefreshIndicator(
                onRefresh: _loadData,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border(
                                bottom:
                                    BorderSide(color: Colors.grey, width: 3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (MediaQuery.of(context).orientation ==
                                    Orientation.portrait)
                                  forumImg!,
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      forum.title,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    IconButton(
                                        onPressed: _folowAcount,
                                        icon: Icon(
                                          (_acountIsFolowing)
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.yellow,
                                        ))
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.center,
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: onPerfilPress,
                                      icon: acountImg!,
                                    ),
                                    Text(
                                      (acount != null) ? acount!.name : '',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              Post post = posts[index];
                              return Container(
                                  margin: EdgeInsets.all(20),
                                  child: PostWidget(
                                    post: post,
                                    manager: manager,
                                  ));
                            },
                            itemCount: posts.length,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: FloatingActionButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => AddPostWidget(
                              forumId: forum.id,
                              manager: manager,
                            ),
                          ));
                        },
                        child: Icon(Icons.add),
                      ),
                    ),
                  ],
                )),
          );
  }
}
