import 'dart:ui';

import '../users/user.dart';

class Post {
  Post(
      {required this.title,
      required this.id,
      required this.forumId,
      this.description,
      required this.acountId,
      this.imageUrl,
      List<String>? downVotesIds,
      List<String>? upVotesIds}) {
    this.downVotesIds = (downVotesIds != null) ? downVotesIds : <String>[];
    this.upVotesIds = (upVotesIds != null) ? upVotesIds : <String>[];
  }
  int id;
  int forumId;
  String title;
  String? description;
  String acountId;
  String? imageUrl;
  late List<String> upVotesIds;
  late List<String> downVotesIds;

  int getNumberOfUpVotes() {
    return upVotesIds.length;
  }

  int getNumberOfDownVotes() {
    return downVotesIds.length;
  }

  bool acountHasUpVoted(String id) {
    return upVotesIds.contains(id);
  }

  bool acountHasDownVoted(String id) {
    return downVotesIds.contains(id);
  }

  void addUpVote(String id) {
    upVotesIds.add(id);
  }

  void addDownVote(String id) {
    downVotesIds.add(id);
  }

  void removeUpVote(String id) {
    upVotesIds.remove(id);
  }

  void removeDownVote(String id) {
    downVotesIds.remove(id);
  }
}
