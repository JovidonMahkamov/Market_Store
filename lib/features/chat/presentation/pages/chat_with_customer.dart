import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_store/features/chat/presentation/widgets/chat_video_circle_wg.dart';
import 'package:market_store/features/chat/presentation/widgets/chat_voice_bubble_wg.dart';
import 'package:market_store/features/chat/presentation/widgets/chat_voice_circle_wg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/widgets/back_widget.dart';
import '../widgets/chat_bubble_worker_widget.dart';
import '../widgets/chat_location_bubble.dart';
import '../widgets/chat_message_worker.dart';

class ChatWithCustomerPage extends StatefulWidget {
  final String name;
  final String? imageUrl;

  const ChatWithCustomerPage({
    super.key,
    required this.name,
    this.imageUrl,
  });

  @override
  State<ChatWithCustomerPage> createState() => _ChatWithCustomerPageState();
}

class _ChatWithCustomerPageState extends State<ChatWithCustomerPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _controller = TextEditingController();

  bool _autoScroll = true;
  bool _isSelectionMode = false;
  final Set<int> _selectedIndexes = {};
  bool _showPlusMenu = false;
  bool _isLoadingLocation = false;
  bool _hasText = false;
  bool _isVideoMode = false;

  final RecorderController _recCtrl = RecorderController();
  bool _isRecording = false;
  bool _isCancelled = false;
  int _recSeconds = 0;

  double _dragOffset = 0.0;
  static const double _cancelThreshold = 80.0;

  double _lockDragUp = 0.0;
  static const double _lockThreshold = 60.0;
  bool _isLocked = false;

  double _micButtonScale = 1.0;

  final Stopwatch _recTimer = Stopwatch();
  int _prevTick = 0;

  late final AnimationController _micPulseCtrl;

  static const _appBarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF3EEFF), Color(0xFFD9C8FF)],
  );

  final List<ChatMessageWorker> _messages = [
    ChatMessageWorker(
      id: '1',
      text: 'product_card',
      createdAt: DateTime(2026, 4, 12, 20, 30),
      isMe: false,
      type: MessageType.productCard,
    ),
    ChatMessageWorker(
      id: '2',
      text: 'Assalomu alaykum, yaxshimisiz?',
      createdAt: DateTime(2026, 4, 12, 20, 31),
      isMe: true,
    ),
    ChatMessageWorker(
      id: '3',
      text: "Vaaleykum assalom, xa rahmat.\nO'ziz ham yaxshimisiz?",
      createdAt: DateTime(2026, 4, 12, 20, 32),
      isMe: false,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _micPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });

    _scrollCtrl.addListener(() {
      if (!_scrollCtrl.hasClients) return;
      final dist = _scrollCtrl.position.maxScrollExtent - _scrollCtrl.offset;
      _autoScroll = dist < 80.0;
    });

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToBottom(animated: false));
  }

  @override
  void dispose() {
    _micPulseCtrl.dispose();
    _recCtrl.dispose();
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollCtrl.hasClients) return;
    final target = _scrollCtrl.position.maxScrollExtent;
    animated
        ? _scrollCtrl.animateTo(target,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut)
        : _scrollCtrl.jumpTo(target);
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recCtrl.checkPermission();
    if (!hasPermission) {
      _showSnackBar("Mikrofon ruxsati berilmadi");
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recCtrl.record(path: path);

    setState(() {
      _isRecording = true;
      _isCancelled = false;
      _recSeconds = 0;
      _dragOffset = 0.0;
      _lockDragUp = 0.0;
      _isLocked = false;
      _micButtonScale = 1.3;
    });

    _micPulseCtrl.repeat(reverse: true);
    _recTimer.reset();
    _recTimer.start();
    _prevTick = 0;

    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!_isRecording) return false;
      final elapsed = _recTimer.elapsed.inSeconds;
      if (elapsed != _prevTick) {
        _prevTick = elapsed;
        if (mounted) setState(() => _recSeconds = elapsed);
      }
      return _isRecording;
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    _recTimer.stop();
    _micPulseCtrl.stop();
    _micPulseCtrl.reset();

    final path = await _recCtrl.stop();
    setState(() {
      _isRecording = false;
      _micButtonScale = 1.0;
      _isLocked = false;
      _lockDragUp = 0.0;
    });

    if (_isCancelled || path == null) {
      if (path != null) {
        try {
          File(path).deleteSync();
        } catch (_) {}
      }
      setState(() {
        _isCancelled = false;
        _dragOffset = 0.0;
        _recSeconds = 0;
        _micButtonScale = 1.0;
        _isLocked = false;
        _lockDragUp = 0.0;
      });
      return;
    }

    if (!File(path).existsSync()) {
      _showSnackBar("Audio fayl saqlanmadi, qaytadan urining");
      setState(() {
        _dragOffset = 0.0;
        _recSeconds = 0;
      });
      return;
    }

    final duration = _recSeconds < 1 ? 1 : _recSeconds;

    setState(() {
      _messages.add(ChatMessageWorker(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: '',
        createdAt: DateTime.now(),
        isMe: true,
        type: MessageType.voice,
        audioPath: path,
        audioDuration: duration,
      ));
      _dragOffset = 0.0;
      _recSeconds = 0;
      _micButtonScale = 1.0;
      _isLocked = false;
      _lockDragUp = 0.0;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _cancelRecording() {
    setState(() => _isCancelled = true);
    _stopRecording();
  }

  Future<void> _recordVideo() async {
    final picker = ImagePicker();
    try {
      final xfile = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 60),
      );
      if (xfile == null) return;
      if (!File(xfile.path).existsSync()) {
        _showSnackBar("Video saqlanmadi, qaytadan urining");
        return;
      }
      setState(() {
        _messages.add(ChatMessageWorker(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: '',
          createdAt: DateTime.now(),
          isMe: true,
          type: MessageType.videoCircle,
          videoPath: xfile.path,
        ));
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      _showSnackBar("Video yozishda xatolik: $e");
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessageWorker(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        createdAt: DateTime.now(),
        isMe: true,
      ));
      _showPlusMenu = false;
    });
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _sendLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar("GPS o'chiq.");
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        _showSnackBar("Lokatsiya ruxsati berilmadi.");
        return;
      }
    }

    if (perm == LocationPermission.deniedForever) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => _confirmDialog(
          title: "Ruxsat kerak",
          content: "Ilovalar sozlamasidan lokatsiya ruxsatini bering.",
          confirmLabel: "Sozlamalar",
        ),
      );
      if (ok == true) await Geolocator.openAppSettings();
      return;
    }

    setState(() => _isLoadingLocation = true);
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessageWorker(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: '',
          createdAt: DateTime.now(),
          isMe: true,
          type: MessageType.location,
          latitude: pos.latitude,
          longitude: pos.longitude,
        ));
        _showPlusMenu = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (_) {
      if (!mounted) return;
      _showSnackBar("Lokatsiya aniqlanmadi.");
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _showSnackBar(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _makePhoneCall(String number) async {
    final uri = Uri.parse("tel:$number");
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _deleteMessage(int i) => setState(() => _messages.removeAt(i));

  void _editMessage(int i) {
    final msg = _messages[i];
    _controller.text = msg.text;
    _controller.selection =
        TextSelection.fromPosition(TextPosition(offset: msg.text.length));
    setState(() => _messages.removeAt(i));
  }

  void _toggleSelectMessage(int i) {
    setState(() {
      _selectedIndexes.contains(i)
          ? _selectedIndexes.remove(i)
          : _selectedIndexes.add(i);
      if (_selectedIndexes.isEmpty) _isSelectionMode = false;
    });
  }

  void _clearSelection() => setState(() {
    _selectedIndexes.clear();
    _isSelectionMode = false;
  });

  Future<void> _deleteSelectedMessages() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _confirmDialog(
        title: "Xabarlarni o'chirish",
        content: "${_selectedIndexes.length} ta xabarni o'chirmoqchimisiz?",
        confirmLabel: "O'chirish",
      ),
    );
    if (ok != true) return;
    setState(() {
      final sorted = _selectedIndexes.toList()..sort((a, b) => b.compareTo(a));
      for (final i in sorted) {
        if (i >= 0 && i < _messages.length) _messages.removeAt(i);
      }
      _clearSelection();
    });
  }

  Future<void> _clearHistory() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _confirmDialog(
        title: 'Tarixni tozalash',
        content: "Barcha xabarlar o'chiriladi.",
        confirmLabel: 'Tozalash',
      ),
    );
    if (ok == true) setState(() => _messages.clear());
  }

  Future<void> _deleteChat() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _confirmDialog(
        title: "Chatni o'chirish",
        content: "Bu chatni o'chirmoqchimisiz?",
        confirmLabel: "O'chirish",
      ),
    );
    if (ok == true && mounted) Navigator.pop(context);
  }

  void _showTapMenu(int index, Offset position, bool isMe) {
    if (_isSelectionMode) {
      _toggleSelectMessage(index);
      return;
    }
    final msg = _messages[index];
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx - 100, position.dy - 10, position.dx, position.dy),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      items: [
        if (isMe)
          const PopupMenuItem(
            value: 'edit',
            child: Row(children: [
              Icon(Icons.edit_outlined, color: Colors.purple),
              SizedBox(width: 10),
              Text('Tahrirlash'),
            ]),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(IconlyLight.delete, color: AppColors.error),
            SizedBox(width: 10),
            Text("O'chirish", style: TextStyle(color: AppColors.error)),
          ]),
        ),
        const PopupMenuItem(
          value: 'copy',
          child: Row(children: [
            Icon(Icons.copy_outlined, color: Colors.purple),
            SizedBox(width: 10),
            Text('Nusxa olish'),
          ]),
        ),
      ],
    ).then((v) {
      if (v == 'edit' && isMe) _editMessage(index);
      if (v == 'delete') _deleteMessage(index);
      if (v == 'copy') {
        Clipboard.setData(ClipboardData(text: msg.text));
        _showSnackBar("Nusxa olindi");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems();
    return GestureDetector(
      onTap: () {
        if (_showPlusMenu) setState(() => _showPlusMenu = false);
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollCtrl,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 8.h),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        if (item['type'] == 'date_header') {
                          return _buildDateHeader(item['date']);
                        }
                        return _buildMessageRow(
                          msg: item['msg'],
                          index: item['index'],
                          isSelected: _selectedIndexes.contains(item['index']),
                        );
                      },
                    ),
                  ),
                  if (_isLoadingLocation)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2,
                                color: Colors.purple),
                          ),
                          SizedBox(width: 8.w),
                          Text("Lokatsiya aniqlanmoqda...",
                              style: TextStyle(fontSize: 13.sp,
                                  color: Colors.grey)),
                        ],
                      ),
                    ),
                  if (_showPlusMenu) _buildPlusMenu(),
                  _buildInput(),
                ],
              ),

              if (_isRecording)
                Positioned(
                  right: 10.w,
                  bottom: 66.h,
                  child: _buildLockIndicator(),
                ),
            ],
          ),
        ),),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace:
      Container(decoration: const BoxDecoration(gradient: _appBarGradient)),
      title: Row(
        children: [
          if (_isSelectionMode)
            GestureDetector(
              onTap: _clearSelection,
              child: Container(
                margin: EdgeInsets.only(right: 8.w),
                padding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                height: 40.h,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.close, color: Colors.purple, size: 22),
                  SizedBox(width: 8.w),
                  Text('${_selectedIndexes.length}',
                      style: const TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.w700,
                          fontSize: 18)),
                ]),
              ),
            )
          else
            GestureDetector(
                onTap: () => Navigator.pop(context), child: BackWidget()),
          SizedBox(width: 10.w),
          if (!_isSelectionMode)
            Expanded(
              child: Text(widget.name,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkGrey,
                      fontSize: 20),
                  overflow: TextOverflow.ellipsis),
            ),
        ],
      ),
      actions: [
        if (!_isSelectionMode)
          Container(
            margin: EdgeInsets.only(right: 8.w),
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.phone_outlined,
                  color: Colors.purple, size: 20),
              onPressed: () => _makePhoneCall("+998900000000"),
            ),
          ),
        if (_isSelectionMode)
          Container(
            margin: EdgeInsets.only(right: 12.w),
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(IconlyLight.delete,
                  color: Colors.purple, size: 22),
              onPressed:
              _selectedIndexes.isEmpty ? null : _deleteSelectedMessages,
            ),
          ),
        if (!_isSelectionMode)
          Container(
            margin: EdgeInsets.only(right: 12.w),
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert,
                  color: AppColors.purple, size: 22),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r)),
              color: Colors.white,
              elevation: 8,
              offset: const Offset(0, 50),
              onSelected: (v) {
                if (v == 'mute')
                  _showSnackBar("Bildirishnomalar o'chirildi");
                if (v == 'clear') _clearHistory();
                if (v == 'delete') _deleteChat();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'mute',
                  child: Row(children: [
                    Icon(Icons.notifications_off_outlined,
                        color: AppColors.error, size: 18),
                    SizedBox(width: 10.w),
                    Text("Bildirishnomalarni o'chirish",
                        style: TextStyle(
                            fontSize: 15, color: AppColors.error)),
                  ]),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: Row(children: [
                    SvgPicture.asset("assets/home/clear.svg",
                        colorFilter: const ColorFilter.mode(
                            AppColors.darkGrey, BlendMode.srcIn)),
                    SizedBox(width: 10.w),
                    Text("Tarixni tozalash",
                        style: TextStyle(
                            fontSize: 15, color: AppColors.darkGrey)),
                  ]),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    const Icon(IconlyLight.delete,
                        color: AppColors.darkGrey, size: 18),
                    SizedBox(width: 10.w),
                    Text("Chatni o'chirish",
                        style: TextStyle(
                            fontSize: 15, color: AppColors.darkGrey)),
                  ]),
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<dynamic> _buildItems() {
    final items = <dynamic>[];
    String? lastDate;
    for (int i = 0; i < _messages.length; i++) {
      final msg = _messages[i];
      final dateStr = _formatDate(msg.createdAt);
      if (dateStr != lastDate) {
        items.add({'type': 'date_header', 'date': dateStr});
        lastDate = dateStr;
      }
      items.add({'type': 'message', 'index': i, 'msg': msg});
    }
    return items;
  }

  Widget _buildDateHeader(String date) => Padding(
    padding: EdgeInsets.symmetric(vertical: 12.h),
    child: Center(
      child: Text(date,
          style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w500)),
    ),
  );

  Widget _buildMessageRow({
    required ChatMessageWorker msg,
    required int index,
    required bool isSelected,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isSelectionMode)
          GestureDetector(
            onTap: () => _toggleSelectMessage(index),
            child: Padding(
              padding: EdgeInsets.only(top: 10.h, right: 6.w),
              child: Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.purple : Colors.white,
                  border: Border.all(
                      color: Colors.purple.withOpacity(0.5), width: 1.5),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
          ),
        Expanded(
          child: Column(
            children: [
              if (msg.isLocation)
                ChatLocationBubble(
                    latitude: msg.latitude!,
                    longitude: msg.longitude!,
                    isMe: msg.isMe)
              else if (msg.isProductCard)
                _buildProductCard(msg)
              else if (msg.isVoiceCircle)
                  ChatVoiceCircleWidget(message: msg)
                else if (msg.isVideoCircle)
                    ChatVideoCircleWidget(message: msg)
                  else if (msg.isVoice)
                      ChatVoiceBubbleWidget(message: msg)
                    else
                      ChatBubbleWorkerWidget(
                        message: msg,
                        isSelectionMode: _isSelectionMode,
                        isSelected: isSelected,
                        onDelete: () => _deleteMessage(index),
                        onEdit: () => _editMessage(index),
                        onCopy: () {
                          Clipboard.setData(ClipboardData(text: msg.text));
                          _showSnackBar("Nusxa olindi");
                        },
                        onShowMenu: (pos, isMe) => _showTapMenu(index, pos, isMe),
                        onTapMenu: (pos, isMe) => _showTapMenu(index, pos, isMe),
                        onEnterSelectionMode: () => setState(() {
                          _isSelectionMode = true;
                          _selectedIndexes.add(index);
                        }),
                        onToggleSelect: () => _toggleSelectMessage(index),
                      ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!_isRecording)
            GestureDetector(
              onTap: () => setState(() => _showPlusMenu = !_showPlusMenu),
              child: Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.purple.withOpacity(0.5), width: 1.5),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.add,
                    color: Colors.purple.withOpacity(0.8), size: 22),
              ),
            ),

          if (!_isRecording) SizedBox(width: 8.w),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isRecording
                  ? _buildRecordingBar()
                  : _buildTextFieldBox(),
            ),
          ),

          SizedBox(width: 8.w),

          if (_hasText && !_isRecording)
            _buildSendButton()
          else if (_isLocked)
            _buildLockedSendButton()
          else
            _buildMicVideoButton(),
        ],
      ),
    );
  }

  Widget _buildTextFieldBox() {
    return Container(
      key: const ValueKey('textfield'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.purple.withOpacity(0.2), width: 1),
      ),
      child: TextField(
        maxLines: 5,
        minLines: 1,
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Xabar yozing',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
          border: InputBorder.none,
          contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        ),
      ),
    );
  }

  Widget _buildRecordingBar() {
    final cancelOpacity =
    (1.0 - (_dragOffset / _cancelThreshold)).clamp(0.3, 1.0);
    final lockProgress = (_lockDragUp / _lockThreshold).clamp(0.0, 1.0);

    return GestureDetector(
      key: const ValueKey('recording'),
      onHorizontalDragUpdate: (d) {
        if (_isLocked) return;
        if (d.delta.dx < 0) {
          setState(() => _dragOffset -= d.delta.dx.abs());
          if (_dragOffset >= _cancelThreshold) _cancelRecording();
        }
      },
      child: Container(
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.purple.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _micPulseCtrl,
              builder: (_, __) => Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red
                      .withOpacity(0.5 + _micPulseCtrl.value * 0.5),
                ),
              ),
            ),

            SizedBox(width: 6.w),

            Text(
              _fmtSecs(_recSeconds),
              style:
              TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
            ),

            SizedBox(width: 8.w),

            Expanded(
              child: AudioWaveforms(
                recorderController: _recCtrl,
                size: Size(double.infinity, 28.h),
                waveStyle: WaveStyle(
                  waveColor: Colors.purple,
                  extendWaveform: true,
                  showMiddleLine: false,
                  spacing: 4,
                  waveThickness: 2.5,
                ),
              ),
            ),

            SizedBox(width: 6.w),

            if (_isLocked)
              GestureDetector(
                onTap: _cancelRecording,
                child:
                Icon(Icons.close, size: 24, color: Colors.red.shade400),
              )
            else
              Opacity(
                opacity: cancelOpacity,
                child: GestureDetector(
                  onTap: _cancelRecording,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios,
                          size: 11, color: Colors.grey.shade500),
                      Text(
                        ' Bekor qilish',
                        style: TextStyle(
                            fontSize: 11.sp, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: _send,
      child: Container(
        width: 46.w,
        height: 46.w,
        decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.circular(14.r)),
        child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildLockIndicator() {
    final lockProgress = (_lockDragUp / _lockThreshold).clamp(0.0, 1.0);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: lockProgress > 0 || _isLocked ? 1.0 : 0.0,
      child: Container(
        width: 46.w,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isLocked ? Icons.lock : Icons.lock_open,
              size: 22,
              color: Color.lerp(
                Colors.grey.shade400,
                Colors.purple,
                _isLocked ? 1.0 : lockProgress,
              ),
            ),
            SizedBox(height: 6.h),
            Icon(
              Icons.keyboard_arrow_up,
              size: 18,
              color: Color.lerp(
                Colors.grey.shade300,
                Colors.purple,
                _isLocked ? 1.0 : lockProgress,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedSendButton() {
    return GestureDetector(
      onTap: _stopRecording,
      child: Container(
        width: 46.w,
        height: 46.w,
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildMicVideoButton() {
    return SizedBox(
      width: 46.w,
      height: 46.h,
      child: GestureDetector(
        onTap: _isRecording
            ? null
            : () => setState(() => _isVideoMode = !_isVideoMode),
        onLongPressStart: (_) async {
          if (_isVideoMode) {
            _recordVideo();
          } else {
            await _startRecording();
          }
        },
        onLongPressMoveUpdate: (details) {
          if (!_isRecording || _isLocked) return;
          final dy = details.offsetFromOrigin.dy;
          final dx = details.offsetFromOrigin.dx;

          if (dy < 0) {
            final upAmount = (-dy).clamp(0.0, _lockThreshold);
            setState(() => _lockDragUp = upAmount);
            if (upAmount >= _lockThreshold && !_isLocked) {
              setState(() => _isLocked = true);
              HapticFeedback.mediumImpact();
            }
          } else {
            setState(() => _lockDragUp = 0.0);
          }

          if (dx < 0 && !_isLocked) {
            final leftAmount = (-dx).clamp(0.0, _cancelThreshold + 10);
            setState(() => _dragOffset = leftAmount);
            if (leftAmount >= _cancelThreshold) _cancelRecording();
          }
        },
        onLongPressEnd: (_) {
          if (!_isVideoMode && !_isLocked) _stopRecording();
        },
        onLongPressCancel: () {
          if (!_isVideoMode && !_isLocked) _stopRecording();
        },
        child: AnimatedBuilder(
          animation: _micPulseCtrl,
          builder: (_, __) {
            final pulseScale = _isRecording ? 1.0 + _micPulseCtrl.value * 0.08 : 1.0;
            final totalScale = _micButtonScale * pulseScale;
            return AnimatedScale(
              scale: totalScale,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.red : Colors.purple,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: _isRecording
                      ? [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3 + _micPulseCtrl.value * 0.3),
                      blurRadius: 14,
                      spreadRadius: 3,
                    ),
                  ]
                      : null,
                ),
                child: Icon(
                  _isRecording
                      ? Icons.mic
                      : _isVideoMode
                      ? Icons.videocam_outlined
                      : Icons.mic_none_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlusMenu() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.purple.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _plusMenuItem(Icons.camera_alt_outlined, 'Kamera'),
          _plusMenuItem(Icons.photo_library_outlined, 'Galereya'),
          _plusMenuItem(Icons.location_on_outlined, 'Lokatsiya',
              onTap: _sendLocation),
        ],
      ),
    );
  }

  Widget _plusMenuItem(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: () {
        setState(() => _showPlusMenu = false);
        onTap?.call();
      },
      child: Column(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.12),
                shape: BoxShape.circle),
            child: Icon(icon, color: Colors.purple, size: 24),
          ),
          SizedBox(height: 6.h),
          Text(label,
              style: TextStyle(fontSize: 11.sp, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildProductCard(ChatMessageWorker msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(top: 6.h, bottom: 2.h),
        width: 220.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
              color: Colors.purple.withOpacity(0.4), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sotuvda bor',
                      style: TextStyle(
                          color: Colors.purple,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 4.h),
                  Text('Krem Klassik Parda',
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4.h),
                  Row(children: [
                    Text('\$12.50',
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.red,
                            decoration: TextDecoration.lineThrough)),
                    SizedBox(width: 6.w),
                    Text('\$10.00/ metr',
                        style:
                        TextStyle(fontSize: 12.sp, color: Colors.black87)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmDialog({
    required String title,
    required String content,
    required String confirmLabel,
  }) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Center(
        child: Text(title,
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: Colors.red)),
      ),
      content: Text(content,
          style: TextStyle(fontSize: 15.sp, color: Colors.red)),
      actions: [
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context, false),
              child: Container(
                height: 46.h,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(color: const Color(0xffECE5E5))),
                alignment: Alignment.center,
                child: Text("Bekor qilish",
                    style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFFC23AF5),
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context, true),
              child: Container(
                height: 46.h,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFC86EF9), Color(0xFF8B7CF6)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight),
                    borderRadius: BorderRadius.circular(30.r)),
                alignment: Alignment.center,
                child: Text("Ha, $confirmLabel",
                    style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.white,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ]),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];
    return '${dt.day}-${months[dt.month]}, ${dt.year}';
  }

  /// Sekundni "0:05" formatida qaytaradi
  String _fmtSecs(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}