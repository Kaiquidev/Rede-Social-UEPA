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

  // ---------------------------------------------------------------------------
  // Seed
  // ---------------------------------------------------------------------------

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
    final uid = authStore.currentUser?.uid;
    if (uid == null) return;

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

  void createPost({
    required String conteudo,
    PostMediaType mediaType = PostMediaType.none,
    String mediaPath = '',
  }) {
    final user = authStore.currentUser;
    if (user == null) return;

    postStore.createPost(
      authorId: user.uid,
      authorName: user.nomeCompleto,
      authorPhoto: user.fotoUrl,
      cursoAutor: user.curso,
      conteudo: conteudo,
      mediaType: mediaType,
      mediaPath: mediaPath,
    );
  }

  void removePost(String postId) => postStore.removePost(postId);

  void toggleCurtida(String postId) {
    final uid = authStore.currentUser?.uid;
    if (uid == null) return;

    final post = posts.firstWhere(
      (p) => p.id == postId,
      orElse: () => throw StateError('Post não encontrado'),
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

    // Notifica o autor do post se não for o próprio comentarista
    if (updatedPost != null && updatedPost.authorId != user.uid) {
      notificationStore.add(
        userId: updatedPost.authorId,
        title: 'Novo comentário',
        body: '${user.nomeCompleto} comentou na sua publicação.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Notificações
  // ---------------------------------------------------------------------------

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
