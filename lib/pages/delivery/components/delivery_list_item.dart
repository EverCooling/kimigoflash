import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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
  final VoidCallback? onSignTap;     // 签收按钮回调
  final VoidCallback? onFailTap;     // 失败按钮回调

  const DeliveryListItem({
    Key? key,
    required this.item,
    required this.onTap,
    required this.status,
    this.onSignTap,
    this.onFailTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              minVerticalPadding: 16,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Row(
                children: [
                  Text('单号：${item['kyInStorageNumber'] ?? ''}'),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _copyNumber(context),
                    child: Icon(Icons.content_copy, size: 18, color: AppColors.redGradient[500]),
                  ),
                  const Spacer(),
                  _buildStatusBadge(),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Row(children: [
                  //   Icon(Icons.shop_outlined, size: 16, color: Colors.red),
                  //   const SizedBox(width: 4),
                  //   Text('订单来源：${item['orderSource'] ?? ''}'),
                  // ]),
                  // const SizedBox(height: 10),
                  Row(children: [
                    Icon(Icons.person_outline, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Text('收件人：${item['recipientName'] ?? ''}'),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Icon(Icons.phone_outlined, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Text('电话：${item['recipietnMobile'] ?? ''}'),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _callPhoneNumber(context),
                      child: Icon(Icons.call, size: 18, color: AppColors.redGradient[500]),
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
                      child: Icon(Icons.open_in_new, size: 18, color: AppColors.redGradient[500]),
                    ),
                  ]),
                ],
              ),
            ),
            // 底部操作按钮（仅在待派件状态显示）
            if (status == DeliveryStatus.pending)
              _buildActionButtons(context),
          ],
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

// 构建右下角操作按钮
  Widget _buildActionButtons(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 16, 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 失败按钮（红色）
            FloatingActionButton(
              onPressed: onFailTap ?? () => _navigateToExceptionPage(context),
              backgroundColor: AppColors.redGradient[500],
              mini: true,
              child: Text('失败',style: TextStyle(fontSize: 12,color: Colors.white),),
            ),
            const SizedBox(width: 16),
            // 签收按钮（绿色）
            FloatingActionButton(
              onPressed: onSignTap ?? () => _navigateToSignPage(context),
              backgroundColor: AppColors.greenGradient[500],
              mini: true,
              child: Text('签收',style: TextStyle(fontSize: 12,color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }

  // 其他功能方法（保持不变）
  void _callPhoneNumber(BuildContext context) {
    final phoneNumber = item['recipientPhone'] ?? '';
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('电话号码为空')));
      return;
    }
    HapticFeedback.lightImpact();
    final uri = Uri.parse('tel:$phoneNumber');
    if (canLaunchUrl(uri) as bool) launchUrl(uri);
    else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('无法拨打电话: $phoneNumber')));
  }

  void _copyNumber(BuildContext context) {
    final phoneNumber = item['kyInStorageNumber'] ?? '';
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('单号为空')));
      return;
    }
    Clipboard.setData(ClipboardData(text: phoneNumber));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已复制单号: $phoneNumber')));
  }

  void _showMapOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text('Google 地图'), onTap: () {
              Navigator.pop(context);
              launchUrl(Uri.parse('https://maps.google.com/?q=${item['recipetenAddressFirst']}'));
            }),
            ListTile(title: Text('2Gis'), onTap: () {
              Navigator.pop(context);
              launchUrl(Uri.parse('https://2gis.com/?q=${item['recipetenAddressFirst']}'));
            }),
          ],
        ),
      ),
    );
  }

  // 修改导航方法，传递完整的deliveryItem
  void _navigateToSignPage(BuildContext context) {
    Get.toNamed(
      '/pending-delivery-detail',
      arguments: item, // 直接传递item作为deliveryItem
    );
  }

  void _navigateToExceptionPage(BuildContext context) {
    Get.toNamed(
      '/exception-report',
      arguments: item, // 直接传递item作为deliveryItem
    );
  }
}