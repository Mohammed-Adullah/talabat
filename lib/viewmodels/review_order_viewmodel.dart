import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import '../models/order_item.dart';

class ReviewOrderViewModel extends ChangeNotifier {
  /// Controller لحقل رقم الطلب (بدون "ORD-")
  final TextEditingController orderNumberController = TextEditingController();

  /// رمز اللون المحلي المُحدَّد
  String? localColorCode;

  /// قائمة الأصناف (مأخوذة من الطلب)
  List<OrderItem> items = [];

  /// إشعار بعدم العثور على الطلب
  bool notFound = false;

  /// معرّف الوثيقة الأصلية (لعمليات التعديل)
  String? _docId;

  /// قائمة بأسماء الأصناف الصالحة (للنص التنبؤي والتحقق)
  List<String> validItemNames = [];

  /// قائمة برموز الألوان المحلية الصالحة (للنص التنبؤي والتحقق)
  List<String> validColorCodes = [];

  /// (اختياري) يمكنك الاحتفاظ بباقي حقول الطلب هنا (مثل: اسم الزبون، التاريخ، ...)
  String? customerName;
  String? date;
  String? colorType;
  String? filmCode;
  int? ovenTemp;
  int? ovenTime;
  List<Map<String, String>> suppliers = [];

  /// حدِّث صنفًا في الموضع [index] بالقيمة [item]، ثم أنذِر المستمعين
  void updateItem(int index, OrderItem item) {
    items[index] = item;
    notifyListeners();
  }

  /// أضف صنفًا جديدًا فارغًا
  void addItem() {
    items.add(OrderItem(name: '', quantity: 0, source: 'المستودع'));
    notifyListeners();
  }

  /// دالة لإزالة صنف من القائمة
  void removeItem(int index) {
    items.removeAt(index);
    notifyListeners();
  }

  /// بعد العثور على الطلب بنجاح، إعيد تهيئة قوائم الاقتراحات
  Future<void> initializeSuggestions() async {
    validItemNames = await fetchItemSuggestions('');
    validColorCodes = await fetchColorSuggestions('');
    notifyListeners();
  }

  /// ابحث عن الطلب في Firestore بناءً على [orderNumberController.text]
  Future<void> fetchOrder(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final orderNumber = 'ORD-${orderNumberController.text.trim()}';
    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('orderNumber', isEqualTo: orderNumber)
        .where('userId', isEqualTo: uid)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      notFound = true;
      items = [];
      notifyListeners();
      return;
    }

    final doc = snapshot.docs.first;
    final data = doc.data();
    _docId = doc.id;

    // عَبِّر الحقول الأخرى إذا احتجت (مثل اسم الزبون وتاريخ الإنشاء)
    customerName = data['customerName'] as String?;
    date = data['date'] as String?;
    localColorCode = data['localColorCode'] as String?;
    colorType = data['colorType'] as String?;
    filmCode = data['filmCode'] as String?;
    ovenTemp = data['ovenTemp'] as int?;
    ovenTime = data['ovenTime'] as int?;
    suppliers =
        (data['suppliers'] as List<dynamic>?)
            ?.map<Map<String, String>>(
              (s) => {
                'paintCode': s['paintCode'].toString(),
                'supplierName': s['supplierName'].toString(),
              },
            )
            .toList() ??
        [];

    final itemList = data['items'] as List<dynamic>? ?? [];
    items = itemList.map((e) {
      return OrderItem(
        name: e['name'] as String? ?? '',
        quantity: e['quantity'] as int? ?? 0,
        source: e['source'] as String? ?? '',
      );
    }).toList();

