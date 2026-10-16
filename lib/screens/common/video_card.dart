import 'package:flutter/material.dart';
import 'subscription_dialog.dart';

class VideoTutorial {
  final String id;
  final String title;
  final String category; // 'Nails', 'Makeup', 'Hair'
  final String duration;
  final String thumbnailUrl;
  final bool isPremium;

  VideoTutorial({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.thumbnailUrl,
    this.isPremium = true,
  });
}

class VideoCard extends StatelessWidget {
  final VideoTutorial video;
  final bool isSubscribed;
  final VoidCallback onWatch;
  final VoidCallback onRedirectPayment;

  const VideoCard({
    super.key,
    required this.video,
    required this.isSubscribed,
    required this.onWatch,
    required this.onRedirectPayment,
  });

  void _handleTap(BuildContext context) {
    if (video.isPremium && !isSubscribed) {
      SubscriptionDialog.show(
        context,
        videoTitle: video.title,
        onProceedToPayment: onRedirectPayment,
      );
    } else {
      onWatch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLocked = video.isPremium && !isSubscribed;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _handleTap(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail container
            Stack(
              children: [
                Container(
                  height: 175,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, _, __) => Container(
                      color: const Color(0xFF2D0C5E).withOpacity(0.08),
                      child: const Center(
                        child: Icon(Icons.play_circle_outline, size: 48, color: Color(0xFF7030A0)),
                      ),
                    ),
                  ),
                ),
                // Lock Badge
                if (isLocked)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, size: 13, color: Color(0xFFFFD700)),
                          SizedBox(width: 4),
                          Text(
                            "Premium",
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Duration Tag
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video.duration,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
            // Title info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7030A0),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          video.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isLocked ? Icons.lock_outline : Icons.play_arrow_rounded,
                    color: isLocked ? Colors.grey : const Color(0xFF7030A0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}