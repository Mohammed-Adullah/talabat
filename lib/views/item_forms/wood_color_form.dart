import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../viewmodels/item_management_viewmodel.dart';

class WoodColorForm extends StatelessWidget {
  final ItemManagementViewModel viewModel;

  const WoodColorForm({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'إضافة لون خشابي',
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
          controller: viewModel.woodLocalCodeController,
          decoration: const InputDecoration(
            labelText: 'رمز اللون الخاص بالشركة',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('هل اللون خلطة؟'),
          value: viewModel.woodIsMixed,
          onChanged: viewModel.setWoodIsMixed,
        ),
        if (viewModel.woodIsMixed) ...[
          TextField(
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // ✅ يمنع أي شيء غير رقم
            ],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'عدد الألوان في الخلطة',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              int count = int.tryParse(value) ?? 1;
              viewModel.setWoodMixCount(count);
            },
          ),
          const SizedBox(height: 12),
        ],
        for (int i = 0; i < viewModel.woodMixCount; i++) ...[
          TextField(
            controller: viewModel.woodSupplierCodeControllers[i],
            inputFormatters: [
              TextInputFormatter.withFunction((oldValue, newValue) {
                return newValue.copyWith(
                  text: newValue.text
                      .toUpperCase(), // ✅ فقط تحويل كل شيء لحروف كابتل
                  selection: newValue.selection,
                );
              }),
            ],
            decoration: InputDecoration(
              labelText: 'رمز البويا من المورد ${i + 1}',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: viewModel.woodCompanyNameControllers[i],
            decoration: InputDecoration(
              labelText: 'اسم الشركة الموردة ${i + 1}',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: viewModel.woodFilmCodeController,
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              return newValue.copyWith(
                text: newValue.text
                    .toUpperCase(), // ✅ فقط تحويل كل شيء لحروف كابتل
                selection: newValue.selection,
              );
            }),
          ],
          decoration: const InputDecoration(
            labelText: 'رمز الفلم',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: viewModel.woodOvenTempController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'درجة حرارة الفرن',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: viewModel.woodOvenTimeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'وقت الفرن بالدقائق',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
