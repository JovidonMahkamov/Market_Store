/// lib/features/chat/presentation/widgets/chat_voice_bubble_wg.dart
/// ✅ To'liq tuzatilgan: speaker orqali ovoz, fayl tekshiruvi

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';
import 'chat_message_worker.dart';

class ChatVoiceBubbleWidget extends StatefulWidget {
  final ChatMessageWorker message;

  const ChatVoiceBubbleWidget({super.key, required this.message});

  @override
  State<ChatVoiceBubbleWidget> createState() => _ChatVoiceBubbleWidgetState();
}

class _ChatVoiceBubbleWidgetState extends State<ChatVoiceBubbleWidget> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  double _progress = 0.0;
  int _currentSec = 0;

  @override
  void initState() {
    super.initState();
    _player.setPlayerMode(PlayerMode.mediaPlayer);

    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state == PlayerState.playing);
    });

    _player.onPositionChanged.listen((pos) {
      if (!mounted) return;
      final total = (widget.message.audioDuration ?? 1).clamp(1, 9999);
      setState(() {
        _currentSec = pos.inSeconds;
        _progress = (pos.inSeconds / total).clamp(0.0, 1.0);
      });
    });

    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _progress = 0.0;
        _currentSec = 0;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    final path = widget.message.audioPath;
    if (path == null) return;

    if (!File(path).existsSync()) {
      debugPrint('Audio fayl topilmadi: $path');
      return;
    }

    if (_isPlaying) {
      await _player.pause();
    } else {
      if (_progress > 0 && _progress < 1.0) {
        await _player.resume();
      } else {
        // ✅ Speaker sozlamasi play qilishdan oldin
        await _player.setAudioContext(
          AudioContext(
            android: AudioContextAndroid(
              isSpeakerphoneOn: true,
              stayAwake: false,
              contentType: AndroidContentType.music,
              usageType: AndroidUsageType.media,
              audioFocus: AndroidAudioFocus.gain,
            ),
            iOS: AudioContextIOS(
              category: AVAudioSessionCategory.playback,
              options: {AVAudioSessionOptions.defaultToSpeaker},
            ),
          ),
        );
        await _player.play(DeviceFileSource(path));
      }
    }
  }

  String _fmt(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.isMe;
    final duration = widget.message.audioDuration ?? 0;
    final wave = widget.message.waveform ?? List.filled(30, 8.0);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 4.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            constraints: BoxConstraints(maxWidth: 260.w, minWidth: 200.w),
            decoration: BoxDecoration(
              color: isMe
                  ? const Color(0xff9859EF)
                  : const Color(0xFFF7F2FF),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Play / Pause tugmasi
                GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.white.withOpacity(0.25)
                          : Colors.purple.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: isMe ? Colors.white : Colors.purple,
                      size: 22,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),

                // ── To'lqin ko'rsatgichi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _WaveformView(
                        heights: wave,
                        progress: _progress,
                        isMe: isMe,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _isPlaying ? _fmt(_currentSec) : _fmt(duration),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isMe
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Vaqt
          Padding(
            padding: EdgeInsets.only(top: 2.h, bottom: 2.h),
            child: Text(
              _fmtTime(widget.message.createdAt),
              style: TextStyle(fontSize: 11.sp, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  To'lqin vizualizatsiyasi
// ─────────────────────────────────────────────────────────────────────────────
class _WaveformView extends StatelessWidget {
  final List<double> heights;
  final double progress;
  final bool isMe;

  const _WaveformView({
    required this.heights,
    required this.progress,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final played = isMe ? Colors.white : Colors.purple;
    final unplayed = isMe
        ? Colors.white.withOpacity(0.35)
        : Colors.purple.withOpacity(0.3);

    return SizedBox(
      height: 28.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(heights.length, (i) {
          final fraction = i / heights.length;
          final isPlayed = fraction < progress;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                height: heights[i].clamp(4.0, 24.0),
                decoration: BoxDecoration(
                  color: isPlayed ? played : unplayed,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}