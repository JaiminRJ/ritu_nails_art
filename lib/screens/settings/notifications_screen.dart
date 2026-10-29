import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _bookingAlerts = true;
  bool _promotions = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'cursive',
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSwitchTile('Push Notifications', 'Receive instant alerts on your device', _pushNotifications, (v) => setState(() => _pushNotifications = v)),
          _buildSwitchTile('Booking Alerts', 'Updates on appointments and schedules', _bookingAlerts, (v) => setState(() => _bookingAlerts = v)),
          _buildSwitchTile('Special Offers & Discounts', 'New courses, nail arts, and seasonal deals', _promotions, (v) => setState(() => _promotions = v)),
          _buildSwitchTile('Email Updates', 'Summaries and receipts delivered to email', _emailNotifications, (v) => setState(() => _emailNotifications = v)),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        activeThumbColor: AppColors.primary,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}