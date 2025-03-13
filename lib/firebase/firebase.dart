import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ips_link/firebase_options.dart';
import 'package:ips_link/models/model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:ips_link/utils/utils.dart';

class FireBase {
  bool _loged = false;

  static Future<bool> start() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      return true;
    } catch (e) {
      print(e.toString());
    }
    return false;
  }
}

class Authentication extends FireBase {
  void checkAutentication(
      {required GlobalKey<NavigatorState> navigatorKey,
      required WidgetBuilder logedWidget,
      required WidgetBuilder notLogedWidget,
      required Function callBackOnLogin}) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
      if (user == null) {
        _loged = false;
        print('Not Logged!');
        // O usuário não está autenticado
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: notLogedWidget,
          ),
        );
      } else {
        _loged = true;
        print('Logged!');
        // O usuário está autenticado
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: logedWidget,
          ),
        );

        callBackOnLogin();
      }
    });
  }

  Future<bool> logIn({required String email, required String pass}) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signIn(
      {required String email,
      required String password,
      required String name,
      String? imageUrl,
      required UserType type}) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Database.insert(id: getUserId()!, databasePath: 'users', data: {
        'email': email,
        'name': name,
        'type': type,
        'imgUrl': imageUrl
      });
      await credential.user?.updateDisplayName(name);

      return true;
    } on FirebaseAuthException catch (e) {
      return false;
    }
  }

  bool isLoged() {
    return _loged;
  }

  String? getUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> endSession() async {
    FirebaseAuth.instance.signOut();
  }

  Future<bool> changeAcount(Acount acount) async {
    if (acount.id != getUserId()) return false;

    await FirebaseAuth.instance.currentUser!.updateDisplayName(acount.name);
    await FirebaseAuth.instance.currentUser!.updateEmail(acount.email);

    return true;
  }
}

class Database extends FireBase {
  static Future<DatabaseReference?> getReference(
      {required String databasePath}) async {
    return await FirebaseDatabase.instance.ref(databasePath);
  }

  static Future<dynamic?> query(
      {required String databasePath, required String id}) async {
    DatabaseReference? db =
        await getReference(databasePath: '${databasePath}/${id}');

    final snapshot = await db?.get();

    if (snapshot?.value == null) return null;
    final query = snapshot?.value;

    return query;
  }

  static update(
      {required String databasePath,
      required final id,
      required final data}) async {
    DatabaseReference? db = await getReference(databasePath: databasePath);
    if (id == null) return;
    db?.child(id).update(data);
  }

  static remove({required String databasePath, required final id}) async {
    DatabaseReference? db = await getReference(databasePath: databasePath);
    db?.child(id!).remove();
  }

  static Future<String?> insert(
      {required String id,
      required String databasePath,
      required final data}) async {
    DatabaseReference? db =
        await getReference(databasePath: '${databasePath}/${id}');

    db?.set(data);

    return db?.key;
  }
}

class FileStorage extends FireBase {
  static Reference firebaseStorageRootRef() {
    return FirebaseStorage.instance.ref();
  }

  static Reference getFirebaseStorageRef(String path) {
    return firebaseStorageRootRef().child(path);
  }

  static Future<String> uploadFile(File fileToUpload) async {
    Reference ref = getFirebaseStorageRef(
        'images/${DateTime.now().microsecondsSinceEpoch.toString()}');
    await ref.putFile(fileToUpload);
    return ref.getDownloadURL();
  }

  static Image downloadImage(String url) {
    return Image.network(url);
  }
}

class Messaging extends FireBase {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final String serverKey =
      'AAAArUKhvo0:APA91bGyUYaX3fOSFQPwfb5l_kIdLJcc2baWXudKkGARRwncYvNaYDkUTr4-gVVRRGvRGW2qvUGSA9orRz8NuVyPIHcJtBwvmQABgttFlwyJRxFDe4VGZXpH93JPRwTHK8funSEnza5G';
  Future<bool> checkPermission() async {
    NotificationSettings settings = await messaging.requestPermission();
    return (settings.authorizationStatus == AuthorizationStatus.authorized);
  }

  Future<String?> getToken() async {
    String? token = await messaging.getToken();
    return token;
  }

  void initListeners(GlobalKey<NavigatorState> navigatorKey) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showSnackbar(
          context: navigatorKey.currentContext!,
          message: message.notification!.title!,
          backgroundColor: Colors.blue);
      print('Notificação recebida: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notificação aberta: ${message.notification?.title}');
    });
  }

  void sendNotification(String? deviceToken) async {
    // Cabeçalhos da requisição HTTP
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    // Corpo da mensagem
    Map<String, dynamic> message = {
      'notification': {
        'title': 'Recebeste uma mensagem nova!',
        'body': 'Acabaste de receber uma mensagem!',
      },
      'priority': 'high',
      'data': {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'id': '1',
        'status': 'done',
      },
      'to': deviceToken,
    };

    // Converter a mensagem para JSON
    String jsonMessage = json.encode(message);

    // Enviar a requisição POST para o servidor FCM
    http.Response response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: headers,
      body: jsonMessage,
    );

    if (response.statusCode == 200) {
      print('Notificação enviada com sucesso');
    } else {
      print(
          'Falha ao enviar a notificação. Status code: ${response.statusCode}');
    }
  }
}
