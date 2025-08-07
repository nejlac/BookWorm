class AuthProvider {
  static String? username;
  static String? password;

  static void logout() {
    username = null;
    password = null;
  }

  static void clearAuth() {
    username = null;
    password = null;
  }

  static void updateUsername(String newUsername) {
    username = newUsername;
  }

  static void updatePassword(String newPassword) {
    password = newPassword;
  }
}