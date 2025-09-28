enum PostType { image, video, text, banking }

class Post {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? videoUrl;
  final PostType type;
  final String author;
  final String timeAgo;
  final int likes;
  final int comments;
  final bool isLiked;
  final bool isSaved;
  final List<String> tags;
  final String? backgroundColor;
  final double aspectRatio;

  const Post({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.videoUrl,
    required this.type,
    required this.author,
    required this.timeAgo,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.tags = const [],
    this.backgroundColor,
    this.aspectRatio = 1.0,
  });

  Post copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? videoUrl,
    PostType? type,
    String? author,
    String? timeAgo,
    int? likes,
    int? comments,
    bool? isLiked,
    bool? isSaved,
    List<String>? tags,
    String? backgroundColor,
    double? aspectRatio,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      type: type ?? this.type,
      author: author ?? this.author,
      timeAgo: timeAgo ?? this.timeAgo,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      tags: tags ?? this.tags,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }
}
