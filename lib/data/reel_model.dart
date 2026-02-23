/// A short reel (video or image) like Instagram Reels / Spotify clips.
/// Events and companies can post reels to promote; users can browse and like.
class ReelModel {
  final String id;
  final String? videoUrl;
  final String thumbnailUrl;
  final String caption;
  final String authorName;
  final String? authorImageUrl;
  final String? eventId;
  final String? eventTitle;
  final int likes;
  final int commentCount;
  final DateTime createdAt;
  final bool isLiked;

  const ReelModel({
    required this.id,
    this.videoUrl,
    required this.thumbnailUrl,
    required this.caption,
    required this.authorName,
    this.authorImageUrl,
    this.eventId,
    this.eventTitle,
    this.likes = 0,
    this.commentCount = 0,
    required this.createdAt,
    this.isLiked = false,
  });

  ReelModel copyWith({
    int? likes,
    int? commentCount,
    bool? isLiked,
  }) =>
      ReelModel(
        id: id,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        caption: caption,
        authorName: authorName,
        authorImageUrl: authorImageUrl,
        eventId: eventId,
        eventTitle: eventTitle,
        likes: likes ?? this.likes,
        commentCount: commentCount ?? this.commentCount,
        createdAt: createdAt,
        isLiked: isLiked ?? this.isLiked,
      );
}
