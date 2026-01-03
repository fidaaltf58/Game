import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class CleanGameScreen extends StatefulWidget {
  const CleanGameScreen({super.key});

  @override
  State<CleanGameScreen> createState() => _CleanGameScreenState();
}

class _CleanGameScreenState extends State<CleanGameScreen> with SingleTickerProviderStateMixin {
  int _currentLevel = 1;
  int _score = 0;
  int _trashCollected = 0;
  int _targetTrash = 0;
  int _timeLeft = 0;
  Timer? _timer;
  Timer? _spawnTimer;
  bool _gameStarted = false;

  final List<TrashItem> _trashItems = [];
  final _random = Random();
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spawnTimer?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  void _startLevel(int level) {
    setState(() {
      _currentLevel = level;
      _score = 0;
      _trashCollected = 0;
      _gameStarted = true;
      _trashItems.clear();

      switch (level) {
        case 1:
          _timeLeft = 40;
          _targetTrash = 15;
          break;
        case 2:
          _timeLeft = 35;
          _targetTrash = 25;
          break;
        case 3:
          _timeLeft = 30;
          _targetTrash = 35;
          break;
      }
    });
    _startTimer();
    _startSpawning();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _endGame();
        }
      });
    });
  }

  void _startSpawning() {
    _spawnTimer?.cancel();
    final spawnInterval = _currentLevel == 1 ? 1500 : (_currentLevel == 2 ? 1200 : 1000);

    _spawnTimer = Timer.periodic(Duration(milliseconds: spawnInterval), (timer) {
      if (_gameStarted && _trashItems.length < 10) {
        setState(() {
          _trashItems.add(TrashItem(
            id: DateTime.now().millisecondsSinceEpoch,
            emoji: _getRandomTrash(),
            x: _random.nextDouble() * 0.8 + 0.1,
            y: -0.1,
          ));
        });
      }
    });

    // Move items
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_gameStarted) {
        timer.cancel();
        return;
      }

      setState(() {
        _trashItems.removeWhere((item) => item.y > 1.1);
        for (var item in _trashItems) {
          item.y += 0.01 * (_currentLevel == 3 ? 1.5 : 1.0);
        }
      });
    });
  }

  String _getRandomTrash() {
    final trashTypes = ['🗑️', '🥤', '🍾', '🛍️', '🧃', '📦', '🥫', '🧴'];
    return trashTypes[_random.nextInt(trashTypes.length)];
  }

  void _collectTrash(TrashItem item) {
    setState(() {
      _trashItems.remove(item);
      _trashCollected++;
      _score += 10;
    });

    if (_trashCollected >= _targetTrash) {
      Future.delayed(const Duration(milliseconds: 500), _endGame);
    }
  }

  void _endGame() {
    _timer?.cancel();
    _spawnTimer?.cancel();
    setState(() => _gameStarted = false);

    final timeBonus = _timeLeft * 2;
    final finalScore = _score + timeBonus;

    AuthService().updateScore('clean', _currentLevel, finalScore);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text('🌊 ممتاز!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 20),
            Text(
              'المستوى $_currentLevel',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'نظفت $_trashCollected قطعة قمامة 🗑️',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'النقاط: $_score',
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            ),
            if (timeBonus > 0)
              Text(
                'مكافأة الوقت: +$timeBonus',
                style: const TextStyle(fontSize: 18, color: Colors.orange),
              ),
            Text(
              'المجموع: $finalScore نقطة',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                '🐠 البحار النظيفة = حياة بحرية سعيدة!\nالقمامة في المحيطات تؤذي الأسماك والحيوانات',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.blue, height: 1.5),
              ),
            ),
          ],
        ),
        actions: [
          if (_currentLevel < 3)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startLevel(_currentLevel + 1);
              },
              child: const Text('المستوى التالي ➡️', style: TextStyle(fontSize: 18)),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('عودة 🏠', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_gameStarted) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('لعبة تنظيف المحيطات', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue.shade700,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.cyan.shade300, Colors.blue.shade400],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.waves, size: 120, color: Colors.white),
                    const SizedBox(height: 30),
                    const Text(
                      '🌊 لعبة تنظيف المحيطات',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'اجمع القمامة من المحيط!\nاحمِ الحياة البحرية 🐠🐢',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.cyan.shade100,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.cyan, width: 2),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            '🎯 الهدف 14 من أهداف التنمية المستدامة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'الحياة تحت الماء',
                            style: TextStyle(fontSize: 14, color: Colors.blue),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildLevelButton(1, 'سهل', '15 قطعة - 40 ثانية'),
                    const SizedBox(height: 15),
                    _buildLevelButton(2, 'متوسط', '25 قطعة - 35 ثانية'),
                    const SizedBox(height: 15),
                    _buildLevelButton(3, 'صعب', '35 قطعة - 30 ثانية'),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('المستوى $_currentLevel', style: const TextStyle(color: Colors.white, fontSize: 24)),
        backgroundColor: Colors.blue.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.blue),
                  const SizedBox(width: 5),
                  Text(
                    '$_timeLeft',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _timeLeft <= 10 ? Colors.red : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Ocean background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.lightBlue.shade300,
                  Colors.blue.shade500,
                  Colors.blue.shade700,
                ],
              ),
            ),
          ),
          // Animated waves
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(_waveController.value),
                );
              },
            ),
          ),
          // Score panel
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoChip('القمامة', '$_trashCollected/$_targetTrash', Colors.orange),
                  _InfoChip('النقاط', '$_score', Colors.blue),
                ],
              ),
            ),
          ),
          // Trash items
          ...(_trashItems.map((item) {
            final size = MediaQuery.of(context).size;
            return Positioned(
              left: item.x * size.width,
              top: item.y * size.height,
              child: GestureDetector(
                onTap: () => _collectTrash(item),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    item.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            );
          })),
          // Fish decorations
          Positioned(
            bottom: 100,
            left: 50,
            child: Text('🐠', style: TextStyle(fontSize: 40, color: Colors.white.withOpacity(0.5))),
          ),
          Positioned(
            bottom: 200,
            right: 80,
            child: Text('🐟', style: TextStyle(fontSize: 35, color: Colors.white.withOpacity(0.5))),
          ),
          Positioned(
            bottom: 150,
            right: 30,
            child: Text('🐢', style: TextStyle(fontSize: 45, color: Colors.white.withOpacity(0.5))),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelButton(int level, String difficulty, String description) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (level * 200)),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.3 * value),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _startLevel(level),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.cyan.shade300, Colors.blue.shade500],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$level',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المستوى $level - $difficulty',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            description,
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, size: 32, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class TrashItem {
  final int id;
  final String emoji;
  double x;
  double y;

  TrashItem({
    required this.id,
    required this.emoji,
    required this.x,
    required this.y,
  });
}

class WavePainter extends CustomPainter {
  final double animation;

  WavePainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.3);

    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.3 + 20 * sin((i / size.width * 4 * pi) + (animation * 2 * pi)),
      );
    }

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }
}