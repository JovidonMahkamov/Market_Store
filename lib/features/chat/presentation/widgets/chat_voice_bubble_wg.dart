import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'chat_message_worker.dart';

/// Telegram uslubidagi Voice Message Bubble Widget
///
/// TO'G'RILANGAN:
///  - Pastdagi liner slider YO'Q (Telegram kabi)
///  - Waveform barlariga bosib yoki siljitib seek ishlaydi
///  - Seek qilganda qotib qolmaydi (_wasPlayingBeforeSeek logikasi)
class ChatVoiceBubbleWidget extends StatefulWidget {
  final ChatMessageWorker message;

  const ChatVoiceBubbleWidget({
    super.key,
    required this.message,
  });

  @override
  State<ChatVoiceBubbleWidget> createState() => _ChatVoiceBubbleWidgetState();
}

class _ChatVoiceBubbleWidgetState extends State<ChatVoiceBubbleWidget>
    with TickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();

  bool _isPlaying = false;
  double _progress = 0.0;
  int _currentSec = 0;

  // Seek uchun flag'lar
  bool _isSeeking = false;
  bool _wasPlayingBeforeSeek = false;

  late final AnimationController _waveCtrl;
  late final List<double> _barHeights;

  static final Random _rng = Random(42);

  @override
  void initState() {
    super.initState();

    // 36 ta bar — o'rtada balandroq (Telegram shakli)
    _barHeights = List.generate(36, (i) {
      final pos = i / 35.0;
      final envelope = sin(pos * pi).clamp(0.3, 1.0);
      return (0.2 + _rng.nextDouble() * 0.8) * envelope;
    });

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _player.setPlayerMode(PlayerMode.mediaPlayer);

    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      final playing = state == PlayerState.playing;
      setState(() => _isPlaying = playing);
      if (playing) {
        _waveCtrl.repeat(reverse: true);
      } else {
        _waveCtrl.stop();
        _waveCtrl.animateTo(0.6);
      }
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
      _waveCtrl.stop();
      _waveCtrl.reset();
    });
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _player.dispose();
    super.dispose();
  }

  // ── Play / Pause ──────────────────────────────────────────────────────────
  Future<void> _togglePlay() async {
    final path = widget.message.audioPath;
    if (path == null || !File(path).existsSync()) return;

    if (_isPlaying) {
      await _player.pause();
    } else {
      if (_progress > 0 && _progress < 1.0) {
        await _player.resume();
      } else {
        setState(() {
          _progress = 0.0;
          _currentSec = 0;
        });
        await _player.setAudioContext(_audioCtx());
        await _player.play(DeviceFileSource(path));
      }
    }
  }

  AudioContext _audioCtx() => AudioContext(
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
  );

  // ── Seek boshlanishi ──────────────────────────────────────────────────────
  void _seekStart() {
    if (_isSeeking) return;
    _wasPlayingBeforeSeek = _isPlaying;
    _isSeeking = true;
    // Seek qilayotganda to'xtatamiz (qotib qolmasligi uchun)
    if (_isPlaying) _player.pause();
  }

  // ── Seek davomida ─────────────────────────────────────────────────────────
  void _seekUpdate(double fraction) {
    final total = widget.message.audioDuration ?? 0;
    setState(() {
      _progress = fraction.clamp(0.0, 1.0);
      _currentSec = (fraction * total).round().clamp(0, total);
    });
  }

  // ── Seek tugashi ──────────────────────────────────────────────────────────
  Future<void> _seekEnd() async {
    if (!_isSeeking) return;
    setState(() => _isSeeking = false);

    final total = widget.message.audioDuration ?? 0;
    if (total <= 0) return;

    final path = widget.message.audioPath;
    if (path == null || !File(path).existsSync()) return;

    final seekDuration = Duration(
      milliseconds: (_progress * total * 1000).round(),
    );

    if (_wasPlayingBeforeSeek) {
      // Avval o'ynayotgan edi — seek + resume
      await _player.seek(seekDuration);
      await _player.resume();
    } else {
      // O'ynayotmagan edi — o'sha pozitsiyadan play
      await _player.setAudioContext(_audioCtx());
      await _player.play(DeviceFileSource(path));
      await _player.seek(seekDuration);
    }
  }

  // ── Formatlar ─────────────────────────────────────────────────────────────
  String _fmtDuration(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  // ════════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.isMe;
    final duration = widget.message.audioDuration ?? 0;

    final bubbleColor =
    isMe ? const Color(0xff9859EF) : const Color(0xFFF1F1F1);
    final playBtnColor = isMe ? Colors.white : const Color(0xff9859EF);
    final playIconColor = isMe ? const Color(0xff9859EF) : Colors.white;
    final activeBarColor = isMe ? Colors.white : const Color(0xff9859EF);
    final inactiveBarColor = isMe
        ? Colors.white.withOpacity(0.35)
        : const Color(0xff9859EF).withOpacity(0.25);
    final timeColor = isMe ? Colors.white.withOpacity(0.90) : Colors.black54;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // ── Bubble ───────────────────────────────────────────────────
            Container(
              width: 265.w,
              padding: EdgeInsets.fromLTRB(10.w, 10.h, 12.w, 10.h),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: (isMe ? const Color(0xff9859EF) : Colors.black)
                        .withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // ── Play / Pause ────────────────────────────────────
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      width: 42.w,
                      height: 42.w,
                      decoration: BoxDecoration(
                        color: playBtnColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          key: ValueKey(_isPlaying),
                          size: 24,
                          color: playIconColor,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 10.w),

                  Expanded(
                    child: LayoutBuilder(
                      builder: (ctx, constraints) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          // Tap (bir marta bosish)
                          onTapDown: (d) {
                            final frac =
                            (d.localPosition.dx / constraints.maxWidth)
                                .clamp(0.0, 1.0);
                            _seekStart();
                            _seekUpdate(frac);
                          },
                          onTapUp: (_) => _seekEnd(),
                          onTapCancel: () => _seekEnd(),
                          // Drag (siljitib seek)
                          onHorizontalDragStart: (_) => _seekStart(),
                          onHorizontalDragUpdate: (d) {
                            final frac =
                            (d.localPosition.dx / constraints.maxWidth)
                                .clamp(0.0, 1.0);
                            _seekUpdate(frac);
                          },
                          onHorizontalDragEnd: (_) => _seekEnd(),
                          onHorizontalDragCancel: () => _seekEnd(),
                          child: SizedBox(
                            height: 40.h,
                            child: AnimatedBuilder(
                              animation: _waveCtrl,
                              builder: (_, __) => CustomPaint(
                                size: Size(constraints.maxWidth, 40.h),
                                painter: _WaveformPainter(
                                  barHeights: _barHeights,
                                  progress: _progress,
                                  activeColor: activeBarColor,
                                  inactiveColor: inactiveBarColor,
                                  animValue: _waveCtrl.value,
                                  isPlaying: _isPlaying,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(width: 8.w),

                  SizedBox(
                    width: 32.w,
                    child: Text(
                      (_isPlaying || _isSeeking) && _currentSec > 0
                          ? _fmtDuration(_currentSec)
                          : _fmtDuration(duration),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: timeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 3.h, left: 4.w, right: 4.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic_rounded,
                      size: 12, color: Colors.grey.shade500),
                  SizedBox(width: 3.w),
                  Text(
                    _fmtTime(widget.message.createdAt),
                    style: TextStyle(
                        fontSize: 11.sp, color: Colors.grey.shade500),
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

class _WaveformPainter extends CustomPainter {
  final List<double> barHeights;
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  final double animValue;
  final bool isPlaying;

  const _WaveformPainter({
    required this.barHeights,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    required this.animValue,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final count = barHeights.length;
    if (count == 0 || size.width == 0) return;

    const gap = 2.5;
    final barW = (size.width - gap * (count - 1)) / count;
    final activeCount = (progress * count).round().clamp(0, count);

    for (int i = 0; i < count; i++) {
      final isActive = i < activeCount;

      double h = barHeights[i];
      // Aktiv barlarning oxirgi 4 tasi yengil pulslanadi
      if (isPlaying && isActive && i >= activeCount - 4) {
        h = (h * (0.78 + animValue * 0.44)).clamp(0.0, 1.0);
      }

      final barH = (h * size.height).clamp(3.0, size.height);
      final x = i * (barW + gap);
      final top = (size.height - barH) / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, top, barW, barH),
          Radius.circular(barW / 2),
        ),
        Paint()
          ..color = isActive ? activeColor : inactiveColor
          ..style = PaintingStyle.fill
          ..isAntiAlias = true,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.progress != progress ||
          old.animValue != animValue ||
          old.isPlaying != isPlaying;
}