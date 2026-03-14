class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String cursoAutor;
  final String conteudo;
  final DateTime createdAt;
  final int curtidas;

  const PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.cursoAutor,
    required this.conteudo,
    required this.createdAt,
    required this.curtidas,
  });

  PostModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? cursoAutor,
    String? conteudo,
    DateTime? createdAt,
    int? curtidas,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      cursoAutor: cursoAutor ?? this.cursoAutor,
      conteudo: conteudo ?? this.conteudo,
      createdAt: createdAt ?? this.createdAt,
      curtidas: curtidas ?? this.curtidas,
    );
  }
}
