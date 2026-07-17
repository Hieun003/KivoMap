import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/assets/image_paths.dart';

class UserProfileService {
  UserProfileService._();
  static final UserProfileService _instance = UserProfileService._();
  factory UserProfileService() => _instance;

  static const String _profileKey = 'kivo.user_profile.v1';

  final Rx<UserProfileData> profile = UserProfileData.defaultProfile().obs;
  bool _isInitialized = false;

  static const List<ProfileAvatarOption> avatarOptions = [
    ProfileAvatarOption(key: 'explorer', label: 'Nhà thám hiểm', assetPath: KivoImagePaths.kivoExplorer),
    ProfileAvatarOption(key: 'home', label: 'Người bạn Kivo', assetPath: KivoImagePaths.kivoHome),
    ProfileAvatarOption(key: 'thinking', label: 'Kivo suy nghĩ', assetPath: KivoImagePaths.kivoThinking),
    ProfileAvatarOption(key: 'story_teller', label: 'Kivo kể chuyện', assetPath: KivoImagePaths.kivoStoryTeller),
    ProfileAvatarOption(key: 'searching', label: 'Kivo tìm kiếm', assetPath: KivoImagePaths.kivoSearching),
  ];

  Future<void> initialize() async {
    if (_isInitialized) return;
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_profileKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        profile.value = UserProfileData.fromJson(jsonDecode(raw));
      } catch (_) {
        profile.value = UserProfileData.defaultProfile();
      }
    }
    _isInitialized = true;
  }

  Future<void> update({required String displayName, required String avatarKey}) async {
    await initialize();
    final normalizedName = displayName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedName.isEmpty || normalizedName.length > 32) {
      throw ArgumentError.value(displayName, 'displayName');
    }
    if (avatarOptions.every((option) => option.key != avatarKey)) {
      throw ArgumentError.value(avatarKey, 'avatarKey');
    }
    profile.value = profile.value.copyWith(
      displayName: normalizedName,
      avatarKey: avatarKey,
    );
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_profileKey, jsonEncode(profile.value.toJson()));
  }

  ProfileAvatarOption avatarFor(String key) => avatarOptions.firstWhere(
    (option) => option.key == key,
    orElse: () => avatarOptions.first,
  );
}

class UserProfileData {
  const UserProfileData({
    required this.displayName,
    required this.email,
    required this.avatarKey,
  });

  factory UserProfileData.defaultProfile() => const UserProfileData(
    displayName: 'Explorer Nguyễn',
    email: 'dev.kivomap@gmail.com',
    avatarKey: 'explorer',
  );

  factory UserProfileData.fromJson(Object? source) {
    final json = source is Map ? source : const <String, Object?>{};
    return UserProfileData(
      displayName: json['displayName']?.toString() ?? 'Explorer Nguyễn',
      email: json['email']?.toString() ?? 'dev.kivomap@gmail.com',
      avatarKey: json['avatarKey']?.toString() ?? 'explorer',
    );
  }

  final String displayName;
  final String email;
  final String avatarKey;

  UserProfileData copyWith({String? displayName, String? avatarKey}) =>
      UserProfileData(
        displayName: displayName ?? this.displayName,
        email: email,
        avatarKey: avatarKey ?? this.avatarKey,
      );

  Map<String, Object?> toJson() => {
    'displayName': displayName,
    'email': email,
    'avatarKey': avatarKey,
  };
}

class ProfileAvatarOption {
  const ProfileAvatarOption({
    required this.key,
    required this.label,
    required this.assetPath,
  });

  final String key;
  final String label;
  final String assetPath;
}
