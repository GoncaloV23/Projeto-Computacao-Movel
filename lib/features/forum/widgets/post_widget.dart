import 'package:flutter/material.dart';
import 'package:ips_link/features/perfil/perfil.dart';
import 'package:ips_link/manager.dart';
import 'package:http/http.dart' as http;

import '../../../models/model.dart';

class PostWidget extends StatefulWidget {
  PostWidget({required this.post, required this.manager});
  Manager manager;
  Post post;
  @override
  State<PostWidget> createState() =>
      _PostWidgetState(post: post, manager: manager);
}

class _PostWidgetState extends State<PostWidget> {
  _PostWidgetState({required this.post, required this.manager});
  Acount? poster;
  Post post;
  Manager manager;
  bool _isLoading = false;
  Image? posterImg = Image.asset(
    'assets/images/Default-Profile-Picture-Transparent-Image.png',
    height: 30,
    width: 30,
  );
  @override
  void initState() {
    _loadData();
    super.initState();
  }

  bool? _liked;
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    await manager.updatePost(post);
    poster = await manager.getAcountWithId(post.acountId);
    _liked = null;
    if (post.upVotesIds.contains(poster!.id)) _liked = true;
    if (post.downVotesIds.contains(poster!.id)) _liked = false;
    if (poster != null &&
        poster!.imageUrl != null &&
        (await http.head(Uri.parse(poster!.imageUrl!)))
                .headers['content-type']
                ?.startsWith('image/') ==
            true) {
      posterImg = Image.network(poster!.imageUrl!);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void pressLikeBtn(bool? liked) async {
    if (liked == null) {
      await manager.addLikeToPost(post.forumId, post.id);
    } else if (liked) {
      await manager.removeLikeToPost(post.forumId, post.id);
    } else {
      await manager.removeDeslikeToPost(post.forumId, post.id);
      await manager.addLikeToPost(post.forumId, post.id);
    }

    await _loadData();
  }

  void pressDeslikeBtn(bool? liked) async {
    if (liked == null) {
      await manager.addDeslikeToPost(post.forumId, post.id);
    } else if (!liked) {
      await manager.removeDeslikeToPost(post.forumId, post.id);
    } else {
      await manager.removeLikeToPost(post.forumId, post.id);
      await manager.addDeslikeToPost(post.forumId, post.id);
    }
    await _loadData();
  }

  void onPerfilPress() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PerfilView(
        manager: manager,
        acountId: poster!.id,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: BorderSide(color: Colors.grey.shade800, width: 3.0),
      ),
      tileColor: Colors.black,
      title: Row(children: [
        IconButton(onPressed: onPerfilPress, icon: posterImg!),
        Text(
          (poster != null) ? poster!.name : '',
          style: TextStyle(color: Colors.white),
        ),
      ]),
      subtitle: PostContent(
        post: post,
        liked: _liked,
        likeCallback: pressLikeBtn,
        deslikeCallback: pressDeslikeBtn,
      ),
    );
  }
}

class PostContent extends StatelessWidget {
  PostContent(
      {super.key,
      required this.post,
      this.liked,
      required this.likeCallback,
      required this.deslikeCallback});
  bool? liked;
  Post post;
  Function deslikeCallback;
  Function likeCallback;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(width: 3, color: Colors.grey)),
        child: Column(children: [
          Text(post.title),
          SizedBox(
            height: 10,
          ),
          (post.imageUrl != null)
              ? Image.network(
                  post.imageUrl!,
                  width: 500,
                )
              : Container(),
          SizedBox(
            height: 30,
          ),
          Text((post.description != null) ? post.description! : ''),
        ]),
      ),
      Row(
        children: [
          IconButton(
            onPressed: () => {likeCallback(liked)},
            icon: Icon(Icons.arrow_circle_up),
            color:
                (liked != null && liked == true) ? Colors.blue : Colors.white,
          ),
          Text(
            '${post.upVotesIds.length}',
            style: TextStyle(color: Colors.white),
          ),
          IconButton(
              onPressed: () => {deslikeCallback(liked)},
              icon: Icon(Icons.arrow_circle_down),
              color: (liked != null && liked == false)
                  ? Colors.red
                  : Colors.white),
          Text(
            '${post.downVotesIds.length}',
            style: TextStyle(color: Colors.white),
          ),
        ],
      )
    ]);
  }
}
