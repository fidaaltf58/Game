import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/auth_service.dart';
import 'games/recycle_game_screen.dart';
import 'games/plant_game_screen.dart';
import 'games/clean_game_screen.dart';
import 'games/energy_game_screen.dart';
import 'login_screen.dart';
import '../chat/eco_assistant_chatbot.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _authService = AuthService();
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;
  bool _showChatbotTooltip = true;

  @override
  void initState() {
    super.initState();

    // Floating animation for chatbot
    _floatingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    // Pulse animation for chatbot
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotation for decorative elements
    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Hide tooltip after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showChatbotTooltip = false);
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _openChatbot() {
    setState(() => _showChatbotTooltip = false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EcoAssistantChatbot(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final totalScore = _authService.getTotalScore();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.lightBlue.shade200,
              Colors.green.shade200,
              Colors.lime.shade100,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background elements
            ...List.generate(6, (index) => _buildFloatingIcon(index)),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Header with logout
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            '🌍 حماة الكوكب',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black26,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Compact logout button
                        Material(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(15),
                          elevation: 8,
                          child: InkWell(
                            onTap: _logout,
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.logout, color: Colors.white, size: 20),
                                  SizedBox(width: 6),
                                  Text(
                                    'خروج',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // User info card
                        _buildUserCard(user?.username ?? '', totalScore),
                        const SizedBox(height: 20),

                        // Games grid
                        _buildAnimatedGameCard(
                          delay: 0,
                          title: '♻️ إعادة التدوير',
                          subtitle: 'فرز النفايات',
                          gradient: [Colors.blue.shade400, Colors.blue.shade700],
                          icon: Icons.recycling,
                          onTap: () => _navigateToGame(const RecycleGameScreen()),
                        ),
                        const SizedBox(height: 16),

                        _buildAnimatedGameCard(
                          delay: 200,
                          title: '🌱 زراعة الأشجار',
                          subtitle: 'ازرع وانقذ الكوكب',
                          gradient: [Colors.green.shade400, Colors.green.shade700],
                          icon: Icons.park,
                          onTap: () => _navigateToGame(const PlantGameScreen()),
                        ),
                        const SizedBox(height: 16),

                        _buildAnimatedGameCard(
                          delay: 400,
                          title: '🌊 تنظيف المحيطات',
                          subtitle: 'نظف البحار من القمامة',
                          gradient: [Colors.cyan.shade400, Colors.blue.shade700],
                          icon: Icons.waves,
                          onTap: () => _navigateToGame(const CleanGameScreen()),
                        ),
                        const SizedBox(height: 16),

                        _buildAnimatedGameCard(
                          delay: 600,
                          title: '⚡ الطاقة النظيفة',
                          subtitle: 'تعلم عن الطاقة المتجددة',
                          gradient: [Colors.amber.shade400, Colors.orange.shade700],
                          icon: Icons.bolt,
                          onTap: () => _navigateToGame(const EnergyGameScreen()),
                        ),
                        const SizedBox(height: 100), // Space for FAB
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Floating Chatbot Button - Version simplifiée
            Positioned(
              bottom: 20,
              right: 20,
              child: AnimatedBuilder(
                animation: _floatingAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatingAnimation.value),
                    child: ScaleTransition(
                      scale: _pulseAnimation,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _openChatbot,
                          borderRadius: BorderRadius.circular(35),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.purple.shade400,
                                  Colors.pink.shade400,
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.6),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.chat_bubble,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingIcon(int index) {
    final icons = [Icons.eco, Icons.recycling, Icons.water_drop, Icons.bolt, Icons.park, Icons.wb_sunny];
    final positions = [
      const Offset(30, 100),
      const Offset(320, 150),
      const Offset(50, 400),
      const Offset(300, 450),
      const Offset(150, 250),
      const Offset(250, 600),
    ];

    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        final position = positions[index];
        final animatedY = position.dy + (math.sin((_rotateController.value * 2 * math.pi) + index) * 20);

        return Positioned(
          left: position.dx,
          top: animatedY,
          child: Transform.rotate(
            angle: _rotateController.value * 2 * math.pi,
            child: Icon(
              icons[index],
              size: 40,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserCard(String username, int score) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.green.shade50],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, color: Colors.green, size: 32),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'مرحباً $username!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade300, Colors.orange.shade400],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.white, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        '$score نقطة',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedGameCard({
    required int delay,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: _GameCardWithHover(
                title: title,
                subtitle: subtitle,
                gradient: gradient,
                icon: icon,
                onTap: onTap,
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToGame(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((_) => setState(() {}));
  }
}

class _GameCardWithHover extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;
  final VoidCallback onTap;

  const _GameCardWithHover({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_GameCardWithHover> createState() => _GameCardWithHoverState();
}

class _GameCardWithHoverState extends State<_GameCardWithHover>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 130,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradient,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: widget.gradient[0].withOpacity(_isPressed ? 0.3 : 0.5),
                blurRadius: _isPressed ? 15 : 25,
                spreadRadius: _isPressed ? 2 : 5,
                offset: Offset(0, _isPressed ? 5 : 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated background circles
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.95),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}