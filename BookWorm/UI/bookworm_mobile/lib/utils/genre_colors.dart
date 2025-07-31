import 'package:flutter/material.dart';

class GenreColors {
  static Color getGenreColor(String genreName) {
    switch (genreName.toLowerCase()) {
      case 'fantasy':
        return const Color(0xFF9C27B0); 
      case 'science fiction':
        return const Color(0xFF2196F3); 
      case 'romance':
        return const Color(0xFFE91E63); 
      case 'mystery':
        return const Color(0xFF795548); 
      case 'historical':
        return const Color(0xFF4CAF50); 
      case 'horror':
        return const Color(0xFF607D8B); 
      case 'biography':
        return const Color(0xFFFF9800); 
      case 'adventure':
        return const Color(0xFF8BC34A); 
      case 'classics':
        return const Color(0xFF8D6E63); 
      case 'drama':
        return const Color(0xFF673AB7); 
      case 'fiction':
        return const Color(0xFF00BCD4); 
      case 'non-fiction':
        return const Color(0xFFA1887F); 
      case 'thriller':
        return const Color(0xFFF44336); 
      case 'comedy':
        return const Color(0xFFFFEB3B); 
      case 'action':
        return const Color(0xFFFF5722); 
      case 'poetry':
        return const Color(0xFFBA68C8); 
      case 'self-help':
        return const Color(0xFF66BB6A); 
      case 'travel':
        return const Color(0xFF26C6DA); 
      case 'humor':
        return const Color(0xFFFFB74D); 
      default:
        return const Color(0xFF8D6E63); 
    }
  }
} 