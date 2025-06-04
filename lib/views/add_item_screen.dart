import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talabat/viewmodels/item_management_viewmodel.dart';
import 'package:talabat/views/item_forms/aluminum_form.dart';
import 'package:talabat/views/item_forms/solid_color_form.dart';
import 'package:talabat/views/item_forms/wood_color_form.dart';

class AddItemScreen extends StatelessWidget {
  const AddItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItemManagementViewModel(),
      child: Consumer<ItemManagementViewModel>(
        builder: (context, viewModel, child) {
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
                Center(
                  child: ElevatedButton.icon(
                    onPressed: viewModel.addItem,
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
