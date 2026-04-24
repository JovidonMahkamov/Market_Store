import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/back_widget.dart';
import '../widgets/text_widget.dart';

class ProductDetailPage extends StatefulWidget {
  final String shopName;

  const ProductDetailPage({
    super.key,
    this.shopName = "Royal Curtains",
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
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

  int _selectedImage = 0;
  double _quantity = 2;

  static const String _productName = "Sheer";
  static const double _oldPrice = 12.50;
  static const double _newPrice = 10.00;
  static const String _unit = "metr";

  final List<String> _images = [
    "https://images.unsplash.com/photo-1505691938895-1758d7feb511",
    "https://images.unsplash.com/photo-1520607162513-77705c0f0d4a",
    "https://images.unsplash.com/photo-1484101403633-562f891dc89a",
    "https://images.unsplash.com/photo-1505691723518-36a5ac3be353",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            BackWidget(),
            const SizedBox(width: 12),
            const Text(
              "Mahsulotni ko'rish",
              style: TextStyle(
                color: AppColors.darkGrey,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration:
        const BoxDecoration(gradient: _backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Stack(
                    children: [
                      Container(
                        height: 260.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(20.r),
                          image: DecorationImage(
                            image: NetworkImage(
                                _images[_selectedImage]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const Positioned.fill(
                        child: Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color:
                            Colors.black.withOpacity(0.5),
                            borderRadius:
                            BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            "${_selectedImage + 1}/${_images.length}",
                            style: const TextStyle(
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 70.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    padding:
                    EdgeInsets.symmetric(horizontal: 16.w),
                    itemBuilder: (_, index) => GestureDetector(
                      onTap: () =>
                          setState(() => _selectedImage = index),
                      child: Container(
                        margin: EdgeInsets.only(right: 10.w),
                        width: 70.w,
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(12.r),
                          border: Border.all(
                            color: _selectedImage == index
                                ? Colors.deepPurple
                                : Colors.transparent,
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(_images[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30.r)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 16, left: 6, right: 6, bottom: 16),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                         Text(
                          _productName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        const Text(
                          "Yumshoq mato, zamonaviy dizayn. Uyingiz uchun mukammal tanlov.",
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Row(children: [
                          SvgPicture.asset("assets/home/Tick.svg",
                              width: 26, height: 26),
                          const SizedBox(width: 6),
                          const Text("Ishlab chiqarilgan:",
                              style: TextStyle(
                                  color: AppColors.darkGrey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1)),
                          const SizedBox(width: 6),
                          const Text("Turkiya",
                              style: TextStyle(
                                  color: AppColors.blue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500)),
                        ]),
                        Divider(
                            height: 30.h,
                            color: const Color(0xffE5E5E5)),
                        const TextWidget(
                            text: 'Narx',
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                        SizedBox(height: 8.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.purple),
                            color: const Color(0xffFCFAFF),
                            borderRadius:
                            BorderRadius.circular(12.r),
                          ),
                          child: const Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                  text: 'Metr',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400),
                              SizedBox(height: 4),
                              Text("\$$_oldPrice",
                                  style: TextStyle(
                                      color: AppColors.darkGrey,
                                      fontSize: 16)),
                            ],
                          ),
                        ),
                        Divider(
                            height: 30.h,
                            color: const Color(0xffE5E5E5)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3EBFF),
                            borderRadius:
                            BorderRadius.circular(25),
                          ),
                        ),
                        Row(children: [
                          const TextWidget(
                              text: 'Sotuvda:',
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                          SizedBox(width: 8.w),
                          const Text("Bor",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.blue)),
                        ]),
                        Divider(
                            height: 30.h,
                            color: const Color(0xffE5E5E5)),
                        Row(children: [
                          const TextWidget(
                              text: 'Tikuv xizmati:',
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                          SizedBox(width: 8.w),
                          const Text("Bor",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.blue)),
                        ]),
                        Divider(
                            height: 30.h,
                            color: const Color(0xffE5E5E5)),
                        Row(children: [
                          const TextWidget(
                              text: 'Yetkazib berish xizmati:',
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                          SizedBox(width: 8.w),
                          const Text("Yo'q",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red)),
                        ]),
                        Divider(
                            height: 30.h,
                            color: const Color(0xffE5E5E5)),
                      ],
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