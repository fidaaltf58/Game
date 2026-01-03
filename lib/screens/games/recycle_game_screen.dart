import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RecycleGameScreen extends StatefulWidget {
  const RecycleGameScreen({super.key});

  @override
  State<RecycleGameScreen> createState() => _RecycleGameScreenState();
}

class _RecycleGameScreenState extends State<RecycleGameScreen> {
  int _currentLevel = 1;
  int _score = 0;
  int _timeLeft = 0;
  Timer? _timer;
  bool _gameStarted = false;

  late List<Map<String, dynamic>> _items;
  int _currentItemIndex = 0;

  final Map<String, Color> _binColors = {
    'بلاستيك': Colors.yellow.shade700,
    'ورق': Colors.blue.shade700,
    'عضوي': Colors.green.shade700,
    'زجاج': Colors.brown.shade700,
  };

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startLevel(int level) {
    setState(() {
      _currentLevel = level;
      _score = 0;
      _currentItemIndex = 0;
      _gameStarted = true;

      // Set time and items based on level
      switch (level) {
        case 1:
          _timeLeft = 60;
          _items = _getLevel1Items();
          break;
        case 2:
          _timeLeft = 45;
          _items = _getLevel2Items();
          break;
        case 3:
          _timeLeft = 30;
          _items = _getLevel3Items();
          break;
        default:
          _timeLeft = 60;
          _items = _getLevel1Items();
      }
      _items.shuffle();
    });
    _startTimer();
  }

  List<Map<String, dynamic>> _getLevel1Items() {
    return [
      {'name': 'زجاجة بلاستيك 🍾', 'bin': 'بلاستيك'},
      {'name': 'ورقة 📄', 'bin': 'ورق'},
      {'name': 'تفاحة 🍎', 'bin': 'عضوي'},
      {'name': 'كرتونة 📦', 'bin': 'ورق'},
      {'name': 'كيس بلاستيك 🛍️', 'bin': 'بلاستيك'},
      {'name': 'موز 🍌', 'bin': 'عضوي'},
      {'name': 'جريدة 📰', 'bin': 'ورق'},
      {'name': 'كوب بلاستيك 🥤', 'bin': 'بلاستيك'},
    ];
  }

  List<Map<String, dynamic>> _getLevel2Items() {
    return [
      {'name': 'زجاجة بلاستيك 🍾', 'bin': 'بلاستيك'},
      {'name': 'ورقة 📄', 'bin': 'ورق'},
      {'name': 'تفاحة 🍎', 'bin': 'عضوي'},
      {'name': 'زجاجة ماء 🍶', 'bin': 'زجاج'},
      {'name': 'كرتونة 📦', 'bin': 'ورق'},
      {'name': 'كيس بلاستيك 🛍️', 'bin': 'بلاستيك'},
      {'name': 'مرطبان زجاج 🫙', 'bin': 'زجاج'},
      {'name': 'موز 🍌', 'bin': 'عضوي'},
      {'name': 'جريدة 📰', 'bin': 'ورق'},
      {'name': 'كوب بلاستيك 🥤', 'bin': 'بلاستيك'},
      {'name': 'طبق زجاج', 'bin': 'زجاج'},
      {'name': 'قشر برتقال 🍊', 'bin': 'عضوي'},
    ];
  }

