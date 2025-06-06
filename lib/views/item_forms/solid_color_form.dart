import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talabat/views/widgets/animated_logo.dart';
import '../../viewmodels/item_management_viewmodel.dart';

class SolidColorForm extends StatelessWidget {
  final ItemManagementViewModel viewModel;

  const SolidColorForm({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: viewModel.fetchItemsForCategory(),
      builder: (context, snapshot) {
        // إذا ما زال في انتظار الجلب → نعرض الأنيميشن
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: AnimatedLogo(),
            ),
          );
        }

        // إذا حدث خطأ أثناء الجلب
        if (snapshot.hasError) {
          return const Text(
            'خطأ في جلب بيانات الألمنيوم',
            style: TextStyle(color: Colors.red),
          );
        }

        // عندما تنتهي عملية الجلب، نحصل على القائمة أو نجعلها فارغة لو لم توجد

        // ثم نعرض الحقول بعد انتهاء التحميل
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إضافة لون سادة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return newValue.copyWith(
                    text: newValue.text
                        .toUpperCase(), // ✅ فقط تحويل كل شيء لحروف كابتل
                    selection: newValue.selection,
                  );
                }),
              ],
              controller: viewModel.solidLocalCodeController,
              decoration: const InputDecoration(
                labelText: 'رمز اللون الخاص بك',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('هل اللون خلطة؟'),
              value: viewModel.solidIsMixed,
              onChanged: viewModel.setSolidIsMixed,
            ),
            if (viewModel.solidIsMixed) ...[
              TextField(
                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly, // ✅ يمنع أي شيء غير رقم
                ],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'عدد الألوان في الخلطة',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  int count = int.tryParse(value) ?? 1;
                  viewModel.setSolidMixCount(count);
                },
              ),
              const SizedBox(height: 12),
            ],
            for (int i = 0; i < viewModel.solidMixCount; i++) ...[
              TextField(
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return newValue.copyWith(
                      text: newValue.text
                          .toUpperCase(), // ✅ فقط تحويل كل شيء لحروف كابتل
                      selection: newValue.selection,
                    );
                  }),
                ],
                controller: viewModel.solidSupplierCodeControllers[i],
                decoration: InputDecoration(
                  labelText: 'رمز الخاص بالشركة الموردة ${i + 1}',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: viewModel.solidCompanyNameControllers[i],
                decoration: InputDecoration(
                  labelText: 'اسم الشركة الموردة ${i + 1}',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}
