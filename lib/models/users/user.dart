enum UserType { visitor, student, professor, department, admin }

UserType getUserType(String type) {
  if (type == 'admin') return UserType.admin;
  if (type == 'student') return UserType.student;
  if (type == 'professor') return UserType.professor;
  if (type == 'department') return UserType.department;
  return UserType.visitor;
}

String userTypeToString(UserType userType) {
  if (userType == UserType.admin) return 'admin';
  if (userType == UserType.student) return 'student';
  if (userType == UserType.professor) return 'professor';
  if (userType == UserType.department) return 'department';
  return 'visitor';
}

class Acount {
  Acount(
      {required this.type,
      required this.id,
      required this.name,
      required this.email,
      this.imageUrl,
      this.deviceToken,
      this.forumsFolowing});
  UserType type;
  String id;
  String email;
  String name;
  String? imageUrl;
  String? deviceToken;
  List<int>? forumsFolowing;
}
