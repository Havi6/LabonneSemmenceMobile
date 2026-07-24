import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/theme/app_colors.dart';
import 'package:la_bonne_semence_mobile/widget/reveal_item.dart';
import 'package:la_bonne_semence_mobile/widget/image_viewer.dart';
import 'package:la_bonne_semence_mobile/widget/empty_state_placeholder.dart';
import 'package:la_bonne_semence_mobile/pages/event_detail_page.dart';
import 'package:la_bonne_semence_mobile/pages/sermon_player_page.dart';
import 'package:la_bonne_semence_mobile/services/app_data.dart';
import 'package:la_bonne_semence_mobile/services/responsive_utils.dart';

class HomePage extends StatefulWidget {
  final Function(int)? onNavigate;

  const HomePage({super.key, this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Sermon> _recentSermons = const [];
  List<Event> _recentEvents = const [];
  List<GalleryItem> _recentGallery = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      final results = await Future.wait([
        AppData.fetchSermons(),
        AppData.fetchEvents(),
        AppData.fetchGallery(),
      ]);

      if (!mounted) return;
      setState(() {
        _recentSermons = (results[0] as List<Sermon>).take(5).toList();
        _recentEvents = (results[1] as List<Event>).take(5).toList();
        _recentGallery = (results[2] as List<GalleryItem>).take(5).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const LinearProgressIndicator(color: AppColors.primary),

            // Section Bienvenue
            const RevealItem(
              delay: Duration(milliseconds: 200),
              offset: Offset(0, -0.05),
              child: _WelcomeSection(),
            ),

            const SizedBox(height: 24),

            // Section Sermons
            RevealItem(
              delay: const Duration(milliseconds: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    "Derniers Enseignements",
                    Icons.mic_external_on,
                    1,
                  ),
                  _buildSermonsCarousel(isDark),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section Événements
            RevealItem(
              delay: const Duration(milliseconds: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Prochains Évènements", Icons.event, 2),
                  _buildEventsCarousel(isDark),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section Galerie
            RevealItem(
              delay: const Duration(milliseconds: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Galerie Photos", Icons.photo_library, 3),
                  _buildGalleryCarousel(isDark),
                ],
              ),
            ),

            SizedBox(height: context.bottomNavigationClearance),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, int targetIndex) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.pageHorizontalPadding,
        vertical: 8,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              if (widget.onNavigate != null) {
                widget.onNavigate!(targetIndex);
              }
            },
            child: const Text(
              "Voir tout",
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSermonsCarousel(bool isDark) {
    return SizedBox(
      height: context.responsiveValue(mobile: 156.0, tablet: 170.0),
      child: _recentSermons.isEmpty
          ? const EmptyStatePlaceholder(
              icon: Icons.mic_off_outlined,
              message: 'Aucun sermon disponible pour le moment.',
              compact: true,
            )
          : ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _recentSermons.length,
        itemBuilder: (context, index) {
          final sermon = _recentSermons[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SermonPlayerPage(sermon: sermon),
                ),
              );
            },
            child: Container(
              width: context.responsiveValue(
                mobile: context.percentWidth(78).clamp(230.0, 320.0),
                tablet: 300,
                desktop: 350,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceLight.withOpacity(0.2)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'sermon_icon_${sermon.title}',
                        child: const Icon(
                          Icons.play_circle_fill,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          sermon.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    sermon.author,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    sermon.date,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventsCarousel(bool isDark) {
    return SizedBox(
      height: context.responsiveValue(mobile: 190.0, tablet: 210.0),
      child: _recentEvents.isEmpty
          ? const EmptyStatePlaceholder(
              icon: Icons.event_busy_outlined,
              message: 'Aucun événement à venir pour le moment.',
              compact: true,
            )
          : ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _recentEvents.length,
        itemBuilder: (context, index) {
          final event = _recentEvents[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailPage(event: event),
                ),
              );
            },
            child: Container(
              width: context.responsiveValue(
                mobile: context.percentWidth(52).clamp(150.0, 220.0),
                tablet: 180,
                desktop: 220,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(event.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'event_${event.imageUrl}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.date,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGalleryCarousel(bool isDark) {
    return SizedBox(
      height: context.responsiveValue(mobile: 140.0, tablet: 160.0),
      child: _recentGallery.isEmpty
          ? const EmptyStatePlaceholder(
              icon: Icons.photo_library_outlined,
              message: 'Aucune photo disponible pour le moment.',
              compact: true,
            )
          : ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _recentGallery.length,
        itemBuilder: (context, index) {
          final photo = _recentGallery[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ImageViewer(imageUrl: photo.url, title: photo.title),
                ),
              );
            },
            child: Container(
              width: context.responsiveValue(
                mobile: context.percentWidth(48).clamp(120.0, 180.0),
                tablet: 160,
                desktop: 200,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: photo.url,
                      child: Image.network(photo.url, fit: BoxFit.cover),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                        child: Text(
                          photo.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.pageHorizontalPadding),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bienvenue,",
            style: TextStyle(
              fontSize: context.responsiveValue(mobile: 24.0, tablet: 28.0),
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            "La Bonne Semence est heureuse de vous retrouver.",
            style: TextStyle(
              fontSize: context.responsiveValue(mobile: 14.0, tablet: 16.0),
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
