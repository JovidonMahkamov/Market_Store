import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/widgets/elevated_wg.dart';
import '../../../home/presentation/widgets/back_widget.dart';
import '../../../home/presentation/widgets/drop_down_widget.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String? _selectedCategory;
  static const _categories = [
    'Klassik Parda', 'Zamonaviy Parda', 'Sheer Parda', 'Blackout Parda', 'Boshqa',
  ];
  final _firstNameController = TextEditingController(text: "Sevinch");
  final _lastNameController  = TextEditingController(text: "Sharobidinova");
  final _phoneController     = TextEditingController(text: "+998 90 000 00 00");
  final _marketNameController  = TextEditingController(text: "Do’kon nomini kiriting...");

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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            BackWidget(),
            SizedBox(width: 12.w),
            Text(
              "Profilni Tahrirlash",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                  color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: _backgroundGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SizedBox(height: 16.h),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30.r),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        20.w, 36.h, 20.w, 30.h + bottomPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 100.w,
                              height: 100.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFE8DEFF),
                                border: Border.all(
                                  color: AppColors.purple,
                                  width: 2.5,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                width: 32.w,
                                height: 32.w,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xffD0AFFF),
                                      Color(0xffC23AF5),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 15.sp,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 32.h),
                        _buildFieldLabel("Ism"),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _firstNameController,
                          prefixIcon: Icons.person_outline_rounded,
                            hintText: "Ismingizni kiriting..."

                        ),

                        SizedBox(height: 18.h),
                        _buildFieldLabel("Familiya"),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _lastNameController,
                          prefixIcon: Icons.person_outline_rounded,
                            hintText: "Familiyangizni kiriting..."
                        ),

                        SizedBox(height: 18.h),
                        _buildFieldLabel("Telefon raqam"),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _phoneController,
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                            hintText: "Telefom raqamingizni kiriting..."
                        ),

                        SizedBox(height: 18.h),
                        _buildFieldLabel("Do’kon nomi"),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _marketNameController,
                          prefixIcon: Icons.shopping_cart_outlined,
                          keyboardType: TextInputType.phone,
                          hintText: "Do’kon nomini kiriting..."
                        ),

                        SizedBox(height: 18.h),
                        _buildFieldLabel("Do’kon tavsifi"),
                        SizedBox(height: 8.h),
                        _buildTextField(
                            controller: _marketNameController,
                            keyboardType: TextInputType.phone,
                            hintText: "Do’konga qisqa tavsif kiriting...",
                          maxLine: 4
                        ),

                        SizedBox(height: 18.h),
                        _buildFieldLabel("Do’kon kategoriyasi"),
                        SizedBox(height: 8.h),
                        AppDropdownField(
                          value: _selectedCategory,
                          items: _categories,
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                        SizedBox(height: 18.h),
                        _buildFieldLabel("Do’kon manzili"),
                        SizedBox(height: 8.h),
                        _buildTextField(
                            controller: _marketNameController,
                            prefixIcon: Icons.shopping_cart_outlined,
                            keyboardType: TextInputType.phone,
                            hintText: "Do’kon manzilini kiriting..."
                        ),
                        SizedBox(height: 36.h),
                        ElevatedWidget(onPressed: (){}, text: "Saqlash", textColor: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildFieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
            color: AppColors.darkGrey),
      ),
    );
  }

  Widget _buildTextField({
    String? hintText,
    int? maxLine,
    required TextEditingController controller,
     IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      maxLines: maxLine,
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14.sp, color: AppColors.darkGrey),
      decoration: InputDecoration(
        hintText: hintText, hintStyle: TextStyle(color: AppColors.grey),
        prefixIcon: Icon(prefixIcon,
            color: AppColors.purple, size: 20.sp),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFFE0D5FF), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide:  BorderSide(color: Color(0xFFC23AF5), width: 1.5),
        ),
      ),
    );
  }
}