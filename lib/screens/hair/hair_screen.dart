import 'package:flutter/material.dart';
import '../common/portfolio_gallery_screen.dart';

class HairScreen extends StatelessWidget {
  const HairScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PortfolioGalleryScreen(serviceType: 'Hair');
  }
}