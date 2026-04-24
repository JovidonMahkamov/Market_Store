import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_store/features/home/presentation/widgets/back_widget.dart';
import 'package:market_store/features/home/presentation/widgets/drop_down_widget.dart';
import 'package:market_store/features/home/presentation/widgets/switch_widget.dart';
import 'package:market_store/features/home/presentation/widgets/textfield_widget.dart';
import '../../../../core/constants/app_colors.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  // ─── Controllers ──────────────────────────────────────────────────────────
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _madeInCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _discountCtrl = TextEditingController();

  // ─── State ────────────────────────────────────────────────────────────────
  String _selectedCategory = 'Klassik Parda';
  String _selectedUnit = 'Narx turi';
  bool _hasDiscount = false;
  bool _inStock = false;
  bool _hasSewing = false;
  bool _hasDelivery = false;

  final List<File> _localImages = [];
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  static const _categories = [
    'Klassik Parda', 'Zamonaviy Parda', 'Sheer Parda', 'Blackout Parda', 'Boshqa',
  ];
  static const _units = ['Narx turi', 'Metr', 'Dona', 'Komplekt'];

  static const _backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFF6F6), Color(0xFFC5B2FF),
      Color(0xFFC3B0FF), Color(0xFFE6C5FF), Color(0xFFFFFFFF),
    ],
    stops: [0.0, 0.3, 0.55, 0.8, 1.0],
  );

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose(); _madeInCtrl.dispose();
    _priceCtrl.dispose(); _discountCtrl.dispose();
    super.dispose();
  }

  // ─── Image picking ─────────────────────────────────────────────────────────
  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;
    setState(() { for (final x in picked) _localImages.add(File(x.path)); });
  }

  void _removeLocalImage(int i) => setState(() => _localImages.removeAt(i));

  // ─── Save ──────────────────────────────────────────────────────────────────
  void _add() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: API ga yuborish
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Mahsulot qo'shildi"),
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
          const Text(
            "Mahsulot qo'shish",
            style: TextStyle(color: AppColors.darkGrey, fontSize: 20, fontWeight: FontWeight.w500),
          ),
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
                SizedBox(height: 20.h),

                // ── Rasm qo'shish section ────────────────────────────────
                _buildImageSection(),

                SizedBox(height: 20.h),

                // ── White form card ──────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    // Mahsulot nomi
                    _fieldLabel('Mahsulot nomi'),
                    SizedBox(height: 8.h),
                    AppTextField(
                      controller: _nameCtrl,
                      hint: 'Mahsulot nomini kiriting...',
                      textInputAction: TextInputAction.next,
                      validator: (v) => v == null || v.isEmpty ? 'Nom kiritish shart' : null,
                    ),

                    SizedBox(height: 16.h),

                    // Kategoriya
                    _fieldLabel('Mahsulot kategoriyasi'),
                    SizedBox(height: 8.h),
                    AppDropdownField<String>(
                      value: _selectedCategory,
                      items: _categories,
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),

                    SizedBox(height: 16.h),

                    // Tavsif
                    _fieldLabel('Tavsif'),
                    SizedBox(height: 8.h),
                    AppTextField(
                      controller: _descCtrl,
                      hint: 'Mahsulot tavsifini kiriting...',
                      maxLines: 4,
                      textInputAction: TextInputAction.next,
                    ),

                    SizedBox(height: 16.h),

                    // Ishlab chiqarilgan joy
                    _fieldLabel('Ishlab chiqarilgan joy'),
                    SizedBox(height: 8.h),
                    AppTextField(
                      controller: _madeInCtrl,
                      hint: 'Ishlab chiqarilgan joyni kiriting...',
                      textInputAction: TextInputAction.next,
                    ),

                    SizedBox(height: 16.h),

                    // Narx
                    _fieldLabel('Narx'),
                    SizedBox(height: 8.h),
                    Row(children: [
                      SizedBox(
                        width: 140.w,
                        child: AppDropdownField<String>(
                          value: _selectedUnit,
                          items: _units,
                          onChanged: (v) => setState(() => _selectedUnit = v!),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(child: _strikePriceField()),
                    ]),

                    SizedBox(height: 14.h),

                    // Chegirma
                    Row(children: [
                      const Text(
                        'Chegirma:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.darkGrey),
                      ),
                      SizedBox(width: 8.w),
                      AppSwitch(
                        value: _hasDiscount,
                        onChanged: (v) => setState(() => _hasDiscount = v),
                      ),
                      if (_hasDiscount) ...[
                        SizedBox(width: 8.w),
                        Expanded(child: AppTextField(
                          controller: _discountCtrl,
                          hint: 'Chegirma narx',
                          prefix: '\$',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                        )),
                      ] else ...[
                        SizedBox(width: 8.w),
                        Expanded(child: AppTextField(
                          controller: _discountCtrl,
                          hint: 'Chegirma narx',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                        )),
                      ],
                    ]),

                    SizedBox(height: 16.h),
                    _divider(),

                    // Toggle rows
                    _toggleRow(
                      label: 'Sotuvda:',
                      statusText: _inStock ? 'Bor' : "Yo'q",
                      value: _inStock,
                      onChanged: (v) => setState(() => _inStock = v),
                    ),
                    _divider(),
                    _toggleRow(
                      label: 'Tikuv xizmati:',
                      statusText: _hasSewing ? 'Bor' : "Yo'q",
                      value: _hasSewing,
                      onChanged: (v) => setState(() => _hasSewing = v),
                    ),
                    _divider(),
                    _toggleRow(
                      label: 'Yetkazib berish xizmati:',
                      statusText: _hasDelivery ? 'Bor' : "Yo'q",
                      value: _hasDelivery,
                      onChanged: (v) => setState(() => _hasDelivery = v),
                    ),

                    SizedBox(height: 32.h),
                    _addButton(),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Image section ─────────────────────────────────────────────────────────
  Widget _buildImageSection() {
    // Rasmlar yo'q bo'lsa — katta bitta placeholder
    if (_localImages.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            height: 160.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.purple,
                width: 1.5,
                style: BorderStyle.solid,
              ),
              color: Colors.white.withOpacity(0.5),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.add_photo_alternate_outlined, color: AppColors.purple, size: 44),
              SizedBox(height: 10.h),
              Text(
                "Rasm yoki video\nqo'shish",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.purple, fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ]),
          ),
        ),
      );
    }

    // Rasmlar bor — gorizontal ro'yxat + qo'shish tugmasi
    return SizedBox(
      height: 160.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          // Birinchi rasm — asosiy
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: _localImageCard(0),
          ),
          // Qolgan rasmlar
          ..._localImages.asMap().entries.skip(1).map((e) => Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: _smallImageCard(e.key),
          )),
          // Qo'shish placeholder
          _addMorePlaceholder(),
        ],
      ),
    );
  }

  Widget _localImageCard(int index) {
    return Stack(children: [
      Container(
        width: 160.w, height: 160.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          image: DecorationImage(image: FileImage(_localImages[index]), fit: BoxFit.cover),
        ),
      ),
      Positioned(
        bottom: 8, right: 8,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text('1/${_localImages.length}', style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ),
      Positioned(top: 6, right: 6, child: _deleteImageBtn(() => _removeLocalImage(index))),
    ]);
  }

  Widget _smallImageCard(int index) {
    return Stack(children: [
      Container(
        width: 100.w, height: 160.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          image: DecorationImage(image: FileImage(_localImages[index]), fit: BoxFit.cover),
        ),
      ),
      Positioned(top: 6, right: 6, child: _deleteImageBtn(() => _removeLocalImage(index))),
    ]);
  }

  Widget _addMorePlaceholder() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 100.w, height: 160.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.purple, width: 1.5),
          color: Colors.white.withOpacity(0.6),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_photo_alternate_outlined, color: AppColors.purple, size: 30),
          SizedBox(height: 6.h),
          Text(
            "Qo'shish",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.purple, fontSize: 12.sp, fontWeight: FontWeight.w500),
          ),
        ]),
      ),
    );
  }

  // ─── Strike price field ─────────────────────────────────────────────────────
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
        hintText: 'Narx',
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 15),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: _hasDiscount ? AppColors.error : AppColors.purple, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: _hasDiscount ? AppColors.error : AppColors.primary, width: 1.8),
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

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _fieldLabel(String text) => Text(
    text,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkGrey),
  );

  Widget _divider() => Divider(color: const Color(0xffE5E5E5), height: 1.h);

  Widget _deleteImageBtn(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28.w, height: 28.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)],
      ),
      child: Icon(Icons.delete_outline, color: AppColors.error, size: 18),
    ),
  );

  Widget _toggleRow({
    required String label,
    required String statusText,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(children: [
          Expanded(child: Text(label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.darkGrey))),
          Text(statusText,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,
                  color: value ? AppColors.blue : Colors.grey)),
          SizedBox(width: 8.w),
          AppSwitch(value: value, onChanged: onChanged),
        ]),
      );

  Widget _addButton() => SizedBox(
    width: double.infinity, height: 54.h,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: AppColors.buttonShadow,
      ),
      child: ElevatedButton(
        onPressed: _add,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        ),
        child: const Text(
          "Qo'shish",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    ),
  );
}