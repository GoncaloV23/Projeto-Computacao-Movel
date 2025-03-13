import 'package:flutter/material.dart';
import 'package:ips_link/models/forum/post.dart';
import 'package:ips_link/models/users/user.dart';

class Forum {
  Forum(
      {required this.id,
      required this.acountId,
      required this.title,
      required List<String>? posts,
      this.imageUrl}) {
    this.posts = (posts != null) ? posts : [];
  }
  int id;
  String acountId;
  String title;
  String? imageUrl;

  late List<String> posts;
}
