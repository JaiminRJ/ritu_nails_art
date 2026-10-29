import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart'; // Adjust import if needed

class CoursePaymentSheet extends StatefulWidget {
  final String courseTitle;
  final String amount;

  const CoursePaymentSheet({
    super.key,
    required this.courseTitle,
    required this.amount,
  });

  static void show(BuildContext context, {required String courseTitle, required String amount}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CoursePaymentSheet(
        courseTitle: courseTitle,
        amount: amount,
      ),
    );
  }

  @override
  State<CoursePaymentSheet> createState() => _CoursePaymentSheetState();
}

class _CoursePaymentSheetState extends State<CoursePaymentSheet> {
  int _selectedMethodIndex = 0; // 0: UPI, 1: QR Code, 2: Bank Transfer

  // Sample Payment Details - replace with your actual values
  final String upiId = 'rituarts@upi';
  final String bankName = 'HDFC Bank';
  final String accNumber = '50100492817263';
  final String ifscCode = 'HDFC0001234';
  final String accHolder = 'Ritu Arts Academy';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Course and Price Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.courseTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Select Payment Method',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.amount,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Method Selector Tabs
          Row(
            children: [
              _buildTabButton('UPI', Icons.mobile_screen_share, 0),
              const SizedBox(width: 8),
              _buildTabButton('Scan QR', Icons.qr_code_2, 1),
              const SizedBox(width: 8),
              _buildTabButton('Bank', Icons.account_balance, 2),
            ],
          ),

          const SizedBox(height: 20),

          // Content based on selection
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildSelectedContent(),
          ),

          const SizedBox(height: 20),

          // Submit / Confirm proof button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment details submitted! Verification in progress.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text(
                'I Have Completed Payment',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, IconData icon, int index) {
    final bool isSelected = _selectedMethodIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedMethodIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.primary : Colors.grey.shade700,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.primary : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedContent() {
    switch (_selectedMethodIndex) {
      case 0:
        return _buildUpiSection();
      case 1:
        return _buildQrSection();
      case 2:
        return _buildBankSection();
      default:
        return const SizedBox.shrink();
    }
  }

  // 1. UPI Section
  Widget _buildUpiSection() {
    return Container(
      key: const ValueKey(0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Send payment via UPI ID:', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                upiId,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, size: 20, color: AppColors.primary),
                tooltip: 'Copy UPI ID',
                onPressed: () => _copyToClipboard(upiId, 'UPI ID copied!'),
              ),
            ],
          ),
          const Divider(),
          const Text(
            'Accepted on: GPay, PhonePe, Paytm, or BHIM',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 2. QR Code Section
  Widget _buildQrSection() {
    return Container(
      key: const ValueKey(1),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(
              Icons.qr_code_2,
              size: 130,
              color: Colors.black87,
            ),
            // Or load your real QR code asset/image:
            // child: Image.asset('assets/payment_qr.png', height: 130, width: 130),
          ),
          const SizedBox(height: 10),
          const Text(
            'Scan using any UPI App',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // 3. Bank Transfer Section
  Widget _buildBankSection() {
    return Container(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildBankDetailRow('Account Holder', accHolder),
          _buildBankDetailRow('Bank Name', bankName),
          _buildBankDetailRow('Account No.', accNumber, copyable: true),
          _buildBankDetailRow('IFSC Code', ifscCode, copyable: true),
        ],
      ),
    );
  }

  Widget _buildBankDetailRow(String title, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              if (copyable) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _copyToClipboard(value, '$title copied!'),
                  child: const Icon(Icons.copy, size: 16, color: AppColors.primary),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}