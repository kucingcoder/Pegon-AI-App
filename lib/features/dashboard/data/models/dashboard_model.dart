class DashboardResponse {
  final int imageTransliterationCount;
  final List<ImageTransliteration> imageTransliterations;
  final int textTransliterationCount;
  final User user;

  DashboardResponse({
    required this.imageTransliterationCount,
    required this.imageTransliterations,
    required this.textTransliterationCount,
    required this.user,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      imageTransliterationCount: json['image_transliteration_count'] ?? 0,
      imageTransliterations:
          (json['image_transliterations'] as List?)
              ?.map((e) => ImageTransliteration.fromJson(e))
              .toList() ??
          [],
      textTransliterationCount: json['text_transliteration_count'] ?? 0,
      user: User.fromJson(json['user']),
    );
  }
}

class ImageTransliteration {
  final String id;
  final String title;
  final String result;
  final String image;
  final String createdAt;

  ImageTransliteration({
    required this.id,
    required this.title,
    required this.result,
    required this.image,
    required this.createdAt,
  });

  factory ImageTransliteration.fromJson(Map<String, dynamic> json) {
    return ImageTransliteration(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      result: json['result'] ?? '',
      image: json['image'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class User {
  final String fullName;
  final String category;
  final int learningLevel;
  final int learningStageLevel;
  final int learningStageMax;
  final String photoProfile;
  final String? expiredAt;

  User({
    required this.fullName,
    required this.category,
    required this.learningLevel,
    required this.learningStageLevel,
    required this.learningStageMax,
    required this.photoProfile,
    this.expiredAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullName: json['full_name'] ?? '',
      category: json['category'] ?? 'Standard',
      learningLevel: json['learning_level'] ?? 1,
      learningStageLevel: json['learning_stage_level'] ?? 1,
      learningStageMax: json['learning_stage_max'] ?? 1,
      photoProfile: json['photo_profile'] ?? '',
      expiredAt: json['expired_at'],
    );
  }

  bool get isPremium => category != 'Standard';
}
