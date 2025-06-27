// lib/route/app_pages.dart
import 'package:get/get.dart';
import 'package:kimiflash/pages/completed_delivery/completed_delivery_list_controller.dart';
import 'package:kimiflash/pages/completed_delivery/completed_delivery_list_page.dart';
import 'package:kimiflash/pages/completed_delivery/detail/complete_delivery_detail_page.dart';
import '../pages/delivery/delivery_list_page.dart';
import '../pages/delivery/detail/pending_delivery_detail_page.dart';
import '../pages/screens/mobile_scanner_advanced.dart';
import 'bindings.dart'; // 引入 Bindings 文件
import '../pages/home/home_page.dart';
import '../pages/login/login_page.dart';
import '../pages/outbound/outbound_scan_page.dart';
import '../pages/exception/exception_report_page.dart';
import '../pages/receipt/sign_receipt_scan_page.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: '/',
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: '/login',
      page: () => LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: '/outbound-scan',
      page: () => const OutboundScanPage(),
      binding: OutboundScanBinding(),
    ),
    GetPage(
      name: '/delivery-list',
      page: () => DeliveryListPage(),
      binding: DeliveryListBinding(),
    ),
    GetPage(
      name: '/sign-receipt-scan',
      page: () => const SignReceiptScanPage(),
      binding: SignReceiptScanBinding(),
    ),
    GetPage(
      name: '/exception-report',
      page: () => ExceptionReportPage(deliveryItem: {},),
      binding: ExceptionReportBinding(),
    ),
    GetPage(
      name: '/complete-delivery-detail',
      page: () => CompleteDeliveryDetailPage(deliveryItem: Get.arguments,), // 页面组件
      binding: CompleteDeliveryDetailBinding(), // 对应 Binding
    ),
    GetPage(
      name: '/pending-delivery-detail',
      page: () => PendingDeliveryDetail(deliveryItem: Get.arguments),
      binding: PendingDeliveryDetailBinding(),
    ),
    GetPage(
      name: '/complete-delivery-list',
      page: () => CompletedDeliveryListPage(), // 页面组件
      binding: CompleteDeliveryListBinding(), // 对应 Binding
    ),
    GetPage(
      name: '/pending-delivery-list',
      page: () => DeliveryListPage(), // 页面组件
      binding: DeliveryListBinding(), // 对应 Binding
    ),
    GetPage(
      name: '/scanner',
      page: () => const MobileScannerAdvanced(),
      binding: MobileScannerAdvancedBinding(),
    ),
  ];
}
