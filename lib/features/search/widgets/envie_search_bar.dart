import 'package:flutter/material.dart';
import 'dart:async';

class EnvieSearchBar extends StatefulWidget {
  const EnvieSearchBar({super.key});

  @override
  State<EnvieSearchBar> createState() => _EnvieSearchBarState();
}

class _EnvieSearchBarState extends State<EnvieSearchBar>
    with SingleTickerProviderStateMixin {
  final _phrases = [
    'manger une crêpe au nutella',
    'boire une bière artisanale',
    'faire un laser game',
    'jouer au bowling',
    'tester la réalité virtuelle',
    'résoudre un escape game',
    'danser toute la nuit',
    'manger un burger',
    'boire un cocktail',
    'voir un concert',
    'faire du karaoké',
    'jouer au billard',
  ];

  late AnimationController _cursorController;
  String _currentPhrase = '';
  int _phraseIndex = 0;
  Timer? _typewriterTimer;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _startTypewriter();
  }

  void _startTypewriter() async {
    while (mounted) {
      await _typePhrase(_phrases[_phraseIndex]);
      await Future.delayed(const Duration(seconds: 2));
      await _erasePhrase();
      _phraseIndex = (_phraseIndex + 1) % _phrases.length;
    }
  }

  Future<void> _typePhrase(String phrase) async {
    for (int i = 0; i <= phrase.length; i++) {
      if (!mounted) break;
      setState(() {
        _currentPhrase = phrase.substring(0, i);
      });
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> _erasePhrase() async {
    for (int i = _currentPhrase.length; i >= 0; i--) {
      if (!mounted) break;
      setState(() {
        _currentPhrase = _currentPhrase.substring(0, i);
      });
      await Future.delayed(const Duration(milliseconds: 30));
    }
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Envie de',
            style: TextStyle(
              color: const Color(0xFFFF751F),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _currentPhrase,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          AnimatedBuilder(
            animation: _cursorController,
            builder: (context, child) {
              return Opacity(
                opacity: _cursorController.value,
                child: Container(
                  width: 2,
                  height: 20,
                  color: const Color(0xFFFF751F),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

