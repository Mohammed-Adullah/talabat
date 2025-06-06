import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum ItemType { aluminum, solidColor, woodColor }

class ItemManagementViewModel extends ChangeNotifier {
  ItemType? selectedItemType;

  void setItemType(ItemType? type) {
    selectedItemType = type;
    notifyListeners();
  }

  String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';
  // ألمنيوم
  final aluminumNameController = TextEditingController();

  // لون سادة
  final solidLocalCodeController = TextEditingController();
  // final solidOvenTempController = TextEditingController();
  // final solidOvenTimeController = TextEditingController();
  bool solidIsMixed = false;
  int solidMixCount = 1;
  bool _isLoading = false; // متغيّر لتتبّع حالة التحميل
  bool get isLoading => _isLoading;
  List<TextEditingController> solidSupplierCodeControllers = [
    TextEditingController(),
  ];
  List<TextEditingController> solidCompanyNameControllers = [
    TextEditingController(),
  ];

  void setSolidIsMixed(bool value) {
    solidIsMixed = value;
    if (!solidIsMixed) {
      solidMixCount = 1;
      solidSupplierCodeControllers = [TextEditingController()];
      solidCompanyNameControllers = [TextEditingController()];
    }
    notifyListeners();
  }

  void setSolidMixCount(int count) {
    solidMixCount = count;
    solidSupplierCodeControllers = List.generate(
      count,
      (_) => TextEditingController(),
    );
    solidCompanyNameControllers = List.generate(
      count,
      (_) => TextEditingController(),
    );
    notifyListeners();
  }

  // لون خشابي
  final woodLocalCodeController = TextEditingController();
  final woodFilmCodeController = TextEditingController();
  final woodOvenTempController = TextEditingController();
  final woodOvenTimeController = TextEditingController();
  bool woodIsMixed = false;
  int woodMixCount = 1;
  List<TextEditingController> woodSupplierCodeControllers = [
    TextEditingController(),
  ];
  List<TextEditingController> woodCompanyNameControllers = [
    TextEditingController(),
  ];

  void setWoodIsMixed(bool value) {
    woodIsMixed = value;
    if (!woodIsMixed) {
      woodMixCount = 1;
      woodSupplierCodeControllers = [TextEditingController()];
      woodCompanyNameControllers = [TextEditingController()];
    }
    notifyListeners();
  }

  void setWoodMixCount(int count) {
    woodMixCount = count;
    woodSupplierCodeControllers = List.generate(
      count,
      (_) => TextEditingController(),
    );
    woodCompanyNameControllers = List.generate(
      count,
      (_) => TextEditingController(),
    );
    notifyListeners();
  }

