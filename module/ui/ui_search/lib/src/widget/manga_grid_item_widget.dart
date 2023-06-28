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
              fit: BoxFit.fill,
              imageUrl: coverUrl ?? '',
              placeholder: (context, url) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              errorWidget: (context, url, error) {
                return const Center(
                  child: Icon(Icons.error),
                );
              },
            ),
          ),
        ),
        Visibility(
          visible: title?.isNotEmpty == true,
          child: Container(
            width: double.infinity,
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
            padding: const EdgeInsets.all(4.0),
            child: Text(
              title ?? '',
              maxLines: 2,
            ),
          ),
        ),
      ],
    );
  }

}