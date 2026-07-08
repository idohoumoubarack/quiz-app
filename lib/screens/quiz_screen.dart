import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question.dart';
import 'result_screen.dart';
import '../services/audio_service.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;

  const QuizScreen({super.key, required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  int questionIndex = 0;
  int score = 0;
  int? reponseSelectionnee;
  bool aRepondu = false;
  int tempsRestant = 15;
  Timer? _timer;
  bool _isMuted = false;

  // Animation pour la transition entre questions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Mélanger les questions aléatoirement
    widget.questions.shuffle();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
    _demarrerTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _demarrerTimer() {
    _timer?.cancel();
    tempsRestant = 15;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (tempsRestant > 0 && !aRepondu) {
        setState(() {
          tempsRestant--;
        });
      } else if (tempsRestant == 0 && !aRepondu) {
        _verifierReponse(-1); // Temps écoulé = mauvaise réponse
      }
    });
  }

  void _verifierReponse(int indexChoix) {
    if (aRepondu) return;

    _timer?.cancel();
    final bonneReponse = widget.questions[questionIndex].reponseCorrecte;

    if (indexChoix == bonneReponse) {
      score++;
      AudioService.playCorrect();
    } else {
      AudioService.playWrong();
    }

    setState(() {
      reponseSelectionnee = indexChoix;
      aRepondu = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (questionIndex < widget.questions.length - 1) {
        _passerQuestionSuivante();
      } else {
        _terminerQuiz();
      }
    });
  }

  void _passerQuestionSuivante() {
    _animationController.reverse().then((_) {
      setState(() {
        questionIndex++;
        reponseSelectionnee = null;
        aRepondu = false;
        
        // Mélanger les choix de la prochaine question
        _melangerChoix();
      });
      _animationController.forward();
      _demarrerTimer();
    });
  }

  void _melangerChoix() {
  final question = widget.questions[questionIndex];
  
  // Créer une liste des indices [0, 1, 2, 3]
  final indices = List<int>.generate(question.choix.length, (i) => i);
  
  // Mélanger les indices
  indices.shuffle();
  
  // Réorganiser les choix selon les indices mélangés
  final nouveauxChoix = indices.map((i) => question.choix[i]).toList();
  
  // Trouver le nouvel index de la bonne réponse
  final nouvelIndex = indices.indexOf(question.reponseCorrecte);
  
  // Mettre à jour la question avec les choix mélangés
  widget.questions[questionIndex] = Question(
    texte: question.texte,
    choix: nouveauxChoix,
    reponseCorrecte: nouvelIndex,
    emoji: question.emoji,
    categorie: question.categorie,
  );
}

  void _terminerQuiz() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          score: score,
          total: widget.questions.length,
          onRestart: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Color _obtenirCouleurBouton(int index) {
    if (!aRepondu) {
      return Colors.white;
    }

    final bonneReponse = widget.questions[questionIndex].reponseCorrecte;

    if (index == bonneReponse) {
      return Colors.green.shade400; // Bonne réponse en vert
    }
    if (index == reponseSelectionnee && index != bonneReponse) {
      return Colors.red.shade400; // Mauvaise réponse en rouge
    }
    return Colors.grey.shade300; // Autres en gris
  }

  IconData _obtenirIconeBouton(int index) {
    if (!aRepondu) return Icons.circle_outlined;

    final bonneReponse = widget.questions[questionIndex].reponseCorrecte;

    if (index == bonneReponse) return Icons.check_circle;
    if (index == reponseSelectionnee) return Icons.cancel;
    return Icons.circle_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final questionActuelle = widget.questions[questionIndex];
    final progression = (questionIndex + 1) / widget.questions.length;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    const Color(0xFF1a1a2e),
                    const Color(0xFF16213e),
                  ]
                : [
                    const Color(0xFF667eea),
                    const Color(0xFF764ba2),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // En-tête avec progression et timer
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // Bouton retour
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    // Progression
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${questionIndex + 1} / ${widget.questions.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progression,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Bouton mute/unmute
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isMuted = !_isMuted;
                          AudioService.isMuted = _isMuted;
                        });
                      },
                      icon: Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                        size: 24,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Timer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: tempsRestant <= 5
                            ? Colors.red.withOpacity(0.8)
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, color: Colors.white, size: 20),
                          const SizedBox(width: 5),
                          Text(
                            '$tempsRestant',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Contenu de la question avec animation
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Emoji de la question
                        Text(
                          questionActuelle.emoji,
                          style: const TextStyle(fontSize: 80),
                        ),
                        const SizedBox(height: 30),

                        // Texte de la question dans une card
                        Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Text(
                            questionActuelle.texte,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Choix de réponses
                        ...questionActuelle.choix.asMap().entries.map((entry) {
                          int index = entry.key;
                          String choix = entry.value;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: _obtenirCouleurBouton(index),
                              borderRadius: BorderRadius.circular(15),
                              child: InkWell(
                                onTap: aRepondu
                                    ? null
                                    : () => _verifierReponse(index),
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 20,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _obtenirIconeBouton(index),
                                        color: aRepondu
                                            ? Colors.white
                                            : const Color(0xFF667eea),
                                        size: 28,
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Text(
                                          choix,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: aRepondu
                                                ? Colors.white
                                                : const Color(0xFF333333),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension pour .asMap()
extension ListExtension<T> on List<T> {
  Iterable<MapEntry<int, T>> asMap() sync* {
    for (var i = 0; i < length; i++) {
      yield MapEntry(i, this[i]);
    }
  }
}