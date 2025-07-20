class AuthProvider {
  static String? username;
  static String? password;

  static void logout() {
    username = null;
    password = null;
  }
}