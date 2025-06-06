import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/order_item.dart';
import 'package:pdf/widgets.dart' as pw;

class NewOrderViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers للحقول
  final TextEditingController orderNumberController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController dateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
  final TextEditingController localColorCodeController =
      TextEditingController();
  final TextEditingController itemController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Regex للتحقق من الأحرف والأرقام
  final RegExp lettersOnly = RegExp(r'^[\u0600-\u06FF\s]+$');
  final RegExp numbersOnly = RegExp(r'^\d+$');

  // قوائم الاقتراح (سَتُملأ من Firestore)
  List<String> validItemNames = [];
  List<String> validColorCodes = [];

  // بيانات الأصناف المضافة لهذا الطلب
  List<OrderItem> addedItems = [];
  bool fromWarehouse = true;

  // معلومات اللون بعد اختيار الرمز
  String? colorType;
  String? filmCode;
  List<Map<String, String>> suppliers = [];
  int? ovenTemp;
  int? ovenTime;
  bool _isDisposed = false;

  NewOrderViewModel() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    // قبل كل شيء، تأكد أنّه لم يدمَّر ViewModel
    if (_isDisposed) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      // إذا لم يكن المستخدم مسجّل دخول، نحاول إعادة المحاولة بعد لحظة بسيطة
      Future.delayed(Duration(milliseconds: 200), () {
        if (!_isDisposed) {
          _initializeData();
        }
      });
      return;
    }

    await initializeOrderNumber();
    if (_isDisposed) return; // بعد كل await
    await loadItemNames();
    if (_isDisposed) return;
    await loadColorCodes();
  }

  /// يولّد رقم الطلب ثلاثي الخانات (001→999 ثم يعود 001)
  Future<void> initializeOrderNumber() async {
    if (_isDisposed) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;

    // نأخذ كل طلبات هذا المستخدم ونستخلص أكبر رقم منها
    final snapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .get();

    if (_isDisposed) return;

    int maxNumeric = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final orderStr = data['orderNumber'] as String?; // مثل "ORD-045"
      if (orderStr != null && orderStr.startsWith('ORD-')) {
        final parsed = int.tryParse(orderStr.replaceAll('ORD-', ''));
        if (parsed != null && parsed > maxNumeric) {
          maxNumeric = parsed;
        }
      }
    }

    final nextNumeric = (maxNumeric >= 999) ? 1 : (maxNumeric + 1);
    final formatted = nextNumeric.toString().padLeft(3, '0'); // "001" .. "999"
    orderNumberController.text = 'ORD-$formatted';
    // لا داعي لـ notify هنا لأن الكائن قد يكون جديداً ولم يُستمع إليه بعد
  }

  /// يحمل أسماء أصناف الألمنيوم الخاصة بالمستخدم
  Future<void> loadItemNames() async {
    if (_isDisposed) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await _firestore
        .collection('aluminum_items')
        .where('userId', isEqualTo: uid)
        .get();

    if (_isDisposed) return; // مهم جداً بعد انتهاء الـ Future

    validItemNames = snapshot.docs
        .map((doc) => (doc.data()['sectorName'] as String?) ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    _safeNotify();
  }

  /// يحمل رموز الألوان المحلية (سادة + خشابي) الخاصة بالمستخدم
  Future<void> loadColorCodes() async {
    if (_isDisposed) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final solidSnapshot = await _firestore
        .collection('solid_colors')
        .where('userId', isEqualTo: uid)
        .get();

    if (_isDisposed) return;

    final woodSnapshot = await _firestore
        .collection('wood_colors')
        .where('userId', isEqualTo: uid)
        .get();

    if (_isDisposed) return;

    final solidCodes = solidSnapshot.docs
        .map((doc) => (doc.data()['localCode'] as String?) ?? '')
        .where((c) => c.isNotEmpty);
    final woodCodes = woodSnapshot.docs
        .map((doc) => (doc.data()['localCode'] as String?) ?? '')
        .where((c) => c.isNotEmpty);

    validColorCodes = [...solidCodes, ...woodCodes];
    _safeNotify();
  }

  /// يرجع قائمة أسماء الأصناف بعد فلترة (للـ DropdownSearch)
  Future<List<String>> fetchItemSuggestions(String filter) async {
    if (_isDisposed) return []; // أو تعيد القائمة الفارغة

    if (validItemNames.isEmpty) {
      // إذا القائمة لا تزال فارغة، نحمّلها أولاً
      await loadItemNames();
      if (_isDisposed) return [];
    }
    if (filter.trim().isEmpty) return validItemNames;
    return validItemNames
        .where(
          (name) => name.toLowerCase().contains(filter.trim().toLowerCase()),
        )
        .toList();
  }

  /// يرجع قائمة رموز الألوان بعد فلترة (للـ DropdownSearch)
  Future<List<String>> fetchColorSuggestions(String filter) async {
    if (_isDisposed) return [];

    if (validColorCodes.isEmpty) {
      // إذا القائمة لا تزال فارغة، نحمّلها أولاً
      await loadColorCodes();
      if (_isDisposed) return [];
    }
    if (filter.trim().isEmpty) return validColorCodes;
    return validColorCodes
        .where(
          (code) => code.toLowerCase().contains(filter.trim().toLowerCase()),
        )
        .toList();
  }

  /// تبديل مصدر الصنف (المستودع ↔ الزبون)
  void toggleSource(bool value) {
    if (_isDisposed) return;
    fromWarehouse = value;
    _safeNotify();
  }

  /// إضافة صنف جديد إلى قائمة الأصناف المضافة
  void addItem(BuildContext context) {
    if (_isDisposed) return;

    final int quantity = int.tryParse(quantityController.text) ?? 0;
    if (quantity == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب أن يكون عدد الأصناف أكبر من 0'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    addedItems.add(
      OrderItem(
        name: itemController.text,
        quantity: quantity,
        source: fromWarehouse ? 'المستودع' : 'الزبون',
      ),
    );
    itemController.clear();
    quantityController.clear();
    _safeNotify();
  }

  /// إزالة صنف من قائمة الأصناف
  void removeItem(int index) {
    if (_isDisposed) return;
    addedItems.removeAt(index);
    _safeNotify();
  }

  /// إنشاء وطباعة ملف PDF ثم حفظ الطلب في Firestore
  Future<void> generateAndPrintOrder(BuildContext context) async {
    if (_isDisposed) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('المستخدم غير مُسجّل')));
      return;
    }

    // تأكد من وجود رمز لون محلي وصنف واحد على الأقل
    if (localColorCodeController.text.trim().isEmpty) {
      _showError(context, 'يرجى اختيار رمز اللون المحلي');
      return;
    }
    if (addedItems.isEmpty) {
      _showError(context, 'يرجى إضافة صنف واحد على الأقل');
      return;
    }

    if (_isDisposed) return;

    // بناء مستند PDF
    final pdf = pw.Document();
    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Almarai-Regular.ttf'),
    );

    if (_isDisposed) return;

    pdf.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          // قبل بناء الـWidget الخاص بالـPDF تأكد أنّه لم يُدمّر
          if (_isDisposed) {
            return pw.Center(child: pw.Text('تم إلغاء العملية'));
          }
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'تفاصيل الطلب',
                style: pw.TextStyle(font: font, fontSize: 24),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'رقم الطلب: ${orderNumberController.text}',
                style: pw.TextStyle(font: font),
              ),
              pw.Text(
                'اسم الزبون: ${customerNameController.text}',
                style: pw.TextStyle(font: font),
              ),
              pw.Text(
                'التاريخ: ${dateController.text}',
                style: pw.TextStyle(font: font),
              ),
              pw.Text(
                'رمز اللون: ${localColorCodeController.text}',
                style: pw.TextStyle(font: font),
              ),
              if (colorType != null)
                pw.Text(
                  'نوع اللون: $colorType',
                  style: pw.TextStyle(font: font),
                ),
              if (suppliers.isNotEmpty)
                ...suppliers.map(
                  (s) => pw.Text(
                    'رمز البويا: ${s['paintCode']}\n - الشركة: ${s['supplierName']}',
                    style: pw.TextStyle(font: font),
                  ),
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
              pw.SizedBox(height: 10),
              pw.Text(
                'ملاحظات: ${notesController.text}',
                style: pw.TextStyle(font: font),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'الأصناف:',
                style: pw.TextStyle(font: font, fontSize: 18),
              ),
              pw.TableHelper.fromTextArray(
                headers: ['المصدر', 'العدد', 'الصنف'],
                data: List.generate(addedItems.length, (index) {
                  final item = addedItems[index];
                  return [item.source, item.quantity.toString(), item.name];
                }),
                cellStyle: pw.TextStyle(font: font),
                headerStyle: pw.TextStyle(
                  font: font,
                  fontWeight: pw.FontWeight.bold,
                ),
                cellAlignment: pw.Alignment.center,
              ),
            ],
          );
        },
      ),
    );

    if (_isDisposed) return;
    // عرض واجهة الطباعة
    await Printing.layoutPdf(
      onLayout: (format) async {
        if (_isDisposed) return Uint8List(0);
        return pdf.save();
      },
    );

    if (_isDisposed) return;
    // حفظ الطلب في Firestore
    final orderData = {
      'orderNumber': orderNumberController.text,
      'customerName': customerNameController.text,
      'date': dateController.text, // نص “yyyy-MM-dd”
      'orderTimestamp': FieldValue.serverTimestamp(), // ← الحقل الجديد
      'localColorCode': localColorCodeController.text,
      'colorType': colorType,
      'filmCode': filmCode,
      'ovenTemp': ovenTemp,
      'ovenTime': ovenTime,
      'suppliers': suppliers,
      'items': addedItems
          .map(
            (item) => {
              'name': item.name,
              'quantity': item.quantity,
              'source': item.source,
            },
          )
          .toList(),
      'notes': notesController.text,
      'userId': user.uid,
    };
    await _firestore.collection('orders').add(orderData);

    if (_isDisposed) return;
    // تفريغ الحقول بعد الحفظ
    customerNameController.clear();
    localColorCodeController.clear();
    itemController.clear();
    quantityController.clear();
    notesController.clear();
    addedItems.clear();
    colorType = null;
    filmCode = null;
    ovenTemp = null;
    ovenTime = null;
    suppliers.clear();
    await initializeOrderNumber(); // إعادة توليد رقم الطلب
    if (_isDisposed) return;
    _safeNotify();
  }

  /// يبحث عن بيانات اللون في Firestore بناءً على الرمز
  Future<void> lookupColorData(String code) async {
    if (_isDisposed) return;

    DocumentSnapshot? doc;

    final solidQuery = await _firestore
        .collection('solid_colors')
        .where('localCode', isEqualTo: code)
        .get();
    if (_isDisposed) return;

    final woodQuery = await _firestore
        .collection('wood_colors')
        .where('localCode', isEqualTo: code)
        .get();
    if (_isDisposed) return;

    suppliers.clear();
    ovenTemp = null;
    ovenTime = null;
    filmCode = null;
    colorType = null;

    if (solidQuery.docs.isNotEmpty) {
      doc = solidQuery.docs.first;
      colorType = 'سادة';
    } else if (woodQuery.docs.isNotEmpty) {
      doc = woodQuery.docs.first;
      colorType = 'خشابي';
    }

    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      ovenTemp = data['ovenTemperature'] as int?;
      ovenTime = data['ovenTime'] as int?;
      filmCode = data['filmCode'] as String?;

      if (data['suppliers'] != null) {
        for (var supplier in data['suppliers']) {
          suppliers.add({
            'paintCode': supplier['paintCode'] as String,
            'supplierName': supplier['supplierName'] as String,
          });
        }
      }
    }

    _safeNotify();
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    // أفضَل دائمًا أنْ تتخلّص من جميع TextEditingController هنا أيضًا:
    orderNumberController.dispose();
    customerNameController.dispose();
    dateController.dispose();
    localColorCodeController.dispose();
    itemController.dispose();
    quantityController.dispose();
    notesController.dispose();
    // أيّ Controllers أو StreamSubscriptions أخرى

    _isDisposed = true;
    super.dispose();
  }

  /// هذه الطريقة تستخدم بدل notifyListeners()
  void _safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
