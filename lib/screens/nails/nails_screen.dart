import 'package:flutter/material.dart';
import '../common/portfolio_gallery_screen.dart';

class NailsScreen extends StatelessWidget {
  const NailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PortfolioGalleryScreen(serviceType: 'Nails');
  }
}