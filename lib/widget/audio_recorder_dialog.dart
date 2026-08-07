import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:la_bonne_semence_mobile/theme/app_colors.dart';

class AudioRecorderDialog extends StatefulWidget {
  const AudioRecorderDialog({super.key});

  @override
  State<AudioRecorderDialog> createState() => _AudioRecorderDialogState();
}

class _AudioRecorderDialogState extends State<AudioRecorderDialog> {
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  
  bool _isRecording = false;
  String? _recordedPath;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) return;

    final dir = await getTemporaryDirectory();
    final path = p.join(dir.path, 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a');
    
    await _recorder.start(const RecordConfig(), path: path);
    setState(() {
      _isRecording = true;
      _recordedPath = null;
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    setState(() {
      _isRecording = false;
      _recordedPath = path;
    });
    if (path != null) {
      await _player.setFilePath(path);
      _duration = _player.duration ?? Duration.zero;
    }
  }

  Future<void> _togglePlay() async {
    if (_recordedPath == null) return;
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
    setState(() {
      _isPlaying = _player.playing;
    });
    
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() => _isPlaying = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enregistrement Audio'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isRecording)
            const Column(
              children: [
                Icon(Icons.mic, color: Colors.red, size: 48),
                SizedBox(height: 10),
                Text('Enregistrement en cours...'),
              ],
            )
          else if (_recordedPath != null)
            Column(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 48),
                const SizedBox(height: 10),
                Text('Audio enregistré (${_duration.inSeconds}s)'),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _togglePlay,
                ),
              ],
            )
          else
            const Column(
              children: [
                Icon(Icons.mic_none, color: AppColors.primary, size: 48),
                SizedBox(height: 10),
                Text('Prêt à enregistrer'),
              ],
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        if (!_isRecording && _recordedPath == null)
          FilledButton.icon(
            onPressed: _startRecording,
            icon: const Icon(Icons.fiber_manual_record),
            label: const Text('Enregistrer'),
          )
        else if (_isRecording)
          FilledButton.icon(
            onPressed: _stopRecording,
            icon: const Icon(Icons.stop),
            label: const Text('Arrêter'),
          )
        else
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, _recordedPath),
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Utiliser cet audio'),
          ),
      ],
    );
  }
}
