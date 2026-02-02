import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How can I track my order?',
      'answer': 'You can track your order by navigating to Profile > My Orders and clicking on the "Track Order" button for the specific order.'
    },
    {
      'question': 'How do I submit manual TID?',
      'answer': 'During checkout, after making the transfer, enter the Transaction ID in the "Payment Details" section to initiate verification.'
    },
    {
      'question': 'What is the return policy?',
      'answer': 'SwiftCart offers a 7-day return policy for unused items in their original packaging. Please contact support for more details.'
    },
    {
      'question': 'How do I change my delivery address?',
      'answer': 'You can manage your saved addresses in Profile > Shipping Address. For active orders, please contact support immediately.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar Section
            _buildSearchHeader(),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildSectionTitle('Quick Support'),
                   const SizedBox(height: 16),
                   _buildSupportChannels(),
                   
                   const SizedBox(height: 40),
                   _buildSectionTitle('Frequently Asked Questions'),
                   const SizedBox(height: 16),
                   _buildFaqList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppTheme.white),
        decoration: InputDecoration(
          hintText: 'Search for help topics...',
          hintStyle: TextStyle(color: AppTheme.grey.withOpacity(0.5)),
          prefixIcon: const Icon(Icons.search, color: AppTheme.accentColor),
          filled: true,
          fillColor: AppTheme.white.withOpacity(0.05),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppTheme.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.accentColor),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.headline4.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSupportChannels() {
    return Row(
      children: [
        _buildSupportCard(
          icon: Icons.chat_bubble_outline,
          title: 'WhatsApp',
          color: const Color(0xFF25D366),
          onTap: () async {
            final url = Uri.parse('whatsapp://send?phone=923011045479');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } else {
              // Fallback to web WhatsApp
              final webUrl = Uri.parse('https://wa.me/923011045479');
              await launchUrl(webUrl, mode: LaunchMode.externalApplication);
            }
          },
        ),
        const SizedBox(width: 12),
        _buildSupportCard(
          icon: Icons.email_outlined,
          title: 'Email Us',
          color: const Color(0xFFEA4335),
          onTap: () async {
            final url = Uri.parse('mailto:shamii9145@gmail.com');
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            }
          },
        ),
        const SizedBox(width: 12),
        _buildSupportCard(
          icon: Icons.phone_outlined,
          title: 'Call Us',
          color: const Color(0xFF34A853),
          onTap: () async {
            final url = Uri.parse('tel:+923011045479');
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSupportCard({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTheme.caption.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqList() {
    return Column(
      children: _faqs.map((faq) => _buildFaqTile(faq['question']!, faq['answer']!)).toList(),
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.white.withOpacity(0.05)),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: AppTheme.bodyText2.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold),
        ),
        iconColor: AppTheme.accentColor,
        collapsedIconColor: AppTheme.grey,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: AppTheme.caption.copyWith(color: AppTheme.grey, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
