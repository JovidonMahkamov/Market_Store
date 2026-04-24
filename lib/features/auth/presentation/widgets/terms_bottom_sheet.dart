import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'contact_widget.dart';
import 'elevated_wg.dart';

class TermsBottomSheet extends StatelessWidget {
  final void Function() onAccept;

  const TermsBottomSheet({super.key, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "So‘nggi yangilanish",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        "12–Aprel, 2026",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "1. Kirish",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Ilovamizga xush kelibsiz. Ushbu ilovadan foydalanish orqali siz quyidagi foydalanish shartlari va qoidalariga rozilik bildirasiz. Iltimos, ilovadan foydalanishdan oldin ushbu shartlar bilan tanishib chiqing.",
                    style: TextStyle(fontSize: 14),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "2. Foydalanish qoidalari",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "• Ilovadan faqat qonuniy maqsadlarda foydalanish kerak",
                  ),
                  const Text(
                    "• Noto‘g‘ri yoki yolg‘on ma’lumot kiritish taqiqlanadi",
                  ),
                  const Text(
                    "• Boshqa foydalanuvchilarga hurmat bilan munosabatda bo‘lish zarur",
                  ),
                  const Text(
                    "• Ilovadagi mahsulotlar va xizmatlar bo‘yicha barcha kelishuvlar foydalanuvchi va do‘kon o‘rtasida amalga oshiriladi",
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "3. Buyurtma va javobgarlik",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  const Text("• Ilova faqat vositachi platforma hisoblanadi"),
                  const Text("• Mahsulot sifati uchun do‘kon javobgar"),
                  const Text("• Narx va kelishuvlar chat orqali amalga oshiriladi"),

                  const SizedBox(height: 20),

                  const Text(
                    "4. Maxfiylik siyosati",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  const Text("• Sizning shaxsiy ma’lumotlaringiz himoyalanadi"),
                  const Text(
                    "• Ma’lumotlar uchinchi shaxslarga berilmaydi (qonuniy holatlar bundan mustasno)",
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "5.  Cheklovlar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    "• Qoidalarni buzgan foydalanuvchilar bloklanishi mumkin",
                  ),
                  const Text("• Soxta faoliyat aniqlansa akkaunt o‘chiriladi"),
                  const SizedBox(height: 20),

                  const Text(
                    "6.  Aloqa",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "• Ushbu Maxfiylik siyosati bo‘yicha savollaringiz bo‘lsa, biz bilan bog‘laning:",
                  ),

                  const SizedBox(height: 50),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ContactWidget(svg: 'assets/backround_image/Icon.svg', text: 'Telefon Raqam', contact: '+998 90 000 00 00',),
                      ContactWidget(svg: 'assets/backround_image/telegram.svg', text: 'Telegram', contact: 'LuxMarket_Support_bot',),
                    ],
                  ),

                  const SizedBox(height: 50),

                ],
              ),
            ),
          ),

          ElevatedWidget(
            onPressed: () {
              onAccept();
              Navigator.pop(context);
            },
            text: "Qabul qilaman",
            textColor: Colors.white,
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
