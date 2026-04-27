import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

/// Lokatsiya xabari uchun alohida widget.
/// Google Maps static image orqali preview ko'rsatadi,
/// bosilganda Google Maps ilovasini ochadi.
class ChatLocationBubble extends StatelessWidget {
  final double latitude;
  final double longitude;
  final bool isMe;

  const ChatLocationBubble({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.isMe,
  });

  /// Statik xarita rasmi URL si (API key siz ishlaydi — tile asosida)
  String get _staticMapUrl {
    // Google Static Maps — API key kerak bo'lsa quyida o'zgartiring
    // Hozirda OpenStreetMap tile ishlatiladi (API keysiz)
    return 'https://staticmap.openstreetmap.de/staticmap.php'
        '?center=$latitude,$longitude'
        '&zoom=15'
        '&size=300x150'
        '&markers=$latitude,$longitude,red-pushpin';
  }

  String get _mapsUrl =>
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

  Future<void> _openMaps() async {
    final uri = Uri.parse(_mapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: _openMaps,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4.h),
          width: 220.w,
          decoration: BoxDecoration(
            color: isMe ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft:
              isMe ? const Radius.circular(16) : Radius.zero,
              bottomRight:
              isMe ? Radius.zero : const Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Xarita preview
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
                child: Stack(
                  children: [
                    Image.network(
                      _staticMapUrl,
                      width: double.infinity,
                      height: 120.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 120.h,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.map_outlined,
                              color: Colors.grey, size: 40),
                        ),
                      ),
                    ),
                    // "Ochish" overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.2),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // "Lokatsiya" nomi + icon
              Padding(
                padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: isMe ? Colors.white : Colors.red,
                      size: 16,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        'Mening joylashuvim',
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.open_in_new,
                      color: isMe
                          ? Colors.white70
                          : Colors.grey,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}