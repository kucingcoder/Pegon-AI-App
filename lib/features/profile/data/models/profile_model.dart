class ProfileData {
  final String addInCode;
  final String dateOfBirth;
  final String fullName;
  final String gender;
  final String photoProfile;

  ProfileData({
    required this.addInCode,
    required this.dateOfBirth,
    required this.fullName,
    required this.gender,
    required this.photoProfile,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      addInCode: json['add_in_code'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      fullName: json['full_name'] ?? '',
      gender: json['gender'] ?? 'Male',
      photoProfile: json['photo_profile'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'add_in_code': addInCode,
      'date_of_birth': dateOfBirth,
      'full_name': fullName,
      'gender': gender,
      'photo_profile': photoProfile,
    };
  }
}
