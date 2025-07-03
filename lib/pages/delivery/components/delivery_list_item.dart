import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 新增：用于HapticFeedback
import 'package:kimiflash/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

enum DeliveryStatus {
  pending,   // 待派
  delivered, // 已派
  failed,    // 失败
  unknown    // 未知
}

class DeliveryListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final DeliveryStatus status;

  const DeliveryListItem({
    Key? key,
    required this.item,
    required this.onTap,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: ListTile(
          minVerticalPadding: 16,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Row(
            children: [
              Text('单号：${item['kyInStorageNumber'] ?? ''}'),
              const Spacer(),
              // 新增：复制电话图标按钮
              GestureDetector(
                onTap: () => _copyPhoneNumber(context),
                child: Icon(Icons.content_copy, color: AppColors.redGradient[500]),
              ),
              _buildStatusBadge(),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(children: [
                Icon(Icons.shop_outlined, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Text('订单来源：${item['orderSource'] ?? ''}'),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Icon(Icons.person_outline, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Text('收件人：${item['recipientName'] ?? ''}'),
              ]),
              // 新增：电话显示行
              const SizedBox(height: 10),
              Row(children: [
                Icon(Icons.phone_outlined, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Text('电话：${item['recipietnMobile'] ?? ''}'),
                const Spacer(),
                // 新增：电话图标按钮
                GestureDetector(
                  onTap: () => _callPhoneNumber(context),
                  child: Icon(Icons.call, color: AppColors.redGradient[500]),
                ),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '地址：${item['recipetenAddressFirst'] ?? ''}${item['recipetenAddressSecond'] ?? ''}${item['recipetenAddressThid'] ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showMapOptions(context),
                  child: Icon(Icons.open_in_new, color: AppColors.redGradient[500]),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // 构建状态徽章
  Widget _buildStatusBadge() {
    switch (status) {
      case DeliveryStatus.pending:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.yellowGradient[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer, size: 12, color: Colors.white),
              const SizedBox(width: 4),
              const Text('待派', style: TextStyle(fontSize: 12, color: Colors.white)),
            ],
          ),
        );
      case DeliveryStatus.delivered:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.greenGradient[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check, size: 12, color: Colors.white),
              const SizedBox(width: 4),
              const Text('已派', style: TextStyle(fontSize: 12, color: Colors.white)),
            ],
          ),
        );
      case DeliveryStatus.failed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.redGradient[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, size: 12, color: Colors.white),
              const SizedBox(width: 4),
              const Text('失败', style: TextStyle(fontSize: 12, color: Colors.white)),
            ],
          ),
        );
      case DeliveryStatus.unknown:
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('未知', style: TextStyle(fontSize: 12, color: Colors.black54)),
        );
    }
  }

  // 新增：拨打电话功能
  void _callPhoneNumber(BuildContext context) {
    final phoneNumber = item['recipietnMobile'] ?? '';

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('电话号码为空'))
      );
      return;
    }

    // 添加点击反馈
    HapticFeedback.lightImpact();

    // 调用系统拨号功能
    final uri = Uri.parse('tel:$phoneNumber');
    if (canLaunchUrl(uri) as bool) {
      launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('无法拨打电话: $phoneNumber'))
      );
    }
  }

  // 新增：复制电话号码功能
  void _copyPhoneNumber(BuildContext context) {
    final phoneNumber = item['kyInStorageNumber'] ?? '';

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('电话号码为空'))
      );
      return;
    }

    // 复制到剪贴板
    Clipboard.setData(ClipboardData(text: phoneNumber));

    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已复制电话号码: $phoneNumber'))
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
                  launchUrl(Uri.parse('https://maps.google.com/?q=${item['recipetenAddressFirst']}'));
                },
              ),
              ListTile(
                title: Text('2Gis'),
                onTap: () {
                  Navigator.pop(context);
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