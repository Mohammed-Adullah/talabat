// lib/views/item_management_screen.dart

import 'package:flutter/material.dart';
import 'package:talabat/views/add_item_screen.dart';
import 'package:talabat/views/delete_item_screen.dart';

class ItemManagementScreen extends StatelessWidget {
  const ItemManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('إدارة الأصناف'),
          bottom: TabBar(
            tabs: [
              Tab(text: "اضافة صنف"),
              Tab(text: "حذف صنف"),
            ],
          ),
        ),

        body: TabBarView(children: [AddItemScreen(), DeleteItemScreen()]),
      ),
    );
  }
}
