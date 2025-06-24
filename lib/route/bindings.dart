// lib/route/bindings.dart
import 'package:get/get.dart';
import 'package:kimiflash/pages/completed_delivery/detail/complete_delivery_detail_page.dart';
import '../pages/completed_delivery/detail/complete_delivery_detail_controller.dart';
import '../pages/delivery/delivery_list_controller.dart';
import '../pages/delivery/detail/pending_delivery_detail_controller.dart';
import '../pages/login/login_controller.dart';
import '../pages/outbound/outbound_scan_controller.dart';
import '../pages/receipt/sign_receipt_scan_controller.dart';
import '../pages/exception/exception_report_controller.dart';
import '../pages/home/home_controller.dart';
import '../pages/completed_delivery/completed_delivery_list_controller.dart';
import '../pages/completed_delivery/completed_delivery_list_page.dart';
import '../pages/screens/mobile_scanner_advanced_controller.dart';
//首页
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController()); // ✅ 确保这里无误
  }
}

//待派件详情页
class PendingDeliveryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() {
      // 从 Get.arguments 获取传入的参数，并传给控制器
      final deliveryItem = Get.arguments as Map<String, dynamic>;
      return PendingDeliveryDetailController(deliveryItem: deliveryItem);
    });
  }
}

//已派件详情页
class CompleteDeliveryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() {
      // 从 Get.arguments 获取传入的参数，并传给控制器
      final deliveryItem = Get.arguments as Map<String, dynamic>;
      return CompleteDeliveryDetailController(deliveryItem: deliveryItem);
    });
  }
}

//登录页
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
  }
}

//出仓扫描页
class OutboundScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OutboundScanController());
  }
}

//派送列表页
class DeliveryListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DeliveryListController());
  }
}

//派送列表页
class CompleteDeliveryListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CompletedDeliveryListController());
  }
}

//签收扫描页
class SignReceiptScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignReceiptScanController());
  }
}

//异常报告页
class ExceptionReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExceptionReportController());
  }
}

//扫描
class MobileScannerAdvancedBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MobileScannerAdvancedController());
  }
}
