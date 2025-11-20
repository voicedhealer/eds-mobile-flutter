import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../data/models/daily_deal.dart';
import '../../../core/utils/deal_utils.dart';
import '../../../data/repositories/deal_engagement_repository.dart';

class DailyDealCard extends StatefulWidget {
  final DailyDeal deal;
  final bool redirectToEstablishment;

  const DailyDealCard({
    super.key,
    required this.deal,
    this.redirectToEstablishment = false,
  });

  @override
  State<DailyDealCard> createState() => _DailyDealCardState();
}

class _DailyDealCardState extends State<DailyDealCard>
    with SingleTickerProviderStateMixin {
  bool _isFlipped = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  String? _userEngagement; // 'liked' | 'disliked' | null
  bool _isSubmitting = false;
  final _engagementRepository = DealEngagementRepository();

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _handleFlip() {
    setState(() {
      _isFlipped = !_isFlipped;
      if (_isFlipped) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    });
  }

  Future<void> _handleEngagement(String type) async {
    if (_isSubmitting) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final success = await _engagementRepository.recordEngagement(
        dealId: widget.deal.id,
        type: type,
      );
      
      if (success) {
        setState(() {
          _userEngagement = type;
        });
      }
    } catch (e) {
      print('Erreur engagement: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _handleCardClick() {
    if (_isFlipped) return; // Ne pas rediriger si la carte est retournée
    
    if (widget.redirectToEstablishment && widget.deal.establishment.slug != null) {
      Navigator.of(context).pushNamed(
        '/establishments/${widget.deal.establishment.slug}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final discount = DealUtils.calculateDiscount(
      widget.deal.originalPrice,
      widget.deal.discountedPrice,
    );
    
    return GestureDetector(
      onTap: _handleCardClick,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * math.pi;
          final isFrontVisible = angle < math.pi / 2 || angle > 3 * math.pi / 2;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(angle),
            child: isFrontVisible ? _buildFront(discount) : _buildBack(discount),
          );
        },
      ),
    );
  }

  Widget _buildFront(int discount) {
    return Container(
      height: 520, // Hauteur fixe pour correspondre à la hauteur du ListView
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF6600), // Bordure orange caractéristique
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image avec badge
          Stack(
            children: [
              // Image
              if (widget.deal.imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  child: Image.network(
                    widget.deal.imageUrl!,
                    height: 224, // h-56
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 224,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 224,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image, size: 48),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 224,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange[100]!, Colors.orange[50]!],
                    ),
                  ),
                ),
              
              // Badge "Bon plan du jour" (centré en haut)
              Positioned(
                top: 0,
                left: 80,
                right: 80,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF751F),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '🎯 BON PLAN DU JOUR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Nom de l'établissement en overlay (bas gauche)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    widget.deal.establishment.name.length > 25
                        ? '${widget.deal.establishment.name.substring(0, 25)}...'
                        : widget.deal.establishment.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              // Boutons de vote (bas droite)
              Positioned(
                bottom: 8,
                right: 8,
                child: Row(
                  children: [
                    // Bouton Like
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleEngagement('liked'),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _userEngagement == 'liked'
                                ? Colors.green[500]
                                : Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.thumb_up,
                            size: 16,
                            color: _userEngagement == 'liked'
                                ? Colors.white
                                : Colors.green[600],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Bouton Dislike
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleEngagement('disliked'),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _userEngagement == 'disliked'
                                ? Colors.red[500]
                                : Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.thumb_down,
                            size: 16,
                            color: _userEngagement == 'disliked'
                                ? Colors.white
                                : Colors.red[600],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                Text(
                  widget.deal.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF171717),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                // Prix
                if (widget.deal.originalPrice != null ||
                    widget.deal.discountedPrice != null)
                  Row(
                    children: [
                      if (widget.deal.originalPrice != null)
                        Text(
                          DealUtils.formatPrice(widget.deal.originalPrice!),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      if (widget.deal.originalPrice != null &&
                          widget.deal.discountedPrice != null)
                        const SizedBox(width: 8),
                      if (widget.deal.discountedPrice != null)
                        Text(
                          DealUtils.formatPrice(widget.deal.discountedPrice!),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF751F),
                          ),
                        ),
                      if (discount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF751F),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '-$discount%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                
                const SizedBox(height: 12),
                
                // Description
                Text(
                  widget.deal.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                // Date et horaires
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.orange[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            DealUtils.formatDateForFront(widget.deal),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.deal.heureDebut != null &&
                        widget.deal.heureFin != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.orange[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'De ${widget.deal.heureDebut} à ${widget.deal.heureFin}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (widget.deal.pdfUrl != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.description,
                            size: 16,
                            color: Colors.orange[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Menu disponible (PDF)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Bouton "Voir les détails" (flip)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _handleFlip,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFFF751F),
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Voir les détails',
                      style: TextStyle(
                        color: Color(0xFFFF751F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack(int discount) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: Container(
        height: 520, // Hauteur fixe pour correspondre à la hauteur du ListView
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[50]!,
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFF6600),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Bouton retour (gauche)
            Positioned(
              left: -12,
              top: 0,
              bottom: 0,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _handleFlip,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Contenu
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xFFFF6600),
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Détails de l\'offre',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Détails
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nom établissement
                          _buildDetailItem(
                            '🏢',
                            widget.deal.establishment.name.length > 25
                                ? '${widget.deal.establishment.name.substring(0, 25)}...'
                                : widget.deal.establishment.name,
                          ),
                          
                          _buildDetailItem('🎯', widget.deal.title),
                          
                          _buildDetailItem(
                            '📅',
                            DealUtils.formatDealDate(widget.deal),
                          ),
                          
                          if (widget.deal.heureDebut != null &&
                              widget.deal.heureFin != null)
                            _buildDetailItem(
                              '⏰',
                              'De ${widget.deal.heureDebut} à ${widget.deal.heureFin}',
                            ),
                          
                          if (widget.deal.modality != null)
                            _buildDetailItem(
                              '📋',
                              widget.deal.modality!,
                              maxLines: 2,
                            ),
                          
                          _buildDetailItemWithWidget(
                            '💰',
                            _buildPriceText(),
                          ),
                          
                          if (widget.deal.pdfUrl != null)
                            _buildDetailItem('📄', 'Menu disponible en PDF'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Conditions
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border(
                        left: BorderSide(
                          color: Colors.orange[400]!,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      widget.deal.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  if (widget.deal.promoUrl != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.orange[300]!),
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Ouvrir le lien promo
                        },
                        child: Row(
                          children: [
                            const Text('🔗'),
                            const SizedBox(width: 8),
                            Text(
                              'Voir la promotion en ligne',
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String icon, String text, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF555555),
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItemWithWidget(String icon, Widget widget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: widget,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceText() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Color(0xFF555555)),
        children: [
          if (widget.deal.originalPrice != null)
            TextSpan(
              text: DealUtils.formatPrice(widget.deal.originalPrice!),
              style: TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey[400],
              ),
            ),
          if (widget.deal.originalPrice != null &&
              widget.deal.discountedPrice != null)
            const TextSpan(text: ' '),
          if (widget.deal.discountedPrice != null)
            TextSpan(
              text: DealUtils.formatPrice(widget.deal.discountedPrice!),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF751F),
              ),
            ),
        ],
      ),
    );
  }
}