  List<Map<String, dynamic>> _getLevel3Items() {
    return [
      {'name': 'زجاجة بلاستيك 🍾', 'bin': 'بلاستيك'},
      {'name': 'ورقة 📄', 'bin': 'ورق'},
      {'name': 'تفاحة 🍎', 'bin': 'عضوي'},
      {'name': 'زجاجة ماء 🍶', 'bin': 'زجاج'},
      {'name': 'كرتونة 📦', 'bin': 'ورق'},
      {'name': 'كيس بلاستيك 🛍️', 'bin': 'بلاستيك'},
      {'name': 'مرطبان زجاج 🫙', 'bin': 'زجاج'},
      {'name': 'موز 🍌', 'bin': 'عضوي'},
      {'name': 'جريدة 📰', 'bin': 'ورق'},
      {'name': 'كوب بلاستيك 🥤', 'bin': 'بلاستيك'},
      {'name': 'طبق زجاج', 'bin': 'زجاج'},
      {'name': 'قشر برتقال 🍊', 'bin': 'عضوي'},
      {'name': 'مجلة 📕', 'bin': 'ورق'},
      {'name': 'علبة عصير 🧃', 'bin': 'بلاستيك'},
      {'name': 'كوب زجاج ☕', 'bin': 'زجاج'},
    ];
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

  void _checkAnswer(String selectedBin) {
    if (_currentItemIndex >= _items.length) return;

    final correctBin = _items[_currentItemIndex]['bin'];
    final isCorrect = selectedBin == correctBin;

    setState(() {
      if (isCorrect) {
        _score += 10;
      } else {
        _score = max(0, _score - 5);
      }
    });

    _showFeedback(isCorrect, correctBin);

    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _currentItemIndex++;
        if (_currentItemIndex >= _items.length) {
          _endGame();
        }
      });
    });
  }

  void _showFeedback(bool isCorrect, String correctBin) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect ? '✓ ممتاز! إجابة صحيحة!' : '✗ خطأ! الإجابة الصحيحة: $correctBin',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _gameStarted = false);

    AuthService().updateScore('recycle', _currentLevel, _score);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text('🎉 أحسنت!', textAlign: TextAlign.center),
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
              'النتيجة: $_score نقطة',
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
                '💚 إعادة التدوير تحمي كوكبنا!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.green),
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
          title: const Text('لعبة إعادة التدوير', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue.shade600,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.green.shade300],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.recycling, size: 120, color: Colors.white),
                    const SizedBox(height: 30),
                    const Text(
                      '♻️ لعبة إعادة التدوير',
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
                        'ضع كل غرض في الصندوق المناسب!\nساعد في حماية البيئة 🌍',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            '🎯 الهدف 12 من أهداف التنمية المستدامة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'الاستهلاك والإنتاج المسؤولان',
                            style: TextStyle(fontSize: 14, color: Colors.blue),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildLevelButton(1, 'سهل', '60 ثانية - 3 أنواع'),
                    const SizedBox(height: 15),
                    _buildLevelButton(2, 'متوسط', '45 ثانية - 4 أنواع'),
                    const SizedBox(height: 15),
                    _buildLevelButton(3, 'صعب', '30 ثانية - 4 أنواع'),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final currentItem = _currentItemIndex < _items.length ? _items[_currentItemIndex] : null;
    final bins = _currentLevel == 1
        ? ['بلاستيك', 'ورق', 'عضوي']
        : ['بلاستيك', 'ورق', 'عضوي', 'زجاج'];

    return Scaffold(
      appBar: AppBar(
        title: Text('المستوى $_currentLevel', style: const TextStyle(color: Colors.white, fontSize: 24)),
        backgroundColor: Colors.blue.shade600,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.green.shade100],
          ),
        ),
        child: currentItem == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
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
                  _InfoChip('النقاط', '$_score', Colors.green),
                  _InfoChip('العنصر', '${_currentItemIndex + 1}/${_items.length}', Colors.blue),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(30),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'أين تضع هذا؟',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    currentItem['name'],
                    style: const TextStyle(fontSize: 48),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Fixed scrollable area for bins
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: bins.length,
                    itemBuilder: (context, index) {
                      final bin = bins[index];
                      return GestureDetector(
                        onTap: () => _checkAnswer(bin),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _binColors[bin] ?? Colors.grey,
                                (_binColors[bin] ?? Colors.grey).withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: (_binColors[bin] ?? Colors.grey).withOpacity(0.4),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.delete, size: 50, color: Colors.white),
                              const SizedBox(height: 10),
                              Text(
                                bin,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
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
                  color: Colors.blue.withOpacity(0.3 * value),
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
                            colors: [Colors.blue.shade300, Colors.blue.shade500],
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
