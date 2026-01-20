class LevelUpdateResponse {
  final bool success;
  final String message;
  final int currentLevel;
  final int currentStageLevel;

  LevelUpdateResponse({
    required this.success,
    required this.message,
    required this.currentLevel,
    required this.currentStageLevel,
  });

  factory LevelUpdateResponse.fromJson(Map<String, dynamic> json) {
    return LevelUpdateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      currentLevel: json['current_level'] ?? 1,
      currentStageLevel: json['current_stage_level'] ?? 1,
    );
  }
}
