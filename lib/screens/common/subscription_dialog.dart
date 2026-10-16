import 'package:flutter/material.dart';

class SubscriptionDialog extends StatelessWidget {
  final String videoTitle;
  final VoidCallback onProceedToPayment;

  const SubscriptionDialog({
    super.key,
    required this.videoTitle,
    required this.onProceedToPayment,
  });

  static Future<void> show(
    BuildContext context, {
    required String videoTitle,
    required VoidCallback onProceedToPayment,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => SubscriptionDialog(
        videoTitle: videoTitle,
        onProceedToPayment: onProceedToPayment,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7030A0).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                size: 38,
                color: Color(0xFF7030A0),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Subscription Required",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D0C5E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "To watch \"$videoTitle\", please subscribe to unlock full access to Nails, Makeup & Hair tutorials.",
              style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7030A0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  onProceedToPayment();        // Open payment
                },
                child: const Text("Subscribe Now & Watch", style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Maybe Later", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}