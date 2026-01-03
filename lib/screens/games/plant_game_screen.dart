import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class PlantGameScreen extends StatefulWidget {
  const PlantGameScreen({super.key});

  @override
  State<PlantGameScreen> createState() => _PlantGameScreenState();
}

class _PlantGameScreenState extends State<PlantGameScreen> {
  int _currentLevel = 1;
  int _score = 0;
  int _treesPlanted = 0;
  int _targetTrees = 0;
  int _timeLeft = 0;
  Timer? _timer;
  bool _gameStarted = false;

  final List<bool> _plantedSpots = List.generate(25, (_) => false);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startLevel(int level) {
    setState(() {
      _currentLevel = level;
      _score = 0;
      _treesPlanted = 0;
      _gameStarted = true;
      _plantedSpots.fillRange(0, _plantedSpots.length, false);

      switch (level) {
        case 1:
          _timeLeft = 45;
          _targetTrees = 10;
          break;
        case 2:
          _timeLeft = 35;
          _targetTrees = 15;
          break;
        case 3:
          _timeLeft = 25;
          _targetTrees = 20;
          break;
      }
    });
    _startTimer();
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

  void _plantTree(int index) {
    if (_plantedSpots[index] || _treesPlanted >= _targetTrees) return;

    setState(() {
      _plantedSpots[index] = true;
      _treesPlanted++;
      _score += 10;
    });

    if (_treesPlanted >= _targetTrees) {
      Future.delayed(const Duration(milliseconds: 500), _endGame);
    }
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _gameStarted = false);

    // Bonus for time left
    final timeBonus = _timeLeft * 2;
    final finalScore = _score + timeBonus;

    AuthService().updateScore('plant', _currentLevel, finalScore);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text('🌳 رائع!', textAlign: TextAlign.center),
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
              'زرعت $_treesPlanted شجرة 🌱',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'النقاط: $_score',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            if (timeBonus > 0)
              Text(
                'مكافأة الوقت: +$timeBonus',
                style: const TextStyle(fontSize: 18, color: Colors.orange),
              ),
            Text(
              'المجموع: $finalScore نقطة',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                '🌍 كل شجرة تنقذ الكوكب!\nالأشجار تنتج الأكسجين وتنظف الهواء',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.green, height: 1.5),
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
          title: const Text('لعبة زراعة الأشجار', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green.shade600,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade300, Colors.lightGreen.shade200],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.park, size: 120, color: Colors.white),
                    const SizedBox(height: 30),
                    const Text(
                      '🌱 لعبة زراعة الأشجار',
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
                        'ازرع أكبر عدد من الأشجار!\nساعد في تنظيف الهواء وحماية الكوكب 🌍',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            '🎯 الهدف 13 و 15 من أهداف التنمية المستدامة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'العمل المناخي والحياة في البر',
                            style: TextStyle(fontSize: 14, color: Colors.green),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildLevelButton(1, 'سهل', '10 أشجار - 45 ثانية'),
                    const SizedBox(height: 15),
                    _buildLevelButton(2, 'متوسط', '15 شجرة - 35 ثانية'),
                    const SizedBox(height: 15),
                    _buildLevelButton(3, 'صعب', '20 شجرة - 25 ثانية'),
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
        backgroundColor: Colors.green.shade600,
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
                  const Icon(Icons.timer, color: Colors.green),
                  const SizedBox(width: 5),
                  Text(
                    '$_timeLeft',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _timeLeft <= 10 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlue.shade100, Colors.green.shade100],
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoChip('الأشجار', '$_treesPlanted/$_targetTrees', Colors.green),
                  _InfoChip('النقاط', '$_score', Colors.orange),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app, color: Colors.orange, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'اضغط على المربعات لزراعة الأشجار',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 25,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _plantTree(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _plantedSpots[index]
                                ? [Colors.green.shade400, Colors.green.shade600]
                                : [Colors.brown.shade200, Colors.brown.shade300],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: _plantedSpots[index]
                                  ? Colors.green.withOpacity(0.4)
                                  : Colors.brown.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _plantedSpots[index] ? '🌳' : '⛰️',
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
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
                  color: Colors.green.withOpacity(0.3 * value),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _startLevel(level),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green.shade700,
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
                            colors: [Colors.green.shade300, Colors.green.shade500],
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
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, size: 32, color: Colors.green),
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