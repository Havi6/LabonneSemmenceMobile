import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/theme/app_colors.dart';
import 'package:la_bonne_semence_mobile/widget/reveal_item.dart';
import 'package:la_bonne_semence_mobile/pages/sermon_player_page.dart';
import 'package:la_bonne_semence_mobile/services/app_data.dart';
import 'package:la_bonne_semence_mobile/services/responsive_utils.dart';

class SermonsPage extends StatefulWidget {
  const SermonsPage({super.key});

  @override
  State<SermonsPage> createState() => _SermonsPageState();
}

class _SermonsPageState extends State<SermonsPage> {
  late List<Sermon> _filteredSermons;
  List<Sermon> _sermons = const [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _filteredSermons = _sermons;
    _loadSermons();
  }

  Future<void> _loadSermons() async {
    try {
      final sermons = await AppData.fetchSermons();
      if (!mounted) return;
      setState(() {
        _sermons = sermons;
        _filteredSermons = _sermons;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterSermons(String query) {
    setState(() {
      _filteredSermons = _sermons
          .where(
            (sermon) =>
                sermon.title.toLowerCase().contains(query.toLowerCase()) ||
                sermon.author.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSermons,
              decoration: InputDecoration(
                hintText: 'Rechercher un sermon ou un pasteur...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterSermons('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? AppColors.surfaceLight.withOpacity(0.3)
                    : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _filteredSermons.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun sermon trouvé',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredSermons.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final sermon = _filteredSermons[index];
                      return RevealItem(
                        key: ValueKey(sermon.title + sermon.date),
                        delay: Duration(milliseconds: (index % 6) * 100),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: isDark
                              ? AppColors.surfaceLight.withOpacity(0.3)
                              : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SermonPlayerPage(sermon: sermon),
                                  ),
                                );
                              },
                              leading: Hero(
                                tag:
                                    'sermon_icon_${sermon.title}_${sermon.date}',
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.mic,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              title: Text(
                                sermon.title,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: context.responsiveValue(
                                    mobile: 15.0,
                                    tablet: 18.0,
                                  ),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Text(
                                    sermon.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontSize: context.responsiveValue(
                                        mobile: 12.0,
                                        tablet: 14.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    sermon.verse,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: context.responsiveValue(
                                        mobile: 10.0,
                                        tablet: 12.0,
                                      ),
                                      color: AppColors.primary.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 4,
                                    children: [
                                      _buildInfoItem(
                                        Icons.person,
                                        sermon.author,
                                        isDark,
                                        context,
                                      ),
                                      _buildInfoItem(
                                        Icons.access_time,
                                        sermon.duration,
                                        isDark,
                                        context,
                                      ),
                                      _buildInfoItem(
                                        Icons.calendar_today,
                                        sermon.date,
                                        isDark,
                                        context,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                iconSize: context.responsiveValue(
                                  mobile: 35.0,
                                  tablet: 45.0,
                                ),
                                icon: Icon(
                                  sermon.isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  color: AppColors.primary,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SermonPlayerPage(sermon: sermon),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    bool isDark,
    BuildContext context,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: context.responsiveValue(mobile: 10.0, tablet: 12.0),
            color: isDark ? Colors.white60 : Colors.black87,
          ),
        ),
      ],
    );
  }
}
