import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'chat_message_worker.dart';

class ChatVoiceCircleWidget extends StatefulWidget {
  final ChatMessageWorker message;

  const ChatVoiceCircleWidget({super.key, required this.message});

  @override
  State<ChatVoiceCircleWidget> createState() => _ChatVoiceCircleWidgetState();
}

class _ChatVoiceCircleWidgetState extends State<ChatVoiceCircleWidget>
    with TickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  double _progress = 0.0;
  int _currentSec = 0;
  bool _isSeeking = false;

  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _player.setPlayerMode(PlayerMode.mediaPlayer);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      final playing = state == PlayerState.playing;
      setState(() => _isPlaying = playing);
      playing ? _pulseCtrl.repeat(reverse: true) : _pulseCtrl.stop();
    });

    _player.onPositionChanged.listen((pos) {
      if (!mounted || _isSeeking) return;
      final total = (widget.message.audioDuration ?? 1).clamp(1, 9999);
      setState(() {
        _currentSec = pos.inSeconds;
        _progress = (pos.inMilliseconds / (total * 1000)).clamp(0.0, 1.0);
      });
    });

    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _progress = 0.0;
        _currentSec = 0;
      });
      _pulseCtrl
        ..stop()
        ..reset();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
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
      _isSeeking = true;
      _progress = fraction;
      _currentSec = newSec;
    });
    await _player.seek(Duration(seconds: newSec));
    setState(() => _isSeeking = false);
    if (!_isPlaying) await _player.resume();
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
    final size = 90.w;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _togglePlay,
              child: SizedBox(
                width: size + 20.w,
                height: size + 20.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulse ring
                    AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, __) => Container(
                        width: size + _pulseCtrl.value * 16.w,
                        height: size + _pulseCtrl.value * 16.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.purple.withOpacity(
                              0.4 * (1 - _pulseCtrl.value),
                            ),
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),

                    // Progress ring
                    SizedBox(
                      width: size + 8.w,
                      height: size + 8.w,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 3.5,
                        backgroundColor: Colors.purple.withOpacity(0.15),
                        color: Colors.purple,
                      ),
                    ),

                    // Gradient doira
                    Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF9859EF), Color(0xFF5B1FCB)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Slider (seek uchun)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: SizedBox(
                width: size + 20.w,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.5,
                    thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: Colors.purple,
                    inactiveTrackColor: Colors.purple.withOpacity(0.2),
                    thumbColor: Colors.purple,
                    overlayColor: Colors.purple.withOpacity(0.15),
                  ),
                  child: Slider(
                    value: _progress,
                    onChangeStart: (_) => setState(() => _isSeeking = true),
                    onChanged: (v) => setState(() => _progress = v),
                    onChangeEnd: (v) => _seekTo(v),
                  ),
                ),
              ),
            ),

            // Mic icon + vaqt
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mic, size: 11, color: Colors.grey),
                  SizedBox(width: 3.w),
                  Text(
                    _isPlaying ? _fmt(_currentSec) : _fmt(duration),
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    _fmtTime(widget.message.createdAt),
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}