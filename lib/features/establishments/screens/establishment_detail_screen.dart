import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/establishment.dart';
import '../../../core/utils/formatters.dart';
import 'package:go_router/go_router.dart';

class EstablishmentDetailScreen extends StatelessWidget {
  final Establishment establishment;

  const EstablishmentDetailScreen({
    super.key,
    required this.establishment,
  });

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
            flexibleSpace: FlexibleSpaceBar(
              background: establishment.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: establishment.imageUrl!,
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
                            establishment.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${establishment.address}${establishment.city != null ? ', ${establishment.city}' : ''}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (establishment.subscription == SubscriptionPlan.premium)
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
                if (establishment.avgRating != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        establishment.avgRating!.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${establishment.totalComments} avis)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
                if (establishment.description != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    establishment.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (establishment.prixMoyen != null ||
                    establishment.priceMin != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Prix',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    establishment.priceMin != null && establishment.priceMax != null
                        ? Formatters.formatPriceRange(
                            establishment.priceMin, establishment.priceMax)
                        : Formatters.formatPrice(establishment.prixMoyen),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                if (establishment.phone != null ||
                    establishment.email != null ||
                    establishment.website != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Contact',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (establishment.phone != null)
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: const Text('Téléphone'),
                      subtitle: Text(establishment.phone!),
                      onTap: () => _launchUrl('tel:${establishment.phone}'),
                    ),
                  if (establishment.email != null)
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle: Text(establishment.email!),
                      onTap: () => _launchUrl('mailto:${establishment.email}'),
                    ),
                  if (establishment.website != null)
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Site web'),
                      subtitle: Text(establishment.website!),
                      onTap: () => _launchUrl(establishment.website),
                    ),
                ],
                if (establishment.latitude != null &&
                    establishment.longitude != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/map?envie=${establishment.name}');
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

