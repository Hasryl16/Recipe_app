class UserModel {
  final int? id;
  final String firebaseUid;
  final String username;
  final String? bio;
  final String? profilePicture;
  final DateTime? createdAt;

  UserModel({
    this.id,
    required this.firebaseUid,
    required this.username,
    this.bio,
    this.profilePicture,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firebaseUid: json['firebase_uid'],
      username: json['username'],
      bio: json['bio'],
      profilePicture: json['profile_picture'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'username': username,
      'bio': bio,
      'profile_picture': profilePicture,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
