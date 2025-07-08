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
  String? _deliveryDays =  '全部'; // 派送方式
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
  void activate() {
    super.activate();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders(_getStatus(controller.tabController.index));
    });
  }

  @override
  void deactivate() {
    super.deactivate();
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
      _deliveryDays = '全部';
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
      child: FormBuilder(
        key: _formKey,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 54,
                child: CustomTextField(
                  name: 'kyInStorageNumber',
                  labelText: '扫描单号',
                  enabled: true,
                  hintText: '请输入运单号',
                  prefixIcon: Icons.vertical_distribute,
                  suffixIcon: Icons.barcode_reader,
                  controller: _searchController, // 确保设置controller
                  onChanged: (value) => _searchText = value,
                  onTapOutside: (event) {
                    //失去焦点
                    FocusScope.of(context).unfocus();
                    final formState = _formKey.currentState;
                    if (formState != null) {
                      final currentValue = formState.fields['kyInStorageNumber']?.value;
                      if (currentValue != null && currentValue.isNotEmpty) {
                        HUD.show(context);
                        _fetchOrders(_getStatus(controller.tabController.index)).whenComplete(() {
                          HUD.hide();
                        });
                      } else {
                        Get.snackbar('提示', '请先输入或扫描订单号');
                      }
                    }
                  },
                  onSuffixPressed: () async {
                    final barcodeResult = await Get.toNamed('/scanner');
                    if (barcodeResult != null) {
                      // 同时更新FormBuilder字段和TextEditingController
                      _formKey.currentState?.fields['kyInStorageNumber']?.didChange(barcodeResult);
                      _searchController.text = barcodeResult;

                      // 更新搜索文本并触发数据获取
                      _searchText = barcodeResult;
                      _fetchOrders(_getStatus(controller.tabController.index));
                    }
                    FocusScope.of(context).unfocus();
                  },
                  onSubmitted: (value) async {
                    FocusScope.of(context).unfocus();

                    if (value != null) {
                      _searchText = value;
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
              ),
            ),
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
      ),
    );
  }

  // 返回int型，当前返回1，三天内返回2，五年内返回4，七天内返回6
  int _getDeliveryDays(String? deliveryDays) {
    switch (_deliveryDays) {
      case '全部':
        return 6;
      case '当天':
        return 1;
      case '三天内':
        return 2;
      case '五天内':
        return 4;
      case '七天内':
        return 6;
      default:
        return 6;
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
        setState(() {
          switch (status) {
            case 22:
              _pendingList = response.data ?? [];
              break;
            case 23:
              _completedList = response.data ?? [];
              break;
            case 24:
              _failedList = response.data ?? [];
              break;
          }
        });
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
          onTap: () => controller.navigateToDetail(order, type),
        );
      },
    );
  }
}