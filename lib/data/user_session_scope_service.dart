class UserSessionScopeService {
  UserSessionScopeService._();
  static final UserSessionScopeService _instance = UserSessionScopeService._();
  factory UserSessionScopeService() => _instance;

  String? _userId;

  String? get userId => _userId;
  String get scopeId => _userId ?? 'guest';

  void bind(String? userId) {
    _userId = userId;
  }

  String scopedKey(String baseKey) {
    final userId = _userId;
    return userId == null ? baseKey : '$baseKey.$userId';
  }
}
