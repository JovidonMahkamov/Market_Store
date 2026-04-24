import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_store/features/home/presentation/widgets/switch_widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/back_widget.dart';
import '../widgets/drop_down_widget.dart';
import '../widgets/textfield_widget.dart';

class ProductEditPage extends StatefulWidget {
  final String? productName;
  final String? category;
  final String? description;
  final String? madeIn;
  final double? price;
  final double? discountPrice;
  final bool hasDiscount;
  final bool inStock;
  final bool hasSewing;
  final bool hasDelivery;
  final List<String>? existingImages;

  const ProductEditPage({
    super.key,
    this.productName,
    this.category,
    this.description,
    this.madeIn,
    this.price,
    this.discountPrice,
    this.hasDiscount = false,
    this.inStock = true,
    this.hasSewing = false,
    this.hasDelivery = true,
    this.existingImages,
  });

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _madeInCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _discountCtrl;

  String _selectedCategory = 'Klassik Parda';
  String _selectedUnit = 'Metr';
  bool _hasDiscount = false;
  bool _inStock = true;
  bool _hasSewing = false;
  bool _hasDelivery = true;

  final List<String> _networkImages = [];
  final List<File> _localImages = [];
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  static const _categories = [
    'Klassik Parda', 'Zamonaviy Parda', 'Sheer Parda', 'Blackout Parda', 'Boshqa',
  ];
  static const _units = ['Metr', 'Dona', 'Komplekt'];

