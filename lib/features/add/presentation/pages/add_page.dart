import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_store/features/auth/presentation/widgets/elevated_wg.dart';
import 'package:market_store/features/home/presentation/widgets/drop_down_widget.dart';
import 'package:market_store/features/home/presentation/widgets/switch_widget.dart';
import 'package:market_store/features/home/presentation/widgets/textfield_widget.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../profile/presentation/widgets/field_label_widget.dart';
import '../widgets/add_image_placeholder_widget.dart';
import '../widgets/image_card_widget.dart';
import '../widgets/toggle_row_widget.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _madeInCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _discountCtrl = TextEditingController();

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
    'Klassik Parda',
    'Zamonaviy Parda',
    'Sheer Parda',
    'Blackout Parda',
    'Boshqa',
  ];
  static const _units = ['Narx turi', 'Metr', 'Dona', 'Komplekt'];

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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _madeInCtrl.dispose();
    _priceCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;
    setState(() {
      for (final x in picked) _localImages.add(File(x.path));
    });
  }

  void _removeLocalImage(int i) => setState(() => _localImages.removeAt(i));

  void _add() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Mahsulot qo'shildi"),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: const Text(
            "Mahsulot qo'shish",
            style: TextStyle(
              color: AppColors.darkGrey,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: _backgroundGradient),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  _buildImageSection(),

                  SizedBox(height: 20.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30.r),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FieldLabel(text: 'Mahsulot nomi'),
                        SizedBox(height: 8.h),
                        AppTextField(
                          controller: _nameCtrl,
                          hint: 'Mahsulot nomini kiriting...',
                          textInputAction: TextInputAction.next,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Nom kiritish shart'
                              : null,
                        ),

                        SizedBox(height: 16.h),

                        FieldLabel(text: 'Mahsulot kategoriyasi'),
                        SizedBox(height: 8.h),
                        AppDropdownField<String>(
                          value: _selectedCategory,
                          items: _categories,
                          onChanged: (v) =>
                              setState(() => _selectedCategory = v!),
                        ),

                        SizedBox(height: 16.h),

                        FieldLabel(text: 'Tavsif'),
                        SizedBox(height: 8.h),
                        AppTextField(
                          controller: _descCtrl,
                          hint: 'Mahsulot tavsifini kiriting...',
                          maxLines: 4,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 16.h),
                        FieldLabel(text: 'Ishlab chiqarilgan joy'),
                        SizedBox(height: 8.h),
                        AppTextField(
                          controller: _madeInCtrl,
                          hint: 'Ishlab chiqarilgan joyni kiriting...',
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 16.h),
                        FieldLabel(text: 'Narx'),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            SizedBox(
                              width: 140.w,
                              child: AppDropdownField<String>(
                                value: _selectedUnit,
                                items: _units,
                                onChanged: (v) =>
                                    setState(() => _selectedUnit = v!),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(child: _strikePriceField()),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        Row(
                          children: [
                            const Text(
                              'Chegirma:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.darkGrey,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            AppSwitch(
                              value: _hasDiscount,
                              onChanged: (v) =>
                                  setState(() => _hasDiscount = v),
                            ),
                            if (_hasDiscount) ...[
                              SizedBox(width: 8.w),
                              Expanded(
                                child: AppTextField(
                                  controller: _discountCtrl,
                                  hint: 'Chegirma narx',
                                  prefix: '\$',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}'),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              SizedBox(width: 8.w),
                              Expanded(
                                child: AppTextField(
                                  controller: _discountCtrl,
                                  hint: 'Chegirma narx',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),

                        SizedBox(height: 16.h),
                        _divider(),

                        ToggleRowWidget(
                          label: 'Sotuvda:',
                          statusText: _inStock ? 'Bor' : "Yo'q",
                          value: _inStock,
                          onChanged: (v) => setState(() => _inStock = v),
                        ),
                        _divider(),
                        ToggleRowWidget(
                          label: 'Tikuv xizmati:',
                          statusText: _hasSewing ? 'Bor' : "Yo'q",
                          value: _hasSewing,
                          onChanged: (v) => setState(() => _hasSewing = v),
                        ),
                        _divider(),
                        ToggleRowWidget(
                          label: 'Yetkazib berish xizmati:',
                          statusText: _hasDelivery ? 'Bor' : "Yo'q",
                          value: _hasDelivery,
                          onChanged: (v) => setState(() => _hasDelivery = v),
                        ),

                        SizedBox(height: 40.h),
                        ElevatedWidget(
                          onPressed: () {},
                          text: "Qo'shish",
                          textColor: AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  color: AppColors.purple,
                  size: 44,
                ),
                SizedBox(height: 10.h),
                Text(
                  "Rasm yoki video\nqo'shish",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.purple,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 160.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          ..._localImages.asMap().entries.map(
            (e) => Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: ImageCardWidget(
                imageFile: _localImages[e.key],
                index: e.key,
                total: _localImages.length,
                onDelete: () => _removeLocalImage(e.key),
                deleteButton: _deleteImageBtn(() {}),
              ),
            ),
          ),

          AddImagePlaceholder(onTap: () {}),
        ],
      ),
    );
  }

  Widget _smallImageCard(int index) {
    return Stack(
      children: [
        Container(
          width: 100.w,
          height: 160.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            image: DecorationImage(
              image: FileImage(_localImages[index]),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: _deleteImageBtn(() => _removeLocalImage(index)),
        ),
      ],
    );
  }

  Widget _strikePriceField() {
    return TextFormField(
      controller: _priceCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      style: TextStyle(
        fontSize: 15,
        color: _hasDiscount ? AppColors.error : AppColors.darkGrey,
        fontWeight: FontWeight.w500,
        decoration: _hasDiscount
            ? TextDecoration.lineThrough
            : TextDecoration.none,
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

  Widget _divider() => Divider(color: const Color(0xffE5E5E5), height: 1.h);

  Widget _deleteImageBtn(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4),
        ],
      ),
      child: Icon(Icons.delete_outline, color: AppColors.error, size: 18),
    ),
  );
}
