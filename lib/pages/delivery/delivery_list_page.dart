import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:kimiflash/http/api/auth_api.dart';
import 'package:kimiflash/pages/delivery/components/delivery_list_item.dart';
import 'package:kimiflash/pages/widgets/loading_manager.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_text_field.dart';
import 'delivery_list_controller.dart';

class DeliveryListPage extends StatefulWidget {
  @override
  State<DeliveryListPage> createState() => _DeliveryListPageState();
}

class _DeliveryListPageState extends State<DeliveryListPage> with SingleTickerProviderStateMixin {
  final AuthApi _authApi = AuthApi();
  final controller = Get.put(DeliveryListController());
  bool _isRequesting = false;
  List<dynamic> _pendingList = [];   // 待派件
  List<dynamic> _completedList = []; // 已派件
  List<dynamic> _failedList = [];    // 派件失败
  bool _tabIsSelected = false;
  String _searchText = '';
  String? _deliveryDays =  ''; // 派送方式
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    controller.tabController.addListener(_handleChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders(_getStatus(controller.tabController.index));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  _handleChange() {
    if (_tabIsSelected) return;
    _tabIsSelected = true;

    if (controller.tabController.indexIsChanging) {
      _clearFilters(); // 切换标签时重置筛选条件
      Future.microtask(() => _fetchOrders(_getStatus(controller.tabController.index)));
    }
  }

  // index ==0 返回22，index === 1返回24，index==2 返回23
  int _getStatus(int index) {
    switch (index) {
      case 0:
        return 22; // 待派件
      case 1:
        return 23; // 已派件
      case 2:
        return 24; // 派件失败
      default:
        return 22;
    }
  }

  // 清除筛选条件
  void _clearFilters() {
    setState(() {
      _searchText = '';
      _searchController.text = '';
      _deliveryDays = '';
    });
  }

  // 显示派送方式选择器
  Future<void> _showDeliveryMethodSelector(BuildContext context) async {
    final List<String> methods = ['全部','当天', '三天内', '五天内','七天内'];
    final String? result = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: methods.length,
          itemBuilder: (context, index) {
            final method = methods[index];
            return ListTile(
              title: Text(method),
              trailing: _deliveryDays == method ? Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, method),
            );
          },
        );
      },
    );

    if (result != null && result != '全部') {
      setState(() => _deliveryDays = result);
      _fetchOrders(_getStatus(controller.tabController.index));
    } else if (result == '全部') {
      setState(() => _deliveryDays = null);
      _fetchOrders(_getStatus(controller.tabController.index));
    }
  }

  // 构建搜索区域（搜索框和时间选择器同一行）
  Widget _buildSearchArea() {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(child: Container(
            height: 44,
            child: CustomTextField(
              name: 'kyInStorageNumber',
              labelText: '扫描单号',
              enabled: true,
              hintText: '请输入运单号',
              prefixIcon: Icons.vertical_distribute,
              suffixIcon: Icons.barcode_reader,
              onChanged: (value) => _searchText = value,
              onTapOutside: (event) {
                //失去焦点
                FocusScope.of(context).unfocus();
                final formState = _formKey.currentState;
                if (formState != null) {
                  // 1. 获取当前输入的订单号
                  final currentValue = formState.fields['kyInStorageNumber']?.value;
                  if (currentValue != null && currentValue.isNotEmpty) {
                    // 2. 显示加载状态
                    HUD.show(context);
                    // 3. 调用校验接口
                    _fetchOrders(_getStatus(controller.tabController.index)).whenComplete(() {
                      // 4. 隐藏加载状态
                      HUD.hide();
                    });
                  } else {
                    // 订单号为空时的处理
                    Get.snackbar('提示', '请先输入或扫描订单号');
                  }
                }
              },
              onSuffixPressed: () async {
                final barcodeResult = await Get.toNamed('/scanner');
                if (barcodeResult != null) {
                  _formKey.currentState?.fields['kyInStorageNumber']?.didChange(barcodeResult);
                  _fetchOrders(_getStatus(controller.tabController.index));
                }
              },
              onSubmitted: (value) async {
                if (value != null) {
                  _fetchOrders(_getStatus(controller.tabController.index));
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入或扫描订单号';
                }
                if (!RegExp(r'^(GR|UKG).+').hasMatch(value)) {
                  return '订单号需以GR或UKG开头';
                }
                return null;
              },
            ),
          )),
          // 搜索框 - 占据大部分宽度
          // Expanded(
          //   child: Container(
          //     height: 44, // 设置高度为44
          //     child: TextField(
          //       controller: _searchController,
          //       decoration: InputDecoration(
          //         hintText: '收件人名称/电话/地址/自提点',
          //         prefixIcon: Icon(Icons.search),
          //         suffixIcon: _searchText.isNotEmpty
          //             ? IconButton(
          //           icon: Icon(Icons.clear),
          //           onPressed: () {
          //             setState(() {
          //               _searchText = '';
          //               _searchController.clear();
          //             });
          //             _fetchOrders(_getStatus(controller.tabController.index));
          //           },
          //         )
          //             : null,
          //         // 重点：确保边框设置正确
          //         contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16), // 调整内边距适配高度
          //         border: OutlineInputBorder(
          //           borderRadius: BorderRadius.circular(8),
          //           borderSide: BorderSide(color: Colors.red, width: 1.0), // 未聚焦红色边框
          //         ),
          //         enabledBorder: OutlineInputBorder(
          //           borderRadius: BorderRadius.circular(8),
          //           borderSide: BorderSide(color: Colors.red, width: 1.0), // 明确设置enabledBorder
          //         ),
          //         focusedBorder: OutlineInputBorder(
          //           borderRadius: BorderRadius.circular(8),
          //           borderSide: BorderSide(color: Colors.red.shade700, width: 1.5), // 聚焦深红色边框，增加宽度突出效果
          //         ),
          //       ),
          //       onChanged: (value) => _searchText = value,
          //       onSubmitted: (value) => _fetchOrders(_getStatus(controller.tabController.index)),
          //     ),
          //   ),
          // ),
          // 间隔
          SizedBox(width: 10),
          // 时间选择按钮 - 固定宽度
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: 120),
            child: ElevatedButton.icon(
              onPressed: () => _showDeliveryMethodSelector(context),
              icon: Icon(Icons.calendar_today),
              label: Text(
                _deliveryDays ?? '时间筛选',
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue,
                backgroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  //返回int型，当前返回1，三天内返回2，五年内返回4，七天内返回6
  int _getDeliveryDays(String? deliveryDays) {
    switch (_deliveryDays) {
      case '全部':
        return 1;
      case '当天':
        return 1;
      case '三天内':
        return 2;
      case '五天内':
        return 4;
      case '七天内':
        return 6;
      default:
        return 1;
    }
  }

  Future<void> _fetchOrders(int status) async {
    print("_fetchOrders--------------------------------${_searchText}");
    if (_isRequesting) return;

    _isRequesting = true;
    HUD.show(context);

    try {
      final response = await _authApi.DeliverManQueryDeliveryList({
        "orderStatus": status,
        "customerCode": "10010",
        "deliveryContent": _searchText,
        "deliveryDays": _getDeliveryDays(_deliveryDays),
      });
      _tabIsSelected = false;
      if (response.code == 200) {
        switch (status) {
          case 22:
            setState(() => _pendingList = response.data ?? []);
            break;
          case 23:
            setState(() => _completedList = response.data ?? []);
            break;
          case 24:
            setState(() => _failedList = response.data ?? []);
            break;
        }
      } else {
        Get.snackbar('加载失败', response.msg ?? '未知错误');
      }
    } catch (e) {
      Get.snackbar('网络错误', e.toString());
    } finally {
      HUD.hide();
      _isRequesting = false;
      _tabIsSelected = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('派件列表'),
        bottom: TabBar(
          controller: controller.tabController,
          tabs: [
            Tab(text: '待派件'),
            Tab(text: '已派件'),
            Tab(text: '派件失败'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchArea(),
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                // 待派件
                _buildOrderList(_pendingList, DeliveryStatus.pending),
                // 已派件
                _buildOrderList(_completedList, DeliveryStatus.delivered),
                // 派件失败
                _buildOrderList(_failedList, DeliveryStatus.failed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders, DeliveryStatus type) {
    if (orders.isEmpty) {
      return Center(child: Text('暂无数据'));
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return DeliveryListItem(
          status: type,
          item: order,
          onTap: () => controller.navigateToDetail(order,type),
        );
      },
    );
  }
}