  static const _backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF6F6), Color(0xFFC5B2FF), Color(0xFFC3B0FF), Color(0xFFE6C5FF), Color(0xFFFFFFFF)],
    stops: [0.0, 0.3, 0.55, 0.8, 1.0],
  );

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.productName ?? 'Sheer');
    _descCtrl = TextEditingController(text: widget.description ?? 'Yumshoq mato, zamonaviy dizayn. Uyingiz uchun makammal tanlov.');
    _madeInCtrl = TextEditingController(text: widget.madeIn ?? 'Turkiya');
    _priceCtrl = TextEditingController(text: widget.price != null ? widget.price!.toStringAsFixed(2) : '12.50');
    _discountCtrl = TextEditingController(text: widget.discountPrice != null ? widget.discountPrice!.toStringAsFixed(2) : '10.00');
    _selectedCategory = widget.category ?? 'Klassik Parda';
    _hasDiscount = widget.hasDiscount;
    _inStock = widget.inStock;
    _hasSewing = widget.hasSewing;
    _hasDelivery = widget.hasDelivery;
    _networkImages.addAll(widget.existingImages ?? [
      'https://images.unsplash.com/photo-1505691938895-1758d7feb511',
      'https://images.unsplash.com/photo-1520607162513-77705c0f0d4a',
      'https://images.unsplash.com/photo-1484101403633-562f891dc89a',
      'https://images.unsplash.com/photo-1505691723518-36a5ac3be353',
    ]);
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose(); _madeInCtrl.dispose();
    _priceCtrl.dispose(); _discountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;
    setState(() { for (final x in picked) _localImages.add(File(x.path)); });
  }

  void _removeNetworkImage(int i) => setState(() => _networkImages.removeAt(i));
  void _removeLocalImage(int i) => setState(() => _localImages.removeAt(i));

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Mahsulot saqlandi'),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
    Navigator.pop(context);
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
        title: Row(children: [
          const BackWidget(),
          SizedBox(width: 12.w),
          const Text('Mahsulotni tahrirlash', style: TextStyle(color: AppColors.darkGrey, fontSize: 20, fontWeight: FontWeight.w500)),
        ]),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: _backgroundGradient),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(height: 30.h),
                _buildImageSection(),
                SizedBox(height: 16.h),
                _buildThumbnailRow(),
                SizedBox(height: 20.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    _fieldLabel('Mahsulot nomi'),
                    SizedBox(height: 8.h),
                    AppTextField(
                      controller: _nameCtrl,
                      hint: 'Mahsulot nomini kiriting',
                      textInputAction: TextInputAction.next,
                      validator: (v) => v == null || v.isEmpty ? 'Nom kiritish shart' : null,
                    ),

                    SizedBox(height: 16.h),
                    _fieldLabel('Mahsulot kategoriyasi'),
                    SizedBox(height: 8.h),
                    AppDropdownField<String>(
                      value: _selectedCategory,
                      items: _categories,
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),

                    SizedBox(height: 16.h),
                    _fieldLabel('Tavsif'),
                    SizedBox(height: 8.h),
                    AppTextField(controller: _descCtrl, hint: 'Tavsif kiriting', maxLines: 4, textInputAction: TextInputAction.next),

                    SizedBox(height: 16.h),
                    _fieldLabel('Ishlab chiqarilgan joy'),
                    SizedBox(height: 8.h),
                    AppTextField(controller: _madeInCtrl, hint: 'Masalan: Turkiya', textInputAction: TextInputAction.next),

                    SizedBox(height: 16.h),
                    _fieldLabel('Narx'),
                    SizedBox(height: 8.h),
                    Row(children: [
                      SizedBox(
                        width: 120.w,
                        child: AppDropdownField<String>(
                          value: _selectedUnit,
                          items: _units,
                          onChanged: (v) => setState(() => _selectedUnit = v!),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      // ── Chegirma yoqilganda qizil + chizilgan ──
                      Expanded(child: _strikePriceField()),
                    ]),

                    SizedBox(height: 14.h),
                    Row(children: [
                      const Text('Chegirma:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.darkGrey)),
                      SizedBox(width: 8.w),
                      _purpleSwitch(value: _hasDiscount, onChanged: (v) => setState(() => _hasDiscount = v)),
                      if (_hasDiscount) ...[
                        SizedBox(width: 8.w),
                        Expanded(child: AppTextField(
                          controller: _discountCtrl, hint: '0.00', prefix: '\$',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                        )),
                      ],
                    ]),

                    SizedBox(height: 16.h),
                    _divider(),
                    _toggleRow(label: 'Sotuvda:', statusText: _inStock ? 'Bor' : "Yo'q", value: _inStock, onChanged: (v) => setState(() => _inStock = v)),
                    _divider(),
                    _toggleRow(label: 'Tikuv xizmati:', statusText: _hasSewing ? 'Bor' : "Yo'q", value: _hasSewing, onChanged: (v) => setState(() => _hasSewing = v)),
                    _divider(),
                    _toggleRow(label: 'Yetkazib berish xizmati:', statusText: _hasDelivery ? 'Bor' : "Yo'q", value: _hasDelivery, onChanged: (v) => setState(() => _hasDelivery = v)),

                    SizedBox(height: 32.h),
                    _saveButton(),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _strikePriceField() {
    return TextFormField(
      controller: _priceCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
      style: TextStyle(
        fontSize: 15,
        color: _hasDiscount ? AppColors.error : AppColors.darkGrey,
        fontWeight: FontWeight.w500,
        decoration: _hasDiscount ? TextDecoration.lineThrough : TextDecoration.none,
        decorationColor: AppColors.error,
        decorationThickness: 2.0,
      ),
      decoration: InputDecoration(
        hintText: '0.00',
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 15),
        prefixText: '\$',
        prefixStyle: TextStyle(
          color: _hasDiscount ? AppColors.error : AppColors.darkGrey,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          decoration: _hasDiscount ? TextDecoration.lineThrough : TextDecoration.none,
          decorationColor: AppColors.error,
          decorationThickness: 2.0,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: _hasDiscount ? AppColors.error : AppColors.purple,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: _hasDiscount ? AppColors.error : AppColors.primary,
            width: 1.8,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error, width: 1.8),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      height: 160.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          if (_networkImages.isNotEmpty)
            Padding(padding: EdgeInsets.only(right: 12.w),
                child: _mainImageCard(_networkImages[0], isNetwork: true, index: 0))
          else if (_localImages.isNotEmpty)
            Padding(padding: EdgeInsets.only(right: 12.w),
                child: _mainImageCard(_localImages[0].path, isNetwork: false, index: 0)),
          _addImagePlaceholder(),
        ],
      ),
    );
  }

  Widget _mainImageCard(String path, {required bool isNetwork, required int index}) {
    return Stack(children: [
      Container(
        width: 160.w, height: 160.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          image: DecorationImage(
            image: isNetwork ? NetworkImage(path) as ImageProvider : FileImage(File(path)),
            fit: BoxFit.cover,
          ),
        ),
      ),
      Positioned.fill(child: Center(child: Icon(Icons.play_circle_fill, color: Colors.white.withOpacity(0.85), size: 40))),
      Positioned(bottom: 8, right: 8, child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(10.r)),
        child: Text('1/${_networkImages.length + _localImages.length}', style: const TextStyle(color: Colors.white, fontSize: 12)),
      )),
      Positioned(top: 6, right: 6, child: _deleteImageBtn(
            () => isNetwork ? _removeNetworkImage(index) : _removeLocalImage(index),
      )),
    ]);
  }

  Widget _addImagePlaceholder() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 160.w, height: 160.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.purple, width: 1.5),
          color: Colors.white.withOpacity(0.6),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_photo_alternate_outlined, color: AppColors.purple, size: 40),
          SizedBox(height: 8.h),
          Text("Rasm yoki video\nqo'shish", textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.purple, fontSize: 13.sp, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  Widget _buildThumbnailRow() {
    final allPaths = [
      ..._networkImages.map((e) => _ImageItem(path: e, isNetwork: true)),
      ..._localImages.map((e) => _ImageItem(path: e.path, isNetwork: false)),
    ];
    if (allPaths.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 80.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: allPaths.length,
        itemBuilder: (_, i) {
          final item = allPaths[i];
          final isLast = i == allPaths.length - 1;
          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 10.w),
            child: Stack(children: [
              Container(
                width: 72.w, height: 72.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  image: DecorationImage(
                    image: item.isNetwork ? NetworkImage(item.path) as ImageProvider : FileImage(File(item.path)),
                    fit: BoxFit.cover,
                  ),
                ),
                child: isLast ? Center(child: Icon(Icons.play_circle_fill, color: Colors.white.withOpacity(0.8), size: 24)) : null,
              ),
              Positioned(top: 4, right: 4, child: _deleteImageBtn(() {
                if (item.isNetwork) {
                  final idx = _networkImages.indexOf(item.path);
                  if (idx != -1) _removeNetworkImage(idx);
                } else {
                  final idx = _localImages.indexWhere((f) => f.path == item.path);
                  if (idx != -1) _removeLocalImage(idx);
                }
              })),
            ]),
          );
        },
      ),
    );
  }


  Widget _fieldLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkGrey));

  Widget _divider() => Divider(color: const Color(0xffE5E5E5), height: 1.h);

  Widget _deleteImageBtn(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28.w, height: 28.w,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)]),
      child: Icon(Icons.delete_outline, color: AppColors.error, size: 18),
    ),
  );

  Widget _purpleSwitch({required bool value, required ValueChanged<bool> onChanged}) =>
      Transform.scale(scale: 0.9, child: AppSwitch(
        value: value, onChanged: onChanged,
      ));

  Widget _toggleRow({required String label, required String statusText, required bool value, required ValueChanged<bool> onChanged}) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.darkGrey))),
          Text(statusText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: value ? AppColors.blue : Colors.red)),
          SizedBox(width: 8.w),
          _purpleSwitch(value: value, onChanged: onChanged),
        ]),
      );

  Widget _saveButton() => SizedBox(
    width: double.infinity, height: 54.h,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: AppColors.buttonShadow,
      ),
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        ),
        child: const Text('Saqlash', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    ),
  );
}

class _ImageItem {
  final String path;
  final bool isNetwork;
  const _ImageItem({required this.path, required this.isNetwork});
}