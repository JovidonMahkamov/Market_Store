import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/chat_list_worker.dart';
import 'chat_with_customer.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isSelectionMode = false;
  final Set<int> selectedIndexes = {};

  final List<ChatListWorker> _rooms = [
    ChatListWorker(id: '1', name: 'Sevinch Sharobidinova', lastMessage: 'Rahmat!', time: '09:38', unread: 0),
    ChatListWorker(id: '2', name: 'Sevinch Sharobidinova', lastMessage: 'Rahmat!', time: '09:38', unread: 1),
    ChatListWorker(id: '3', name: 'Sevinch Sharobidinova', lastMessage: 'Rahmat!', time: '09:38', unread: 0),
    ChatListWorker(id: '4', name: 'Sevinch Sharobidinova', lastMessage: 'Rahmat!', time: '09:38', unread: 0),
    ChatListWorker(id: '5', name: 'Sevinch Sharobidinova', lastMessage: 'Rahmat!', time: '09:38', unread: 0),
  ];

  static const _backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFF6F6),
      Color(0xFFC5B2FF),
      Color(0xFFC3B0FF),
      Color(0xFFE6C5FF),
      Color(0xFFFFFFFF),
    ],
    stops: [0.0, 0.3, 0.55, 0.8, 1.0],
  );

  void _clearSelection() {
    setState(() {
      selectedIndexes.clear();
      isSelectionMode = false;
    });
  }

  void toggleSelection(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
      } else {
        selectedIndexes.add(index);
      }
      if (selectedIndexes.isEmpty) isSelectionMode = false;
    });
  }

  Future<void> deleteSelected() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Center(
          child: const Text("Chatni o'chirish",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20,  color: Colors.red,)),
        ),
        content: Text("${selectedIndexes.length} ta chatni o'chirmoqchimisiz?",
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.red,
          ),),
        actions: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 46.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(color: Color(0xffECE5E5FF)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Bekor qilish",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFFC23AF5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 46.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC86EF9), Color(0xFF8B7CF6)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Ha, o'chirish",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() {
      final sorted = selectedIndexes.toList()..sort((a, b) => b.compareTo(a));
      for (final i in sorted) {
        if (i >= 0 && i < _rooms.length) _rooms.removeAt(i);
      }
      _clearSelection();
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Chatlar o'chirildi")));
  }

  void _clearAllNotifications() {
    setState(() {
      for (final room in _rooms) {
        room.unread = 0;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Barcha bildirishnomalar o'chirildi")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Chap icon (chat bubble)
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child:  Icon(IconlyBold.chat,
                  color: Color(0xffC449F2), size: 30),
            ),
            SizedBox(width: 10.w),
            Text(
              isSelectionMode
                  ? '${selectedIndexes.length} tanlangan'
                  : 'Chatlar',
              style:  TextStyle(
                  fontWeight: FontWeight.w500, color: AppColors.darkGrey, fontSize: 20),
            ),
          ],
        ),
        actions: [
          if (isSelectionMode)
            IconButton(
              onPressed: () {
                if (selectedIndexes.isEmpty) {
                  _clearSelection();
                } else {
                  deleteSelected();
                }
              },
              icon: Icon(
                IconlyLight.delete,
                size: 26,
                color: selectedIndexes.isEmpty ? Colors.black : Colors.red,
              ),
              tooltip: selectedIndexes.isEmpty ? "Bekor qilish" : "O'chirish",
            ),
          Container(
            margin: EdgeInsets.only(right: 12.w),
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: PopupMenuButton<String>(
              icon:  Icon(Icons.more_vert, color: AppColors.purple, size: 28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              color: Colors.white,
              elevation: 8,
              offset: const Offset(0, 50),
              onSelected: (value) {
                if (value == 'clear_notifications') {
                  _clearAllNotifications();
                } else if (value == 'select_delete') {
                  setState(() => isSelectionMode = true);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'clear_notifications',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_off_outlined,
                            color: AppColors.error, size: 18),
                      ),
                      SizedBox(width: 10.w),
                      const Text(
                        "Bildirishnomalarni o'chirish",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.darkGrey),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'select_delete',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(IconlyLight.delete,
                            color: AppColors.error, size: 18),
                      ),
                      SizedBox(width: 10.w),
                      const Text(
                        "Chatlarni o'chirish" ,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.darkGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: _backgroundGradient),
        child: SafeArea(
          child: _rooms.isEmpty
              ? const Center(child: Text("Hozircha chatlar yo'q"))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _rooms.length,
            itemBuilder: (context, index) {
              final room = _rooms[index];
              return _buildItem(index: index, room: room);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildItem({required int index, required ChatListWorker room}) {
    final isSelected = selectedIndexes.contains(index);
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onLongPress: () {
            setState(() {
              isSelectionMode = true;
              selectedIndexes.add(index);
            });
          },
          onTap: () {
            if (isSelectionMode) {
              toggleSelection(index);
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ChatWithCustomerPage(name: room.name, imageUrl: null),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            height: 70.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              color: Colors.white,
            ),
            child: Row(
              children: [
                if (isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor:
                      isSelected ? AppColors.purple : Colors.grey[300],
                      child: isSelected
                          ? const Icon(Icons.check,
                          size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
                 CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.purple,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        room.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        room.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(room.time,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 4),
                    if (room.unread > 0)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                            color: Color(0xff9859EF), shape: BoxShape.circle),
                        child: Text(
                          room.unread.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}