import 'package:flutter/foundation.dart';

import '../../models/post_model.dart';
import '../../models/user_model.dart';

class AppStore extends ChangeNotifier {
  AppStore._internal() {
    _seed();
  }

  static final AppStore instance = AppStore._internal();

  final List<UserModel> _users = [];
  final List<PostModel> _posts = [];
  UserModel? _currentUser;

  List<UserModel> get users => List.unmodifiable(_users);
  List<PostModel> get posts => List.unmodifiable(_posts)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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

    final aluno = UserModel(
      uid: '3',
      nomeCompleto: 'Bruno Lima',
      dataNascimento: '15/11/2002',
      curso: 'Sistemas de Informação',
      cpf: '16899535009',
      instagram: '@bruno.dev',
      fotoUrl: '',
      tipoPerfil: 'aluno',
      biografia: 'Curto tecnologia, projetos acadêmicos e inovação.',
      ativo: true,
      email: 'bruno@uepa.com',
      senha: '123456',
    );

    final professora = UserModel(
      uid: '4',
      nomeCompleto: 'Prof. Camila Ferreira',
      dataNascimento: '10/06/1986',
      curso: 'Pedagogia',
      cpf: '45317828791',
      instagram: '@prof.camila',
      fotoUrl: '',
      tipoPerfil: 'professor',
      biografia: 'Professora da UEPA, focada em extensão universitária.',
      ativo: true,
      email: 'camila@uepa.com',
      senha: '123456',
    );

    _users.addAll([admin, aluna, aluno, professora]);

    _posts.addAll([
      PostModel(
        id: 'p1',
        authorId: aluna.uid,
        authorName: aluna.nomeCompleto,
        cursoAutor: aluna.curso,
        conteudo:
            'Muito feliz em começar mais um semestre na UEPA. Vamos com tudo!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        curtidas: 7,
        likedByUserIds: const ['3', '4'],
      ),
      PostModel(
        id: 'p2',
        authorId: aluno.uid,
        authorName: aluno.nomeCompleto,
        cursoAutor: aluno.curso,
        conteudo:
            'Nosso projeto de rede social da UEPA está ganhando forma. Bora finalizar!',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        curtidas: 12,
        likedByUserIds: const ['2'],
      ),
      PostModel(
        id: 'p3',
        authorId: professora.uid,
        authorName: professora.nomeCompleto,
        cursoAutor: professora.curso,
        conteudo:
            'Parabéns aos alunos que apresentaram hoje. O campus estava cheio de ideias boas.',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        curtidas: 18,
        likedByUserIds: const ['2', '3'],
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
    notifyListeners();
    return null;
  }

  String? login({required String email, required String senha}) {
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
      cursoAutor: _currentUser!.curso,
      conteudo: conteudo.trim(),
      createdAt: DateTime.now(),
      curtidas: 0,
      mediaType: mediaType,
      mediaPath: mediaPath,
      likedByUserIds: const [],
    );

    _posts.insert(0, newPost);
    notifyListeners();
  }

  void toggleCurtida(String postId) {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1 || _currentUser == null) return;

    final post = _posts[index];
    final likes = List<String>.from(post.likedByUserIds);
    final currentUserId = _currentUser!.uid;

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
    final index = _users.indexWhere((user) => user.uid == userId);
    if (index == -1) return;

    final selected = _users[index];
    _users[index] = selected.copyWith(ativo: !selected.ativo);

    if (_currentUser?.uid == userId && !_users[index].ativo) {
      _currentUser = null;
    }

    notifyListeners();
  }

  List<PostModel> postsByUser(String userId) {
    final result = _posts.where((post) => post.authorId == userId).toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }
}
