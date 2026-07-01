import 'package:flutter/material.dart';
import '../../data/learning_service.dart';
import '../../data/models/level_check_response.dart';
import 'stage_list_page.dart';
import '../../data/learning_content.dart';
import '../../../dashboard/data/dashboard_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class LevelListPage extends StatefulWidget {
  const LevelListPage({super.key});

  @override
  State<LevelListPage> createState() => _LevelListPageState();
}

class _LevelListPageState extends State<LevelListPage> {
  final LearningService _service = LearningService();
  LevelCheckResponse? _data;
  bool _isLoading = true;

  // Ads
  BannerAd? _bannerAd;
  bool _isBannerReady = false;
  bool _isPremium = true;
  final DashboardService _dashboardService = DashboardService();

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkPremiumAndLoadAds();
  }

  Future<void> _checkPremiumAndLoadAds() async {
    final data = await _dashboardService.getDashboardData();
    if (data != null && mounted) {
      setState(() {
        _isPremium = data.user.isPremium;
      });

      if (!_isPremium) {
        _loadBannerAd();
      }
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-1144248073011584/6668460405',
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          _isBannerReady = false;
        },
      ),
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  IconData _getIconForLevel(int level) {
    switch (level) {
      case 1: return Icons.abc;
      case 2: return Icons.record_voice_over;
      case 3: return Icons.spellcheck;
      case 4: return Icons.font_download;
      case 5: return Icons.g_translate;
      case 6: return Icons.text_fields;
      case 7: return Icons.library_books;
      case 8: return Icons.workspace_premium;
      case 9: return Icons.school;
      default: return Icons.menu_book;
    }
  }

  Color _getColorForLevel(int level) {
    switch (level) {
      case 1: return Colors.teal;
      case 2: return Colors.blue;
      case 3: return Colors.indigo;
      case 4: return Colors.purple;
      case 5: return Colors.deepPurple;
      case 6: return Colors.orange;
      case 7: return Colors.deepOrange;
      case 8: return Colors.red;
      case 9: return Colors.pink;
      default: return Colors.cyan;
    }
  }

  Future<void> _loadData() async {
    try {
      final data = await _service.checkLevelStage();
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Default if data fetch fails, assume level 1
    final currentLevel = _data?.currentLevel ?? 1;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Belajar'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: learningLevels.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final levelContent = learningLevels[index];
                return _buildLevelCard(
                  level: levelContent.level,
                  title: levelContent.title,
                  subtitle: levelContent.subtitle,
                  icon: _getIconForLevel(levelContent.level),
                  currentLevel: currentLevel,
                  color: _getColorForLevel(levelContent.level),
                  totalStages: levelContent.stages.length,
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StageListPage(
                          selectedLevel: levelContent.level,
                          data: _data,
                          onRefresh: () => _loadData(),
                        ),
                      ),
                    ).then((_) => _loadData());
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isBannerReady && !_isPremium && _bannerAd != null
          ? SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : null,
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        // Base Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.amber[50]!, Colors.white, Colors.teal[50]!],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Abstract Shapes
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber[100]!.withOpacity(0.3),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.teal[100]!.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelCard({
    required int level,
    required String title,
    required String subtitle,
    required IconData icon,
    required int currentLevel,
    required Color color,
    required int totalStages,
    VoidCallback? onTap,
  }) {
    final isLocked = level > currentLevel;

    final cardColor = isLocked ? Colors.grey[100] : Colors.white;
    final iconBgColor = isLocked
        ? Colors.grey[200]
        : color; 
    final iconColor = isLocked ? Colors.grey : Colors.white;
    final actualIcon = isLocked
        ? Icons.lock_outline
        : icon; 

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(actualIcon, color: iconColor, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isLocked ? Colors.grey : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLocked)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Terkunci',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else
              _buildProgressSection(level, currentLevel, totalStages),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(int level, int currentLevel, int totalStages) {
    int completedStages = 0;

    if (level < currentLevel) {
      completedStages = totalStages;
    } else if (level == currentLevel) {
      // Karena stage dimulai dari 1 (terbawah 1), maka yang selesai = stage sekarang dikurangi 1
      completedStages = (_data?.currentStage ?? 1) - 1;
      
      // Fix for final level/stage stuck bug
      if (level == 9 && (_data?.currentStage ?? 1) == 10) {
        completedStages = 10;
      }
      
      if (completedStages < 0) completedStages = 0;
    }

    double percent = completedStages / totalStages;
    // Memastikan nilai persentase tidak di bawah 0 atau lebih dari 100%
    if (percent < 0.0) percent = 0.0;
    if (percent > 1.0) percent = 1.0;

    // Special handling to match valid data
    if (level < currentLevel) percent = 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completedStages/$totalStages Selesai',
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
            Text(
              '${(percent * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.grey[200],
            color: Colors.orange,
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
