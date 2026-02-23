import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:event_app/data/reel_model.dart';
import 'package:event_app/services/reels_service.dart';

/// Instagram-style reels: full-screen vertical swipe, like/comment/share, double-tap to like.
class ReelsScreen extends StatefulWidget {
  final bool isVisible;

  const ReelsScreen({super.key, this.isVisible = true});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final ReelsService _reelsService = ReelsService();
  final PageController _pageController = PageController();
  List<ReelModel> _reels = [];
  int _currentIndex = 0;
  bool _loading = true;
  final Map<int, VideoPlayerController> _controllers = {};
  final Set<int> _initFailed = {};

  @override
  void initState() {
    super.initState();
    _loadReels();
  }

  Future<void> _loadReels() async {
    final list = await _reelsService.getReels();
    if (!mounted) return;
    setState(() {
      _reels = list;
      _loading = false;
    });
    if (list.isNotEmpty) _initVideo(0);
  }

  @override
  void didUpdateWidget(ReelsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isVisible != widget.isVisible) {
      if (widget.isVisible) {
        _controllers[_currentIndex]?.play();
      } else {
        _controllers[_currentIndex]?.pause();
      }
    }
  }

  void _initVideo(int index) {
    if (index < 0 || index >= _reels.length) return;
    final reel = _reels[index];
    if (reel.videoUrl == null || reel.videoUrl!.isEmpty) return;
    if (_controllers.containsKey(index) || _initFailed.contains(index)) return;
    final controller = VideoPlayerController.networkUrl(Uri.parse(reel.videoUrl!));
    _controllers[index] = controller;
    controller.initialize().then((_) {
      if (!mounted) return;
      if (_currentIndex == index && widget.isVisible) {
        setState(() {});
        controller.play();
        controller.setLooping(true);
      }
    }).catchError((Object e, StackTrace st) {
      if (!mounted) return;
      _controllers.remove(index)?.dispose();
      setState(() => _initFailed.add(index));
    });
  }

  void _retryVideo(int index) {
    setState(() => _initFailed.remove(index));
    _initVideo(index);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    final prev = _currentIndex;
    _currentIndex = index;
    _controllers[prev]?.pause();
    _initVideo(index);
    if (widget.isVisible) _controllers[index]?.play();
    if (index < _reels.length - 1) _initVideo(index + 1);
    setState(() {});
  }

  void _toggleLike(int index) {
    final r = _reels[index];
    _reelsService.toggleLike(r.id);
    setState(() {
      _reels[index] = r.copyWith(
        isLiked: !r.isLiked,
        likes: r.likes + (r.isLiked ? -1 : 1),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    if (_reels.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, title: const Text('Reels', style: TextStyle(color: Colors.white))),
        body: const Center(child: Text('No reels yet', style: TextStyle(color: Colors.white54))),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: _reels.length,
            itemBuilder: (context, index) => _ReelPage(
              reel: _reels[index],
              index: index,
              controller: _controllers[index],
              initFailed: _initFailed.contains(index),
              onRetry: () => _retryVideo(index),
              onDoubleTap: () => _toggleLike(index),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildProgressBars(),
                const Spacer(),
                _buildSideBar(index: _currentIndex),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 100,
            child: _buildCaption(index: _currentIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBars() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: List.generate(
          _reels.length,
          (i) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 2,
              decoration: BoxDecoration(
                color: i <= _currentIndex ? Colors.white : Colors.white24,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSideBar({required int index}) {
    if (index >= _reels.length) return const SizedBox.shrink();
    final r = _reels[index];
    return Padding(
      padding: const EdgeInsets.only(right: 12, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SideBarButton(icon: Icons.favorite, label: _formatCount(r.likes), isActive: r.isLiked, onTap: () => _toggleLike(index)),
          const SizedBox(height: 20),
          _SideBarButton(icon: Icons.chat_bubble_outline, label: _formatCount(r.commentCount), onTap: () {}),
          const SizedBox(height: 20),
          _SideBarButton(icon: Icons.send, label: 'Share', onTap: () {}),
          const SizedBox(height: 20),
          _SideBarButton(icon: Icons.bookmark_border, label: 'Save', onTap: () {}),
          const SizedBox(height: 16),
          CircleAvatar(radius: 22, backgroundImage: r.authorImageUrl != null ? NetworkImage(r.authorImageUrl!) : null, child: r.authorImageUrl == null ? const Icon(Icons.person) : null),
        ],
      ),
    );
  }

  Widget _buildCaption({required int index}) {
    if (index >= _reels.length) return const SizedBox.shrink();
    final r = _reels[index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('@${r.authorName.replaceAll(' ', '').toLowerCase()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 4),
            Text(r.caption, style: const TextStyle(color: Colors.white, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
            if (r.eventTitle != null) ...[
              const SizedBox(height: 4),
              Text('📍 ${r.eventTitle}', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCount(int n) => n >= 1000000 ? '${(n / 1000000).toStringAsFixed(1)}M' : n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';
}

class _ReelPage extends StatelessWidget {
  final ReelModel reel;
  final int index;
  final VideoPlayerController? controller;
  final bool initFailed;
  final VoidCallback? onRetry;
  final VoidCallback onDoubleTap;

  const _ReelPage({
    required this.reel,
    required this.index,
    this.controller,
    this.initFailed = false,
    this.onRetry,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final showVideo = controller != null && controller!.value.isInitialized && !initFailed;
    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showVideo)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller!.value.size.width,
                height: controller!.value.size.height,
                child: VideoPlayer(controller!),
              ),
            )
          else
            Image.network(
              reel.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900),
            ),
          if (initFailed && onRetry != null)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.white70),
                  const SizedBox(height: 12),
                  Text(
                    'Video couldn\'t load',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SideBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SideBarButton({required this.icon, required this.label, this.isActive = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(icon: Icon(icon, color: isActive ? Colors.red : Colors.white, size: 32), onPressed: onTap),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
