import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:kimiflash/http/api/auth_api.dart';
import 'package:kimiflash/pages/delivery/components/delivery_list_item.dart';
import 'package:kimiflash/pages/widgets/loading_manager.dart';
import 'package:kimiflash/theme/app_colors.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../widgets/custom_text_field.dart';
import 'delivery_list_controller.dart';

// 导入状态枚举
import 'package:kimiflash/pages/delivery/components/delivery_list_item.dart' show DeliveryStatus;

class DeliveryListPage extends StatefulWidget {
  @override
  State<DeliveryListPage> createState() => _DeliveryListPageState();
}

class _DeliveryListPageState extends State<DeliveryListPage> with SingleTickerProviderStateMixin {
  final AuthApi _authApi = AuthApi();
  final controller = Get.put(DeliveryListController());
  bool _isRequesting = false;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  List<dynamic> _pendingList = [];
  List<dynamic> _completedList = [];
  List<dynamic> _failedList = [];
  bool _tabIsSelected = false;
  String? _deliveryDays;
  late ScrollController _scrollController;
  int _currentPage = 1;
  final int _pageSize = 10;

  // 表单键，用于获取表单数据
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    controller.tabController.addListener(_handleChange);
    _scrollController = ScrollController()..addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders(_getStatus(controller.tabController.index), isRefresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_isLoadingMore || !_hasMoreData) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchMoreOrders(_getStatus(controller.tabController.index));
    }
  }

  _handleChange() {
    if (_tabIsSelected) return;
    _tabIsSelected = true;

    if (controller.tabController.indexIsChanging) {
      _clearFilters();
      _currentPage = 1;
      _hasMoreData = true;
      Future.microtask(() => _fetchOrders(_getStatus(controller.tabController.index), isRefresh: true));
    }
  }

  DeliveryStatus _getStatus(int index) {
    switch (index) {
      case 0:
        return DeliveryStatus.pending;
      case 1:
        return DeliveryStatus.delivered;
      case 2:
        return DeliveryStatus.failed;
      default:
        return DeliveryStatus.pending;
    }
  }

  void _clearFilters() {
    if (_formKey.currentState != null) {
      _formKey.currentState!.reset(); // 重置表单
    }
    setState(() {
      _deliveryDays = '';
    });
  }

  Future<void> _showDeliveryMethodSelector(BuildContext context) async {
    final List<String> methods = ['全部', '当天', '三天内', '五天内', '七天内'];
    final String? result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
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

    if (result != null) {
      setState(() {
        _deliveryDays = result;
      });
      _fetchOrders(_getStatus(controller.tabController.index), isRefresh: true);
    }
  }

  Widget _buildSearchArea() {
    return FormBuilder(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.all(10),
        color: Colors.grey[100],
        child: Row(
          children: [
            Expanded(
              child: CustomTextField(
                name: 'searchQuery',
                enabled: true,
                labelText: '搜索订单号、收件人...',
                hintText: '搜索订单号、收件人...',
                prefixIcon: Icons.search,
                suffixIcon: Icons.barcode_reader,
                onSuffixPressed: () async {
                  final barcodeResult = await Get.toNamed('/scanner');
                  if (barcodeResult != null) {
                    if (_formKey.currentState != null) {
                      _formKey.currentState!.fields['searchQuery']?.didChange(barcodeResult);
                      _fetchOrders(_getStatus(controller.tabController.index), isRefresh: true);
                    }
                  }
                },
                onSubmitted: (value) {
                  if (value != null && _formKey.currentState != null) {
                    _fetchOrders(_getStatus(controller.tabController.index), isRefresh: true);
                  }
                },
              ),
            ),
            SizedBox(width: 10),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: 10),
              child: ElevatedButton.icon(
                onPressed: () => _showDeliveryMethodSelector(context),
                icon: Icon(Icons.calendar_today, size: 12),
                label: Text(
                  _deliveryDays ?? '时间筛选',
                  style: TextStyle(color: AppColors.redGradient[400], fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
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

  int _getDeliveryDays(String? deliveryDays) {
    switch (deliveryDays) {
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

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    final currentStatus = _getStatus(controller.tabController.index);
    await _fetchOrders(currentStatus, isRefresh: true);
  }

  Future<void> _fetchMoreOrders(DeliveryStatus status) async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final response = await _authApi.DeliverManQueryDeliveryList({
        "orderStatus": _getStatusCode(status),
        "customerCode": "10010",
        "deliveryContent": _getSearchQuery(), // 通过表单获取搜索内容
        "deliveryDays": _getDeliveryDays(_deliveryDays),
        "page": nextPage,
        "pageSize": _pageSize,
      });

      if (response.code == 200) {
        final newData = response.data ?? [];
        _currentPage = nextPage;

        switch (status) {
          case DeliveryStatus.pending:
            setState(() {
              _pendingList.addAll(newData);
              _hasMoreData = newData.length == _pageSize;
            });
            break;
          case DeliveryStatus.delivered:
            setState(() {
              _completedList.addAll(newData);
              _hasMoreData = newData.length == _pageSize;
            });
            break;
          case DeliveryStatus.failed:
            setState(() {
              _failedList.addAll(newData);
              _hasMoreData = newData.length == _pageSize;
            });
            break;
          case DeliveryStatus.unknown:
            throw UnimplementedError();
        }
      } else {
        Get.snackbar('加载失败', response.msg ?? '未知错误');
      }
    } catch (e) {
      Get.snackbar('网络错误', e.toString());
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _fetchOrders(DeliveryStatus status, {bool isRefresh = false}) async {
    print("_fetchOrders--------------------------------${_getSearchQuery()}");
    if (_isRequesting) return;

    if (isRefresh) {
      setState(() {
        _isRefreshing = true;
        _currentPage = 1;
        _hasMoreData = true;
      });
    } else {
      _isRequesting = true;
      HUD.show(context);
    }

    try {
      final response = await _authApi.DeliverManQueryDeliveryList({
        "orderStatus": _getStatusCode(status),
        "customerCode": "10010",
        "deliveryContent": _getSearchQuery(), // 通过表单获取搜索内容
        "deliveryDays": _getDeliveryDays(_deliveryDays),
        "page": _currentPage,
        "pageSize": _pageSize,
      });
      _tabIsSelected = false;

      if (response.code == 200) {
        final data = response.data ?? [];

        switch (status) {
          case DeliveryStatus.pending:
            setState(() {
              _pendingList = isRefresh ? data : _pendingList;
              _hasMoreData = data.length == _pageSize;
            });
            break;
          case DeliveryStatus.delivered:
            setState(() {
              _completedList = isRefresh ? data : _completedList;
              _hasMoreData = data.length == _pageSize;
            });
            break;
          case DeliveryStatus.failed:
            setState(() {
              _failedList = isRefresh ? data : _failedList;
              _hasMoreData = data.length == _pageSize;
            });
            break;
          case DeliveryStatus.unknown:
            throw UnimplementedError();
        }
      } else {
        Get.snackbar('加载失败', response.msg ?? '未知错误');
      }
    } catch (e) {
      Get.snackbar('网络错误', e.toString());
    } finally {
      if (isRefresh) {
        setState(() {
          _isRefreshing = false;
        });
      } else {
        HUD.hide();
        _isRequesting = false;
      }
      _tabIsSelected = false;
    }
  }

  int _getStatusCode(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return 22;
      case DeliveryStatus.delivered:
        return 23;
      case DeliveryStatus.failed:
        return 24;
      default:
        return 22;
    }
  }

  // 从表单获取搜索内容
  String _getSearchQuery() {
    return _formKey.currentState?.fields['searchQuery']?.value ?? '';
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
                _buildRefreshableList(_pendingList, DeliveryStatus.pending),
                _buildRefreshableList(_completedList, DeliveryStatus.delivered),
                _buildRefreshableList(_failedList, DeliveryStatus.failed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshableList(List<dynamic> orders, DeliveryStatus status) {
    return LiquidPullToRefresh(
      onRefresh: _handleRefresh,
      showChildOpacityTransition: false,
      color: Colors.red,
      backgroundColor: Colors.white,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: orders.isEmpty && !_isRefreshing ? 1 : orders.length + (_isLoadingMore || _hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (orders.isEmpty && !_isRefreshing) {
            return _buildEmptyState(status);
          } else if (index < orders.length) {
            final order = orders[index];
            return DeliveryListItem(
              item: order,
              onTap: () => controller.navigateToDetail(order, status),
              status: status,
            );
          } else {
            return _buildLoadingIndicator();
          }
        },
      ),
    );
  }

  Widget _buildEmptyState(DeliveryStatus status) {
    String emptyText = '';
    IconData emptyIcon = Icons.hourglass_empty_outlined;

    switch (status) {
      case DeliveryStatus.pending:
        emptyText = '暂无待派件';
        break;
      case DeliveryStatus.delivered:
        emptyText = '暂无已派件';
        break;
      case DeliveryStatus.failed:
        emptyText = '暂无派件失败记录';
        break;
      case DeliveryStatus.unknown:
        emptyText = '暂无数据';
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(emptyIcon, size: 80, color: AppColors.redGradient[200]),
          const SizedBox(height: 20),
          Text(
            emptyText,
            style: TextStyle(fontSize: 18, color: Colors.grey[500], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Text(
            '请尝试更换筛选条件或稍后再试',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: _isLoadingMore
          ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red)),
          SizedBox(width: 10),
          Text('加载更多...'),
        ],
      )
          : _hasMoreData
          ? Text('上拉加载更多')
          : Text('没有更多数据了'),
    );
  }
}
