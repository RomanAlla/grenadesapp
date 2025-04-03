import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grenadesapp/core/constants/app_contants.dart';
import 'package:grenadesapp/features/video/data/models/video_model.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoDetailPage extends StatefulWidget {
  final VideoModel video;
  final String mapName;

  const VideoDetailPage(
      {super.key, required this.video, required this.mapName});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late FlickManager flickManager;
  final TextEditingController _commentController = TextEditingController();
  bool _isInitialized = false;
  bool _isDisposed = false;
  bool _isLiked = false;
  bool _isFavorited = false;
  int _likeCount = 0;
  late StreamSubscription<User?> _authStateSubscription;
  bool _isUserAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _updateAuthState();
    _checkIfLiked();
    _checkIfFavorited();
    _getLikeCount();

    _authStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _isUserAuthenticated = user != null;
        });
        if (user != null) {
          _checkIfLiked();
          _checkIfFavorited();
        }
      }
    });
  }

  void _updateAuthState() {
    setState(() {
      _isUserAuthenticated = FirebaseAuth.instance.currentUser != null;
    });
  }

  void _initializePlayer() async {
    if (_isDisposed) return;

    try {
      String videoUrl = widget.video.videoUrl;
      if (videoUrl.contains('drive.google.com')) {
        final fileId = videoUrl.split('/d/')[1].split('/')[0];
        videoUrl = 'https://drive.google.com/uc?export=download&id=$fileId';
      }

      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
        ),
        autoPlay: true,
      );

      if (!_isDisposed && mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка воспроизведения видео: $e')),
        );
      }
    }
  }

  Future<void> _checkIfLiked() async {
    if (!_isUserAuthenticated) return;

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('videos')
          .doc(widget.video.id)
          .collection('likes')
          .doc(userId)
          .get();

      if (mounted) {
        setState(() {
          _isLiked = doc.exists;
        });
      }
    } catch (e) {
      print('Ошибка при проверке лайка: $e');
    }
  }

  Future<void> _checkIfFavorited() async {
    if (!_isUserAuthenticated) return;

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(widget.video.id)
          .get();

      if (mounted) {
        setState(() {
          _isFavorited = doc.exists;
        });
      }
    } catch (e) {
      print('Ошибка при проверке избранного: $e');
    }
  }

  Future<void> _getLikeCount() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('videos')
          .doc(widget.video.id)
          .collection('likes')
          .count()
          .get();

      if (mounted) {
        setState(() {
          _likeCount = snapshot.count ?? 0;
        });
      }
    } catch (e) {
      print('Ошибка при получении количества лайков: $e');
    }
  }

  Future<void> _toggleLike() async {
    if (!_isUserAuthenticated) {
      return;
    }

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final likeRef = FirebaseFirestore.instance
          .collection('videos')
          .doc(widget.video.id)
          .collection('likes')
          .doc(userId);

      if (_isLiked) {
        await likeRef.delete();
        setState(() {
          _isLiked = false;
          _likeCount--;
        });
      } else {
        await likeRef.set({
          'timestamp': FieldValue.serverTimestamp(),
        });
        setState(() {
          _isLiked = true;
          _likeCount++;
        });
      }
    } catch (e) {
      print('Ошибка при обновлении лайка: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (!_isUserAuthenticated) {
      return;
    }

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final favoriteRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(widget.video.id);

      if (_isFavorited) {
        await favoriteRef.delete();
        setState(() {
          _isFavorited = false;
        });
      } else {
        await favoriteRef.set({
          'videoId': widget.video.id,
          'mapName': widget.mapName,
          'grenadeType': widget.video.grenadeType,
          'description': widget.video.description,
          'videoUrl': widget.video.videoUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });
        setState(() {
          _isFavorited = true;
        });
      }
    } catch (e) {
      print('Ошибка при обновлении избранного: $e');
    }
  }

  Future<void> _addComment() async {
    if (!_isUserAuthenticated) {
      return;
    }

    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance
          .collection('videos')
          .doc(widget.video.id)
          .collection('comments')
          .add({
        'text': text,
        'authorId': user.uid,
        'authorEmail': user.email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _commentController.clear();
      // Обновление не требуется, так как используем StreamBuilder
    } catch (e) {
      print('Ошибка при добавлении комментария: $e');
    }
  }

  Widget _buildCommentSection() {
    if (!_isUserAuthenticated) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.orange.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            const Text(
              'Чтобы оставлять комментарии, необходимо войти в аккаунт',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await Navigator.pushNamed(
                  context,
                  '/login',
                  arguments: {
                    'returnRoute': '/video_detail',
                    'videoData': widget.video
                  },
                );
                _updateAuthState();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Войти'),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Написать комментарий...',
                hintStyle: TextStyle(
                  color: Colors.white54,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.send_rounded,
              color: Colors.orange,
            ),
            onPressed: _addComment,
          ),
        ],
      ),
    );
  }

  Widget _buildComments() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('videos')
          .doc(widget.video.id)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final comments = snapshot.data!.docs;

        if (comments.isEmpty) {
          return const Center(
            child: Text(
              'Нет комментариев',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index].data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.orange,
                        radius: 16,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        comment['authorEmail'] ?? 'Аноним',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTimestamp(
                          comment['timestamp'] != null
                              ? (comment['timestamp'] as Timestamp).toDate()
                              : DateTime.now(),
                        ),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    comment['text'] ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    _isDisposed = true;
    if (_isInitialized) {
      flickManager.dispose();
    }
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text(
          '${widget.mapName} - ${widget.video.grenadeType}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.orange),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.star : Icons.star_border,
              color:
                  _isFavorited ? Colors.orange : Colors.white.withOpacity(0.5),
            ),
            onPressed: _toggleFavorite,
            tooltip:
                _isFavorited ? 'Удалить из избранного' : 'Добавить в избранное',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isInitialized)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                margin: const EdgeInsets.all(16),
                clipBehavior: Clip.antiAlias,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: FlickVideoPlayer(
                    flickManager: flickManager,
                  ),
                ),
              )
            else
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.mapName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.video.grenadeType,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: Colors.orange,
                        ),
                        onPressed: _toggleLike,
                      ),
                      Text(
                        '$_likeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ...[
                    const SizedBox(height: 16),
                    Text(
                      widget.video.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Комментарии',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildComments(),
            _buildCommentSection(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}.${timestamp.month}.${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class Comment {
  final String text;
  final DateTime timestamp;
  final String author;

  Comment({
    required this.text,
    required this.timestamp,
    required this.author,
  });
}
