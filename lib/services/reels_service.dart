import 'package:event_app/data/reel_model.dart';

/// Service for reels (short clips). Swap with API when backend is ready.
class ReelsService {
  ReelsService._();
  static final ReelsService _instance = ReelsService._();
  factory ReelsService() => _instance;

  final List<ReelModel> _reels = [];
  final Set<String> _likedIds = {};

  List<ReelModel> get reels => _reels.isEmpty ? _mockReels : _reels;

  static final List<ReelModel> _mockReels = [
    ReelModel(
      id: 'r1',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400',
      caption: 'Lusaka Music Festival 🔥 Coming soon to Showgrounds!',
      authorName: 'Zed Culture Live',
      authorImageUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=200',
      eventId: 'zm_001',
      eventTitle: 'Lusaka Music & Arts Festival',
      likes: 1204,
      commentCount: 89,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ReelModel(
      id: 'r2',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=400',
      caption: 'Super League Derby — get your tickets before they’re gone ⚽',
      authorName: 'Zambia Football Events',
      eventId: 'zm_003',
      eventTitle: 'Zambia Super League Derby Night',
      likes: 892,
      commentCount: 45,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    ReelModel(
      id: 'r3',
      thumbnailUrl: 'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?w=400',
      caption: 'Zambezi sunset party vibes 🌅 Livingstone',
      authorName: 'Falls Nightlife Collective',
      eventId: 'zm_008',
      eventTitle: 'Zambezi Riverside Sunset Party',
      likes: 456,
      commentCount: 23,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ReelModel(
      id: 'r4',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?w=400',
      caption: 'Copperbelt Expo — tech & industry under one roof.',
      authorName: 'Copperbelt Business Council',
      eventId: 'zm_002',
      eventTitle: 'Copperbelt Industrial Expo',
      likes: 312,
      commentCount: 12,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  Future<List<ReelModel>> getReels() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return reels.map((r) => r.copyWith(isLiked: _likedIds.contains(r.id))).toList();
  }

  void toggleLike(String reelId) {
    if (_likedIds.contains(reelId)) {
      _likedIds.remove(reelId);
    } else {
      _likedIds.add(reelId);
    }
  }

  bool isLiked(String reelId) => _likedIds.contains(reelId);
}
