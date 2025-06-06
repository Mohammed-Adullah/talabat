import 'package:flutter/material.dart';
import 'package:talabat/views/widgets/animated_logo.dart';
import '../../viewmodels/item_management_viewmodel.dart';

class AluminumForm extends StatelessWidget {
  final ItemManagementViewModel viewModel;

  const AluminumForm({super.key, required this.viewModel});

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
        // final existingNames = snapshot.data ?? [];

        // ثم نعرض الحقول بعد انتهاء التحميل
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إضافة قطاع ألمنيوم',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: viewModel.aluminumNameController,
              decoration: const InputDecoration(
                labelText: 'اسم قطاع الألمنيوم',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      },
    );
  }
}
