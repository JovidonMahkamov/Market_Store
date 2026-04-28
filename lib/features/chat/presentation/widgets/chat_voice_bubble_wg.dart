// lib/features/chat/presentation/widgets/chat_voice_bubble_wg.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:market_store/core/constants/app_colors.dart';
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
  bool _isSeeking = false;
  double _volume = 1.0;
  bool _showVolumeSlider = false;

  @override
  void initState() {
    super.initState();
    _player.setPlayerMode(PlayerMode.mediaPlayer);

    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state == PlayerState.playing);
    });

    _player.onPositionChanged.listen((pos) {
      if (!mounted || _isSeeking) return;
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
    if (!File(path).existsSync()) return;

    if (_isPlaying) {
      await _player.pause();
    } else {
      if (_progress > 0 && _progress < 1.0) {
        await _player.resume();
      } else {
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
              options: {},
            ),
          ),
        );
        await _player.play(DeviceFileSource(path));
      }
    }
  }

  Future<void> _seekTo(double fraction) async {
    final total = widget.message.audioDuration ?? 0;
    if (total <= 0) return;
    final newSec = (fraction * total).round();
    setState(() {
      _progress = fraction;
      _currentSec = newSec;
      _isSeeking = true;
    });
    await _player.seek(Duration(seconds: newSec));
    setState(() => _isSeeking = false);
    if (!_isPlaying) await _player.resume();
  }

  String _fmt(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
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
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            constraints: BoxConstraints(maxWidth: 280.w, minWidth: 220.w),
            decoration: BoxDecoration(
              color: isMe
                  ? const Color(0xff9859EF)
                  : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Play / Pause button — yumaloq, ko'k/oq
                GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: AppColors.purple,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // Waveform (seekable) + timer
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SeekableWaveformView(
                        heights: wave,
                        progress: _progress,
                        isMe: isMe,
                        onSeek: _seekTo,
                        onDragStart: () => setState(() => _isSeeking = true),
                        onDragEnd: () => setState(() => _isSeeking = false),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _isPlaying ? _fmt(_currentSec) : _fmt(duration),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isMe
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),

                // Volume icon — o'ng tarafda
                GestureDetector(
                  onTap: () {
                    setState(() => _showVolumeSlider = !_showVolumeSlider);
                  },
                  child: Icon(
                    _volume > 0.5
                        ? Icons.volume_up_rounded
                        : _volume > 0
                        ? Icons.volume_down_rounded
                        : Icons.volume_off_rounded,
                    color: isMe
                        ? Colors.white.withOpacity(0.85)
                        : Colors.black54,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),

          // Volume slider (ixtiyoriy, tap bilan ochiladi)
          if (_showVolumeSlider)
            Container(
              width: 160.w,
              margin: EdgeInsets.only(bottom: 2.h),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                  activeTrackColor: Colors.purple,
                  inactiveTrackColor: Colors.purple.withOpacity(0.2),
                  thumbColor: Colors.purple,
                ),
                child: Slider(
                  value: _volume,
                  min: 0,
                  max: 1,
                  onChanged: (v) {
                    setState(() => _volume = v);
                    _player.setVolume(v);
                  },
                ),
              ),
            ),

          // Vaqt
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

// ── Seekable Waveform ──────────────────────────────────────────────────────
class _SeekableWaveformView extends StatefulWidget {
  final List<double> heights;
  final double progress;
  final bool isMe;
  final ValueChanged<double> onSeek;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;

  const _SeekableWaveformView({
    required this.heights,
    required this.progress,
    required this.isMe,
    required this.onSeek,
    required this.onDragStart,
    required this.onDragEnd,
  });

  @override
  State<_SeekableWaveformView> createState() => _SeekableWaveformViewState();
}

class _SeekableWaveformViewState extends State<_SeekableWaveformView> {
  double? _dragProgress;

  double _posToFraction(Offset local, double width) =>
      (local.dx / width).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final played =
    widget.isMe ? Colors.white : const Color(0xFF6B5EFF);
    final unplayed = widget.isMe
        ? Colors.white.withOpacity(0.35)
        : Colors.grey.withOpacity(0.4);
    final thumbColor =
    widget.isMe ? Colors.white : const Color(0xFF6B5EFF);
    final currentProgress = _dragProgress ?? widget.progress;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) {
            widget.onSeek(_posToFraction(d.localPosition, width));
          },
          onHorizontalDragStart: (d) {
            widget.onDragStart();
            setState(
                    () => _dragProgress = _posToFraction(d.localPosition, width));
          },
          onHorizontalDragUpdate: (d) {
            setState(
                    () => _dragProgress = _posToFraction(d.localPosition, width));
          },
          onHorizontalDragEnd: (_) {
            if (_dragProgress != null) widget.onSeek(_dragProgress!);
            setState(() => _dragProgress = null);
            widget.onDragEnd();
          },
          child: SizedBox(
            height: 28.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Bars
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(widget.heights.length, (i) {
                    final fraction = i / widget.heights.length;
                    final isPlayed = fraction < currentProgress;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0.8.w),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 80),
                          height: widget.heights[i].clamp(3.0, 22.0),
                          decoration: BoxDecoration(
                            color: isPlayed ? played : unplayed,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                // Thumb
                Positioned(
                  left: (currentProgress * width - 5.w).clamp(0, width - 12.w),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    width: _dragProgress != null ? 13.w : 9.w,
                    height: _dragProgress != null ? 13.w : 9.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: thumbColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}