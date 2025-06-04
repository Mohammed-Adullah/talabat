import 'package:flutter/material.dart';
import '../../viewmodels/item_management_viewmodel.dart';

class AluminumForm extends StatelessWidget {
  final ItemManagementViewModel viewModel;

  const AluminumForm({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
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
  }
}
