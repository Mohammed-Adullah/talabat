import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:talabat/views/widgets/animated_logo.dart';

import '../viewmodels/item_management_viewmodel.dart';

class DeleteItemScreen extends StatefulWidget {
  const DeleteItemScreen({super.key});

  @override
  State<DeleteItemScreen> createState() => _DeleteItemScreenState();
}

class _DeleteItemScreenState extends State<DeleteItemScreen> {
  String? _selectedItemNameToDelete;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ItemManagementViewModel>(
      create: (_) => ItemManagementViewModel(),
      child: Consumer<ItemManagementViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // DropdownButton لاختيار نوع الصنف
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
                  onChanged: (type) {
                    viewModel.setItemType(type);
                    setState(() {
                      _selectedItemNameToDelete = null;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // إذا اختار المستخدم نوعًا، نعرض DropdownSearch لجلب الأسماء من Firestore
                if (viewModel.selectedItemType != null)
                  FutureBuilder<List<String>>(
                    future: viewModel.fetchItemsForCategory(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: AnimatedLogo());
                      }

                      final items = snapshot.data ?? [];
                      if (items.isEmpty) {
                        return const Text(
                          'لا توجد عناصر للحذف في هذا القسم',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        );
                      }

                      return DropdownSearch<String>(
                        // استخدام PopupProps لتهيئة البحث داخل القائمة
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: const TextFieldProps(
                            decoration: InputDecoration(
                              hintText: 'ابحث هنا...',
                            ),
                          ),
                        ),
                        items: items,
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'اختر الصنف للحذف',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedItemNameToDelete = value;
                          });
                        },
                        selectedItem: _selectedItemNameToDelete,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء اختيار صنف للحذف';
                          }
                          return null;
                        },
                      );
                    },
                  ),

                // زر الحذف
                const SizedBox(height: 24),
                if (viewModel.selectedItemType != null)
                  viewModel.isLoading
                      // إذا في تحميل: عرض الشعار المتحرك في المنتصف
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: const Center(child: AnimatedLogo()),
                        )
                      // إذا انتهى التحميل: عرض زر الإضافة
                      : ElevatedButton.icon(
                          onPressed: () async {
                            if (viewModel.selectedItemType == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('رجاءً اختر نوع الصنف أولاً'),
                                ),
                              );
                              return;
                            }
                            if (_selectedItemNameToDelete == null ||
                                _selectedItemNameToDelete!.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('رجاءً اختر الصنف للحذف'),
                                ),
                              );
                              return;
                            }

                            final success = await viewModel.deleteItemByName(
                              _selectedItemNameToDelete!,
                            );
                            if (success) {
                              () async {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم حذف الصنف بنجاح'),
                                  ),
                                );
                              };

                              // إعادة تهيئة لاختيار عنصر جديد بعد الحذف
                              setState(() {
                                _selectedItemNameToDelete = null;
                              });
                            } else {
                              () async {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('حدث خطأ أثناء الحذف'),
                                  ),
                                );
                              };
                            }
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('حذف الصنف'),
                        ),
              ],
            ),
          );
        },
      ),
    );
  }
}
