import 'package:flutter/foundation.dart';

import '../../models/app_notification_model.dart';
import '../../models/comment_model.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import 'auth_store.dart';
import 'notification_store.dart';
import 'post_store.dart';
import 'user_store.dart';

/// Fachada central que mantém 100% da API pública original.
///
/// Internamente delega toda a lógica para quatro stores especializados:
///   - [AuthStore]         → sessão / login / logout
///   - [UserStore]         → usuários, cursos, seguir, perfil
///   - [PostStore]         → posts, curtidas, comentários
///   - [NotificationStore] → notificações in-app
///
/// Nenhuma página ou controller precisa ser alterado.
class AppStore extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Stores internos — inicializados antes do construtor rodar
  // (Dart inicializa field initializers antes do corpo do construtor)
  // ---------------------------------------------------------------------------

  final AuthStore authStore = AuthStore();
  final UserStore userStore = UserStore();
  final PostStore postStore = PostStore();
  final NotificationStore notificationStore = NotificationStore();

  AppStore._internal() {
    // Propaga qualquer notifyListeners dos stores filhos para os
    // listeners do AppStore (ex: widgets que chamam addListener(AppStore))
    authStore.addListener(notifyListeners);
    userStore.addListener(notifyListeners);
    postStore.addListener(notifyListeners);
    notificationStore.addListener(notifyListeners);

    _seed();
  }

  static final AppStore instance = AppStore._internal();

<<<<<<< HEAD
  // ---------------------------------------------------------------------------
  // Seed
  // ---------------------------------------------------------------------------
