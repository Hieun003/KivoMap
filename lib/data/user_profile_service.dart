import 'dart:convert';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/assets/image_paths.dart';

class UserProfileService {
  UserProfileService._();
  static final UserProfileService _instance = UserProfileService._();
  factory UserProfileService() => _instance;

  static const String _legacyProfileKey = 'kivo.user_profile.v1';
  static const String _profileKeyPrefix = 'kivo.user_profile.v2';

  final Rx<UserProfileData> profile = UserProfileData.defaultProfile().obs;
  bool _isInitialized = false;
  String? _activeUserId;

  static const List<ProfileAvatarOption> avatarOptions = [
    ProfileAvatarOption(
      key: 'explorer',
      label: 'Nhà thám hiểm',
      assetPath: KivoImagePaths.kivoExplorer,
    ),
    ProfileAvatarOption(
      key: 'home',
      label: 'Người bạn Kivo',
      assetPath: KivoImagePaths.kivoHome,
    ),
    ProfileAvatarOption(
      key: 'thinking',
      label: 'Kivo suy nghĩ',
      assetPath: KivoImagePaths.kivoThinking,
    ),
    ProfileAvatarOption(
      key: 'story_teller',
      label: 'Kivo kể chuyện',
      assetPath: KivoImagePaths.kivoStoryTeller,
    ),
    ProfileAvatarOption(
      key: 'searching',
      label: 'Kivo tìm kiếm',
      assetPath: KivoImagePaths.kivoSearching,
    ),
  ];

  String get _storageKey => _activeUserId == null
      ? _legacyProfileKey
      : '$_profileKeyPrefix.${_activeUserId!}';

  Future<void> initialize() async {
    if (_isInitialized) return;
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        profile.value = UserProfileData.fromJson(jsonDecode(raw));
      } on Object {
        profile.value = UserProfileData.defaultProfile();
      }
    }
    _isInitialized = true;
  }

  Future<void> bindAuthenticatedUser({
    required String uid,
    String? displayName,
    String? email,
    String? phoneNumber,
  }) async {
    if (_activeUserId == uid && _isInitialized) return;

    _activeUserId = uid;
    _isInitialized = false;
    final contact = email?.trim().isNotEmpty == true
        ? email!.trim()
        : phoneNumber?.trim();
    var nextProfile = UserProfileData.defaultProfile(
      displayName: displayName,
      contact: contact,
    );

    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final local = UserProfileData.fromJson(jsonDecode(raw));
        nextProfile = local.copyWith(email: contact ?? local.email);
      } on Object {
        // Fall back to the authenticated identity.
      }
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = snapshot.data();
      if (data != null) {
        final remoteName = data['name']?.toString().trim();
        final remoteAvatar = data['avatarKey']?.toString();
        nextProfile = nextProfile.copyWith(
          displayName: remoteName?.isNotEmpty == true ? remoteName : null,
          avatarKey: avatarOptions.any((item) => item.key == remoteAvatar)
              ? remoteAvatar
              : null,
          email: contact,
        );
      }
    } on Object catch (error, stackTrace) {
      developer.log(
        'Remote profile load failed.',
        name: 'KivoMap.Profile',
        error: error,
        stackTrace: stackTrace,
      );
    }

    profile.value = nextProfile;
    await preferences.setString(_storageKey, jsonEncode(nextProfile.toJson()));
    _isInitialized = true;
  }

  Future<void> update({
    required String displayName,
    required String avatarKey,
  }) async {
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
    await preferences.setString(
      _storageKey,
      jsonEncode(profile.value.toJson()),
    );

    final uid = _activeUserId;
    if (uid != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': normalizedName,
          'avatarKey': avatarKey,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } on Object catch (error, stackTrace) {
        developer.log(
          'Remote profile update failed.',
          name: 'KivoMap.Profile',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  void resetToGuest() {
    _activeUserId = null;
    _isInitialized = false;
    profile.value = UserProfileData.defaultProfile();
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

  factory UserProfileData.defaultProfile({
    String? displayName,
    String? contact,
  }) => UserProfileData(
    displayName: displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : 'Người học Kivo',
    email: contact?.trim().isNotEmpty == true
        ? contact!.trim()
        : 'Tài khoản Kivo',
    avatarKey: 'explorer',
  );

  factory UserProfileData.fromJson(Object? source) {
    final json = source is Map ? source : const <String, Object?>{};
    return UserProfileData(
      displayName: json['displayName']?.toString() ?? 'Người học Kivo',
      email: json['email']?.toString() ?? 'Tài khoản Kivo',
      avatarKey: json['avatarKey']?.toString() ?? 'explorer',
    );
  }

  final String displayName;
  final String email;
  final String avatarKey;

  UserProfileData copyWith({
    String? displayName,
    String? email,
    String? avatarKey,
  }) => UserProfileData(
    displayName: displayName ?? this.displayName,
    email: email ?? this.email,
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
