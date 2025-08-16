import 'dart:ui';
import 'package:bookworm_desktop/providers/auth_provider.dart';
import 'package:bookworm_desktop/providers/bookReview_provider.dart';
import 'package:bookworm_desktop/providers/book_provider.dart';
import 'package:bookworm_desktop/providers/book_club_provider.dart';
import 'package:bookworm_desktop/providers/country_provider.dart';
import 'package:bookworm_desktop/providers/genre_provider.dart';
import 'package:bookworm_desktop/providers/author_provider.dart';
import 'package:bookworm_desktop/providers/role_provider.dart';
import 'package:bookworm_desktop/providers/statistics_provider.dart';
import 'package:bookworm_desktop/providers/user_provider.dart';
import 'package:bookworm_desktop/screens/book_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookworm_desktop/layouts/master_screen.dart';

void main() {
 runApp(MultiProvider(providers: [
    ChangeNotifierProvider<BookProvider>(
        create: (context) => BookProvider()),
    ChangeNotifierProvider<GenreProvider>(
        create: (context) => GenreProvider()),
    ChangeNotifierProvider<AuthorProvider>(
        create: (context) => AuthorProvider()),
    ChangeNotifierProvider<BookClubProvider>(
        create: (context) => BookClubProvider()),
    ChangeNotifierProvider<CountryProvider>(
        create: (context) => CountryProvider()),
    ChangeNotifierProvider<UserProvider>(
      create: (context) => UserProvider()),
    ChangeNotifierProvider<RoleProvider>(
        create: (context) => RoleProvider()),
    ChangeNotifierProvider<BookReviewProvider>(
        create: (context) => BookReviewProvider()),
    ChangeNotifierProvider<StatisticsProvider>(
        create: (context) => StatisticsProvider()),
  ], child: const LoginPageApp()));
}



class LoginPageApp extends StatelessWidget {
  const LoginPageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookWorm Login',
      theme: ThemeData(
        fontFamily: 'Literata',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8D6748), 
          primary: const Color(0xFF8D6748), 
          secondary: const Color(0xFFF6E3B4), 
          surface: const Color(0xFFF6E3B4), 
        ),
        scaffoldBackgroundColor: const Color(0xFFF6E3B4), 
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFFFF8E1),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF8D6748),
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home:  LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  static void clearFields(BuildContext context) {
    final state = context.findAncestorStateOfType<_LoginPageState>();
    state?.clearFields();
  }

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  void clearFields() {
    usernameController.clear();
    passwordController.clear();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    try {
      setState(() {
        _isLoading = true;
      });

      var userProvider = UserProvider();
      var user = await userProvider.login(usernameController.text, passwordController.text);
      
      if (user != null) {
        AuthProvider.username = usernameController.text;
        AuthProvider.password = passwordController.text;
        
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            Future.delayed(const Duration(seconds: 1), () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            });
            return Dialog(
              backgroundColor: const Color(0xFFFFF8E1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.7, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) => Transform.scale(
                        scale: value,
                        child: child,
                      ),
                      child: Icon(Icons.menu_book_rounded, color: Color(0xFF8D6748), size: 60),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Login Successful!",
                      style: TextStyle(
                        fontFamily: 'Literata',
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Color(0xFF8D6748),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Welcome to BookWorm!",
                      style: TextStyle(
                        fontFamily: 'Literata',
                        fontSize: 16,
                        color: Color(0xFF8D6748),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.7, end: 1.0),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) => Transform.scale(
                        scale: value,
                        child: child,
                      ),
                      child: Icon(Icons.favorite, color: Color(0xFFe57373), size: 32),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MasterScreen(
              child: BookList(),
              title: "Book List",
              selectedIndex: 0,
            ),
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Login Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK")
            )
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox.expand(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withOpacity(0.08),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Login',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8D6748),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8D6748),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Literata',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.login, size: 20),
                                SizedBox(width: 12),
                                Text('Login'),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}