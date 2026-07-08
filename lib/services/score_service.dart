import 'package:shared_preferences/shared_preferences.dart';

class ScoreService {
  static const String _bestScoreKey = 'best_score';
  static const String _totalGamesKey = 'total_games';

  // Récupérer le meilleur score
  static Future<int> getBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestScoreKey) ?? 0;
  }

  // Sauvegarder un nouveau score (si c'est le meilleur)
  static Future<bool> saveScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = await getBestScore();
    
    if (score > currentBest) {
      await prefs.setInt(_bestScoreKey, score);
      return true; // Nouveau record !
    }
    return false; // Pas un nouveau record
  }

  // Incrémenter le nombre de parties jouées
  static Future<void> incrementGamesPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final currentGames = prefs.getInt(_totalGamesKey) ?? 0;
    await prefs.setInt(_totalGamesKey, currentGames + 1);
  }

  // Récupérer le nombre de parties jouées
  static Future<int> getTotalGames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalGamesKey) ?? 0;
  }

  // Réinitialiser tous les scores (optionnel)
  static Future<void> resetScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bestScoreKey);
    await prefs.remove(_totalGamesKey);
  }
}