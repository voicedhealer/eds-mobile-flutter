import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'radius_selector.dart';
import '../../../config/constants.dart';

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
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      _currentPhrase,
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
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
                          margin: const EdgeInsets.only(left: 2),
                          color: const Color(0xFFFF751F),
                        ),
                      );
                    },
                  ),
                ],
              ),
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
  final _cityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _selectedRadius = 10; // Valeur par défaut, sera adaptée selon la ville

  @override
  void dispose() {
    _searchController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _performSearch(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    
    final envie = _searchController.text.trim();
    final ville = _cityController.text.trim();
    
    if (envie.isEmpty || ville.isEmpty) return;
    
    context.pop();
    context.push('/search?envie=${Uri.encodeComponent(envie)}&ville=${Uri.encodeComponent(ville)}&radius=${_selectedRadius}');
  }

  void _updateRadius(int radius) {
    setState(() {
      _selectedRadius = radius;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Déterminer le rayon par défaut selon la ville
    final city = _cityController.text.trim();
    final defaultRadius = RadiusSelector.largeCities.any((largeCity) =>
            city.toLowerCase().contains(largeCity.toLowerCase()) ||
            largeCity.toLowerCase().contains(city.toLowerCase()))
        ? 1
        : 10;
    
    if (_selectedRadius == 10 && defaultRadius == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedRadius = 1;
        });
      });
    }

    return AlertDialog(
      title: const Text('Que recherchez-vous ?'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Envie de...',
                  hintText: 'manger une pizza, boire un cocktail...',
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.brandOrange, width: 2),
                  ),
                ),
                autofocus: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir votre envie';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _performSearch(context),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Ville *',
                  hintText: 'Paris, Lyon, Beaune...',
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.brandOrange, width: 2),
                  ),
                  helperText: 'Champ obligatoire',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La ville est obligatoire';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    // Adapter le rayon selon la ville
                    final isLargeCity = RadiusSelector.largeCities.any((largeCity) =>
                        value.toLowerCase().contains(largeCity.toLowerCase()) ||
                        largeCity.toLowerCase().contains(value.toLowerCase()));
                    _selectedRadius = isLargeCity ? 1 : 10;
                  });
                },
              ),
              const SizedBox(height: 24),
              RadiusSelector(
                selectedCity: _cityController.text.trim().isNotEmpty
                    ? _cityController.text.trim()
                    : null,
                selectedRadius: _selectedRadius,
                onRadiusChanged: _updateRadius,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'Annuler',
            style: TextStyle(color: AppColors.brandOrange),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.brandOrange, AppColors.brandPink],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton(
            onPressed: () => _performSearch(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Trouve-moi ça !',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

