import 'package:flutter/foundation.dart';

import '../../models/user_model.dart';

class UserStore extends ChangeNotifier {
  final List<UserModel> _users = <UserModel>[];

  final List<String> _courses = <String>[
    'Administração',
    'Direito',
    'Enfermagem',
    'Medicina',
    'Psicologia',
    'Pedagogia',
    'Engenharia Civil',
    'Ciência da Computação',
    'Sistemas de Informação',
    'Educação Física',
  ];

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  List<UserModel> get users => List<UserModel>.unmodifiable(_users);
  List<String> get courses => List<String>.from(_courses)..sort();

  UserModel? getUserById(String userId) {
    try {
      return _users.firstWhere((item) => item.uid == userId);
    } catch (_) {
      return null;
    }
  }

  bool isFollowing({
    required String currentUserId,
    required String targetUserId,
  }) {
    final me = getUserById(currentUserId);
    if (me == null) return false;
    return me.seguindo.contains(targetUserId);
  }

  /// Verifica se [viewerId] pode interagir (curtir/comentar) com posts de [authorId].
  /// Regra: se o autor tem perfil privado, só seguidores podem interagir.
  bool podeInteragir({
    required String viewerId,
    required String authorId,
  }) {
    if (viewerId == authorId) return true; // próprio autor sempre pode
    final author = getUserById(authorId);
    if (author == null) return false;
    if (!author.perfilPrivado) return true; // perfil público — todos podem
    return author.seguidores.contains(viewerId); // privado — só seguidores
  }

  // ---------------------------------------------------------------------------
  // Seed
  // ---------------------------------------------------------------------------

  void seed(List<UserModel> users) {
    if (_users.isNotEmpty) return;
    _users.addAll(users);
  }

  // ---------------------------------------------------------------------------
  // Registro
  // ---------------------------------------------------------------------------

  String? registerUser(UserModel user) {
    final emailExists = _users.any(
      (item) => item.email.toLowerCase() == user.email.toLowerCase(),
    );
    if (emailExists) return 'Este e-mail já está cadastrado.';

    final cpfExists = _users.any((item) => item.cpf == user.cpf);
    if (cpfExists) return 'Este CPF já está cadastrado.';

    _users.add(user);
    if (!_courses.contains(user.curso)) _courses.add(user.curso);
    notifyListeners();
    return null;
  }

  // ---------------------------------------------------------------------------
  // Perfil
  // ---------------------------------------------------------------------------

  UserModel? updateProfile({
    required String uid,
    required String nomeCompleto,
    required String curso,
    required String instagram,
    required String biografia,
    required String fotoUrl,
  }) {
    final index = _users.indexWhere((item) => item.uid == uid);
    if (index == -1) return null;

    final updated = _users[index].copyWith(
      nomeCompleto: nomeCompleto.trim(),
      curso: curso.trim(),
      instagram: instagram.trim(),
      biografia: biografia.trim(),
      fotoUrl: fotoUrl.trim(),
    );

    _users[index] = updated;
    notifyListeners();
    return updated;
  }

  // ---------------------------------------------------------------------------
  // Toggle perfil privado
  // ---------------------------------------------------------------------------

  UserModel? togglePerfilPrivado(String uid) {
    final index = _users.indexWhere((u) => u.uid == uid);
    if (index == -1) return null;

    final updated =
        _users[index].copyWith(perfilPrivado: !_users[index].perfilPrivado);
    _users[index] = updated;
    notifyListeners();
    return updated;
  }

  // ---------------------------------------------------------------------------
  // Seguir / Deixar de seguir
  // ---------------------------------------------------------------------------

  bool? toggleFollow({
    required String currentUserId,
    required String targetUserId,
  }) {
    if (currentUserId == targetUserId) return null;

    final myIndex = _users.indexWhere((u) => u.uid == currentUserId);
    final targetIndex = _users.indexWhere((u) => u.uid == targetUserId);
    if (myIndex == -1 || targetIndex == -1) return null;

    final me = _users[myIndex];
    final target = _users[targetIndex];

    final myFollowing = List<String>.from(me.seguindo, growable: true);
    final targetFollowers =
        List<String>.from(target.seguidores, growable: true);

    final nowFollowing = !myFollowing.contains(targetUserId);

    if (nowFollowing) {
      myFollowing.add(targetUserId);
      targetFollowers.add(currentUserId);
    } else {
      myFollowing.remove(targetUserId);
      targetFollowers.remove(currentUserId);
    }

    _users[myIndex] = me.copyWith(seguindo: myFollowing);
    _users[targetIndex] = target.copyWith(seguidores: targetFollowers);

    notifyListeners();
    return nowFollowing;
  }

  // ---------------------------------------------------------------------------
  // Admin
  // ---------------------------------------------------------------------------

  UserModel? toggleUserStatus(String userId) {
    final index = _users.indexWhere((user) => user.uid == userId);
    if (index == -1) return null;

    final updated = _users[index].copyWith(ativo: !_users[index].ativo);
    _users[index] = updated;
    notifyListeners();
    return updated;
  }

  // ---------------------------------------------------------------------------
  // Cursos
  // ---------------------------------------------------------------------------

  void addCourse(String courseName) {
    final course = courseName.trim();
    if (course.isEmpty || _courses.contains(course)) return;
    _courses.add(course);
    notifyListeners();
  }

  void updateCourse(String oldName, String newName) {
    final novo = newName.trim();
    if (novo.isEmpty) return;

    final index = _courses.indexOf(oldName);
    if (index == -1) return;
    _courses[index] = novo;

    for (int i = 0; i < _users.length; i++) {
      if (_users[i].curso == oldName) {
        _users[i] = _users[i].copyWith(curso: novo);
      }
    }
    notifyListeners();
  }

  void removeCourse(String courseName) {
    _courses.remove(courseName);
    notifyListeners();
  }
}
