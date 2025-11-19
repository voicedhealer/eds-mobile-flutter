import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class EnvieSearchBar extends StatefulWidget {
  final bool isInteractive;
  
  const EnvieSearchBar({
    super.key,
    this.isInteractive = false,
  });

  @override
  State<EnvieSearchBar> createState() => _EnvieSearchBarState();
}

class _EnvieSearchBarState extends State<EnvieSearchBar>
    with SingleTickerProviderStateMixin {
  final _phrases = [
    'goûter un plat indien',
    'boire une bière artisanale',
    'faire un laser game',
    'jouer au bowling',
    'tester la réalité virtuelle',
    'faire un escape game',
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

  void _handleTap(BuildContext context) {
    if (widget.isInteractive) {
      // Ouvrir un dialogue de recherche ou naviguer vers la recherche
      showDialog(
        context: context,
        builder: (context) => _SearchDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isInteractive ? () => _handleTap(context) : null,
      child: Container(
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
            if (widget.isInteractive) ...[
              const SizedBox(width: 8),
              const Icon(Icons.search, color: Color(0xFFFF751F)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SearchDialog extends StatefulWidget {
  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final _searchController = TextEditingController();
  String? _selectedCity;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(BuildContext context) {
    final envie = _searchController.text.trim();
    if (envie.isEmpty) return;
    
    context.pop();
    context.push('/search?envie=${Uri.encodeComponent(envie)}${_selectedCity != null ? '&ville=${Uri.encodeComponent(_selectedCity!)}' : ''}');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Que recherchez-vous ?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Envie de...',
              hintText: 'manger une pizza, boire un cocktail...',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (_) => _performSearch(context),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Ville (optionnel)',
              hintText: 'Paris, Lyon...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _selectedCity = value.isEmpty ? null : value,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => _performSearch(context),
          child: const Text('Rechercher'),
        ),
      ],
    );
  }
}