    notFound = false;
    notifyListeners();
  }

  /// حفظ التعديلات على الطلب في Firestore
  Future<void> saveChanges(BuildContext context) async {
    if (_docId == null) return;
    final validItems = items
        .where((item) => item.name.trim().isNotEmpty)
        .toList();
    for (var item in validItems) {
      if (item.quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('الكمية يجب أن تكون أكبر من صفر لكل الأصناف'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }
    for (var item in items) {
      if (item.name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تحقق احدى الاصناف فارغة'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }
    final updatedData = {
      'localColorCode': localColorCode,
      'items': items
          .map(
            (e) => {'name': e.name, 'quantity': e.quantity, 'source': e.source},
          )
          .toList(),
      'updatedAt': Timestamp.now(),
    };

    await FirebaseFirestore.instance
        .collection('orders')
        .doc(_docId)
        .update(updatedData);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حفظ التعديلات')));

    clear();
  }

  /// مسح النموذج بعد الحفظ أو تفريغ البيانات
  void clear() {
    orderNumberController.clear();
    localColorCode = null;
    customerName = null;
    date = null;
    colorType = null;
    filmCode = null;
    ovenTemp = null;
    ovenTime = null;
    suppliers = [];
    items.clear();
    notFound = false;
    notifyListeners();
  }

  /// طباعة تفاصيل الطلب بنفس صيغة إنشاء الطلب
  Future<void> printOrder(BuildContext context) async {
    final pdf = pw.Document();
    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Almarai-Regular.ttf'),
    );
    if (_docId == null) return;
    final validItems = items
        .where((item) => item.name.trim().isNotEmpty)
        .toList();
    for (var item in validItems) {
      if (item.quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('الكمية يجب أن تكون أكبر من صفر لكل الأصناف'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }
    for (var item in items) {
      if (item.name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تحقق احدى الاصناف فارغة'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    pdf.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'تفاصيل الطلب',
                style: pw.TextStyle(font: font, fontSize: 24),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'رمز الطلب: ORD-${orderNumberController.text.trim()}',
                style: pw.TextStyle(font: font),
              ),
              if (customerName != null)
                pw.Text(
                  'اسم الزبون: $customerName',
                  style: pw.TextStyle(font: font),
                ),
              if (date != null)
                pw.Text('التاريخ: $date', style: pw.TextStyle(font: font)),
              if (localColorCode != null)
                pw.Text(
                  'رمز اللون: $localColorCode',
                  style: pw.TextStyle(font: font),
                ),
              if (colorType != null)
                pw.Text(
                  'نوع اللون: $colorType',
                  style: pw.TextStyle(font: font),
                ),
              if (filmCode != null)
                pw.Text(
                  'رمز الفلم: $filmCode',
                  style: pw.TextStyle(font: font),
                ),
              if (ovenTemp != null)
                pw.Text(
                  'درجة الحرارة: $ovenTemp',
                  style: pw.TextStyle(font: font),
                ),
              if (ovenTime != null)
                pw.Text(
                  'مدة الفرن: $ovenTime دقيقة',
                  style: pw.TextStyle(font: font),
                ),
              ...suppliers.map(
                (s) => pw.Text(
                  'رمز البويا: ${s['paintCode']} - المورد: ${s['supplierName']}',
                  style: pw.TextStyle(font: font),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'الأصناف:',
                style: pw.TextStyle(font: font, fontSize: 18),
              ),
              pw.Table.fromTextArray(
                headers: ['#', 'الصنف', 'العدد', 'المصدر'],
                data: List.generate(items.length, (index) {
                  final item = items[index];
                  return [
                    '${index + 1}',
                    item.name,
                    item.quantity.toString(),
                    item.source,
                  ];
                }),
                cellStyle: pw.TextStyle(font: font),
                headerStyle: pw.TextStyle(
                  font: font,
                  fontWeight: pw.FontWeight.bold,
                ),
                cellAlignment: pw.Alignment.centerRight,
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    final updatedData = {
      'localColorCode': localColorCode,
      'items': items
          .map(
            (e) => {'name': e.name, 'quantity': e.quantity, 'source': e.source},
          )
          .toList(),
      'updatedAt': Timestamp.now(),
    };
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(_docId)
        .update(updatedData);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حفظ التعديلات')));
    clear();
  }

  /// جلب اقتراحات أسماء الأصناف من بيز البيانات (ألمنيوم)
  Future<List<String>> fetchItemSuggestions(String filter) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('aluminum_items')
        .where('userId', isEqualTo: uid)
        .get();

    final allNames = snapshot.docs
        .map((doc) => (doc.data()['sectorName'] as String?) ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    if (filter.isEmpty) return allNames;
    return allNames
        .where((name) => name.toLowerCase().contains(filter.toLowerCase()))
        .toList();
  }

  /// جلب اقتراحات رموز اللون المحلية (سادة + خشابي)
  Future<List<String>> fetchColorSuggestions(String filter) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final solidSnapshot = await FirebaseFirestore.instance
        .collection('solid_colors')
        .where('userId', isEqualTo: uid)
        .get();

    final woodSnapshot = await FirebaseFirestore.instance
        .collection('wood_colors')
        .where('userId', isEqualTo: uid)
        .get();

    final solidCodes = solidSnapshot.docs
        .map((doc) => (doc.data()['localCode'] as String?) ?? '')
        .where((code) => code.isNotEmpty);
    final woodCodes = woodSnapshot.docs
        .map((doc) => (doc.data()['localCode'] as String?) ?? '')
        .where((code) => code.isNotEmpty);

    final allCodes = <String>[...solidCodes, ...woodCodes];

    if (filter.isEmpty) return allCodes;
    return allCodes
        .where((code) => code.toLowerCase().contains(filter.toLowerCase()))
        .toList();
  }
}
