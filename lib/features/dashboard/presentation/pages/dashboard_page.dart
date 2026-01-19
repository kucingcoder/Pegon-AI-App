import 'package:flutter/material.dart';
import '../../data/dashboard_service.dart';
import '../../data/models/dashboard_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardService _service = DashboardService();
  DashboardResponse? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _service.getDashboardData();
    if (mounted) {
      setState(() {
        _data = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_data == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load data'),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  _loadData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final user = _data!.user;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Profile)
              _buildHeader(user),
              const SizedBox(height: 20),

              // 2. Progress Card
              _buildProgressCard(user),
              const SizedBox(height: 20),

              // 3. Premium/Upgrade Card
              if (!user.isPremium) _buildUpgradeCard(),
              if (user.isPremium) _buildPremiumCard(user),
              const SizedBox(height: 20),

              // 4. Statistics Section
              Row(
                children: [
                  Image.asset(
                    'assets/images/icon_statistic.png',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Statistikmu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildStatistics(
                imageCount: _data!.imageTransliterationCount,
                textCount: _data!.textTransliterationCount,
              ),
              const SizedBox(height: 24),

              // 5. Action Buttons (Grid/List)
              const Text(
                'Apa yang ingin anda lakukan?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                icon: Icons.image,
                color: Colors.orange,
                title: 'Transliterasi Gambar',
                subtitle:
                    'Ubah teks pegon dari foto atau gambar di galeri menjadi latin',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                icon: Icons.description,
                color: Colors.teal,
                title: 'Transliterasi Teks',
                subtitle: 'Ubah teks latin menjadi pegon',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                icon: Icons.book,
                color: Colors.blue,
                title: 'Belajar',
                subtitle: 'Pelajaran & latihan interaktif',
                onTap: () {},
              ),
              const SizedBox(height: 24),

              // 6. Recent Activity List
              _buildRecentActivitySection(_data!.imageTransliterations),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            image: user.photoProfile.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(user.photoProfile),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: user.photoProfile.isEmpty
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.fullName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: user.isPremium ? Colors.amber : Colors.green[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                user.category,
                style: TextStyle(
                  fontSize: 10,
                  color: user.isPremium ? Colors.black : Colors.green[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressCard(User user) {
    // Calculate progress (e.g. 8/30)
    double progress = user.learningStageLevel / 30.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF00ACC1), // Keep simple solid teal for now
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress Belajar',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                  Text(
                    'Level ${user.learningLevel}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Stars placeholder
              Row(
                children: List.generate(5, (index) {
                  double starValue =
                      (user.learningStageLevel / user.learningStageMax) * 5;
                  if (index < starValue.floor()) {
                    return const Icon(
                      Icons.star,
                      color: Colors.yellow,
                      size: 20,
                    );
                  } else if (index < starValue && (starValue - index) >= 0.5) {
                    return const Icon(
                      Icons.star_half,
                      color: Colors.yellow,
                      size: 20,
                    );
                  } else {
                    return const Icon(
                      Icons.star_border,
                      color: Colors.white54,
                      size: 20,
                    );
                  }
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${user.learningStageLevel} dari ${user.learningStageMax} tahap diselesaikan',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.orange, Colors.green]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upgrade ke Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Buka semua fitur eksklusif!',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    // Note: "hanya muncul jika user standard" - Logic handled in build()
  }

  Widget _buildPremiumCard(User user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.yellow[700]!, Colors.amber[300]!], // Yellow gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.verified, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Premium Member',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (user.expiredAt != null)
                  Text(
                    'Berlaku sampai: ${_formatDate(user.expiredAt!)}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics({required int imageCount, required int textCount}) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem('Gambar', imageCount.toString(), Colors.orange),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatItem('Teks', textCount.toString(), Colors.teal),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              label == 'Gambar' ? Icons.image : Icons.description,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(Icons.arrow_forward_ios, size: 14),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildRecentActivitySection(List<ImageTransliteration> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Aktivitas Terbaru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {},
              child: const Row(
                children: [
                  Text('Lihat Semua', style: TextStyle(color: Colors.teal)),
                  Icon(Icons.arrow_forward_ios, size: 12, color: Colors.teal),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty) const Center(child: Text('Belum ada aktivitas')),
        ...items.map((item) => _buildActivityItem(item)),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString).toLocal();
      // Format: dd/mm/yyyy HH:mm
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildActivityItem(ImageTransliteration item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              image: item.image.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(item.image),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item.image.isEmpty ? const Icon(Icons.image) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title.isNotEmpty ? item.title : 'No Title',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(item.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.result,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
