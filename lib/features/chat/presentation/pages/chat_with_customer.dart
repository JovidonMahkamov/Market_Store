import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
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

class _ChatWithCustomerPageState extends State<ChatWithCustomerPage> {
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _controller = TextEditingController();
  bool _autoScroll = true;

  bool _isSelectionMode = false;
  final Set<int> _selectedIndexes = {};
  bool _showPlusMenu = false;
  bool _isLoadingLocation = false; // Loading indikator

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
    ChatMessageWorker(
      id: '4',
      text: 'Raxmat!',
      createdAt: DateTime(2026, 4, 12, 20, 31),
      isMe: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (!_scrollCtrl.hasClients) return;
      final distanceToBottom =
          _scrollCtrl.position.maxScrollExtent - _scrollCtrl.offset;
      _autoScroll = distanceToBottom < 80.0;
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToBottom(animated: false));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollCtrl.hasClients) return;
    final target = _scrollCtrl.position.maxScrollExtent;
    if (animated) {
      _scrollCtrl.animateTo(target,
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      _scrollCtrl.jumpTo(target);
    }
  }

  Future<void> _sendLocation() async {
    // 1. GPS yoqilganmi?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      _showSnackBar("GPS o'chiq. Sozlamalardan yoqing.");
      // Foydalanuvchini sozlamaga olib borish
      await Geolocator.openLocationSettings();
      return;
    }

    // 2. Ruxsat tekshirish
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        _showSnackBar("Lokatsiya ruxsati berilmadi.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      // Foydalanuvchini app sozlamalariga yo'naltirish
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Ruxsat kerak",
              style: TextStyle(fontWeight: FontWeight.w600)),
          content: const Text(
            "Lokatsiya ruxsati doimiy rad etilgan. "
                "Ilovalar sozlamasidan ruxsat bering.",
          ),
          actions: [
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Bekor qilish'),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Sozlamalar',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ]),
          ],
        ),
      );
      if (ok == true) await Geolocator.openAppSettings();
      return;
    }

    // 3. Loading ko'rsatish
    setState(() => _isLoadingLocation = true);

    try {
      // 4. Koordinatalarni olish
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      if (!mounted) return;

      // 5. Lokatsiya xabarini qo'shish — MATN EMAS, alohida tip!
      setState(() {
        _messages.add(ChatMessageWorker(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: '', // lokatsiya uchun matn bo'sh
          createdAt: DateTime.now(),
          isMe: true,
          latitude: position.latitude,
          longitude: position.longitude,
        ));
        _showPlusMenu = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } on LocationServiceDisabledException {
      if (!mounted) return;
      _showSnackBar("GPS o'chirib qo'yilgan.");
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Lokatsiya aniqlanmadi. Qayta urinib ko'ring.");
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnackBar("Qo'ng'iroq qilib bo'lmadi");
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

  void _deleteMessage(int index) {
    setState(() => _messages.removeAt(index));
  }

  void _editMessage(int index) {
    final msg = _messages[index];
    _controller.text = msg.text;
    _controller.selection =
        TextSelection.fromPosition(TextPosition(offset: msg.text.length));
    setState(() => _messages.removeAt(index));
  }

  void _toggleSelectMessage(int index) {
    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
      } else {
        _selectedIndexes.add(index);
      }
      if (_selectedIndexes.isEmpty) _isSelectionMode = false;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIndexes.clear();
      _isSelectionMode = false;
    });
  }

  void _deleteSelectedMessages() async {
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

  void _clearHistory() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _confirmDialog(
        title: 'Tarixni tozalash',
        content: "Barcha xabarlar o'chiriladi. Davom etasizmi?",
        confirmLabel: 'Tozalash',
      ),
    );
    if (ok != true) return;
    setState(() => _messages.clear());
  }

  void _deleteChat() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _confirmDialog(
        title: "Chatni o'chirish",
        content: "Bu chatni o'chirmoqchimisiz?",
        confirmLabel: "O'chirish",
      ),
    );
    if (ok != true) return;
    if (mounted) Navigator.pop(context);
  }

  Widget _confirmDialog({
    required String title,
    required String content,
    required String confirmLabel,
  }) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      content: Text(content),
      actions: [
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Bekor qilish'),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmLabel,
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '',
      'Yanvar',
      'Fevral',
      'Mart',
      'Aprel',
      'May',
      'Iyun',
      'Iyul',
      'Avgust',
      'Sentabr',
      'Oktabr',
      'Noyabr',
      'Dekabr'
    ];
    return '${dt.day}-${months[dt.month]}, ${dt.year}';
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: _appBarGradient),
          ),
          title: Row(
            children: [
              if (_isSelectionMode)
                GestureDetector(
                  onTap: _clearSelection,
                  child: Container(
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    height: 36.h,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close, color: Colors.purple, size: 16),
                        SizedBox(width: 2.w),
                        Text(
                          '${_selectedIndexes.length}',
                          style: const TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: BackWidget(),
                ),
              SizedBox(width: 10.w),
              if (!_isSelectionMode)
                Expanded(
                  child: Text(
                    widget.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkGrey,
                      fontSize: 20,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
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
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
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
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.purple, size: 22),
                  onPressed: _selectedIndexes.isEmpty
                      ? null
                      : _deleteSelectedMessages,
                ),
              ),
            if (!_isSelectionMode)
              Container(
                margin: EdgeInsets.only(right: 12.w),
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: Colors.black87, size: 22),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r)),
                  color: Colors.white,
                  elevation: 8,
                  offset: const Offset(0, 50),
                  onSelected: (value) {
                    if (value == 'mute') {
                      _showSnackBar("Bildirishnomalar o'chirildi");
                    } else if (value == 'clear') {
                      _clearHistory();
                    } else if (value == 'delete') {
                      _deleteChat();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'mute',
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.notifications_off_outlined,
                              color: AppColors.error, size: 18),
                        ),
                        SizedBox(width: 10.w),
                        const Text("Bildirishnomalarni o'chirish",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.red)),
                      ]),
                    ),
                    PopupMenuItem<String>(
                      value: 'clear',
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset("assets/home/clear.svg"),
                        ),
                        SizedBox(width: 10.w),
                        Text("Tarixni tozalash",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.darkGrey)),
                      ]),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.black87, size: 18),
                        ),
                        SizedBox(width: 10.w),
                        Text("Chatni o'chirish",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.darkGrey)),
                      ]),
                    ),
                  ],
                ),
              ),
          ],
        ),

        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    if (item['type'] == 'date_header') {
                      return _buildDateHeader(item['date']);
                    }
                    final int msgIndex = item['index'];
                    final ChatMessageWorker msg = item['msg'];
                    final bool isSelected = _selectedIndexes.contains(msgIndex);
                    return _buildMessageRow(
                        msg: msg, index: msgIndex, isSelected: isSelected);
                  },
                ),
              ),

              // Loading lokatsiya
              if (_isLoadingLocation)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.purple),
                      ),
                      SizedBox(width: 8.w),
                      Text("Lokatsiya aniqlanmoqda...",
                          style:
                          TextStyle(fontSize: 13.sp, color: Colors.grey)),
                    ],
                  ),
                ),

              if (_showPlusMenu) _buildPlusMenu(),
              _buildInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Center(
        child: Text(
          date,
          style: TextStyle(
              fontSize: 13.sp,
              color: Colors.black54,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildMessageRow({
    required ChatMessageWorker msg,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          _isSelectionMode = true;
          _selectedIndexes.add(index);
        });
      },
      onTap: () {
        if (_isSelectionMode) _toggleSelectMessage(index);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isSelectionMode)
            Padding(
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

          Expanded(
            child: Column(
              children: [
                // ── Xabar turi bo'yicha render ──────────────────────────
                if (msg.isLocation)
                // Lokatsiya bubble
                  ChatLocationBubble(
                    latitude: msg.latitude!,
                    longitude: msg.longitude!,
                    isMe: msg.isMe,
                  )
                else if (msg.isProductCard)
                // Mahsulot kartochkasi
                  _buildProductCard(msg)
                else
                // Oddiy matn xabari
                  ChatBubbleWorkerWidget(
                    message: msg,
                    onDelete: () => _deleteMessage(index),
                    onEdit: () => _editMessage(index),
                  ),

                // Vaqt
                Align(
                  alignment: msg.isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: msg.isMe ? 0 : 4.w,
                        right: msg.isMe ? 4.w : 0,
                        bottom: 4.h),
                    child: Text(
                      _formatTime(msg.createdAt),
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
          border: Border.all(color: Colors.purple.withOpacity(0.4), width: 1.5),
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
                  topRight: Radius.circular(16.r),
                ),
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
                  SizedBox(height: 4.h),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: 'Miqdor: ',
                            style: TextStyle(
                                fontSize: 12.sp, color: Colors.black54)),
                        TextSpan(
                            text: '25/',
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                        TextSpan(
                            text: 'metr',
                            style: TextStyle(
                                fontSize: 12.sp, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          // ✅ Lokatsiya tugmasi — onTap to'g'ri ulangan
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
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.purple, size: 24),
          ),
          SizedBox(height: 6.h),
          Text(label,
              style: TextStyle(fontSize: 11.sp, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      color: Colors.transparent,
      child: Row(
        children: [
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
              child:
              Icon(Icons.add, color: Colors.purple.withOpacity(0.8), size: 22),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                    color: Colors.purple.withOpacity(0.2), width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      maxLines: 5,
                      minLines: 1,
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Xabar yozing',
                        hintStyle:
                        TextStyle(color: Colors.grey, fontSize: 14.sp),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 10.h),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: const Icon(Icons.mic_none_outlined,
                        color: Colors.grey, size: 22),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}