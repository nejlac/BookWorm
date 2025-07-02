import 'dart:ui';
import 'package:bookworm_desktop/providers/auth_provider.dart';
import 'package:bookworm_desktop/providers/book_provider.dart';
import 'package:bookworm_desktop/screens/book_list.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const LoginPageApp());
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

class LoginPage extends StatelessWidget {
   LoginPage({super.key});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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
                      onPressed: () async {
                          AuthProvider.username = usernameController.text;
                        AuthProvider.password = passwordController.text;
                    try {
                      print("Username: ${AuthProvider.username}, Password: ${AuthProvider.password}");
                      var bookProvider = BookProvider();
                      var books = await bookProvider.get();


await showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) {
    Future.delayed(const Duration(seconds:1 ), () {
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

Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => BookList()),
);
                    } on Exception catch (e) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text("Error"),
                                content: Text(e.toString()),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("OK"))
                                ],
                              ));
                    } catch (e) {
                      print(e);
                    }

                      },
                      child: Row(
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
