import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
import '../services/post_service.dart';

import '../screens/feed/comments_screen.dart';
import 'user_avatar.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final _postService = PostService();

  late bool _isLiked;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.post.likesCount;
    _loadLikeStatus();
  }

  Future<void> _loadLikeStatus() async {
    final liked = await _postService.hasLikedPost(widget.post.id);
    if (mounted) {
      setState(() => _isLiked = liked);
    }
  }

  Future<void> _toggleLike() async {
    final wasLiked = _isLiked;
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });

    try {
      if (_isLiked) {
        await _postService.likePost(widget.post.id);
      } else {
        await _postService.unlikePost(widget.post.id);
      }
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _isLiked = wasLiked;
          _likesCount += wasLiked ? 1 : -1;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final author = widget.post.author;

    return Container(
      color: Colors.white, // Explicitly white background
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info
          Row(
            children: [
              UserAvatar(avatarUrl: author?.avatarUrl, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author?.fullName ?? author?.username ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, h:mm a').format(widget.post.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content
          if (widget.post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                widget.post.content,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),

          // Image
          if (widget.post.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: widget.post.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                // height: 250, // Optional: Limit height or let it expand
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey[100],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey[100],
                  child: const Icon(Icons.error, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Actions (Inline)
          Row(
            children: [
              // Like
              InkWell(
                onTap: _toggleLike,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: _isLiked ? Colors.red : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_likesCount',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Comment
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CommentsScreen(postId: widget.post.id),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.post.commentsCount}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
