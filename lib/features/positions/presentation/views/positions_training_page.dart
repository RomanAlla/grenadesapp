import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grenadesapp/core/constants/app_contants.dart';
import 'package:grenadesapp/features/positions/data/models/position_model.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';

class PositionsTrainingPage extends StatefulWidget {
  final String mapName;

  const PositionsTrainingPage({
    super.key,
    required this.mapName,
  });

  @override
  State<PositionsTrainingPage> createState() => _PositionsTrainingPageState();
}

class _PositionsTrainingPageState extends State<PositionsTrainingPage> {
  List<PositionModel> _positions = [];
  int _currentIndex = 0;
  int _correctAnswers = 0;
  bool _hasAnswered = false;
  String? _selectedAnswer;
  bool _isLoading = true;

  Timer? _timer;
  int _remainingTime = 10;

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingTime = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime < 1) {
        timer.cancel();
        _handleTimeout();
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  void _handleTimeout() {
    if (!_hasAnswered) {
      setState(() {
        _hasAnswered = true;
        _selectedAnswer = null;
      });
    }
  }

  Future<void> _loadPositions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('maps')
          .doc(widget.mapName.toLowerCase())
          .collection('positions')
          .get();

      final positions = snapshot.docs.map((doc) {
        final data = doc.data();
        return PositionModel(
          id: doc.id,
          mapName: data['mapName'] ?? '',
          correctName: data['correctName'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          options: List<String>.from(data['options'] ?? []),
        );
      }).toList();

      positions.shuffle();
      final selectedPositions =
          positions.length > 5 ? positions.sublist(0, 5) : positions;

      setState(() {
        _positions = selectedPositions;
        _isLoading = false;
      });

      if (_positions.isNotEmpty) {
        for (final position in _positions) {
          if (position.imageUrl.isNotEmpty) {
            precacheImage(
              CachedNetworkImageProvider(position.imageUrl),
              context,
            );
          }
        }
        _startTimer();
      }
    } catch (e) {
      print('Ошибка при загрузке позиций: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkAnswer(String answer) {
    if (_hasAnswered) return;

    _timer?.cancel();

    setState(() {
      _selectedAnswer = answer;
      _hasAnswered = true;
      if (answer == _positions[_currentIndex].correctName) {
        _correctAnswers++;
      }
    });
  }

  void _nextPosition() {
    if (_currentIndex < _positions.length - 1) {
      setState(() {
        _currentIndex++;
        _hasAnswered = false;
        _selectedAnswer = null;
        _startTimer();
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: const Text(
          'Результаты',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Правильных ответов: $_correctAnswers из ${_positions.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Завершить',
              style: TextStyle(color: Colors.orange),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentIndex = 0;
                _correctAnswers = 0;
                _hasAnswered = false;
                _selectedAnswer = null;
                _positions.shuffle();
              });
            },
            child: const Text(
              'Начать заново',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }

    if (_positions.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          title: Text(
            'Позиции - ${widget.mapName}',
            style: const TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.orange),
        ),
        body: const Center(
          child: Text(
            'Позиции для этой карты пока не добавлены',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final currentPosition = _positions[_currentIndex];
    final isAnsweredIncorrectly =
        _hasAnswered && _selectedAnswer != currentPosition.correctName;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3), // Subtle shadow
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.orange, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),

                    Expanded(
                      child: Text(
                        widget.mapName.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Timer
                    Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.orange, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '$_remainingTime',
                          style: TextStyle(
                            color: _remainingTime <= 5
                                ? Colors.redAccent
                                : Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Позиция ${_currentIndex + 1} из ${_positions.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5), // Darker shadow
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: currentPosition.imageUrl,
                    fit: BoxFit.cover,
                    height: 200,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.black12,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.black26,
                      child: const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ...currentPosition.options.map((option) {
                final isCorrect = option == currentPosition.correctName;
                final isSelected = option == _selectedAnswer;
                Color backgroundColor = Colors.white.withOpacity(0.05);
                Color borderColor =
                    Colors.white.withOpacity(0.1); // Subtle border initially
                Color textColor = Colors.white;

                if (_hasAnswered) {
                  if (isCorrect) {
                    backgroundColor = Colors.green.withOpacity(0.2);
                    borderColor = Colors.green;
                    textColor = Colors.white;
                  } else if (isSelected) {
                    backgroundColor = Colors.red.withOpacity(0.2);
                    borderColor = Colors.red;
                    textColor = Colors.white;
                  } else {
                    backgroundColor = Colors.white.withOpacity(0.03);
                    borderColor = Colors.white.withOpacity(0.05);
                    textColor = Colors.white54;
                  }
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _hasAnswered ? null : () => _checkAnswer(option),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: borderColor,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: borderColor.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight:
                                      isSelected || (_hasAnswered && isCorrect)
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (_hasAnswered && (isCorrect || isSelected))
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                color: isCorrect ? Colors.green : Colors.red,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              if (_hasAnswered) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Правильный ответ: ${currentPosition.correctName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPosition,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentIndex < _positions.length - 1
                            ? 'Следующая позиция'
                            : 'Завершить',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
