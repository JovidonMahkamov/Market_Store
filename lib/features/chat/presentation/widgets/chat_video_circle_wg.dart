import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'chat_message_worker.dart';

class ChatVideoCircleWidget extends StatefulWidget {
  final ChatMessageWorker message;

  const ChatVideoCircleWidget({super.key, required this.message});

  @override
  State<ChatVideoCircleWidget> createState() => _ChatVideoCircleWidgetState();
}

class _ChatVideoCircleWidgetState extends State<ChatVideoCircleWidget>
    with TickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  double _progress = 0.0;

  // Pulse ring uchun (tashqi halqa)
  late final AnimationController _pulseCtrl;

  // Avatar o'zi kattalashib-kichrayishi uchun
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    // Tashqi pulse halqa animatsiyasi
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Avatar scale animatsiyasi: 1.0 → 1.12 → 1.0 (yumshoq)
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOutBack),
    );

    _initVideo();
  }

  Future<void> _initVideo() async {
    final path = widget.message.videoPath;
    if (path == null) return;

    final file = File(path);
    if (!file.existsSync()) {
      debugPrint('Video fayl topilmadi: $path');
      return;
    }

    final ctrl = VideoPlayerController.file(file);
    await ctrl.initialize();

    if (!mounted) {
      ctrl.dispose();
      return;
    }

    ctrl.addListener(() {
      if (!mounted) return;

      final duration = ctrl.value.duration.inMilliseconds;
      final pos = ctrl.value.position.inMilliseconds;
      final playing = ctrl.value.isPlaying;
      final newProgress = duration > 0 ? (pos / duration).clamp(0.0, 1.0) : 0.0;

      setState(() {
        _isPlaying = playing;
        _progress = newProgress;
      });

      if (playing) {
        // Video o'ynayotganda: avatar kattalashadi + pulse ishlaydi
        if (!_scaleCtrl.isCompleted) _scaleCtrl.forward();
        if (!_pulseCtrl.isAnimating) _pulseCtrl.repeat(reverse: true);
      } else {
        // Video to'xtaganda yoki tugaganda: avatar kichrayadi + pulse to'xtaydi
        _scaleCtrl.reverse();
        _pulseCtrl.stop();

        // Video oxiriga yetganda reset
        if (newProgress >= 0.99) {
          ctrl.seekTo(Duration.zero);
          setState(() => _progress = 0.0);
          _pulseCtrl.reset();
        }
      }
    });

    setState(() {
      _controller = ctrl;
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _scaleCtrl.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    final ctrl = _controller;
    if (ctrl == null || !_isInitialized) return;

    if (ctrl.value.isPlaying) {
      await ctrl.pause();
    } else {
      await ctrl.play();
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.isMe;
    final ctrl = _controller;
    final size = 100.w;

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
              // ✅ Butun avatar scale animatsiyasi
              child: AnimatedBuilder(
                animation: _scaleAnim,
                builder: (_, child) => Transform.scale(
                  scale: _scaleAnim.value,
                  child: child,
                ),
                child: SizedBox(
                  width: size + 24.w,
                  height: size + 24.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // ── Pulse ring (o'ynatilayotganda tashqarida yiltillab turadi)
                      AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, __) => Container(
                          width: size + 18.w + _pulseCtrl.value * 6.w,
                          height: size + 18.w + _pulseCtrl.value * 6.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.purple.withOpacity(
                                0.5 * (1 - _pulseCtrl.value),
                              ),
                              width: 2.5,
                            ),
                          ),
                        ),
                      ),

                      // ── Progress ring (doira bo'ylab progress)
                      SizedBox(
                        width: size + 10.w,
                        height: size + 10.w,
                        child: CircularProgressIndicator(
                          value: _progress,
                          strokeWidth: 3.5,
                          backgroundColor: Colors.purple.withOpacity(0.15),
                          color: Colors.purple,
                        ),
                      ),

                      // ── Video yoki loading
                      ClipOval(
                        child: SizedBox(
                          width: size,
                          height: size,
                          child: _isInitialized && ctrl != null
                              ? FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: ctrl.value.size.width,
                              height: ctrl.value.size.height,
                              child: VideoPlayer(ctrl),
                            ),
                          )
                              : Container(
                            color: Colors.black87,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── Play overlay (faqat pauza paytida)
                      if (!_isPlaying)
                        Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.35),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Duration va vaqt
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.videocam_outlined, size: 11, color: Colors.grey),
                  SizedBox(width: 3.w),
                  Text(
                    _isInitialized && ctrl != null
                        ? _fmt(ctrl.value.duration)
                        : '0:00',
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