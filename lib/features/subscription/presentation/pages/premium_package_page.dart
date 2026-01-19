import 'package:flutter/material.dart';
import 'checkout_page.dart';

class PremiumPackagePage extends StatelessWidget {
  const PremiumPackagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 40),

                  // Features List
                  _buildFeatureItem(
                    icon: Icons.verified_user_outlined,
                    color: Colors.purpleAccent,
                    text: 'Bebas Iklan',
                  ),
                  _buildFeatureItem(
                    icon: Icons.all_inclusive,
                    color: Colors.blueAccent,
                    text: 'Transliterasi Harian Tanpa Batas',
                  ),
                  _buildFeatureItem(
                    icon: Icons.auto_awesome,
                    color: Colors.pinkAccent,
                    text: 'Belajar Harian Tanpa Batas',
                  ),
                  _buildFeatureItem(
                    icon: Icons.description_outlined,
                    color: Colors.green,
                    text: 'Akses Add-in Microsoft Word',
                  ),
                  _buildFeatureItem(
                    icon: Icons.control_camera_outlined,
                    color: Colors.orange,
                    text: 'Akurasi Lebih Tinggi',
                  ),
                  _buildFeatureItem(
                    icon: Icons.speed,
                    color: Colors.cyan,
                    text: 'Pemrosesan Lebih Cepat',
                  ),

                  const SizedBox(height: 40),

                  // Text Label
                  Text(
                    'Paket Premium',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 10),

                  // Pricing Card
                  _buildPricingCard(),

                  const SizedBox(height: 30),

                  // Upgrade Button
                  _buildUpgradeButton(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFDE7), // Light Yellow
                Colors.white,
                Color(0xFFE0F2F1), // Light Teal
              ],
            ),
          ),
        ),
        // Decorative shapes could be added here if needed to match exact design
        // For now, the clean gradient serves the purpose well.
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Colors.amber, // Brownish text
              height: 1.2,
            ),
            children: [TextSpan(text: 'PREMIUM')],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Dapatkan akses tanpa batas ke semua\nfitur premium',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00BCD4), // Cyan
            Color(0xFF2979FF), // Blue
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Abstract circles
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Paket Terpopuler',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bulanan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: 'Rp ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextSpan(
                          text: '30.000',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'per bulan',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Akses penuh ke semua fitur premium!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF6D00), // Orange
            Color(0xFFFFD600), // Yellow/Gold
            Color(0xFF1DE9B6), // Teal accent similar to image bottom right
          ],
          stops: [0.0, 0.6, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CheckoutPage()),
            );
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flash_on, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Upgrade Sekarang!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.auto_awesome, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
