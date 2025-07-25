import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talabat/viewmodels/item_management_viewmodel.dart';
import 'package:talabat/views/item_forms/aluminum_form.dart';
import 'package:talabat/views/item_forms/solid_color_form.dart';
import 'package:talabat/views/item_forms/wood_color_form.dart';
import 'package:talabat/views/widgets/animated_logo.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItemManagementViewModel(),
      child: Consumer<ItemManagementViewModel>(
        builder: (context, viewModel, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'اختر نوع الصنف:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButton<ItemType>(
                  value: viewModel.selectedItemType,
                  hint: const Text('اختر نوع الصنف'),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: ItemType.aluminum,
                      child: Text('ألمنيوم'),
                    ),
                    DropdownMenuItem(
                      value: ItemType.solidColor,
                      child: Text('لون سادة'),
                    ),
                    DropdownMenuItem(
                      value: ItemType.woodColor,
                      child: Text('لون خشابي'),
                    ),
                  ],
                  onChanged: viewModel.setItemType,
                ),
                const SizedBox(height: 24),

                // عرض النموذج المناسب حسب نوع الصنف المختار
                if (viewModel.selectedItemType == ItemType.aluminum)
                  AluminumForm(viewModel: viewModel),

                if (viewModel.selectedItemType == ItemType.solidColor)
                  SolidColorForm(viewModel: viewModel),

                if (viewModel.selectedItemType == ItemType.woodColor)
                  WoodColorForm(viewModel: viewModel),
                const SizedBox(height: 24),
                if (viewModel.selectedItemType != null)
                  viewModel.isLoading
                      // إذا في تحميل: عرض الشعار المتحرك في المنتصف
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: const Center(child: AnimatedLogo()),
                        )
                      // إذا انتهى التحميل: عرض زر الإضافة
                      : Center(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              // نستدعي addItem() وننتظر نتيجة النص
                              final errorMessage = await viewModel.addItem();
                              if (!context.mounted) return;

                              if (errorMessage.isEmpty) {
                                // نجاح → نعرض SnackBar نجاح
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تمت الإضافة بنجاح'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                // فشل → نعرض نص رسالة الخطأ
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },

                            icon: const Icon(Icons.add),
                            label: const Text('إضافة الصنف'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
              ],
            ),
          );
        },
      ),
    );
  }
}
