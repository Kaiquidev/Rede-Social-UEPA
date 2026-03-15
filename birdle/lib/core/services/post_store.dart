import 'package:flutter/foundation.dart';

import '../../models/comment_model.dart';
import '../../models/post_model.dart';

class PostStore extends ChangeNotifier {
  final List<PostModel> _posts = <PostModel>[];

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  List<PostModel> get posts {
    final list = List<PostModel>.from(_posts, growable: true);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<PostModel> postsByUser(String userId) {
    final result = _posts
        .where((post) => post.authorId == userId)
        .toList(growable: true);
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  // ---------------------------------------------------------------------------
  // Seed
  // ---------------------------------------------------------------------------

  void seed(List<PostModel> posts) {
    if (_posts.isNotEmpty) return;
    _posts.addAll(posts);
  }

  // ---------------------------------------------------------------------------
  // CRUD de posts
  // ---------------------------------------------------------------------------

  void createPost({
    required String authorId,
    required String authorName,
    required String authorPhoto,
    required String cursoAutor,
    required String conteudo,
    PostMediaType mediaType = PostMediaType.none,
    String mediaPath = '',
  }) {
    final newPost = PostModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      authorId: authorId,
      authorName: authorName,
      authorPhoto: authorPhoto,
      cursoAutor: cursoAutor,
      conteudo: conteudo.trim(),
      createdAt: DateTime.now(),
      curtidas: 0,
      mediaType: mediaType,
      mediaPath: mediaPath,
      likedByUserIds: const [],
      comments: const [],
      comentariosAtivos: true,
    );
    _posts.insert(0, newPost);
    notifyListeners();
  }

  bool editPost({
    required String postId,
    required String requesterId,
    required String novoConteudo,
  }) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return false;
    if (_posts[index].authorId != requesterId) return false;
    _posts[index] = _posts[index].copyWith(conteudo: novoConteudo.trim());
    notifyListeners();
    return true;
  }

  void removePost(String postId) {
    _posts.removeWhere((post) => post.id == postId);
    notifyListeners();
  }

  void syncAuthorData({
    required String authorId,
    required String authorName,
    required String authorPhoto,
    required String cursoAutor,
  }) {
    bool changed = false;
    for (int i = 0; i < _posts.length; i++) {
      if (_posts[i].authorId == authorId) {
        _posts[i] = _posts[i].copyWith(
          authorName: authorName,
          authorPhoto: authorPhoto,
          cursoAutor: cursoAutor,
        );
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Toggle comentários ativos
  // ---------------------------------------------------------------------------

  /// Liga/desliga comentários de um post. Só o autor pode fazer isso.
  bool toggleComentarios({
    required String postId,
    required String requesterId,
  }) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return false;
    if (_posts[index].authorId != requesterId) return false;

    _posts[index] = _posts[index].copyWith(
      comentariosAtivos: !_posts[index].comentariosAtivos,
    );
    notifyListeners();
    return true;
  }

  // ---------------------------------------------------------------------------
  // Curtidas
  // ---------------------------------------------------------------------------

  bool toggleCurtida({required String postId, required String userId}) {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) return false;

    final post = _posts[index];
    final likes = List<String>.from(post.likedByUserIds, growable: true);
    final nowLiked = !likes.contains(userId);

    if (nowLiked) {
      likes.add(userId);
    } else {
      likes.remove(userId);
    }

    _posts[index] = post.copyWith(
      curtidas: likes.length,
      likedByUserIds: likes,
    );
    notifyListeners();
    return nowLiked;
  }

  // ---------------------------------------------------------------------------
  // Comentários — adicionar
  // ---------------------------------------------------------------------------

  PostModel? addComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String authorCourse,
    required String content,
  }) {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) return null;

    // Respeita a configuração de comentários ativos
    if (!_posts[index].comentariosAtivos) return null;

    final post = _posts[index];
    final comments = List<CommentModel>.from(post.comments, growable: true);

    comments.add(CommentModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      authorCourse: authorCourse,
      content: content.trim(),
      createdAt: DateTime.now(),
    ));

    _posts[index] = post.copyWith(comments: comments);
    notifyListeners();
    return _posts[index];
  }

  // ---------------------------------------------------------------------------
  // Comentários — editar
  // ---------------------------------------------------------------------------

  /// Edita um comentário. Só o autor do comentário pode editar.
  bool editComment({
    required String postId,
    required String commentId,
    required String requesterId,
    required String novoConteudo,
  }) {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return false;

    final comments =
        List<CommentModel>.from(_posts[postIndex].comments, growable: true);
    final commentIndex =
        comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) return false;
    if (comments[commentIndex].authorId != requesterId) return false;

    comments[commentIndex] =
        comments[commentIndex].copyWith(content: novoConteudo.trim());

    _posts[postIndex] = _posts[postIndex].copyWith(comments: comments);
    notifyListeners();
    return true;
  }

  // ---------------------------------------------------------------------------
  // Comentários — excluir
  // ---------------------------------------------------------------------------

  /// Exclui um comentário.
  /// Pode ser excluído pelo autor do comentário OU pelo autor do post.
  bool removeComment({
    required String postId,
    required String commentId,
    required String requesterId,
  }) {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return false;

    final post = _posts[postIndex];
    final comments =
        List<CommentModel>.from(post.comments, growable: true);
    final commentIndex =
        comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) return false;

    // Permite excluir se for o autor do comentário ou autor do post
    final isCommentAuthor =
        comments[commentIndex].authorId == requesterId;
    final isPostAuthor = post.authorId == requesterId;

    if (!isCommentAuthor && !isPostAuthor) return false;

    comments.removeAt(commentIndex);
    _posts[postIndex] = post.copyWith(comments: comments);
    notifyListeners();
    return true;
  }
}
