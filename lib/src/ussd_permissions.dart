/// Checks and requests the Android permissions a multi-session call needs.
abstract interface class UssdPermissions {
  /// `true` when phone and accessibility access are already granted.
  ///
  /// A platform failure is reported as `false`.
  Future<bool> hasPermissions();

  /// Asks for phone permissions and opens accessibility settings when needed.
  Future<void> requestPermissions();
}
