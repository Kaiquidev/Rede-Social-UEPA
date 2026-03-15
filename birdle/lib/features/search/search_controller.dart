import '../../core/services/app_store.dart';
import '../../models/user_model.dart';

class SearchController {
  final AppStore _store = AppStore.instance;

  String? get currentUserId => _store.currentUser?.uid;

  /// Busca usuários pelo [query] — filtra por nome, curso ou tipo de perfil.
  /// Exclui o próprio usuário logado dos resultados.
  List<UserModel> buscar(String query) {
    final termo = query.toLowerCase().trim();

    if (termo.isEmpty) return [];

    return _store.users.where((user) {
      if (user.uid == currentUserId) return false;
      if (!user.ativo) return false;

      return user.nomeCompleto.toLowerCase().contains(termo) ||
          user.curso.toLowerCase().contains(termo) ||
          user.tipoPerfil.toLowerCase().contains(termo) ||
          user.instagram.toLowerCase().contains(termo);
    }).toList();
  }

  bool isFollowing(String targetUserId) => _store.isFollowing(targetUserId);

  void toggleFollow(String targetUserId) =>
      _store.toggleFollow(targetUserId);
}
