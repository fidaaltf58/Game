import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLogin = true;
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    ));
    _animController.forward();
  }

  Future<void> _handleAuth() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMessage('الرجاء ملء جميع الحقول', Colors.orange);
      return;
    }

    bool success;
    if (_isLogin) {
      success = await _authService.login(username, password);
      if (success) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        _showMessage('اسم المستخدم أو كلمة المرور غير صحيحة', Colors.red);
      }
    } else {
      success = await _authService.register(username, password);
      if (success) {
        _showMessage('تم التسجيل بنجاح! يمكنك تسجيل الدخول الآن', Colors.green);
        setState(() {
          _isLogin = true;
          _passwordController.clear();
        });
      } else {
        _showMessage('اسم المستخدم موجود بالفعل', Colors.red);
      }
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade300,
              Colors.lightGreen.shade200,
              Colors.lime.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SlideTransition(
                position: _slideAnimation,
                child: Card(
                  elevation: 15,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Colors.green.shade50],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.eco,
                            size: 80,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _isLogin ? 'مرحباً بعودتك!' : 'انضم إلينا!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'دعونا نحمي البيئة معاً 🌍',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.green.shade600,
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextField(
                          controller: _usernameController,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                            labelText: 'اسم المستخدم',
                            labelStyle: const TextStyle(fontSize: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.person, size: 28),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            labelStyle: const TextStyle(fontSize: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.lock, size: 28),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _handleAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                            ),
                            child: Text(
                              _isLogin ? 'دخول' : 'تسجيل',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            setState(() => _isLogin = !_isLogin);
                          },
                          child: Text(
                            _isLogin
                                ? 'ليس لديك حساب؟ سجل الآن 🌱'
                                : 'لديك حساب؟ سجل الدخول 🌿',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }
}