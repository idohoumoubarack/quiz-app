import 'package:flutter/material.dart';

enum Category {
  geographie,
  sciences,
  histoire,
  cinema,
  cultureGenerale,
  mathematiques;

  String get nom {
    switch (this) {
      case Category.geographie:
        return 'Géographie';
      case Category.sciences:
        return 'Sciences';
      case Category.histoire:
        return 'Histoire';
      case Category.cinema:
        return 'Cinéma';
      case Category.cultureGenerale:
        return 'Culture Générale';
      case Category.mathematiques:
        return 'Mathématiques';
    }
  }

  String get emoji {
    switch (this) {
      case Category.geographie:
        return '🌍';
      case Category.sciences:
        return '🔬';
      case Category.histoire:
        return '📜';
      case Category.cinema:
        return '🎬';
      case Category.cultureGenerale:
        return '📚';
      case Category.mathematiques:
        return '🧮';
    }
  }

  Color get couleur {
    switch (this) {
      case Category.geographie:
        return const Color(0xFF4CAF50); // Vert
      case Category.sciences:
        return const Color(0xFF2196F3); // Bleu
      case Category.histoire:
        return const Color(0xFF795548); // Marron
      case Category.cinema:
        return const Color(0xFFE91E63); // Rose
      case Category.cultureGenerale:
        return const Color(0xFF9C27B0); // Violet
      case Category.mathematiques:
        return const Color(0xFFFF9800); // Orange
    }
  }

  String get description {
    switch (this) {
      case Category.geographie:
        return 'Pays, capitales, drapeaux...';
      case Category.sciences:
        return 'Physique, chimie, biologie...';
      case Category.histoire:
        return 'Événements, dates, personnages...';
      case Category.cinema:
        return 'Films, acteurs, réalisateurs...';
      case Category.cultureGenerale:
        return 'Un peu de tout !';
      case Category.mathematiques:
        return 'Calculs, logique, géométrie...';
    }
  }
}