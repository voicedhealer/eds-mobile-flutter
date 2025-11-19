import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/comments_repository.dart';
import '../../../data/models/user_comment.dart';

final userCommentsProvider = FutureProvider<List<UserComment>>((ref) async {
  final repository = CommentsRepository();
  return repository.getUserComments();
});

class CommentsTab extends ConsumerWidget {
  const CommentsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(userCommentsProvider);

    return commentsAsync.when(
      data: (comments) {
        if (comments.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.comment_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Aucun avis pour le moment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Laissez votre premier avis sur un établissement !'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: comment.establishment?.imageUrl != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(comment.establishment!.imageUrl!),
                      )
                    : const CircleAvatar(
                        child: Icon(Icons.store),
                      ),
                title: Text(comment.establishment?.name ?? 'Établissement'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (comment.rating != null)
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < comment.rating! ? Icons.star : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(comment.content),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(comment.createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Supprimer l\'avis'),
                        content: const Text('Êtes-vous sûr de vouloir supprimer cet avis ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Annuler'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Supprimer'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      try {
                        final repository = CommentsRepository();
                        await repository.deleteComment(comment.id);
                        ref.invalidate(userCommentsProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Avis supprimé')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur: $e')),
                          );
                        }
                      }
                    }
                  },
                ),
                onTap: () {
                  if (comment.establishment != null) {
                    context.push('/establishment/${comment.establishment!.slug}');
                  }
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Erreur: $error'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

