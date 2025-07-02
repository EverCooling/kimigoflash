import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kimiflash/http/api/auth_api.dart';
import 'package:kimiflash/pages/delivery/components/delivery_list_item.dart';
import 'package:kimiflash/pages/widgets/loading_manager.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:intl/intl.dart';
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
  DateTime? _startDate;
  DateTime? _endDate;
  String? _deliveryMethod; // 派送方式
  final TextEditingController _searchController = TextEditingController();

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
      _fetchOrders(_getStatus(controller.tabController.index));
    }
  }

  // index ==0 返回22，index === 1返回24，index==2 返回23
  int _getStatus(int index) {
    switch (index) {
      case 0:
        return 22; // 待派件
      case 1:
        return 24; // 已派件
      case 2:
        return 23; // 派件失败
      default:
        return 22;
    }
  }

  // 清除筛选条件
  void _clearFilters() {
    setState(() {
      _searchText = '';
      _searchController.text = '';
      _startDate = null;
      _endDate = null;
      _deliveryMethod = null;
    });
  }

  // 显示时间选择器
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime? start = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (start != null) {
      final DateTime? end = await showDatePicker(
        context: context,
        initialDate: _endDate ?? DateTime.now(),
        firstDate: start,
        lastDate: DateTime.now(),
      );

      if (end != null) {
        setState(() {
          _startDate = start;
          _endDate = end;
        });
        _fetchOrders(_getStatus(controller.tabController.index));
      }
    }
  }

  // 显示派送方式选择器
  Future<void> _showDeliveryMethodSelector(BuildContext context) async {
    final List<String> methods = ['全部', '本人签收', '家人待签收', '自提签收'];
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
              trailing: _deliveryMethod == method ? Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, method),
            );
          },
        );
      },
    );

    if (result != null && result != '全部') {
      setState(() => _deliveryMethod = result);
      _fetchOrders(_getStatus(controller.tabController.index));
    } else if (result == '全部') {
      setState(() => _deliveryMethod = null);
      _fetchOrders(_getStatus(controller.tabController.index));
    }
  }

  // 构建搜索区域
  Widget _buildSearchArea() {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.grey[100],
      child: Column(
        children: [
          // 搜索框
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索订单号、收件人...',
              prefixIcon: Icon(Icons.search),
              suffixIcon: _searchText.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _searchText = '';
                    _searchController.clear();
                  });
                  _fetchOrders(_getStatus(controller.tabController.index));
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => _searchText = value,
            onSubmitted: (value) => _fetchOrders(_getStatus(controller.tabController.index)),
          ),

          // 筛选按钮行
          Row(
            children: [
              // 时间选择器
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _selectDateRange(context),
                  icon: Icon(Icons.calendar_today),
                  label: Text(
                    _startDate != null && _endDate != null
                        ? '${DateFormat('yyyy-MM-dd').format(_startDate!)} - ${DateFormat('yyyy-MM-dd').format(_endDate!)}'
                        : '选择日期范围',
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

              SizedBox(width: 10),

              // 派送方式选择器
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDeliveryMethodSelector(context),
                  icon: Icon(Icons.local_shipping),
                  label: Text(
                    _deliveryMethod ?? '派送方式',
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
        ],
      ),
    );
  }

  Future<void> _fetchOrders(int status) async {
    print("_fetchOrders--------------------------------");
    if (_isRequesting) return;

    _isRequesting = true;
    HUD.show(context);

    try {
      final response = await _authApi.DeliverManQueryDeliveryList({
        "orderStatus": status,
        "customerCode": "10010",
        "orderNumber": _searchText, // 搜索订单号
        "recipientName": _searchText, // 搜索收件人
        "startDate": _startDate?.toIso8601String(),
        "endDate": _endDate?.toIso8601String(),
        "deliveryMethod": _deliveryMethod,
      });

      if (response.code == 200) {
        switch (status) {
          case 22:
            setState(() => _pendingList = response.data ?? []);
            break;
          case 24:
            setState(() => _completedList = response.data ?? []);
            break;
          case 23:
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
                _buildOrderList(_pendingList, 'pending'),
                // 已派件
                _buildOrderList(_completedList, 'completed'),
                // 派件失败
                _buildOrderList(_failedList, 'failed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders, String type) {
    if (orders.isEmpty) {
      return Center(child: Text('暂无数据'));
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return DeliveryListItem(
          item: order,
          onTap: () => controller.navigateToDetail(order, type),
        );
      },
    );
  }
}