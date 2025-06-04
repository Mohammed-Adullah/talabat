// هذا الكلاس يمثل معلومات اللون التي يتم جلبها بناءً على الرمز المحلي

class ColorInfo {
  // نوع اللون (مثل: sada, wood, mix, wood_mix)
  final String? type;

  // رمز المورد في حال كان اللون فردي (sada أو wood)
  final String? supplierCode;

  // قائمة برموز الموردين في حال كان اللون مزيج (mix أو wood_mix)
  final List<String>? supplierCodes;

  // اسم الشركة المصنعة أو الموردة
  final String? company;

  // رمز الفيلم المرتبط باللون (إن وجد)
  final String? filmCode;

  // الباني الأساسي للكلاس، جميع الحقول اختيارية
  ColorInfo({
    this.type,
    this.supplierCode,
    this.supplierCodes,
    this.company,
    this.filmCode,
  });
}
