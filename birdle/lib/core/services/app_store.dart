import 'package:flutter/foundation.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';

class AppStore extends ChangeNotifier {
  AppStore._internal() {
    _seed();
  }

  static final AppStore instance = AppStore._internal();

  final List<UserModel> _users = <UserModel>[];
  final List<PostModel> _posts = <PostModel>[];
  UserModel? _currentUser;

  List<UserModel> get users => List<UserModel>.unmodifiable(_users);

  List<PostModel> get posts {
    final List<PostModel> list = List<PostModel>.from(_posts, growable: true);
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
      curso: 'Gestão do Sistema',
      cpf: '11144477735',
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
      cpf: '52998224725',
      instagram: '@ana.uepa',
      fotoUrl: '',
      tipoPerfil: 'aluno',
      biografia: 'Acadêmica da UEPA apaixonada por pesquisa e extensão.',
      ativo: true,
      email: 'ana@uepa.com',
      senha: '123456',
    );

    final professor = UserModel(
      uid: '3',
      nomeCompleto: 'Prof. Carlos Lima',
      dataNascimento: '10/10/1980',
      curso: 'Sistemas de Informação',
      cpf: '16899535009',
      instagram: '@prof.carlos',
      fotoUrl: '',
      tipoPerfil: 'professor',
      biografia: 'Professor da UEPA.',
      ativo: true,
      email: 'carlos@uepa.com',
      senha: '123456',
    );

    _users.addAll([admin, aluna, professor]);

    _posts.addAll([
      PostModel(
        id: 'p1',
        authorId: aluna.uid,
        authorName: aluna.nomeCompleto,
        cursoAutor: aluna.curso,
        conteudo: 'Muito feliz em começar mais um semestre na UEPA!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        curtidas: 2,
        likedByUserIds: const ['1', '3'],
      ),
      PostModel(
        id: 'p2',
        authorId: professor.uid,
        authorName: professor.nomeCompleto,
        cursoAutor: professor.curso,
        conteudo: 'Parabéns aos alunos pelo desempenho nas apresentações.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        curtidas: 1,
        likedByUserIds: const ['2'],
      ),
    ]);
  }

  String? registerUser(UserModel user) {
    final bool emailExists = _users.any(
      (item) => item.email.toLowerCase() == user.email.toLowerCase(),
    );
    if (emailExists) {
      return 'Este e-mail já está cadastrado.';
    }

    final bool cpfExists = _users.any((item) => item.cpf == user.cpf);
    if (cpfExists) {
      return 'Este CPF já está cadastrado.';
    }

    _users.add(user);
    notifyListeners();
    return null;
  }

  String? login({
    required String email,
    required String senha,
  }) {
    try {
      final UserModel user = _users.firstWhere(
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

  void createPost({
    required String conteudo,
    PostMediaType mediaType = PostMediaType.none,
    String mediaPath = '',
  }) {
    if (_currentUser == null) return;

    final PostModel newPost = PostModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      authorId: _currentUser!.uid,
      authorName: _currentUser!.nomeCompleto,
      cursoAutor: _currentUser!.curso,
      conteudo: conteudo.trim(),
      createdAt: DateTime.now(),
      curtidas: 0,
      mediaType: mediaType,
      mediaPath: mediaPath,
      likedByUserIds: const <String>[],
    );

    _posts.insert(0, newPost);
    notifyListeners();
  }

  void toggleCurtida(String postId) {
    if (_currentUser == null) return;

    final int index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    final PostModel post = _posts[index];
    final List<String> likes =
        List<String>.from(post.likedByUserIds, growable: true);

    final String currentUserId = _currentUser!.uid;

    if (likes.contains(currentUserId)) {
      likes.remove(currentUserId);
    } else {
      likes.add(currentUserId);
    }

    _posts[index] = post.copyWith(
      curtidas: likes.length,
      likedByUserIds: likes,
    );

    notifyListeners();
  }

  void removePost(String postId) {
    _posts.removeWhere((post) => post.id == postId);
    notifyListeners();
  }

  void toggleUserStatus(String userId) {
    final int index = _users.indexWhere((user) => user.uid == userId);
    if (index == -1) return;

    final UserModel selected = _users[index];
    _users[index] = selected.copyWith(
      ativo: !selected.ativo,
    );

    if (_currentUser?.uid == userId && !_users[index].ativo) {
      _currentUser = null;
    }

    notifyListeners();
  }

  List<PostModel> postsByUser(String userId) {
    final List<PostModel> result =
        _posts.where((post) => post.authorId == userId).toList(growable: true);

    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }
}
