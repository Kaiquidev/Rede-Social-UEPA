import 'package:flutter/foundation.dart';

import '../../models/user_model.dart';

/// Gerencia o estado de autenticação: usuário logado, login, logout e registro.
class AuthStore extends ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // ---------------------------------------------------------------------------
  // Login / Logout
  // ---------------------------------------------------------------------------

  /// Tenta autenticar com [email] e [senha] usando a lista [users] fornecida.
  /// Retorna uma mensagem de erro ou `null` em caso de sucesso.
  String? login({
    required String email,
    required String senha,
    required List<UserModel> users,
  }) {
    try {
      final user = users.firstWhere(
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

  // ---------------------------------------------------------------------------
  // Sincronização do usuário atual
  // ---------------------------------------------------------------------------

  /// Chamado pelo [UserStore] sempre que o perfil do usuário logado for alterado,
  /// mantendo [currentUser] em sincronia sem necessidade de novo login.
  void syncCurrentUser(UserModel updated) {
    if (_currentUser == null) return;
    if (_currentUser!.uid != updated.uid) return;
    _currentUser = updated;
    notifyListeners();
  }

  /// Desativa a sessão local caso o admin desative o usuário logado.
  void invalidateIfDisabled(String userId) {
    if (_currentUser?.uid == userId && _currentUser?.ativo == false) {
      _currentUser = null;
      notifyListeners();
    }
  }
}
