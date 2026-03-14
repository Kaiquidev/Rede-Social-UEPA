import 'package:flutter/foundation.dart';

import '../../models/app_notification_model.dart';
import '../../models/comment_model.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';

class AppStore extends ChangeNotifier {
  AppStore._internal() {
    _seed();
  }

  static final AppStore instance = AppStore._internal();

  final List<UserModel> _users = <UserModel>[];
  final List<PostModel> _posts = <PostModel>[];
  final List<AppNotificationModel> _notifications = <AppNotificationModel>[];

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

  UserModel? _currentUser;

  List<UserModel> get users => List<UserModel>.unmodifiable(_users);

  List<String> get courses => List<String>.from(_courses)..sort();

  List<PostModel> get posts {
    final list = List<PostModel>.from(_posts, growable: true);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<AppNotificationModel> get currentUserNotifications {
    if (_currentUser == null) return [];
    final list = _notifications
        .where((item) => item.userId == _currentUser!.uid)
        .toList(growable: true);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  void _seed() {
    if (_users.isNotEmpty) return;

    final admin = UserModel(
      uid: '1',
      nomeCompleto: 'Administrador UEPA',
      dataNascimento: '01/01/1990',
      curso: 'Administração',
      cpf: '111.444.777-35',
      instagram: '@admin.uepa',
      fotoUrl: '',
      tipoPerfil: 'admin',
      biografia: 'Conta administrativa da rede social UEPA.',
      ativo: true,
      email: 'admin@uepa.com',
      senha: '123456',
    );

    final aluna = UserModel(
      uid: '2',
      nomeCompleto: 'Ana Souza',
      dataNascimento: '04/08/2003',
      curso: 'Enfermagem',
      cpf: '529.982.247-25',
      instagram: '@ana.uepa',
      fotoUrl: '',
      tipoPerfil: 'aluno',
      biografia: 'Acadêmica da UEPA apaixonada por pesquisa e extensão.',
      ativo: true,
      email: 'ana@uepa.com',
      senha: '123456',
      seguidores: const ['3'],
      seguindo: const ['3'],
    );

    final professor = UserModel(
      uid: '3',
      nomeCompleto: 'Prof. Carlos Lima',
      dataNascimento: '10/10/1980',
      curso: 'Sistemas de Informação',
      cpf: '168.995.350-09',
      instagram: '@prof.carlos',
      fotoUrl: '',
      tipoPerfil: 'professor',
      biografia: 'Professor da UEPA.',
      ativo: true,
      email: 'carlos@uepa.com',
      senha: '123456',
      seguidores: const ['2'],
      seguindo: const ['2'],
    );

    _users.addAll([admin, aluna, professor]);

    _posts.addAll([
      PostModel(
        id: 'p1',
        authorId: aluna.uid,
        authorName: aluna.nomeCompleto,
        authorPhoto: aluna.fotoUrl,
        cursoAutor: aluna.curso,
        conteudo: 'Muito feliz em começar mais um semestre na UEPA!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        curtidas: 2,
        likedByUserIds: const ['1', '3'],
        comments: [
          CommentModel(
            id: 'c1',
            postId: 'p1',
            authorId: '3',
            authorName: 'Prof. Carlos Lima',
            authorCourse: 'Sistemas de Informação',
            content: 'Parabéns, Ana! Excelente começo.',
            createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
          ),
        ],
      ),
      PostModel(
        id: 'p2',
        authorId: professor.uid,
        authorName: professor.nomeCompleto,
        authorPhoto: professor.fotoUrl,
        cursoAutor: professor.curso,
        conteudo: 'Parabéns aos alunos pelo desempenho nas apresentações.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        curtidas: 1,
        likedByUserIds: const ['2'],
      ),
    ]);
  }

  String? registerUser(UserModel user) {
    final emailExists = _users.any(
      (item) => item.email.toLowerCase() == user.email.toLowerCase(),
    );
    if (emailExists) {
      return 'Este e-mail já está cadastrado.';
    }

    final cpfExists = _users.any((item) => item.cpf == user.cpf);
    if (cpfExists) {
      return 'Este CPF já está cadastrado.';
    }

    _users.add(user);

    if (!_courses.contains(user.curso)) {
      _courses.add(user.curso);
    }

    notifyListeners();
    return null;
  }

  String? login({
    required String email,
    required String senha,
  }) {
    try {
      final user = _users.firstWhere(
        (item) => item.email.toLowerCase() == email.toLowerCase().trim(),
      );

      if (!user.ativo) {
        return 'Este usuário está desativado pelo administrador.';
      }

      if (user.senha != senha) {
        return 'Senha incorreta.';
      }

      _currentUser = user;
      notifyListeners();
      return null;
    } catch (_) {
      return 'Usuário não encontrado.';
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void updateCurrentUserProfile({
    required String nomeCompleto,
    required String curso,
    required String instagram,
    required String biografia,
    required String fotoUrl,
  }) {
    if (_currentUser == null) return;

    final index = _users.indexWhere((item) => item.uid == _currentUser!.uid);
    if (index == -1) return;

    final updated = _users[index].copyWith(
      nomeCompleto: nomeCompleto.trim(),
      curso: curso.trim(),
      instagram: instagram.trim(),
      biografia: biografia.trim(),
      fotoUrl: fotoUrl.trim(),
    );

    _users[index] = updated;
    _currentUser = updated;

    for (int i = 0; i < _posts.length; i++) {
      if (_posts[i].authorId == updated.uid) {
        _posts[i] = _posts[i].copyWith(
          authorName: updated.nomeCompleto,
          authorPhoto: updated.fotoUrl,
          cursoAutor: updated.curso,
        );
      }
    }

    notifyListeners();
  }

  void createPost({
    required String conteudo,
    PostMediaType mediaType = PostMediaType.none,
    String mediaPath = '',
  }) {
    if (_currentUser == null) return;

    final newPost = PostModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      authorId: _currentUser!.uid,
      authorName: _currentUser!.nomeCompleto,
      authorPhoto: _currentUser!.fotoUrl,
      cursoAutor: _currentUser!.curso,
      conteudo: conteudo.trim(),
      createdAt: DateTime.now(),
      curtidas: 0,
      mediaType: mediaType,
      mediaPath: mediaPath,
      likedByUserIds: const [],
      comments: const [],
    );

    _posts.insert(0, newPost);
    notifyListeners();
  }

  void toggleCurtida(String postId) {
    if (_currentUser == null) return;

    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    final likes = List<String>.from(post.likedByUserIds, growable: true);
    final currentUserId = _currentUser!.uid;

    if (likes.contains(currentUserId)) {
      likes.remove(currentUserId);
    } else {
      likes.add(currentUserId);

      if (post.authorId != currentUserId) {
        _addNotification(
          userId: post.authorId,
          title: 'Nova curtida',
          body: '${_currentUser!.nomeCompleto} curtiu sua publicação.',
        );
      }
    }

    _posts[index] = post.copyWith(
      curtidas: likes.length,
      likedByUserIds: likes,
    );

    notifyListeners();
  }

  void addComment({
    required String postId,
    required String content,
  }) {
    if (_currentUser == null) return;

    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    final comments = List<CommentModel>.from(post.comments, growable: true);

    final comment = CommentModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      postId: postId,
      authorId: _currentUser!.uid,
      authorName: _currentUser!.nomeCompleto,
      authorCourse: _currentUser!.curso,
      content: content.trim(),
      createdAt: DateTime.now(),
    );

    comments.add(comment);

    _posts[index] = post.copyWith(comments: comments);

    if (post.authorId != _currentUser!.uid) {
      _addNotification(
        userId: post.authorId,
        title: 'Novo comentário',
        body: '${_currentUser!.nomeCompleto} comentou na sua publicação.',
      );
    }

    notifyListeners();
  }

  void toggleFollow(String targetUserId) {
    if (_currentUser == null) return;
    if (_currentUser!.uid == targetUserId) return;

    final myIndex = _users.indexWhere((u) => u.uid == _currentUser!.uid);
    final targetIndex = _users.indexWhere((u) => u.uid == targetUserId);

    if (myIndex == -1 || targetIndex == -1) return;

    final me = _users[myIndex];
    final target = _users[targetIndex];

    final myFollowing = List<String>.from(me.seguindo, growable: true);
    final targetFollowers =
        List<String>.from(target.seguidores, growable: true);

    if (myFollowing.contains(targetUserId)) {
      myFollowing.remove(targetUserId);
      targetFollowers.remove(me.uid);
    } else {
      myFollowing.add(targetUserId);
      targetFollowers.add(me.uid);

      _addNotification(
        userId: target.uid,
        title: 'Novo seguidor',
        body: '${me.nomeCompleto} começou a seguir você.',
      );
    }

    final updatedMe = me.copyWith(seguindo: myFollowing);
    final updatedTarget = target.copyWith(seguidores: targetFollowers);

    _users[myIndex] = updatedMe;
    _users[targetIndex] = updatedTarget;
    _currentUser = updatedMe;

    notifyListeners();
  }

  bool isFollowing(String targetUserId) {
    if (_currentUser == null) return false;
    return _currentUser!.seguindo.contains(targetUserId);
  }

  UserModel? getUserById(String userId) {
    try {
      return _users.firstWhere((item) => item.uid == userId);
    } catch (_) {
      return null;
    }
  }

  void markNotificationsAsRead() {
    if (_currentUser == null) return;

    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == _currentUser!.uid &&
          !_notifications[i].read) {
        _notifications[i] = _notifications[i].copyWith(read: true);
      }
    }

    notifyListeners();
  }

  void _addNotification({
    required String userId,
    required String title,
    required String body,
  }) {
    _notifications.add(
      AppNotificationModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        userId: userId,
        title: title,
        body: body,
        createdAt: DateTime.now(),
      ),
    );
  }

  void removePost(String postId) {
    _posts.removeWhere((post) => post.id == postId);
    notifyListeners();
  }

  void toggleUserStatus(String userId) {
    final index = _users.indexWhere((user) => user.uid == userId);
    if (index == -1) return;

    final selected = _users[index];
    _users[index] = selected.copyWith(ativo: !selected.ativo);

    if (_currentUser?.uid == userId && !_users[index].ativo) {
      _currentUser = null;
    }

    notifyListeners();
  }

  void addCourse(String courseName) {
    final course = courseName.trim();
    if (course.isEmpty) return;
    if (_courses.contains(course)) return;
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

  List<PostModel> postsByUser(String userId) {
    final result =
        _posts.where((post) => post.authorId == userId).toList(growable: true);

    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }
}