=======
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
>>>>>>> 2e6868e4a8ecc016b2cc80022d23334c9f3d616c

  void _seed() {
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

    userStore.seed([admin, aluna, professor]);

    postStore.seed([
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

<<<<<<< HEAD
  // ===========================================================================
  // API PÚBLICA — idêntica à versão original
  // ===========================================================================

  // ---------------------------------------------------------------------------
  // Usuário atual / sessão
  // ---------------------------------------------------------------------------

  UserModel? get currentUser => authStore.currentUser;
  bool get isLoggedIn => authStore.isLoggedIn;

  String? login({required String email, required String senha}) {
    return authStore.login(
      email: email,
      senha: senha,
      users: userStore.users,
    );
=======
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
>>>>>>> 2e6868e4a8ecc016b2cc80022d23334c9f3d616c
  }

  void logout() => authStore.logout();

  // ---------------------------------------------------------------------------
  // Usuários
  // ---------------------------------------------------------------------------

  List<UserModel> get users => userStore.users;
  List<String> get courses => userStore.courses;

  UserModel? getUserById(String userId) => userStore.getUserById(userId);

  String? registerUser(UserModel user) => userStore.registerUser(user);

  void toggleUserStatus(String userId) {
    final updated = userStore.toggleUserStatus(userId);
    if (updated != null) {
      authStore.invalidateIfDisabled(userId);
    }
  }

  bool isFollowing(String targetUserId) {
    final uid = authStore.currentUser?.uid;
    if (uid == null) return false;
    return userStore.isFollowing(
      currentUserId: uid,
      targetUserId: targetUserId,
    );
  }

  void toggleFollow(String targetUserId) {
    final uid = authStore.currentUser?.uid;
    if (uid == null) return;

    final nowFollowing = userStore.toggleFollow(
      currentUserId: uid,
      targetUserId: targetUserId,
    );

    // Sincroniza currentUser no AuthStore após mudança de seguindo
    final updatedMe = userStore.getUserById(uid);
    if (updatedMe != null) authStore.syncCurrentUser(updatedMe);

    // Dispara notificação ao alvo quando começa a seguir
    if (nowFollowing == true) {
      final me = authStore.currentUser;
      if (me != null) {
        notificationStore.add(
          userId: targetUserId,
          title: 'Novo seguidor',
          body: '${me.nomeCompleto} começou a seguir você.',
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Cursos
  // ---------------------------------------------------------------------------

  void addCourse(String courseName) => userStore.addCourse(courseName);
  void updateCourse(String oldName, String newName) =>
      userStore.updateCourse(oldName, newName);
  void removeCourse(String courseName) => userStore.removeCourse(courseName);

  // ---------------------------------------------------------------------------
  // Perfil
  // ---------------------------------------------------------------------------

  void updateCurrentUserProfile({
    required String nomeCompleto,
    required String curso,
    required String instagram,
    required String biografia,
    required String fotoUrl,
  }) {
<<<<<<< HEAD
    final uid = authStore.currentUser?.uid;
    if (uid == null) return;
=======
    try {
      final user = _users.firstWhere(
        (item) => item.email.toLowerCase() == email.toLowerCase().trim(),
      );
>>>>>>> 2e6868e4a8ecc016b2cc80022d23334c9f3d616c

    final updated = userStore.updateProfile(
      uid: uid,
      nomeCompleto: nomeCompleto,
      curso: curso,
      instagram: instagram,
      biografia: biografia,
      fotoUrl: fotoUrl,
    );

    if (updated == null) return;

    // Mantém AuthStore em sincronia
    authStore.syncCurrentUser(updated);

    // Propaga as alterações de nome/foto para os posts já publicados
    postStore.syncAuthorData(
      authorId: uid,
      authorName: updated.nomeCompleto,
      authorPhoto: updated.fotoUrl,
      cursoAutor: updated.curso,
    );
  }

  // ---------------------------------------------------------------------------
  // Posts
  // ---------------------------------------------------------------------------

  List<PostModel> get posts => postStore.posts;

  List<PostModel> postsByUser(String userId) => postStore.postsByUser(userId);

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
    final user = authStore.currentUser;
    if (user == null) return;

<<<<<<< HEAD
    postStore.createPost(
      authorId: user.uid,
      authorName: user.nomeCompleto,
      authorPhoto: user.fotoUrl,
      cursoAutor: user.curso,
      conteudo: conteudo,
      mediaType: mediaType,
      mediaPath: mediaPath,
=======
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
>>>>>>> 2e6868e4a8ecc016b2cc80022d23334c9f3d616c
    );
  }

  void removePost(String postId) => postStore.removePost(postId);

  void toggleCurtida(String postId) {
    final uid = authStore.currentUser?.uid;
    if (uid == null) return;

<<<<<<< HEAD
    final post = posts.firstWhere(
      (p) => p.id == postId,
      orElse: () => throw StateError('Post não encontrado'),
=======
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
>>>>>>> 2e6868e4a8ecc016b2cc80022d23334c9f3d616c
    );

    final nowLiked = postStore.toggleCurtida(postId: postId, userId: uid);

    // Notifica o autor se o usuário atual curtiu (e não é o próprio autor)
    if (nowLiked && post.authorId != uid) {
      final me = authStore.currentUser!;
      notificationStore.add(
        userId: post.authorId,
        title: 'Nova curtida',
        body: '${me.nomeCompleto} curtiu sua publicação.',
      );
    }
  }

<<<<<<< HEAD
  // ---------------------------------------------------------------------------
  // Comentários
  // ---------------------------------------------------------------------------

  void addComment({required String postId, required String content}) {
    final user = authStore.currentUser;
    if (user == null) return;

    final updatedPost = postStore.addComment(
      postId: postId,
      authorId: user.uid,
      authorName: user.nomeCompleto,
      authorCourse: user.curso,
      content: content,
    );
=======
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
>>>>>>> 2e6868e4a8ecc016b2cc80022d23334c9f3d616c

    // Notifica o autor do post se não for o próprio comentarista
    if (updatedPost != null && updatedPost.authorId != user.uid) {
      notificationStore.add(
        userId: updatedPost.authorId,
        title: 'Novo comentário',
        body: '${user.nomeCompleto} comentou na sua publicação.',
      );
    }
  }

<<<<<<< HEAD
  // ---------------------------------------------------------------------------
  // Notificações
  // ---------------------------------------------------------------------------
=======
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
>>>>>>> 2e6868e4a8ecc016b2cc80022d23334c9f3d616c

  List<AppNotificationModel> get currentUserNotifications {
    final uid = authStore.currentUser?.uid;
    if (uid == null) return [];
    return notificationStore.notificationsForUser(uid);
  }

  void markNotificationsAsRead() {
    final uid = authStore.currentUser?.uid;
    if (uid == null) return;
    notificationStore.markAllAsRead(uid);
  }
}
