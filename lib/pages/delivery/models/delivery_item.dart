
class DeliveryItem {
  final Map<String, dynamic> data;

  DeliveryItem(this.data);

  String get kyInStorageNumber => data['kyInStorageNumber'] ?? '';
  String get recipientName => data['recipientName'] ?? '';
  String get recipetenAddressFirst => data['recipetenAddressFirst'] ?? '';
  String get recipetenAddressSecond => data['recipetenAddressSecond'] ?? '';
  String get recipetenAddressThid => data['recipetenAddressThid'] ?? '';
  int get pcscount => data['pcscount'] as int? ?? 0;
  List<dynamic> get category1Items => data['category1Items'] as List<dynamic>? ?? [];
  List<dynamic> get category2Items => data['category2Items'] as List<dynamic>? ?? [];
}