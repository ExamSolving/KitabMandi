/// Unified exception hierarchy for KitabMandi.
///
/// All layers throw subtypes of [AppException].
/// Controllers catch these and surface a user-facing message via AppSnackbar.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Thrown when a Firebase Auth operation fails (non-standard codes are
/// normalised to a human-readable message before throwing).
class AuthException extends AppException {
  const AuthException(super.message);
}

/// Thrown when a Firestore / Storage network call fails.
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

/// Thrown when a Firebase Storage upload/delete fails.
class StorageException extends AppException {
  const StorageException(super.message);
}

/// Thrown when the caller passes invalid input to a repository method.
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// Catch-all for unexpected errors.
class UnknownException extends AppException {
  const UnknownException([super.message = 'Something went wrong']);
}
