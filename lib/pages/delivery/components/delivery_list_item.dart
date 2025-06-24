
// delivery_list_item.dart
import 'package:flutter/material.dart';

class DeliveryListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const DeliveryListItem({Key? key, required this.item, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('单号：${item['trackingNumber']}', style: TextStyle(fontWeight: FontWeight.bold)),
                  Chip(
                    label: Text(item['deliveryMethod']?.toString() ?? ''),
                    backgroundColor: item['deliveryMethod'] == '上门'
                        ? Colors.blue.shade100
                        : Colors.green.shade100,
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text('订单来源：${item['orderSource']}'),
              SizedBox(height: 4),
              Text('收件人：${item['recipientName']} (${item['recipientPhone']})'),
              SizedBox(height: 4),
              Text('地址：${item['address']}'),
            ],
          ),
        ),
      ),
    );
  }
}
