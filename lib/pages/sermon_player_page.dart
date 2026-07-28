import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/theme/app_colors.dart';
import 'package:la_bonne_semence_mobile/services/app_data.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:la_bonne_semence_mobile/services/responsive_utils.dart';
import 'package:la_bonne_semence_mobile/services/download_service.dart';
import 'package:rxdart/rxdart.dart';

class SermonPlayerPage extends StatefulWidget {
  final Sermon sermon;

  const SermonPlayerPage({super.key, required this.sermon});

  @override
  State<SermonPlayerPage> createState() => _SermonPlayerPageState();
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

class _SermonPlayerPageState extends State<SermonPlayerPage> {
  late AudioPlayer _audioPlayer;
  late Sermon _currentSermon;

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  @override
  void initState() {
    super.initState();
    _currentSermon = widget.sermon;
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setUrl(_currentSermon.audioUrl);
      _audioPlayer.play();
      _currentSermon.isPlaying = true;
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _currentSermon.isPlaying = false;
    super.dispose();
  }

  void _nextSermon() async {
    final sermons = AppData.instance.cachedSermons;
    int index = sermons.indexOf(_currentSermon);
    if (index >= 0 && index < sermons.length - 1) {
      setState(() {
        _currentSermon.isPlaying = false;
        _currentSermon = sermons[index + 1];
      });
      await _audioPlayer.setUrl(_currentSermon.audioUrl);
      _audioPlayer.play();
      _currentSermon.isPlaying = true;
    }
  }

  void _previousSermon() async {
    final sermons = AppData.instance.cachedSermons;
    int index = sermons.indexOf(_currentSermon);
    if (index > 0) {
      setState(() {
        _currentSermon.isPlaying = false;
        _currentSermon = sermons[index - 1];
      });
      await _audioPlayer.setUrl(_currentSermon.audioUrl);
      _audioPlayer.play();
      _currentSermon.isPlaying = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageHeight = context.percentHeight(35).clamp(180.0, 400.0);
    final controlSize = context.responsiveValue(mobile: 40.0, tablet: 50.0);
    final playBtnSize = context.responsiveValue(mobile: 60.0, tablet: 80.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: isDark ? Colors.white : Colors.black,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveValue(mobile: 20.0, tablet: 40.0),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Cover Image
              Container(
                height: imageHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Hero(
                  tag: 'sermon_icon_${_currentSermon.title}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: _currentSermon.imageUrl.isNotEmpty
                        ? Image.network(
                            _currentSermon.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: AppColors.primary,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.church_outlined,
                              size: imageHeight * 0.5,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(
                            Icons.church_outlined,
                            size: imageHeight * 0.5,
                            color: AppColors.primary,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Title and Author
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentSermon.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentSermon.author,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListenableBuilder(
                      listenable: DownloadService.instance,
                      builder: (context, _) {
                        final isDownloaded =
                            DownloadService.instance.isDownloaded(_currentSermon.id);
                        final progress = DownloadService.instance
                            .getProgress(_currentSermon.id ?? '');

                        if (progress > 0 && progress < 1) {
                          return SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          );
                        }

                        return IconButton(
                          icon: Icon(
                            isDownloaded ? Icons.download_done : Icons.download,
                            color: isDownloaded ? Colors.green : AppColors.primary,
                          ),
                          onPressed: isDownloaded
                              ? null
                              : () async {
                                  try {
                                    await DownloadService.instance
                                        .downloadSermon(_currentSermon);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Téléchargement terminé"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Erreur de téléchargement"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                        );
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              // Progress Bar
              StreamBuilder<PositionData>(
                stream: _positionDataStream,
                builder: (context, snapshot) {
                  final positionData = snapshot.data;
                  return ProgressBar(
                    progress: positionData?.position ?? Duration.zero,
                    buffered: positionData?.bufferedPosition ?? Duration.zero,
                    total: positionData?.duration ?? Duration.zero,
                    onSeek: _audioPlayer.seek,
                    barHeight: 4,
                    baseBarColor: AppColors.primary.withValues(alpha: 0.2),
                    bufferedBarColor: AppColors.primary.withValues(alpha: 0.1),
                    progressBarColor: AppColors.primary,
                    thumbColor: AppColors.primary,
                    thumbRadius: 6,
                    timeLabelTextStyle: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 12,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.skip_previous_rounded, size: controlSize),
                    onPressed: _previousSermon,
                  ),
                  const SizedBox(width: 20),
                  StreamBuilder<PlayerState>(
                    stream: _audioPlayer.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final processingState = playerState?.processingState;
                      final playing = playerState?.playing;

                      if (processingState == ProcessingState.loading ||
                          processingState == ProcessingState.buffering) {
                        return Container(
                          height: playBtnSize,
                          width: playBtnSize,
                          padding: const EdgeInsets.all(16),
                          child: const CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      } else if (playing != true) {
                        return GestureDetector(
                          onTap: _audioPlayer.play,
                          child: Container(
                            height: playBtnSize,
                            width: playBtnSize,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: playBtnSize * 0.6,
                            ),
                          ),
                        );
                      } else if (processingState != ProcessingState.completed) {
                        return GestureDetector(
                          onTap: _audioPlayer.pause,
                          child: Container(
                            height: playBtnSize,
                            width: playBtnSize,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.pause_rounded,
                              color: Colors.white,
                              size: playBtnSize * 0.6,
                            ),
                          ),
                        );
                      } else {
                        return GestureDetector(
                          onTap: () => _audioPlayer.seek(Duration.zero),
                          child: Container(
                            height: playBtnSize,
                            width: playBtnSize,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.replay_rounded,
                              color: Colors.white,
                              size: playBtnSize * 0.6,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Icon(Icons.skip_next_rounded, size: controlSize),
                    onPressed: _nextSermon,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Verse section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceLight.withValues(alpha: 0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Verset Clé",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _currentSermon.verse,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
