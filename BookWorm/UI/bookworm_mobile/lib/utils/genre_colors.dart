import 'package:flutter/material.dart';

class GenreColors {
  static Color getGenreColor(String genreName) {
    switch (genreName.toLowerCase()) {
      case 'fantasy':
        return const Color(0xFFE91E63); // Pink
      case 'science fiction':
        return const Color(0xFF2196F3); // Blue
      case 'romance':
        return const Color(0xFFFF5722); // Deep Orange
      case 'mystery':
        return const Color(0xFF9C27B0); // Purple
      case 'historical':
        return const Color(0xFF4CAF50); // Green
      case 'horror':
        return const Color(0xFFF44336); // Red
      case 'biography':
        return const Color(0xFFFF9800); // Orange
      case 'adventure':
        return const Color(0xFF8BC34A); // Light Green
      case 'classics':
        return const Color(0xFF795548); // Brown
      case 'drama':
        return const Color(0xFF673AB7); // Deep Purple
      case 'fiction':
        return const Color(0xFF00BCD4); // Cyan
      case 'non-fiction':
        return const Color(0xFF607D8B); // Blue Grey
      case 'thriller':
        return const Color(0xFFD32F2F); // Dark Red
      case 'comedy':
        return const Color(0xFFFFEB3B); // Yellow
      case 'action':
        return const Color(0xFFFF5722); // Deep Orange
      case 'poetry':
        return const Color(0xFFBA68C8); // Light Purple
      case 'self-help':
        return const Color(0xFF66BB6A); // Medium Green
      case 'travel':
        return const Color(0xFF26C6DA); // Bright Cyan
      case 'humor':
        return const Color(0xFFFFB74D); // Light Orange
      case 'young adult':
        return const Color(0xFF42A5F5); // Light Blue
      case 'children':
        return const Color(0xFF81C784); // Light Green
      case 'cookbook':
        return const Color(0xFFFF8A65); // Deep Orange
      case 'philosophy':
        return const Color(0xFF9575CD); // Deep Purple
      case 'religion':
        return const Color(0xFF4DB6AC); // Teal
      case 'education':
        return const Color(0xFF64B5F6); // Light Blue
      case 'business':
        return const Color(0xFF7986CB); // Indigo
      case 'technology':
        return const Color(0xFF4FC3F7); // Light Blue
      case 'health':
        return const Color(0xFF81C784); // Light Green
      case 'sports':
        return const Color(0xFFFF7043); // Deep Orange
      default:
        return const Color(0xFF8D6E63); // Default Brown
    }
  }
} 