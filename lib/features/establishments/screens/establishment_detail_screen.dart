import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/establishment.dart';
import '../../../data/models/professional.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/services/favorites_service.dart';
import '../../../core/providers/favorites_provider.dart';
import 'package:go_router/go_router.dart';

class EstablishmentDetailScreen extends ConsumerStatefulWidget {
  final Establishment establishment;

  const EstablishmentDetailScreen({
    super.key,
    required this.establishment,
  });

  @override
  ConsumerState<EstablishmentDetailScreen> createState() => _EstablishmentDetailScreenState();
}

class _EstablishmentDetailScreenState extends ConsumerState<EstablishmentDetailScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  bool? _isFavorite;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final isFav = await _favoritesService.isFavorite(widget.establishment.id, user.id);
      if (mounted) {
        setState(() => _isFavorite = isFav);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ErrorHandler.showInfo(context, 'Connectez-vous pour ajouter aux favoris');
        context.push('/login');
      }
      return;
    }

    try {
      await _favoritesService.toggleFavorite(widget.establishment.id, user.id);
      await _checkFavorite();
      ref.invalidate(favoritesProvider);
      
      if (mounted) {
        ErrorHandler.showSuccess(
          context,
          _isFavorite == true ? 'Retiré des favoris' : 'Ajouté aux favoris',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite == true ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite == true ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
                tooltip: _isFavorite == true ? 'Retirer des favoris' : 'Ajouter aux favoris',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: widget.establishment.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: widget.establishment.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 64),
                    ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.establishment.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.establishment.address}${widget.establishment.city != null ? ', ${widget.establishment.city}' : ''}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (widget.establishment.subscription == SubscriptionPlan.premium)
                      Container(
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
                  ],
                ),
                if (widget.establishment.avgRating != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        widget.establishment.avgRating!.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${widget.establishment.totalComments} avis)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
                if (widget.establishment.description != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.establishment.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (widget.establishment.prixMoyen != null ||
                    widget.establishment.priceMin != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Prix',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.establishment.priceMin != null && widget.establishment.priceMax != null
                        ? Formatters.formatPriceRange(
                            widget.establishment.priceMin, widget.establishment.priceMax)
                        : Formatters.formatPrice(widget.establishment.prixMoyen),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                if (widget.establishment.phone != null ||
                    widget.establishment.email != null ||
                    widget.establishment.website != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Contact',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (widget.establishment.phone != null)
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: const Text('Téléphone'),
                      subtitle: Text(widget.establishment.phone!),
                      onTap: () => _launchUrl('tel:${widget.establishment.phone}'),
                    ),
                  if (widget.establishment.email != null)
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle: Text(widget.establishment.email!),
                      onTap: () => _launchUrl('mailto:${widget.establishment.email}'),
                    ),
                  if (widget.establishment.website != null)
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Site web'),
                      subtitle: Text(widget.establishment.website!),
                      onTap: () => _launchUrl(widget.establishment.website),
                    ),
                ],
                if (widget.establishment.latitude != null &&
                    widget.establishment.longitude != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/map?envie=${Uri.encodeComponent(widget.establishment.name)}');
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('Voir sur la carte'),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

