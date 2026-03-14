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

    final aluno1 = UserModel(
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

    final aluno2 = UserModel(
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

    _users.addAll([admin, aluno1, aluno2]);

    _posts.addAll([
      PostModel(
        id: 'p1',
        authorId: aluno1.uid,
        authorName: aluno1.nomeCompleto,
        cursoAutor: aluno1.curso,
        conteudo:
            'Muito feliz em começar mais um semestre na UEPA. Vamos com tudo!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        curtidas: 7,
      ),
      PostModel(
        id: 'p2',
        authorId: aluno2.uid,
        authorName: aluno2.nomeCompleto,
        cursoAutor: aluno2.curso,
        conteudo:
            'Nosso projeto de rede social da UEPA está ganhando forma. Bora finalizar!',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        curtidas: 12,
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

  void createPost(String conteudo) {
    if (_currentUser == null) return;

    final newPost = PostModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      authorId: _currentUser!.uid,
      authorName: _currentUser!.nomeCompleto,
      cursoAutor: _currentUser!.curso,
      conteudo: conteudo.trim(),
      createdAt: DateTime.now(),
      curtidas: 0,
    );

    _posts.insert(0, newPost);
    notifyListeners();
  }

  void curtirPost(String postId) {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    _posts[index] = _posts[index].copyWith(curtidas: _posts[index].curtidas + 1);
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
