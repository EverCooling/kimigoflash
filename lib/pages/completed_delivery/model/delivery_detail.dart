// order_model.dart
import 'dart:convert';

class DeliveryDetail {
  final int id;
  final String orderNumber;
  final String trackingNumber;
  final String recipientName;
  final String recipietnMobile;
  final String recipetenAddressFirst;
  final String kyInStorageNumber;
  final dynamic signForType; // 原数据为 null
  final String signForImg; // 注意：这是一个 JSON 字符串，而非数组
  final dynamic signature; // 原数据为 null
  final List<OrderItem> deliveryCustomerOrderDetailViewList;
  final int pcsCount;

  DeliveryDetail({
    required this.id,
    required this.orderNumber,
    required this.trackingNumber,
    required this.recipientName,
    required this.recipietnMobile,
    required this.recipetenAddressFirst,
    required this.kyInStorageNumber,
    required this.signForType,
    required this.signForImg,
    required this.signature,
    required this.deliveryCustomerOrderDetailViewList,
    required this.pcsCount,
  });

  factory DeliveryDetail.fromJson(Map<String, dynamic> json) {
    return DeliveryDetail(
      id: json['id'] ?? 0,
      orderNumber: json['orderNumber'] ?? '',
      trackingNumber: json['trackingNumber'] ?? '',
      recipientName: json['recipientName'] ?? '',
      recipietnMobile: json['recipietnMobile'] ?? '',
      recipetenAddressFirst: json['recipetenAddressFirst'] ?? '',
      kyInStorageNumber: json['kyInStorageNumber'] ?? '',
      signForType: json['signForType'],
      signForImg: json['signForImg'] ?? '',
      signature: json['signature'],
      deliveryCustomerOrderDetailViewList: (json['deliveryCustomerOrderDetailViewList'] as List?)
          ?.map<OrderItem>((item) => OrderItem.fromJson(item))
          .toList() ??
          [],
      pcsCount: json['pcsCount'] ?? 0,
    );
  }

  // 解析 signForImg 字段中的 JSON 字符串为 List<String>
  List<String> get signForImageUrls {
    try {
      if (signForImg.isEmpty) return [];
      return List<String>.from(json.decode(signForImg));
    } catch (e) {
      print('解析签名图片 URL 失败: $e');
      return [];
    }
  }
}

class OrderItem {
  final String brandEnglishName;
  final int pcs;

  OrderItem({
    required this.brandEnglishName,
    required this.pcs,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      brandEnglishName: json['brandEnglishName'] ?? '',
      pcs: json['pcs'] ?? 0,
    );
  }
}