  Future<String> addItem() async {
    final firestore = FirebaseFirestore.instance;
    final uid = userId;
    // مساعدة: دالة للتحقق من وجود مستند بنفس القيمة في المجموعة المحددة
    Future<bool> exists(String collection, String field, String value) async {
      final query = await firestore
          .collection(collection)
          .where(field, isEqualTo: value)
          .where('userId', isEqualTo: uid)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    }

    if (selectedItemType == ItemType.aluminum) {
      final name = aluminumNameController.text.trim();

      if (name.isEmpty) {
        return 'يرجى إدخال  اسم قطاع الألمنيوم';
      }
      // تحقق أولاً إن كان هذا الاسم موجوداً بالفعل
      final alreadyAluminum = await exists(
        'aluminum_items',
        'sectorName',
        name,
      );
      if (alreadyAluminum) {
        return 'قطاع الألمنيوم هذا موجود مسبقاً';
      }

      _isLoading = true;
      notifyListeners();
      try {
        await firestore.collection('aluminum_items').add({
          'sectorName': name,
          'userId': uid,
        });
        clearFields();
        return ''; // يعني: نجح
      } catch (e) {
        return 'فشل في إضافة عنصر الألمنيوم';
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }

    if (selectedItemType == ItemType.solidColor) {
      final code = solidLocalCodeController.text.trim();
      if (code.isEmpty) {
        return 'يرجى إدخال رمز اللون المحلي';
      }
      final alreadySolid = await exists('solid_colors', 'localCode', code);
      if (alreadySolid) {
        return 'رمز اللون السادة هذا موجود مسبقاً';
      }
      // لكل مورد، يجب أن يكون paintCode و supplierName غير فارغين
      for (int i = 0; i < solidMixCount; i++) {
        final paintCode = solidSupplierCodeControllers[i].text.trim();
        final supplierName = solidCompanyNameControllers[i].text.trim();

        if (paintCode.isEmpty) {
          return 'يرجى إدخال رمز اللون الخاص بالمورد رقم ${i + 1}';
        }
        if (supplierName.isEmpty) {
          return 'يرجى إدخال اسم الشركة الموردة رقم ${i + 1}';
        }
      }

      // نجمع قائمة الموردين
      List<Map<String, String>> suppliers = [];
      for (int i = 0; i < solidMixCount; i++) {
        suppliers.add({
          'supplierName': solidCompanyNameControllers[i].text.trim(),
          'paintCode': solidSupplierCodeControllers[i].text.trim(),
        });
      }

      _isLoading = true;
      notifyListeners();
      try {
        await firestore.collection('solid_colors').add({
          'localCode': code,
          'suppliers': suppliers,
          'userId': uid,
        });
        clearFields();
        return ''; // نجاح
      } catch (e) {
        return 'فشل في إضافة اللون السادة';
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }

    if (selectedItemType == ItemType.woodColor) {
      final code = woodLocalCodeController.text.trim();
      final film = woodFilmCodeController.text.trim();
      final temp = int.tryParse(woodOvenTempController.text.trim()) ?? 0;
      final time = int.tryParse(woodOvenTimeController.text.trim()) ?? 0;

      if (film.isEmpty) {
        return 'يرجى إدخال رمز الفلم';
      }
      if (temp <= 150) {
        return 'يرجى إدخال درجة حرارة صحيحة (> 150)';
      }
      if (time == 0) {
        return 'يرجى إدخال الوقت اللازم للتخشيب';
      }
      if (code.isEmpty) {
        return 'يرجى إدخال رمز اللون المحلي';
      }
      // تحقق وجود رمز اللون مسبقاً
      final alreadyWood = await exists('wood_colors', 'localCode', code);
      if (alreadyWood) {
        return 'رمز اللون الخشابي هذا موجود مسبقاً';
      }

      for (int i = 0; i < woodMixCount; i++) {
        final paintCode = woodSupplierCodeControllers[i].text.trim();
        final supplierName = woodCompanyNameControllers[i].text.trim();
        if (paintCode.isEmpty) {
          return 'يرجى إدخال رمز اللون الخاص بالمورد رقم ${i + 1}';
        }
        if (supplierName.isEmpty) {
          return 'يرجى إدخال اسم الشركة الموردة رقم ${i + 1}';
        }
      }

      List<Map<String, String>> suppliers = [];
      for (int i = 0; i < woodMixCount; i++) {
        suppliers.add({
          'supplierName': woodCompanyNameControllers[i].text.trim(),
          'paintCode': woodSupplierCodeControllers[i].text.trim(),
        });
      }
      _isLoading = true;
      notifyListeners();

      try {
        await firestore.collection('wood_colors').add({
          'localCode': code,
          'filmCode': film,
          'suppliers': suppliers,
          'ovenTemperature': temp,
          'ovenTime': time,
          'userId': uid,
        });
        clearFields();
        return ''; // نجاح
      } catch (e) {
        return 'فشل في إضافة اللون الخشابي';
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }

    clearFields(); // 🧹 تفريغ الحقول بعد الإضافة
    notifyListeners();
    // إذا لم يُحدد نوع، نعيد خطأ
    return 'يرجى اختيار نوع الصنف أولاً';
  }

  void clearFields() {
    // ألمنيوم
    aluminumNameController.clear();

    // سادة
    solidLocalCodeController.clear();
    // solidOvenTempController.clear();
    // solidOvenTimeController.clear();
    for (var c in solidSupplierCodeControllers) {
      c.clear();
    }
    for (var c in solidCompanyNameControllers) {
      c.clear();
    }

    // خشابي
    woodLocalCodeController.clear();
    woodFilmCodeController.clear();
    woodOvenTempController.clear();
    woodOvenTimeController.clear();
    for (var c in woodSupplierCodeControllers) {
      c.clear();
    }
    for (var c in woodCompanyNameControllers) {
      c.clear();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    aluminumNameController.dispose();

    solidLocalCodeController.dispose();
    // solidOvenTempController.dispose();
    // solidOvenTimeController.dispose();
    for (var c in solidSupplierCodeControllers) {
      c.dispose();
    }
    for (var c in solidCompanyNameControllers) {
      c.dispose();
    }

    woodLocalCodeController.dispose();
    woodFilmCodeController.dispose();
    woodOvenTempController.dispose();
    woodOvenTimeController.dispose();
    for (var c in woodSupplierCodeControllers) {
      c.dispose();
    }
    for (var c in woodCompanyNameControllers) {
      c.dispose();
    }

    super.dispose();
  }

  /// يجلب قائمة الأسماء/الأكواد المحفوظة في الـ Firestore
  /// بناءً على الـ selectedItemType الحالي.
  Future<List<String>> fetchItemsForCategory() async {
    final firestore = FirebaseFirestore.instance;
    String collectionName;
    String fieldName;
    final uid = userId;

    switch (selectedItemType) {
      case ItemType.aluminum:
        collectionName = 'aluminum_items';
        fieldName = 'sectorName';
        break;
      case ItemType.solidColor:
        collectionName = 'solid_colors';
        fieldName = 'localCode';
        break;
      case ItemType.woodColor:
        collectionName = 'wood_colors';
        fieldName = 'localCode';
        break;
      default:
        return [];
    }

    try {
      final querySnapshot = await firestore
          .collection(collectionName)
          .where('userId', isEqualTo: uid)
          .orderBy(fieldName)
          .get();

      // نحول كل وثيقة إلى اسم/كود (String)
      final List<String> result = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            final value = data[fieldName];
            return (value is String) ? value : '';
          })
          .where((s) => s.isNotEmpty)
          .toList();

      return result;
    } catch (e) {
      // في حال وجود خطأ، نعيد قائمة فارغة
      return [];
    }
  }

  /// يحذف عنصر واحد من الـ Firestore بناءً على اسمه/الكود.
  /// يعيد true إذا نجحت عملية الحذف، false خلاف ذلك.
  Future<bool> deleteItemByName(String nameToDelete) async {
    final firestore = FirebaseFirestore.instance;
    String collectionName;
    String fieldName;
    final uid = userId;

    switch (selectedItemType) {
      case ItemType.aluminum:
        collectionName = 'aluminum_items';
        fieldName = 'sectorName';
        break;
      case ItemType.solidColor:
        collectionName = 'solid_colors';
        fieldName = 'localCode';
        break;
      case ItemType.woodColor:
        collectionName = 'wood_colors';
        fieldName = 'localCode';
        break;
      default:
        return false;
    }
    _isLoading = true;
    notifyListeners();
    try {
      // نبحث عن الوثيقة التي تحتوي على الحقل بقيمة nameToDelete
      final querySnapshot = await firestore
          .collection(collectionName)
          .where(fieldName, isEqualTo: nameToDelete)
          .where('userId', isEqualTo: uid) // ← إضافة هذا الشرط
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // إذا لم نجد أي وثيقة بنفس الاسم/الكود
        return false;
      }

      // نحصل على الـ document ID للأول (من المفترض أن يكون وحيدًا أو مرتبطة بمفتاح فريد)
      final docId = querySnapshot.docs.first.id;

      // ننفذ الحذف
      await firestore.collection(collectionName).doc(docId).delete();

      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
