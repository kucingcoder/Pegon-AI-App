import 'package:flutter/material.dart';
import '../../data/learning_service.dart';
import '../../data/models/level_check_response.dart';
import 'level_one_page.dart';
import 'level_two_page.dart';
import 'level_three_page.dart';

class LevelListPage extends StatefulWidget {
  const LevelListPage({super.key});

  @override
  State<LevelListPage> createState() => _LevelListPageState();
}

class _LevelListPageState extends State<LevelListPage> {
  final LearningService _service = LearningService();
  LevelCheckResponse? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _service.checkLevelStage();
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
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildLevelCard(
                  level: 1,
                  title: 'Level 1: Materi',
                  subtitle: 'Contoh halaman penampilan materi',
                  icon: Icons.menu_book,
                  currentLevel: currentLevel,
                  color: Colors.teal,
                  onTap: () async {
                    // Navigate to Level 1
                    // Check if locked? Level 1 is always unlocked basically if we can see it.
                    // But effectively if currentLevel < 1 it would be locked (impossible).

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LevelOnePage(),
                      ),
                    );

                    if (result == true) {
                      _loadData(); // Refresh data if updated
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildLevelCard(
                  level: 2,
                  title: 'Level 2: Tes Membaca',
                  subtitle: 'Contoh halaman tes membaca',
                  icon: Icons.lock_outline,
                  currentLevel: currentLevel,
                  color: Colors.grey,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LevelTwoPage(),
                      ),
                    );

                    if (result == true) {
                      _loadData(); // Refresh data if updated
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildLevelCard(
                  level: 3,
                  title: 'Level 3: Tes Menulis',
                  subtitle: 'Contoh halaman tes menulis',
                  icon: Icons.lock_outline,
                  currentLevel: currentLevel,
                  color: Colors.grey,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LevelThreePage(),
                      ),
                    );

                    if (result == true) {
                      _loadData(); // Refresh data if updated
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
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
    VoidCallback? onTap,
  }) {
    final isLocked = level > currentLevel;

    final cardColor = isLocked ? Colors.grey[100] : Colors.white;
    final iconBgColor = isLocked
        ? Colors.grey[200]
        : (level == 1
              ? Colors.cyan
              : Colors.cyan); // Use cyan for active levels
    final iconColor = isLocked ? Colors.grey : Colors.white;
    final actualIcon = isLocked
        ? Icons.lock_outline
        : (level == 1 ? Icons.menu_book : Icons.edit); // Customize icons

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
              _buildProgressSection(level, currentLevel),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(int level, int currentLevel) {
    // Logic for progress visualization
    // If level < currentLevel, assume 100% done.
    // If level == currentLevel, calculate based on stage.
    // User said "masing-masing cuma 1 stage". So if checking "level-stage", it might return current_stage: 1, max: 1.
    // If I'm AT level 1, stage 1... is it 0% or what?
    // Let's assume if I'm AT level 1, I haven't finished it yet?
    // OR if existing logic implies "current_level: 1" means Level 1 is accessible.

    // Let's simply show:
    // If level < currentLevel -> 1/1 Selesai 100%
    // If level == currentLevel -> "Belum Selesai" or "0/1" or depending on stage.

    // Wait, the API returns current level.
    // If current_level = 1. User sees Level 1.
    // Is Level 1 finished? No.
    // So progress is 0/1. 0%.

    // BUT the image for Level 1 shows "1/1 Selesai 100%".
    // This implies Level 1 is DONE.
    // So maybe the user in the screenshot has current_level = 2 ?
    // Or maybe the API returns "current_level: 1" meaning "Working on Level 1".
    // If the screenshot shows Level 1 done, likely they have finished it.

    // I will stick to logic:
    // If level < currentLevel -> 100%.
    // If level == currentLevel -> Calculate % based on stage.
    // Since max stage is 1. If current_stage is 1. Progress = (1-1)/1 = 0% ?
    // Or maybe stage 1 means started stage 1.

    // Let's mock it for now to match visual appealing.
    // If level == currentLevel, I'll show it as "Active" or partial progress.
    // In many games, if I am Level 1, I have 0 progress on Level 1.

    // However, for the purpose of matching the "1/1 Selesai 100%" look in the request image (which is likely a reference to what it *should* look like when done, or the user wants Level 1 to be done):
    // I will implement dynamic progress.

    int completedStages = 0;
    int totalStages = 1;

    if (level < currentLevel) {
      completedStages = 1;
    } else if (level == currentLevel) {
      // If we are at this level.
      // Assuming current_stage starts at 1.
      // If max is 1.
      // We probably have completed 0.
      completedStages = (_data?.currentStage ?? 1) - 1;
      totalStages = _data?.maxStageInCurrentLevel ?? 1;
      if (totalStages < 1) totalStages = 1;
    }

    double percent = completedStages / totalStages;
    // Cap at 1.0
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
        const SizedBox(height: 12),
        Row(
          children: List.generate(5, (index) {
            // Stars logic.
            // If 100% -> 5 stars? Or based on score?
            // API doesn't return score. I'll just show full stars if completed, or empty if not.
            return Icon(
              Icons.star,
              color: percent >= 1.0 ? Colors.amber : Colors.grey[300],
              size: 20,
            );
          }),
        ),
      ],
    );
  }
}
