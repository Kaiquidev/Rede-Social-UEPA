import 'package:flutter/foundation.dart';

import '../../models/user_model.dart';

/// Resultado do toggleFollow — indica o que aconteceu.
enum FollowResult {
  seguindo,        // passou a seguir (perfil público)
  deixouDeSeguir,  // deixou de seguir
  solicitacaoEnviada,  // perfil privado — solicitação enviada
  solicitacaoCancelada, // cancelou solicitação pendente
  bloqueado,       // tentou seguir alguém que o bloqueou
}

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

  bool hasPendingRequest({
    required String fromUserId,
    required String toUserId,
  }) {
    final target = getUserById(toUserId);
    if (target == null) return false;
    return target.solicitacoesPendentes.contains(fromUserId);
  }

  bool isBloqueado({
    required String byUserId,
    required String targetUserId,
  }) {
    final user = getUserById(byUserId);
    if (user == null) return false;
    return user.bloqueados.contains(targetUserId);
  }

  bool podeInteragir({
    required String viewerId,
    required String authorId,
  }) {
    if (viewerId == authorId) return true;

    // Verifica se o viewer foi bloqueado pelo autor
    final author = getUserById(authorId);
    if (author == null) return false;
    if (author.bloqueados.contains(viewerId)) return false;

    if (!author.perfilPrivado) return true;
    return author.seguidores.contains(viewerId);
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
  // Seguir / Solicitação
  // ---------------------------------------------------------------------------

  /// Alterna o estado de seguir.
  /// - Perfil público: segue/deixa de seguir imediatamente.
  /// - Perfil privado: envia/cancela solicitação pendente.
  /// - Bloqueado: retorna [FollowResult.bloqueado].
  FollowResult toggleFollow({
    required String currentUserId,
    required String targetUserId,
  }) {
    if (currentUserId == targetUserId) return FollowResult.deixouDeSeguir;

    final myIndex = _users.indexWhere((u) => u.uid == currentUserId);
    final targetIndex = _users.indexWhere((u) => u.uid == targetUserId);
    if (myIndex == -1 || targetIndex == -1) return FollowResult.deixouDeSeguir;

    final me = _users[myIndex];
    final target = _users[targetIndex];

    // Bloqueado pelo alvo
    if (target.bloqueados.contains(currentUserId)) {
      return FollowResult.bloqueado;
    }

    // Já segue — deixar de seguir
    if (me.seguindo.contains(targetUserId)) {
      final myFollowing =
          List<String>.from(me.seguindo, growable: true)..remove(targetUserId);
      final targetFollowers = List<String>.from(target.seguidores,
          growable: true)
        ..remove(currentUserId);

      _users[myIndex] = me.copyWith(seguindo: myFollowing);
      _users[targetIndex] = target.copyWith(seguidores: targetFollowers);
      notifyListeners();
      return FollowResult.deixouDeSeguir;
    }

    // Perfil privado — solicitação
    if (target.perfilPrivado) {
      final pendentes = List<String>.from(target.solicitacoesPendentes,
          growable: true);

      if (pendentes.contains(currentUserId)) {
        // Cancela solicitação
        pendentes.remove(currentUserId);
        _users[targetIndex] =
            target.copyWith(solicitacoesPendentes: pendentes);
        notifyListeners();
        return FollowResult.solicitacaoCancelada;
      } else {
        // Envia solicitação
        pendentes.add(currentUserId);
        _users[targetIndex] =
            target.copyWith(solicitacoesPendentes: pendentes);
        notifyListeners();
        return FollowResult.solicitacaoEnviada;
      }
    }

    // Perfil público — segue imediatamente
    final myFollowing =
        List<String>.from(me.seguindo, growable: true)..add(targetUserId);
    final targetFollowers =
        List<String>.from(target.seguidores, growable: true)
          ..add(currentUserId);

    _users[myIndex] = me.copyWith(seguindo: myFollowing);
    _users[targetIndex] = target.copyWith(seguidores: targetFollowers);
    notifyListeners();
    return FollowResult.seguindo;
  }

  // ---------------------------------------------------------------------------
  // Aceitar / Negar solicitação
  // ---------------------------------------------------------------------------

  /// Aceita a solicitação de [requesterId] para seguir o usuário [targetId].
  bool aceitarSolicitacao({
    required String targetId,
    required String requesterId,
  }) {
    final myIndex = _users.indexWhere((u) => u.uid == targetId);
    final requesterIndex = _users.indexWhere((u) => u.uid == requesterId);
    if (myIndex == -1 || requesterIndex == -1) return false;

    final me = _users[myIndex];
    final requester = _users[requesterIndex];

    if (!me.solicitacoesPendentes.contains(requesterId)) return false;

    final pendentes = List<String>.from(me.solicitacoesPendentes,
        growable: true)..remove(requesterId);
    final seguidores =
        List<String>.from(me.seguidores, growable: true)..add(requesterId);
    final seguindo =
        List<String>.from(requester.seguindo, growable: true)..add(targetId);

    _users[myIndex] = me.copyWith(
      solicitacoesPendentes: pendentes,
      seguidores: seguidores,
    );
    _users[requesterIndex] = requester.copyWith(seguindo: seguindo);

    notifyListeners();
    return true;
  }

  /// Nega a solicitação de [requesterId].
  bool negarSolicitacao({
    required String targetId,
    required String requesterId,
  }) {
    final myIndex = _users.indexWhere((u) => u.uid == targetId);
    if (myIndex == -1) return false;

    final me = _users[myIndex];
    if (!me.solicitacoesPendentes.contains(requesterId)) return false;

    final pendentes = List<String>.from(me.solicitacoesPendentes,
        growable: true)..remove(requesterId);

    _users[myIndex] = me.copyWith(solicitacoesPendentes: pendentes);
    notifyListeners();
    return true;
  }

  // ---------------------------------------------------------------------------
  // Bloquear / Desbloquear
  // ---------------------------------------------------------------------------

  /// Bloqueia [targetId] para o usuário [userId].
  /// Remove automaticamente o relacionamento de seguir em ambos os sentidos.
  void bloquear({required String userId, required String targetId}) {
    final myIndex = _users.indexWhere((u) => u.uid == userId);
    final targetIndex = _users.indexWhere((u) => u.uid == targetId);
    if (myIndex == -1 || targetIndex == -1) return;

    final me = _users[myIndex];
    final target = _users[targetIndex];

    final bloqueados =
        List<String>.from(me.bloqueados, growable: true)..add(targetId);

    // Remove qualquer relacionamento de seguir
    final myFollowing =
        List<String>.from(me.seguindo, growable: true)..remove(targetId);
    final myFollowers =
        List<String>.from(me.seguidores, growable: true)..remove(targetId);
    final targetFollowing =
        List<String>.from(target.seguindo, growable: true)..remove(userId);
    final targetFollowers =
        List<String>.from(target.seguidores, growable: true)..remove(userId);

    // Remove solicitações pendentes
    final myPendentes =
        List<String>.from(me.solicitacoesPendentes, growable: true)
          ..remove(targetId);
    final targetPendentes =
        List<String>.from(target.solicitacoesPendentes, growable: true)
          ..remove(userId);

    _users[myIndex] = me.copyWith(
      bloqueados: bloqueados,
      seguindo: myFollowing,
      seguidores: myFollowers,
      solicitacoesPendentes: myPendentes,
    );
    _users[targetIndex] = target.copyWith(
      seguindo: targetFollowing,
      seguidores: targetFollowers,
      solicitacoesPendentes: targetPendentes,
    );

    notifyListeners();
  }

  void desbloquear({required String userId, required String targetId}) {
    final myIndex = _users.indexWhere((u) => u.uid == userId);
    if (myIndex == -1) return;

    final me = _users[myIndex];
    final bloqueados =
        List<String>.from(me.bloqueados, growable: true)..remove(targetId);

    _users[myIndex] = me.copyWith(bloqueados: bloqueados);
    notifyListeners();
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
