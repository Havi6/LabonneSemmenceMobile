import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/theme/app_colors.dart';
import 'package:la_bonne_semence_mobile/services/app_data.dart';
import 'package:la_bonne_semence_mobile/pages/video_player_page.dart';
import 'package:la_bonne_semence_mobile/services/responsive_utils.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: context.percentHeight(35).clamp(200.0, 450.0),
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'event_${event.imageUrl}',
                child: Image.network(event.imageUrl, fit: BoxFit.cover),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(
                context.responsiveValue(mobile: 20.0, tablet: 32.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          event.label.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (event.videoUrl != null)
                        IconButton(
                          icon: const Icon(
                            Icons.play_circle_fill,
                            color: AppColors.primary,
                            size: 32,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoPlayerPage(
                                  videoUrl: event.videoUrl!,
                                  title: event.title,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    event.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: context.responsiveValue(
                        mobile: 22.0,
                        tablet: 28.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(
                    Icons.calendar_today,
                    "Date",
                    event.date,
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.access_time,
                    "Heure",
                    event.time,
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    "Lieu",
                    event.location,
                    isDark,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      if (event.videoUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoPlayerPage(
                                      videoUrl: event.videoUrl!,
                                      title: event.title,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.play_circle_outline),
                              label: const Text("Regarder l'enseignement"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "S'inscrire / Participer",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
