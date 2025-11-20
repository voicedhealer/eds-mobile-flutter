import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/establishment.dart';
import '../../../data/models/professional.dart';
import '../../../data/models/daily_deal.dart';
import '../../../data/models/event.dart';
import '../../../data/models/event_engagement.dart';
import '../../../data/repositories/event_repository.dart';
import '../../location/widgets/daily_deal_overlay.dart';
import '../../events/widgets/event_overlay.dart';
import '../../../core/providers/auth_provider.dart';

class EstablishmentCard extends ConsumerStatefulWidget {
  final Establishment establishment;
  final VoidCallback? onTap;

  const EstablishmentCard({
    super.key,
    required this.establishment,
    this.onTap,
  });

  @override
  ConsumerState<EstablishmentCard> createState() => _EstablishmentCardState();
}

class _EstablishmentCardState extends ConsumerState<EstablishmentCard> {
  DailyDeal? _activeDeal;
  Event? _upcomingEvent;
  bool _isEventInProgress = false;
  EngagementStats? _eventEngagement;
  bool _isLoadingDeal = true;
  bool _isLoadingEvent = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadDeal();
    _loadEvent();
    _checkFavorite();
  }

  Future<void> _loadDeal() async {
    // TODO: Implémenter le chargement des bons plans depuis l'API
    // Pour l'instant, on simule qu'il n'y a pas de bon plan
    setState(() {
      _isLoadingDeal = false;
    });
  }

  Future<void> _loadEvent() async {
    try {
      final repository = EventRepository();
      final now = DateTime.now();
      
      // Récupérer le prochain événement de l'établissement
      final event = await repository.getNextEventForEstablishment(widget.establishment.id);
      
      if (event != null) {
        final startDate = event.startDate;
        final endDate = event.endDate;
        final isInProgress = startDate.isBefore(now) && 
            (endDate == null || endDate.isAfter(now));
        
        setState(() {
          _upcomingEvent = event;
          _isEventInProgress = isInProgress;
        });
        
        // Charger les stats d'engagement
        _loadEventEngagement(event.id);
      }
    } catch (e) {
      print('Erreur chargement événement: $e');
    } finally {
      setState(() {
        _isLoadingEvent = false;
      });
    }
  }

  Future<void> _loadEventEngagement(String eventId) async {
    try {
      final repository = EventRepository();
      final stats = await repository.getEngagementStats(eventId);
      setState(() {
        _eventEngagement = stats;
      });
    } catch (e) {
      print('Erreur chargement engagement: $e');
    }
  }

  Future<void> _checkFavorite() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    
    // TODO: Implémenter la vérification des favoris depuis l'API
    setState(() {
      _isFavorite = false;
    });
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength).trim()}...';
  }

  String _formatAddress(String address) {
    final parts = address.split(',');
    if (parts.isNotEmpty) {
      return parts.first.trim();
    }
    return address;
  }

  String _formatPrice() {
    if (widget.establishment.priceMin != null &&
        widget.establishment.priceMax != null) {
      return '${widget.establishment.priceMin}-${widget.establishment.priceMax}€';
    } else if (widget.establishment.priceMin != null) {
      return 'À partir de ${widget.establishment.priceMin}€';
    } else if (widget.establishment.priceMax != null) {
      return 'Jusqu\'à ${widget.establishment.priceMax}€';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec overlays
            Stack(
              children: [
                // Image principale
                Container(
                  height: 192,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: widget.establishment.imageUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: widget.establishment.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image, size: 48),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.store, size: 48, color: Colors.grey),
                        ),
                ),
                
                // Overlay Bon plan du jour (EN HAUT)
                if (_activeDeal != null)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: DailyDealOverlay(deal: _activeDeal!),
                  ),
                
                // Boutons d'interaction (EN HAUT À DROITE)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Column(
                    children: [
                      // Bouton Like (Favoris)
                      IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          // TODO: Implémenter le toggle favoris
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.3),
                          padding: const EdgeInsets.all(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Bouton Share
                      IconButton(
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          // TODO: Implémenter le partage
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.3),
                          padding: const EdgeInsets.all(4),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Badge Premium (EN HAUT À DROITE si pas d'événement)
                if (_upcomingEvent == null && widget.establishment.subscription == SubscriptionPlan.premium)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF751F),
                            Color(0xFFFF1FA9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                
                // Overlay événement (EN BAS DE L'IMAGE)
                if (_upcomingEvent != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: EventOverlay(
                      event: _upcomingEvent!,
                      isInProgress: _isEventInProgress,
                      engagement: _eventEngagement,
                      establishmentSlug: widget.establishment.slug,
                    ),
                  ),
              ],
            ),
            
            // Corps de la card
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nom
                  Text(
                    widget.establishment.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF171717),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Note + Avis
                  _buildRatingSection(),
                  
                  const SizedBox(height: 8),
                  
                  // Description courte
                  if (widget.establishment.description != null)
                    Text(
                      _truncateText(widget.establishment.description!, 65),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Adresse
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatAddress(widget.establishment.address),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  // Prix (si disponible)
                  if (widget.establishment.priceMin != null ||
                      widget.establishment.priceMax != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(color: Colors.orange[200]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatPrice(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF7C3AED),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    final rating = widget.establishment.avgRating;
    final reviewCount = widget.establishment.totalComments;
    
    if (rating != null && reviewCount > 0) {
      return Row(
        children: [
          const Icon(Icons.star, size: 16, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '($reviewCount avis)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(Icons.star_border, size: 12, color: Colors.grey[400]),
          const SizedBox(width: 4),
          Text(
            'Aucun avis, laissez le vôtre ?',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      );
    }
  }
}
