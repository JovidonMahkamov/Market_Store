// lib/features/chat/presentation/widgets/chat_video_circle_wg.dart

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

class _ChatVideoCircleWidgetState extends State<ChatVideoCircleWidget> {
  VideoPlayerController? _thumbController;
  bool _isThumbInitialized = false;

  @override
  void initState() {
    super.initState();
    _initThumb();
  }

  Future<void> _initThumb() async {
    final path = widget.message.videoPath;
    if (path == null || !File(path).existsSync()) return;

    final ctrl = VideoPlayerController.file(File(path));
    await ctrl.initialize();
    if (!mounted) {
      ctrl.dispose();
      return;
    }
    // Birinchi kadrni ko'rsatish uchun faqat init — play qilmaymiz
    setState(() {
      _thumbController = ctrl;
      _isThumbInitialized = true;
    });
  }

  @override
  void dispose() {
    _thumbController?.dispose();
    super.dispose();
  }

  void _openFullScreen() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => _FullScreenVideoPlayer(
          videoPath: widget.message.videoPath!,
          createdAt: widget.message.createdAt,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.isMe;
    const smallSize = 100.0; // kichik preview

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Kichik dumaloq preview
            GestureDetector(
              onTap: () {
                if (widget.message.videoPath != null) _openFullScreen();
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Video preview (birinchi kadr)
                  ClipOval(
                    child: SizedBox(
                      width: smallSize,
                      height: smallSize,
                      child: _isThumbInitialized && _thumbController != null
                          ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _thumbController!.value.size.width,
                          height: _thumbController!.value.size.height,
                          child: VideoPlayer(_thumbController!),
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

                  // Play overlay
                  Container(
                    width: smallSize,
                    height: smallSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),

            // Vaqt
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.videocam_outlined, size: 11, color: Colors.grey),
                SizedBox(width: 3.w),
                Text(
                  _fmtTime(widget.message.createdAt),
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Full Screen Video Player ──────────────────────────────────────────────
class _FullScreenVideoPlayer extends StatefulWidget {
  final String videoPath;
  final DateTime createdAt;

  const _FullScreenVideoPlayer({
    required this.videoPath,
    required this.createdAt,
  });

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer>
    with TickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  double _progress = 0.0;
  bool _isSeeking = false;
  bool _showControls = true;

  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _initVideo();
  }

  Future<void> _initVideo() async {
    final file = File(widget.videoPath);
    if (!file.existsSync()) return;

    final ctrl = VideoPlayerController.file(file);
    await ctrl.initialize();
    if (!mounted) {
      ctrl.dispose();
      return;
    }

    ctrl.addListener(() {
      if (!mounted || _isSeeking) return;
      final dur = ctrl.value.duration.inMilliseconds;
      final pos = ctrl.value.position.inMilliseconds;
      final playing = ctrl.value.isPlaying;
      final prog = dur > 0 ? (pos / dur).clamp(0.0, 1.0) : 0.0;

      setState(() {
        _isPlaying = playing;
        _progress = prog;
      });

      if (playing) {
        if (!_pulseCtrl.isAnimating) _pulseCtrl.repeat(reverse: true);
      } else {
        _pulseCtrl.stop();
        if (prog >= 0.99) {
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
    // Auto play ochilganda
    await ctrl.play();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
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
    setState(() => _showControls = true);
  }

  Future<void> _seekTo(double fraction) async {
    final ctrl = _controller;
    if (ctrl == null || !_isInitialized) return;
    setState(() {
      _isSeeking = true;
      _progress = fraction;
    });
    await ctrl.seekTo(ctrl.value.duration * fraction);
    setState(() => _isSeeking = false);
    if (!ctrl.value.isPlaying) await ctrl.play();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _controller;
    final screenW = MediaQuery.of(context).size.width;
    final bigSize = screenW * 0.82;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: GestureDetector(
            onTap: () => setState(() => _showControls = !_showControls),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Katta dumaloq video
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, child) => Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulse ring
                      Container(
                        width: bigSize + 22 + _pulseCtrl.value * 8,
                        height: bigSize + 22 + _pulseCtrl.value * 8,
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

                      // Progress ring
                      SizedBox(
                        width: bigSize + 12,
                        height: bigSize + 12,
                        child: CircularProgressIndicator(
                          value: _progress,
                          strokeWidth: 4.0,
                          backgroundColor: Colors.purple.withOpacity(0.15),
                          color: Colors.purple,
                        ),
                      ),

                      // Video content
                      ClipOval(
                        child: SizedBox(
                          width: bigSize,
                          height: bigSize,
                          child: _isInitialized && ctrl != null
                              ? GestureDetector(
                            onTap: _togglePlay,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: ctrl.value.size.width,
                                height: ctrl.value.size.height,
                                child: VideoPlayer(ctrl),
                              ),
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

                      // Controls overlay
                      if (_showControls && _isInitialized)
                        GestureDetector(
                          onTap: _togglePlay,
                          child: Container(
                            width: bigSize,
                            height: bigSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.3),
                            ),
                            child: Icon(
                              _isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 64,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Seek slider
                if (_isInitialized && ctrl != null)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14),
                            activeTrackColor: Colors.purple,
                            inactiveTrackColor: Colors.white30,
                            thumbColor: Colors.white,
                            overlayColor: Colors.purple.withOpacity(0.2),
                          ),
                          child: Slider(
                            value: _progress,
                            onChangeStart: (_) =>
                                setState(() => _isSeeking = true),
                            onChanged: (v) => setState(() => _progress = v),
                            onChangeEnd: (v) => _seekTo(v),
                          ),
                        ),

                        // Vaqt ko'rsatkichi
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _fmt(ctrl.value.position),
                                style: TextStyle(
                                    fontSize: 12.sp, color: Colors.white70),
                              ),
                              Text(
                                _fmt(ctrl.value.duration),
                                style: TextStyle(
                                    fontSize: 12.sp, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 12.h),

                // Yopish tugmasi
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Yopish',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}