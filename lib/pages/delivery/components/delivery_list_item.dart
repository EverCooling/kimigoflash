
// delivery_list_item.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const DeliveryListItem({Key? key, required this.item, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8,horizontal: 12),
        child: ListTile(
          // leading: Icon(Icons.assignment_outlined), // 单号图标
          minVerticalPadding: 16,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text('单号：${item['kyInStorageNumber'] ?? ''}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Row(children: [
                Icon(Icons.shop_outlined, size: 16, color: Colors.red), // 订单来源图标
                SizedBox(width: 4),
                Text('订单来源：${item['orderSource'] ?? ''}'),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Icon(Icons.person_outline, size: 16, color: Colors.red), // 收件人图标
                SizedBox(width: 4),
                Text('收件人：${item['recipientName'] ?? ''}'),
              ]),
              SizedBox(height: 10),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 16, color: Colors.red), // 地址图标
                SizedBox(width: 4),
                Text('地址：${item['recipetenAddressFirst'] ?? ''}${item['recipetenAddressSecond'] ?? ''}${item['recipetenAddressThid'] ?? ''}'),
                GestureDetector(
                  onTap: () => _showMapOptions(context),
                  child: Icon(Icons.open_in_new, color: Colors.blue),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _showMapOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Google 地图'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 使用 url_launcher 打开 Google Maps
                  launchUrl(Uri.parse('https://maps.google.com/?q=${item['recipetenAddressFirst']}'));
                },
              ),
              ListTile(
                title: Text('2Gis'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 使用 url_launcher 打开 2Gis
                  launchUrl(Uri.parse('https://2gis.com/?q=${item['recipetenAddressFirst']}'));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
