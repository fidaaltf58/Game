import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class EnergyGameScreen extends StatefulWidget {
  const EnergyGameScreen({super.key});

  @override
  State<EnergyGameScreen> createState() => _EnergyGameScreenState();
}

class _EnergyGameScreenState extends State<EnergyGameScreen> {
  int _currentLevel = 1;
  int _score = 0;
  int _correctChoices = 0;
  int _targetChoices = 0;
  int _timeLeft = 0;
  Timer? _timer;
  bool _gameStarted = false;

  int _currentQuestionIndex = 0;
  late List<Map<String, dynamic>> _questions;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startLevel(int level) {
    setState(() {
      _currentLevel = level;
      _score = 0;
      _correctChoices = 0;
      _currentQuestionIndex = 0;
      _gameStarted = true;

      switch (level) {
        case 1:
          _timeLeft = 60;
          _targetChoices = 5;
          _questions = _getLevel1Questions();
          break;
        case 2:
          _timeLeft = 50;
          _targetChoices = 7;
          _questions = _getLevel2Questions();
          break;
        case 3:
          _timeLeft = 40;
          _targetChoices = 10;
          _questions = _getLevel3Questions();
          break;
      }
      _questions.shuffle();
    });
    _startTimer();
  }

  List<Map<String, dynamic>> _getLevel1Questions() {
    return [
      {
        'question': 'ما هو مصدر الطاقة النظيفة؟',
        'options': ['الطاقة الشمسية ☀️', 'الفحم 🏭', 'البترول ⛽', 'الغاز 💨'],
        'correct': 0,
        'explanation': 'الطاقة الشمسية نظيفة ومتجددة!'
      },
      {
        'question': 'أي من هذه يوفر الطاقة؟',
        'options': ['إطفاء الأنوار 💡', 'ترك التلفاز مفتوح 📺', 'فتح الثلاجة طويلاً ❄️', 'تشغيل كل الأجهزة ⚡'],
        'correct': 0,
        'explanation': 'إطفاء الأنوار يوفر الكهرباء!'
      },
      {
        'question': 'ما هو أفضل وسيلة نقل للبيئة؟',
        'options': ['الدراجة الهوائية 🚴', 'السيارة 🚗', 'الطائرة ✈️', 'الشاحنة 🚚'],
        'correct': 0,
        'explanation': 'الدراجة لا تلوث الهواء!'
      },
      {
        'question': 'طاقة الرياح هي:',
        'options': ['طاقة متجددة 🌬️', 'طاقة ملوثة 🏭', 'طاقة نادرة ⚠️', 'طاقة خطيرة ⛔'],
        'correct': 0,
        'explanation': 'طاقة الرياح نظيفة ومتجددة!'
      },
      {
        'question': 'لتوفير الماء الساخن:',
        'options': ['استخدم سخان شمسي ☀️', 'اترك السخان مفتوح 🔥', 'استخدم ماء ساخن جداً 🌡️', 'لا تطفئ السخان ⚡'],
        'correct': 0,
        'explanation': 'السخان الشمسي يستخدم طاقة الشمس!'
      },
      {
        'question': 'الهدف 7 من أهداف التنمية المستدامة:',
        'options': ['طاقة نظيفة بأسعار معقولة ⚡', 'القضاء على الفقر 💰', 'التعليم الجيد 📚', 'المياه النظيفة 💧'],
        'correct': 0,
        'explanation': 'SDG 7: طاقة نظيفة وبأسعار معقولة'
      },
    ];
  }

  List<Map<String, dynamic>> _getLevel2Questions() {
    return [
      ..._getLevel1Questions(),
      {
        'question': 'الألواح الشمسية تحول:',
        'options': ['ضوء الشمس إلى كهرباء ☀️⚡', 'الماء إلى كهرباء 💧', 'الرياح إلى كهرباء 🌬️', 'الفحم إلى كهرباء 🏭'],
        'correct': 0,
        'explanation': 'الألواح الشمسية تحول الضوء لطاقة!'
      },
      {
        'question': 'لتقليل استهلاك الكهرباء:',
        'options': ['استخدم لمبات LED 💡', 'اترك الأجهزة متصلة 🔌', 'افتح النوافذ بدل المكيف ❌', 'استخدم لمبات قديمة 💡'],
        'correct': 0,
        'explanation': 'LED توفر 80% من الطاقة!'
      },
      {
        'question': 'الطاقة الكهرومائية تأتي من:',
        'options': ['حركة الماء 💧', 'الشمس ☀️', 'الرياح 🌬️', 'الفحم 🏭'],
        'correct': 0,
        'explanation': 'الماء المتحرك ينتج طاقة نظيفة!'
      },
    ];
  }

