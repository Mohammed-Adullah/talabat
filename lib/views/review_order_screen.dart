import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../models/order_item.dart';
import '../viewmodels/review_order_viewmodel.dart';

class ReviewOrderScreen extends StatelessWidget {
  const ReviewOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReviewOrderViewModel(),
      child: Scaffold(
        appBar: AppBar(title: Text('مراجعة طلب')),
        body: Consumer<ReviewOrderViewModel>(
          builder: (context, vm, _) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // حقل إدخال رقم الطلب (المستخدم يكتب الجزء الرقمي فقط)
                  TextFormField(
                    controller: vm.orderNumberController,
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // ✅ يمنع أي شيء غير رقم
                    ],
                    decoration: InputDecoration(
                      labelText: 'رمز الطلب',
                      prefixText: 'ORD-',
                    ),
                  ),
                  SizedBox(height: 10),

                  // زر البحث لاسترجاع بيانات الطلب
                  ElevatedButton(
                    onPressed: () async {
                      await vm.fetchOrder(context);
                      if (!vm.notFound) {
                        // بعد إيجاد الطلب، نعيد تهيئة قوائم الاقتراح
                        await vm.initializeSuggestions();
                      }
                    },
                    child: Text('بحث'),
                  ),

                  SizedBox(height: 20),

                  // إذا لم يتم العثور على الطلب
                  if (vm.notFound)
                    Text(
                      'لم يتم العثور على الطلب',
                      style: TextStyle(color: Colors.red),
                    ),

                  // إذا عُثر على الأصناف ضمن الطلب
                  if (vm.items.isNotEmpty) ...[
                    // DropdownSearch لرمز اللون المحلي
                    DropdownSearch<String>(
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            labelText: 'بحث عن رمز اللون',
                          ),
                        ),
                      ),
                      asyncItems: (String filter) =>
                          vm.fetchColorSuggestions(filter),
                      selectedItem: vm.localColorCode,
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'رمز اللون المحلي',
                        ),
                      ),
                      onChanged: (val) {
                        if (val != null) vm.localColorCode = val;
                      },
                      validator: (value) {
                        if (value == null ||
                            !vm.validColorCodes.contains(value)) {
                          return 'رمز اللون غير موجود في قاعدة البيانات';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16),
                    Text(
                      'الأصناف:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    // قائمة الأصناف الموجودة في الطلب
                    ...List.generate(vm.items.length, (index) {
                      final item = vm.items[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              // DropdownSearch لاسم الصنف مع البحث
                              Expanded(
                                child: DropdownSearch<String>(
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        labelText: 'بحث عن صنف',
                                      ),
                                    ),
                                  ),
                                  asyncItems: (String filter) =>
                                      vm.fetchItemSuggestions(filter),
                                  selectedItem:
                                      item.name.isNotEmpty &&
                                          vm.validItemNames.contains(item.name)
                                      ? item.name
                                      : null,
                                  dropdownDecoratorProps:
                                      DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(labelText: 'الصنف'),
                                      ),
                                  onChanged: (val) {
                                    if (val != null) {
                                      vm.updateItem(
                                        index,
                                        OrderItem(
                                          name: val,
                                          quantity: item.quantity,
                                          source: item.source,
                                        ),
                                      );
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null ||
                                        !vm.validItemNames.contains(value)) {
                                      return 'الصنف غير موجود في قاعدة البيانات';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              SizedBox(width: 10),

                              // حقل إدخال العدد
                              SizedBox(
                                width: 80,
                                child: TextFormField(
                                  initialValue: item.quantity.toString(),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .digitsOnly, // ✅ يمنع أي شيء غير رقم
                                  ],
                                  decoration: InputDecoration(
                                    labelText: 'العدد',
                                  ),
                                  onChanged: (val) {
                                    vm.updateItem(
                                      index,
                                      OrderItem(
                                        name: item.name,
                                        quantity: int.tryParse(val) ?? 0,
                                        source: item.source,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 8),

                              // **زر الحذف بجانب كل صنف**
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  // استدعاء دالة الحذف في الـ ViewModel
                                  vm.removeItem(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    SizedBox(height: 10),
                    // زر إضافة صنف جديد فارغ
                    ElevatedButton.icon(
                      icon: Icon(Icons.add),
                      label: Text('إضافة صنف جديد'),
                      onPressed: vm.addItem,
                    ),

                    SizedBox(height: 20),
                    // زر لحفظ التعديلات
                    ElevatedButton(
                      onPressed: () async {
                        vm.saveChanges(context);
                      },
                      child: Text('حفظ التعديلات'),
                    ),

                    SizedBox(height: 10),
                    // زر لطباعة تفاصيل الطلب
                    ElevatedButton.icon(
                      icon: Icon(Icons.print),
                      label: Text('طباعة'),
                      onPressed: () async {
                        await vm.printOrder(context);
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
