class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorCourse;
  final String content;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorCourse,
    required this.content,
    required this.createdAt,
  });

  CommentModel copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? authorName,
    String? authorCourse,
    String? content,
    DateTime? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorCourse: authorCourse ?? this.authorCourse,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