  List<Map<String, dynamic>> _getLevel3Questions() {
    return [
      ..._getLevel2Questions(),
      {
        'question': 'الطاقة الحرارية الأرضية:',
        'options': ['طاقة من حرارة الأرض 🌋', 'طاقة من الشمس ☀️', 'طاقة من الرياح 🌬️', 'طاقة من البترول ⛽'],
        'correct': 0,
        'explanation': 'نستخدم حرارة باطن الأرض!'
      },
      {
        'question': 'استهلاك الطاقة في المنازل:',
        'options': ['التدفئة والتبريد أكثر 🌡️', 'الإضاءة فقط 💡', 'الطبخ فقط 🍳', 'الشحن فقط 🔋'],
        'correct': 0,
        'explanation': '40% من الطاقة للتدفئة/التبريد!'
      },
      {
        'question': 'السيارات الكهربائية:',
        'options': ['لا تلوث الهواء 🚗⚡', 'أسوأ للبيئة 💨', 'نفس التلوث 🏭', 'تلوث أكثر ⛽'],
        'correct': 0,
        'explanation': 'السيارات الكهربائية صفر انبعاثات!'
      },
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

  void _checkAnswer(int selectedIndex) {
    if (_currentQuestionIndex >= _questions.length) return;

    final question = _questions[_currentQuestionIndex];
    final isCorrect = selectedIndex == question['correct'];

    setState(() {
      if (isCorrect) {
        _score += 15;
        _correctChoices++;
      }
    });

    _showFeedback(isCorrect, question['explanation']);

    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _currentQuestionIndex++;
        if (_currentQuestionIndex >= _questions.length || _correctChoices >= _targetChoices) {
          _endGame();
        }
      });
    });
  }

  void _showFeedback(bool isCorrect, String explanation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isCorrect
                  ? [Colors.green.shade300, Colors.green.shade100]
                  : [Colors.orange.shade300, Colors.orange.shade100],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.info,
                size: 80,
                color: isCorrect ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 20),
              Text(
                isCorrect ? 'ممتاز! ✓' : 'معلومة مهمة! 💡',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green.shade800 : Colors.orange.shade800,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                explanation,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, height: 1.5),
              ),
              const SizedBox(height: 20),
              Text(
                isCorrect ? '+15 نقطة' : 'حاول مرة أخرى!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _gameStarted = false);

    final timeBonus = _timeLeft * 1;
    final finalScore = _score + timeBonus;

    AuthService().updateScore('energy', _currentLevel, finalScore);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text('⚡ رائع!', textAlign: TextAlign.center),
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
              'إجابات صحيحة: $_correctChoices',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'النقاط: $_score',
              style: const TextStyle(fontSize: 18, color: Colors.amber),
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
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                '⚡ SDG 7: طاقة نظيفة وبأسعار معقولة\n🌍 الطاقة المتجددة تحمي كوكبنا!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.orange, height: 1.5),
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
          title: const Text('لعبة الطاقة النظيفة', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.amber.shade700,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade300, Colors.orange.shade200],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.bolt, size: 120, color: Colors.white),
                    const SizedBox(height: 30),
                    const Text(
                      '⚡ لعبة الطاقة النظيفة',
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
                        'تعلم عن الطاقة المتجددة!\nساعد في حماية البيئة من التلوث ⚡🌍',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.orange, width: 2),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            '🎯 الهدف 7 من أهداف التنمية المستدامة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'طاقة نظيفة وبأسعار معقولة',
                            style: TextStyle(fontSize: 14, color: Colors.orange),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildLevelButton(1, 'سهل', '5 أسئلة - 60 ثانية'),
                    _buildLevelButton(2, 'متوسط', '7 أسئلة - 50 ثانية'),
                    _buildLevelButton(3, 'صعب', '10 أسئلة - 40 ثانية'),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final currentQuestion = _currentQuestionIndex < _questions.length
        ? _questions[_currentQuestionIndex]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('المستوى $_currentLevel', style: const TextStyle(color: Colors.white, fontSize: 24)),
        backgroundColor: Colors.amber.shade700,
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
                  const Icon(Icons.timer, color: Colors.orange),
                  const SizedBox(width: 5),
                  Text(
                    '$_timeLeft',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _timeLeft <= 10 ? Colors.red : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: currentQuestion == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade100, Colors.orange.shade50],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
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
                      _InfoChip('السؤال', '${_currentQuestionIndex + 1}/${_questions.length}', Colors.blue),
                      _InfoChip('الصحيحة', '$_correctChoices/$_targetChoices', Colors.green),
                      _InfoChip('النقاط', '$_score', Colors.orange),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade300, Colors.orange.shade300],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.help_outline, size: 40, color: Colors.white),
                      const SizedBox(height: 15),
                      Text(
                        currentQuestion['question'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: currentQuestion['options'].length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: ElevatedButton(
                          onPressed: () => _checkAnswer(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.orange.shade800,
                            padding: const EdgeInsets.all(20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                          ),
                          child: Text(
                            currentQuestion['options'][index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
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
                  color: Colors.orange.withOpacity(0.3 * value),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _startLevel(level),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange.shade700,
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
                            colors: [Colors.amber.shade300, Colors.orange.shade500],
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
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, size: 32, color: Colors.orange),
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
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }
}