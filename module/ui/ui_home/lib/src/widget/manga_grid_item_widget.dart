import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MangaGridItemWidget extends StatelessWidget {
  const MangaGridItemWidget({
    super.key,
    required this.title,
    required this.coverUrl,
  });

  final String? title;

  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueGrey),
            ),
            child: CachedNetworkImage(
              imageUrl: coverUrl ?? '',
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
        Visibility(
          visible: title?.isNotEmpty == true,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(title ?? ''),
          ),
        ),
      ],
    );
  }

}