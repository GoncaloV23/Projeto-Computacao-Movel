import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:light/light.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'features/library/library_widgets.dart';
import 'features/login/authentication_page.dart';
import 'features/main_page/main_page.dart';
import 'features/notifications/notifications.dart';
import 'firebase/firebase.dart';
import 'models/model.dart';
import 'base/base.dart';
import 'features/perfil/perfil.dart';
import 'features/perfil/widgets/perfil_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Manager {
  late final StreamSubscription<int> _subscription;
  ScreenBrightness _screenBrightness = ScreenBrightness();

  Messaging messager = Messaging();
  bool notificationPermission = false;
  Acount? _acount;
  GlobalKey<NavigatorState> navigatorKey;
  BuildContext? context;
  Authentication fb = Authentication();
  Manager({required this.navigatorKey}) {
    init();

    _initLightSensor();
  }

  void dispose() {
    _subscription.cancel();
  }

  void _initLightSensor() async {
    bool hasPermission = await getPermission('light');
    if (!hasPermission) return;
    _subscription = Light().lightSensorStream.listen(
      (int data) {
        double brightness = 0.3 + data.clamp(0, 1000) / 2000;
        // Supondo que o valor máximo do sensor de luz seja 1000 lux
        brightness = brightness.clamp(0, 1);
        _screenBrightness.setScreenBrightness(brightness);
      },
      onError: (e) {
        ScaffoldMessenger.of(context!)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Falhou a obter dados do sensor de luz!'),
              backgroundColor: Colors.red,
            ),
          );
      },
      cancelOnError: true,
    );
  }

  void setContext({required BuildContext context}) {
    this.context = context;
  }

  void init() async {
    fb.checkAutentication(
        callBackOnLogin: initNotifications,
        navigatorKey: navigatorKey,
        logedWidget: (_) => BaseWidget(
              manager: this,
              appBar: BaseAppBar(manager: this),
              body: MainPage(manager: this),
              pageIndex: 0,
            ),
        notLogedWidget: (_) => AuthenticationPage(
              manager: this,
            ));
  }

  void initNotifications() async {
    bool hasPermission = await getPermission('messages');
    if (!hasPermission) return;
    notificationPermission = await messager.checkPermission();
    if (notificationPermission) {
      String? token = await messager.getToken();
      Database.update(
          id: fb.getUserId(), databasePath: 'users', data: {'token': token});

      messager.initListeners(navigatorKey);
    }
  }

  Future<Acount?> getAcount() async {
    if (fb.getUserId() == null) return null;
    String id = fb.getUserId()!;
    Map map = await Database.query(databasePath: 'users', id: id);
    Map entrys = (map['folowing'] != null) ? map['folowing'] : {};
    List<int> forums = [];
    Iterator it = entrys.values.iterator;
    while (it.moveNext()) {
      forums.add(it.current['value'] as int);
    }
    _acount = Acount(
        type: getUserType(map['type']),
        id: id,
        name: map['name'],
        email: map['email'],
        imageUrl: map['imgUrl'],
        forumsFolowing: forums);

    return _acount!;
  }

  Future<Acount?> getAcountWithId(String id) async {
    try {
      Map map = await Database.query(databasePath: 'users', id: id);

      Acount? acount = Acount(
          type: getUserType(map['type']),
          id: id,
          name: map['name'],
          email: map['email'],
          imageUrl: map['imgUrl']);
      return acount;
    } catch (e) {}
    return null;
  }

  Future<bool> updateAcount(Acount acount) async {
    if (!(await fb.changeAcount(acount))) return false;
    Database.update(databasePath: 'users', id: acount.id, data: {
      'name': acount.name,
      'email': acount.email,
      'imgUrl': acount.imageUrl
    });

    await getAcount();

    return true;
  }

  Future<bool> getPermission(String permission) async {
    Map<String, bool> aux = {permission: false};
    await getPermissions(aux);
    return aux[permission]!;
  }

  Future<void> getPermissions(Map<String, bool> permissions) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Iterator<MapEntry<String, bool>> it = permissions.entries.iterator;

    while (it.moveNext()) {
      MapEntry<String, bool> entry = it.current;
      bool? val = await prefs.getBool(entry.key);
      permissions[entry.key] = (val == null) ? false : val;
    }
  }

  Future<void> setPermissions(Map<String, bool> permissions) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Iterator<MapEntry<String, bool>> it = permissions.entries.iterator;

    while (it.moveNext()) {
      MapEntry<String, bool> entry = it.current;
      await prefs.setBool(entry.key, entry.value);
    }
  }

  Future<bool> logIn({required String email, required String password}) async {
    return await fb.logIn(email: email, pass: password);
  }

  Future<bool> singIn(
      {required String email,
      required String name,
      required String password,
      required UserType type}) async {
    if (await fb.signIn(
        email: email, password: password, name: name, type: type)) {
      await Database.insert(id: fb.getUserId()!, databasePath: 'users', data: {
        'type': userTypeToString(type),
        'name': name,
        'email': email,
      });

      setPermissions({
        "messages": true,
        "camera": true,
        "location": false,
        "microphone": true,
        "light": true
      });
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (_) => BaseWidget(
            manager: this,
            appBar: BaseAppBar(manager: this),
            body: Container(),
            pageIndex: 0,
          ),
        ),
      );
      return true;
    }
    return false;
  }

  void endSession() {
    fb.endSession();
  }

  Future<void> getPosts(
      {required int forumId, required List<Post> posts}) async {
    posts.clear();
    List? list =
        await Database.query(databasePath: 'forums', id: '$forumId/posts');
    if (list == null) return;
    for (int i = 0; i < list!.length; i++) {
      Map postQuery = list[i];

      int id = i;
      String title = postQuery!['title'];
      String acountId = postQuery['acountId'];
      String? description = postQuery['description'];
      String? imageUrl = postQuery['imageUrl'];
      Map<String, Object?>? auxUp = (postQuery['upVotesIds'] != null)
          ? postQuery['upVotesIds'].cast<String, Object?>()
          : null;
      List<String>? upVotesIds = (auxUp != null) ? auxUp.keys.toList() : null;
      Map<String, Object?>? auxDown = (postQuery['downVotesIds'] != null)
          ? postQuery['downVotesIds'].cast<String, Object?>()
          : null;
      List<String>? downVotesIds =
          (auxDown != null) ? auxDown.keys.toList() : null;
      Post newPost = Post(
          forumId: forumId,
          title: title,
          id: id,
          acountId: acountId,
          description: description,
          imageUrl: imageUrl,
          upVotesIds: upVotesIds,
          downVotesIds: downVotesIds);
      posts.add(newPost);
    }
  }

  Future<void> addLikeToPost(int forumId, int postId) async {
    Database.update(
        databasePath: 'forums/$forumId/posts',
        id: '$postId/upVotesIds/${fb.getUserId()}',
        data: <String, Object?>{'liked': true});
  }

  Future<void> removeLikeToPost(int forumId, int postId) async {
    Database.remove(
        databasePath: 'forums/$forumId/posts',
        id: '$postId/upVotesIds/${fb.getUserId()}');
  }

  Future<void> addDeslikeToPost(int forumId, int postId) async {
    Database.update(
        databasePath: 'forums/$forumId/posts',
        id: '$postId/downVotesIds/${fb.getUserId()}',
        data: <String, Object?>{'desliked': true});
  }

  Future<void> removeDeslikeToPost(int forumId, int postId) async {
    Database.remove(
        databasePath: 'forums/$forumId/posts',
        id: '$postId/downVotesIds/${fb.getUserId()}');
  }

  Future<void> getForums(List<Forum> forums) async {
    forums.clear();
    List forumsQuery = await Database.query(databasePath: 'forums', id: '');
    for (int i = 0; i < forumsQuery.length; i++) {
      Map? query = forumsQuery[i];
      if (query == null) continue;
      Forum forum = Forum(
          id: i,
          acountId: query['acountId'],
          title: query['title'],
          posts: null,
          imageUrl: query['imageUrl']);
      forums.add(forum);
    }
  }

  Future<void> createPost(
      {required int forumId,
      File? img,
      required String title,
      String? description}) async {
    String? imageUrl;
    if (img != null) imageUrl = await FileStorage.uploadFile(img);
    List? posts =
        await Database.query(databasePath: 'forums/$forumId/posts', id: '');

    if (posts == null) posts = [];
    Database.insert(
        id: '${posts.length}',
        databasePath: 'forums/$forumId/posts',
        data: {
          'acountId': fb.getUserId(),
          'imageUrl': imageUrl,
          'title': title,
          'description': description,
        });
  }

  Future<void> createForum({required String title, File? img}) async {
    String? imageUrl;
    if (img != null) imageUrl = await FileStorage.uploadFile(img);
    List? forums = await Database.query(databasePath: 'forums', id: '');
    int index = forums == null ? 0 : forums.length;
    Database.insert(id: '${index}', databasePath: 'forums', data: {
      'acountId': fb.getUserId(),
      'title': title,
      'imageUrl': imageUrl
    });
  }

  Future<void> updatePost(Post post) async {
    Map postQuery = await Database.query(
        databasePath: 'forums/${post.forumId}/posts', id: '${post.id}');

    Map<String, Object?>? auxUp = (postQuery['upVotesIds'] != null)
        ? postQuery['upVotesIds'].cast<String, Object?>()
        : null;
    Map<String, Object?>? auxDown = (postQuery['downVotesIds'] != null)
        ? postQuery['downVotesIds'].cast<String, Object?>()
        : null;

    post.downVotesIds = (auxDown != null) ? auxDown.keys.toList() : [];
    post.upVotesIds = (auxUp != null) ? auxUp.keys.toList() : [];
  }

  Future<void> folowForum(int forumId) async {
    Database.update(
        databasePath: 'users/${fb.getUserId()}/folowing',
        id: 'forum$forumId',
        data: {'value': forumId});
  }

  Future<void> unFolowForum(int forumId) async {
    Database.remove(
        databasePath: 'users/${fb.getUserId()}/folowing', id: 'forum$forumId');
  }

  Future<void> getAllAcount(List<Acount> acounts) async {
    Map<String, dynamic> query =
        (await Database.query(databasePath: 'users', id: ''))
            .cast<String, dynamic>();
    Iterator<String> it = query.keys.iterator;
    String userId = fb.getUserId()!;
    while (it.moveNext()) {
      String id = it.current;
      if (userId == id) continue;
      Acount? acount = await getAcountWithId(id);
      if (acount == null) continue;
      acounts.add(acount);
    }
  }

  Future<void> createChattingAcount(Acount acount) async {
    Database.insert(
        id: acount.id,
        databasePath: 'users/${fb.getUserId()}/chats',
        data: {'messages': ''});
  }

  Future<void> getChattingAcounts(
      List<Acount> acounts, Map<String, MapEntry<String, int>> chats) async {
    Map? aux = (await Database.query(
        databasePath: 'users/${fb.getUserId()}/chats', id: ''));
    Map<String, dynamic> query = aux == null ? {} : aux.cast<String, dynamic>();
    Iterator<String> it = query.keys.iterator;
    String userId = fb.getUserId()!;
    while (it.moveNext()) {
      String id = it.current;
      if (userId == id) continue;
      Acount? acount = await getAcountWithId(id);
      if (acount == null) continue;
      acounts.add(acount);
      List aux = query['${acount.id}'];
      Map<String, String> m = aux[aux.length - 1].cast<String, String>();
      String? key = m['message'];
      chats['${acount.id}'] =
          MapEntry((key == null) ? 'Enviou-lhe algo' : key, aux.length);
    }
  }

  Future<void> sendMessage(
      {required String acountId,
      String? message,
      File? audioFile,
      File? imageFile}) async {
    List? messages = await Database.query(
        databasePath: 'users/${fb.getUserId()}/chats/${acountId}', id: '');

    int index = (messages == null) ? 0 : messages.length;
    String? imageUrl;
    String? audioUrl;
    print(audioFile);
    if (imageFile != null) imageUrl = await FileStorage.uploadFile(imageFile);
    if (audioFile != null) audioUrl = await FileStorage.uploadFile(audioFile);
    await Database.insert(
        id: index.toString(),
        databasePath: 'users/${fb.getUserId()}/chats/${acountId}',
        data: {
          'message': message,
          'imgUrl': imageUrl,
          'audioUrl': audioUrl,
          'isReceiver': 'false'
        });
    await Database.insert(
        id: index.toString(),
        databasePath: 'users/${acountId}/chats/${fb.getUserId()}',
        data: {
          'message': message,
          'imgUrl': imageUrl,
          'audioUrl': audioUrl,
          'isReceiver': 'true'
        });
  }

  Future<void> getMessages(List<Message> messagesList,
      {required String acountId}) async {
    List? messages = await Database.query(
        databasePath: 'users/${fb.getUserId()}/chats/${acountId}', id: '');

    if (messages == null) return;

    for (int i = 0; i < messages.length; i++) {
      Map<String, String> map = messages[i].cast<String, String>();
      messagesList.add(
        Message(
            audioUrl: map['audioUrl'],
            imageUrl: map['imgUrl'],
            message: map['message'],
            isRecieved: map['isReceiver']!.toLowerCase() == 'true'),
      );
    }
  }

  Future<void> sendNotification(
      String acountId, String message, String title) async {
    List? notifications = await Database.query(
        databasePath: 'users/$acountId/notifications', id: '');
    int index = (notifications == null) ? 0 : notifications.length;
    await Database.insert(
        id: index.toString(),
        databasePath: 'users/$acountId/notifications',
        data: {
          'message': '${fb.getUserId()} $message',
          'title': title,
        });

    String? token =
        await Database.query(databasePath: 'users/$acountId', id: 'token');
    if (token == null) return;
    messager.sendNotification(token);
  }

  Future<void> resetNotifications() async {
    await Database.remove(
        databasePath: 'users/${fb.getUserId()}/notifications', id: '');
  }

  Future<void> getNotifications(
      List<NotificationData> notificationsList) async {
    List? notifications = await Database.query(
        databasePath: 'users/${fb.getUserId()}/notifications', id: '');

    if (notifications == null) return;

    for (int i = 0; i < notifications.length; i++) {
      Map<String, String> map = notifications[i].cast<String, String>();
      notificationsList.add(NotificationData(
        title: map['title']!,
        message: map['message']!,
        icon: Icons.notification_important,
      ));
    }
  }

  Future<void> addBook(String bookName, int numberOfBooks) async {
    await Database.insert(
        id: bookName,
        databasePath: 'books',
        data: {'number': numberOfBooks.toString()});
  }

  Future<void> getBooks(List<Book> books) async {
    Map map = await Database.query(id: '', databasePath: 'books');
    if (map == null) return;

    map.forEach((key, value) {
      books.add(Book(
          title: key, numberOfBooks: int.parse(value['number']), acounts: []));
    });
  }

  Future<void> getBookAcounts(Book book) async {
    Map? aux = await Database.query(
        id: '${book.title}/acounts', databasePath: 'books');
    if (aux == null) return;
    Map<String, dynamic>? map = aux.cast<String, dynamic>();

    List<String> acounts = [];
    map.forEach((key, value) {
      acounts.add(key);
    });

    book.acounts = acounts;
  }

  Future<void> addtBookAcount(Book book) async {
    Database.update(
        id: '${fb.getUserId()}',
        databasePath: 'books/${book.title}/acounts',
        data: {'hasBook': 'true'});
  }

  Future<void> removetBookAcount(Book book) async {
    Database.remove(
        id: '${fb.getUserId()}', databasePath: 'books/${book.title}/acounts');
  }
}
