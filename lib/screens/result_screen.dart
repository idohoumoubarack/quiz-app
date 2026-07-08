import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../services/score_service.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int total;
  final VoidCallback onRestart;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.onRestart,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int _bestScore = 0;
  bool _isNewRecord = false;
  int _totalGames = 0;
  
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _chargerScores();
    
    // Initialiser le contrôleur de confettis
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    
    // Lancer les confettis après un court délai
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_shouldShowConfetti()) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  bool _shouldShowConfetti() {
    final percentage = (widget.score / widget.total) * 100;
    return percentage >= 60; // Confettis si score >= 60%
  }

  Future<void> _chargerScores() async {
    final isNewRecord = await ScoreService.saveScore(widget.score);
    final bestScore = await ScoreService.getBestScore();
    final totalGames = await ScoreService.getTotalGames();
    
    await ScoreService.incrementGamesPlayed();
    final updatedTotalGames = await ScoreService.getTotalGames();

    setState(() {
      _isNewRecord = isNewRecord;
      _bestScore = bestScore;
      _totalGames = updatedTotalGames;
    });
  }

  String get _message {
    final percentage = (widget.score / widget.total) * 100;
    if (percentage == 100) return '🏆 PARFAIT ! Tu es un génie !';
    if (percentage >= 80) return '🌟 Excellent ! Bravo !';
    if (percentage >= 60) return '😊 Bien joué !';
    if (percentage >= 40) return '💪 Pas mal, continue !';
    return '📚 Tu peux mieux faire !';
  }

  Color get _color {
    final percentage = (widget.score / widget.total) * 100;
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.blue;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond avec gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [
                        _color.withOpacity(0.6),
                        _color.withOpacity(0.9),
                      ]
                    : [
                        _color.withOpacity(0.8),
                        _color,
                      ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animation du trophée
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1500),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: const Text(
                      '🏆',
                      style: TextStyle(fontSize: 100),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Message de nouveau record
                  if (_isNewRecord)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.yellow.withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.orange, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'NOUVEAU RECORD !',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.star, color: Colors.orange, size: 24),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Message
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Score dans un cercle
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: widget.score),
                          duration: const Duration(seconds: 2),
                          builder: (context, value, child) {
                            return Text(
                              '$value',
                              style: TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: _color,
                              ),
                            );
                          },
                        ),
                        Text(
                          'sur ${widget.total}',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Statistiques
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatCard(
                        '🏆 Meilleur',
                        '$_bestScore/${widget.total}',
                      ),
                      const SizedBox(width: 20),
                      _buildStatCard(
                        '🎮 Parties',
                        '$_totalGames',
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Bouton recommencer
                  ElevatedButton.icon(
                    onPressed: widget.onRestart,
                    icon: const Icon(Icons.refresh, size: 28),
                    label: const Text(
                      'Rejouer',
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _color,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confettis (au-dessus de tout)
          if (_shouldShowConfetti())
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.yellow,
                ],
                emissionFrequency: 0.1,
                numberOfParticles: 50,
                gravity: 0.2,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}