enum AuthStatus {
  uninitialized('uninitialized'),
  loggedIn('loggedIn'),
  loggedOut('loggedOut');

  const AuthStatus(this.status);

  final String status;

  factory AuthStatus.fromCode(String status) {
    return AuthStatus.values.firstWhere(
      (e) => e.status == status,
      orElse: () => AuthStatus.loggedOut,
    );
  }
}
