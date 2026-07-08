import 'category.dart';

class Question {
  final String texte;
  final List<String> choix;
  final int reponseCorrecte;
  final String emoji;
  final Category categorie;

  Question({
    required this.texte,
    required this.choix,
    required this.reponseCorrecte,
    this.emoji = '❓',
    required this.categorie,
  });
}