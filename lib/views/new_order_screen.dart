import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../viewmodels/new_order_viewmodel.dart';

class NewOrderScreen extends StatelessWidget {
  const NewOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewOrderViewModel(),
      child: Scaffold(
        appBar: AppBar(title: Text('طلب تشغيل جديد')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<NewOrderViewModel>(
            builder: (context, viewModel, child) {
              return ListView(
                children: [
                  // 1. رقم الطلب (قراءة فقط)
                  TextFormField(
                    controller: viewModel.orderNumberController,
                    decoration: InputDecoration(labelText: 'رقم الطلب'),
                    readOnly: true,
                  ),

                  SizedBox(height: 12),

                  SizedBox(height: 12),

                  // 3. التاريخ (قراءة فقط + اختيار من التقويم)
                  TextFormField(
                    controller: viewModel.dateController,
                    decoration: InputDecoration(labelText: 'التاريخ'),
                    readOnly: true,
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        viewModel.dateController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(picked);
                      }
                    },
                  ),

                  SizedBox(height: 20),

                  // ------------------------
                  // 4. DropdownSearch: رمز اللون المحلي
                  // ------------------------
                  DropdownSearch<String>(
                    popupProps: PopupProps.modalBottomSheet(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          labelText: 'بحث عن رمز اللون',
                        ),
                      ),
                    ),
                    asyncItems: (String filter) =>
                        viewModel.fetchColorSuggestions(filter),
                    selectedItem: viewModel.localColorCodeController.text,

                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'رمز اللون المحلي',
                      ),
                    ),
                    onChanged: (String? val) {
                      if (val != null) {
                        viewModel.localColorCodeController.text = val;
                        viewModel.lookupColorData(val);
                      }
                    },
                    validator: (value) {
                      if (value == null ||
                          !viewModel.validColorCodes.contains(value)) {
                        return 'يرجى اختيار رمز لون من القائمة';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20),

                  // 5. عرض بيانات اللون إذا وُجدت (بعد اختيار الرمز)
                  if (viewModel.colorType != null) ...[
                    Text(
                      'نوع اللون: ${viewModel.colorType}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (viewModel.suppliers.isNotEmpty)
                      ...viewModel.suppliers.map(
                        (s) => Text(
                          'رمز البويا: ${s['paintCode']}\n  الشركة: ${s['supplierName']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    if (viewModel.filmCode != null)
                      Text(
                        'رمز الفلم: ${viewModel.filmCode}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    if (viewModel.ovenTemp != null)
                      Text(
                        'درجة الحرارة: ${viewModel.ovenTemp}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    if (viewModel.ovenTime != null)
                      Text(
                        'مدة الفرن: ${viewModel.ovenTime} دقيقة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    SizedBox(height: 20),
                  ],
                  // 2. اسم الزبون
                  TextFormField(
                    controller: viewModel.customerNameController,
                    decoration: InputDecoration(labelText: 'اسم الزبون'),
                  ),
                  // 6. قسم “إضافة أصناف الألمنيوم”
                  Text(
                    'إضافة أصناف الألمنيوم',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 8),

                  // 7. تحديد المصدر: من المستودع أم من الزبون
                  Row(
                    children: [
                      Checkbox(
                        value: viewModel.fromWarehouse,
                        onChanged: (value) {
                          if (value != null) viewModel.toggleSource(value);
                        },
                      ),
                      Text('من المستودع'),
                      SizedBox(width: 20),
                      Checkbox(
                        value: !viewModel.fromWarehouse,
                        onChanged: (value) {
                          if (value != null) viewModel.toggleSource(!(value));
                        },
                      ),
                      Text('من الزبون'),
                    ],
                  ),

                  SizedBox(height: 8),

                  // 8. DropdownSearch: اختيار اسم الصنف مع بحث
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownSearch<String>(
                          popupProps: PopupProps.modalBottomSheet(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                labelText: 'بحث عن صنف',
                              ),
                            ),
                          ),
                          asyncItems: (String filter) =>
                              viewModel.fetchItemSuggestions(filter),
                          selectedItem: viewModel.itemController.text,
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'اسم الصنف',
                            ),
                          ),
                          onChanged: (String? val) {
                            if (val != null) {
                              viewModel.itemController.text = val;
                            }
                          },
                          validator: (value) {
                            if (value == null ||
                                !viewModel.validItemNames.contains(value)) {
                              return 'يرجى اختيار صنف من القائمة';
                            }
                            return null;
                          },
                        ),
                      ),

                      SizedBox(width: 10),

                      // 9. حقل العدد
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: viewModel.quantityController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly, // ✅ يمنع أي شيء غير رقم
                          ],
                          decoration: InputDecoration(labelText: 'العدد'),
                        ),
                      ),

                      SizedBox(width: 10),

                      // 10. زر “إضافة”
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (viewModel
                                .localColorCodeController
                                .text
                                .isEmpty) {
                              _showError(
                                context,
                                'يرجى اختيار رمز اللون أولاً',
                              );
                              return;
                            }
                            if (viewModel.customerNameController.text.isEmpty ||
                                !viewModel.lettersOnly.hasMatch(
                                  viewModel.customerNameController.text,
                                )) {
                              _showError(context, 'يرجى إدخال اسم زبون صالح');
                              return;
                            }
                            if (viewModel.itemController.text.isEmpty ||
                                !viewModel.validItemNames.contains(
                                  viewModel.itemController.text,
                                )) {
                              _showError(context, 'يرجى اختيار صنف من القائمة');
                              return;
                            }
                            if (viewModel.quantityController.text.isEmpty ||
                                !viewModel.numbersOnly.hasMatch(
                                  viewModel.quantityController.text,
                                )) {
                              _showError(context, 'يرجى إدخال عدد صالح');
                              return;
                            }
                            viewModel.addItem(context);
                          },
                          child: Text('إضافة'),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // 11. جدول عرض الأصناف المضافة (إن وجدت)
                  if (viewModel.addedItems.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          // DataColumn(label: Text('رقم')),
                          DataColumn(label: Text('الصنف')),
                          DataColumn(label: Text('العدد')),
                          DataColumn(label: Text('المصدر')),
                          DataColumn(label: Text('حذف')),
                        ],
                        rows: List<DataRow>.generate(
                          viewModel.addedItems.length,
                          (index) {
                            final item = viewModel.addedItems[index];
                            return DataRow(
                              cells: [
                                // DataCell(Text((index + 1).toString())),
                                DataCell(Text(item.name)),
                                DataCell(Text(item.quantity.toString())),
                                DataCell(Text(item.source)),
                                DataCell(
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () =>
                                        viewModel.removeItem(index),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                  SizedBox(height: 20),

                  // 12. حقل الملاحظات
                  TextFormField(
                    controller: viewModel.notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'ملاحظات',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  // 13. زر الطباعة (يحفظ الطلب في Firestore ثم يعرض PDF)
                  ElevatedButton.icon(
                    onPressed: () => viewModel.generateAndPrintOrder(context),
                    icon: Icon(Icons.print),
                    label: Text('طباعة الطلب'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
