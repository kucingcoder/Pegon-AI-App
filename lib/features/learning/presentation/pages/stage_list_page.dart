import 'package:flutter/material.dart';
import '../../data/models/level_check_response.dart';
import 'level_one_page.dart';
import 'level_two_page.dart';
import 'level_three_page.dart';
import '../../data/learning_content.dart';

class StageListPage extends StatefulWidget {
  final int selectedLevel;
  final LevelCheckResponse? data;
  final VoidCallback onRefresh;

  const StageListPage({
    super.key,
    required this.selectedLevel,
    required this.data,
    required this.onRefresh,
  });

  @override
  State<StageListPage> createState() => _StageListPageState();
}

class _StageListPageState extends State<StageListPage> {
  void _navigateToStage(int stageIndex) async {
    Widget page;
    int apiStage = stageIndex + 1; // Backend requires 1-based index
    final levelContent = learningLevels.firstWhere((l) => l.level == widget.selectedLevel);
    final stageContent = levelContent.stages[stageIndex];
    
    if (stageContent.type == StageType.info) {
      page = LevelOnePage(level: widget.selectedLevel, stage: apiStage, content: stageContent);
    } else if (stageContent.type == StageType.read) {
      page = LevelTwoPage(level: widget.selectedLevel, stage: apiStage, content: stageContent);
    } else {
      page = LevelThreePage(level: widget.selectedLevel, stage: apiStage, content: stageContent);
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );

    if (result == true) {
      widget.onRefresh();
      // Wait a moment for data to refresh then pop back?
      // User might want to stay on stage list page to see progress update, so we can pop if we want, or just wait.
      // Since data is passed from LevelListPage, calling onRefresh will fetch data, but it might not immediately rebuild StageListPage unless we fetch data locally or use a state manager.
      // Wait, let's just pop back to Level list page when a stage is done, or pop down to refresh.
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLevel = widget.data?.currentLevel ?? 1;
    final currentStage = widget.data?.currentStage ?? 1;

    final levelContent = learningLevels.firstWhere((l) => l.level == widget.selectedLevel);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Level ${widget.selectedLevel}'),
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
              itemCount: levelContent.stages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final stageContent = levelContent.stages[index];
                IconData icon;
                if (stageContent.type == StageType.info) icon = Icons.menu_book;
                else if (stageContent.type == StageType.read) icon = Icons.mic;
                else icon = Icons.edit;
                
                return _buildStageCard(
                  stageIndex: index,
                  title: 'Stage ${index + 1}: ${stageContent.title}',
                  icon: icon,
                  userCurrentLevel: currentLevel,
                  userCurrentStage: currentStage,
                );
              },
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.amber[50]!, Colors.white, Colors.teal[50]!],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
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

  Widget _buildStageCard({
    required int stageIndex,
    required String title,
    required IconData icon,
    required int userCurrentLevel,
    required int userCurrentStage,
  }) {
    bool isLocked = true;
    if (widget.selectedLevel < userCurrentLevel) {
      isLocked = false;
    } else if (widget.selectedLevel == userCurrentLevel) {
      isLocked = (stageIndex + 1) > userCurrentStage;
      
      // Special case: if at max level and max stage, it's not locked
      if (widget.selectedLevel == 9 && userCurrentStage == 10 && stageIndex == 9) {
        isLocked = false;
      }
    }

    // Determine completion status
    bool isCompleted = false;
    if (widget.selectedLevel < userCurrentLevel) {
      isCompleted = true;
    } else if (widget.selectedLevel == userCurrentLevel) {
      isCompleted = (stageIndex + 1) < userCurrentStage;
      
      // Fix for final level/stage bug
      if (widget.selectedLevel == 9 && userCurrentStage == 10 && stageIndex == 9) {
        isCompleted = true;
      }
    }

    final cardColor = isLocked ? Colors.grey[100] : Colors.white;
    final iconBgColor = isLocked ? Colors.grey[200] : Colors.cyan;
    final iconColor = isLocked ? Colors.grey : Colors.white;

    return GestureDetector(
      onTap: isLocked ? null : () => _navigateToStage(stageIndex),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? Colors.cyan.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isLocked ? Icons.lock_outline : icon,
                color: iconColor,
              ),
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
                  if (isCompleted)
                    const Text(
                      'Selesai',
                      style: TextStyle(
                        color: Colors.cyan,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else if (isLocked)
                    const Text(
                      'Terkunci',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    )
                  else
                    const Text(
                      'Belum Selesai',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                ],
              ),
            ),
            if (isCompleted) const Icon(Icons.check_circle, color: Colors.cyan),
          ],
        ),
      ),
    );
  }
}
