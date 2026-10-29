import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CaptchaWidget extends StatefulWidget {
  final Function(String captchaCode) onGenerated;

  const CaptchaWidget({super.key, required this.onGenerated});

  @override
  State<CaptchaWidget> createState() => CaptchaWidgetState();
}

class CaptchaWidgetState extends State<CaptchaWidget> {
  String _captchaCode = '';

  @override
  void initState() {
    super.initState();
    generateNewCaptcha();
  }

  void generateNewCaptcha() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    final newCode = List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();

    setState(() {
      _captchaCode = newCode;
    });

    widget.onGenerated(newCode);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Captcha Text styling with custom spacing/styling to mimic captcha security
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              _captchaCode,
              style: const TextStyle(
                fontSize: 20,
                letterSpacing: 4,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: AppColors.primary,
                decoration: TextDecoration.lineThrough,
                decorationThickness: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Refresh Captcha',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: generateNewCaptcha,
          ),
        ],
      ),
    );
  }
}