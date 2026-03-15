import '../../core/services/app_store.dart';
import '../../models/post_model.dart';

class FeedController {
  final AppStore _store = AppStore.instance;

  /// Todos os posts ordenados do mais recente.
  List<PostModel> get posts => _store.posts;

  /// Apenas posts de usuários que o usuário logado segue (+ os próprios).
  List<PostModel> get postsSeguindo {
    final uid = _store.currentUser?.uid;
    if (uid == null) return [];

    final seguindo = _store.currentUser!.seguindo;

    return posts.where((post) {
      return post.authorId == uid || seguindo.contains(post.authorId);
    }).toList();
  }

  void publicar({
    required String conteudo,
    PostMediaType mediaType = PostMediaType.none,
    String mediaPath = '',
  }) {
    _store.createPost(
      conteudo: conteudo,
      mediaType: mediaType,
      mediaPath: mediaPath,
    );
  }

  void curtir(String postId) => _store.toggleCurtida(postId);

  void remover(String postId) => _store.removePost(postId);

  /// Edita o conteúdo de um post. Retorna `true` se bem-sucedido.
  bool editar({required String postId, required String novoConteudo}) {
    return _store.editPost(postId: postId, novoConteudo: novoConteudo);
  }
}
