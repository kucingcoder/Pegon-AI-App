class LevelCheckResponse {
  final int currentLevel;
  final int currentStage;
  final int maxLevel;
  final int maxStageInCurrentLevel;

  LevelCheckResponse({
    required this.currentLevel,
    required this.currentStage,
    required this.maxLevel,
    required this.maxStageInCurrentLevel,
  });

  factory LevelCheckResponse.fromJson(Map<String, dynamic> json) {
    return LevelCheckResponse(
      currentLevel: json['current_level'] ?? 1,
      currentStage: json['current_stage'] ?? 1,
      maxLevel: json['max_level'] ?? 3,
      maxStageInCurrentLevel: json['max_stage_in_current_level'] ?? 1,
    );
  }
}
