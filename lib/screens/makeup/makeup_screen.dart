import 'package:flutter/material.dart';
import '../common/portfolio_gallery_screen.dart';

class MakeupScreen extends StatelessWidget {
  const MakeupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PortfolioGalleryScreen(serviceType: 'Makeup');
  }
}