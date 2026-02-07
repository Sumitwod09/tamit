import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double size;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.grey[300],
        child: Icon(
          Icons.person,
          size: size * 0.6,
          color: Colors.grey[600],
        ),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundImage: CachedNetworkImageProvider(avatarUrl!),
    );
  }
}
