import 'package:flutter/material.dart';
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
  final DeliveryStatus status; // 新增：外部状态变量

  const DeliveryListItem({
    Key? key,
    required this.item,
    required this.onTap,
    required this.status, // 状态作为必选参数
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
              // 单号文本
              Text('单号：${item['kyInStorageNumber'] ?? ''}'),
              // 状态图标（右上角）
              const Spacer(),
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

  // 构建状态徽章（基于外部状态变量）
  Widget _buildStatusBadge() {
    switch (status) {
      case DeliveryStatus.pending:
      // 待派状态：圆形橙色背景，时钟图标
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
      // 已派状态：圆形绿色背景，勾选图标
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
      // 失败状态：圆形红色背景，错误图标
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
      // 未知状态：灰色背景
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