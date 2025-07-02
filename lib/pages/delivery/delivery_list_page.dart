import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kimiflash/http/api/auth_api.dart';
import 'package:kimiflash/pages/delivery/components/delivery_list_item.dart';
import 'package:kimiflash/pages/widgets/loading_manager.dart';
import 'package:kimiflash/theme/app_colors.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'delivery_list_controller.dart';

class DeliveryListPage extends StatefulWidget {
  @override
  State<DeliveryListPage> createState() => _DeliveryListPageState();
}

class _DeliveryListPageState extends State<DeliveryListPage> with SingleTickerProviderStateMixin {
  final AuthApi _authApi = AuthApi();
  final controller = Get.put(DeliveryListController());
  bool _isRequesting = false;
  bool _isRefreshing = false; // 下拉刷新状态
  bool _isLoadingMore = false; // 上拉加载状态
  bool _hasMoreData = true; // 是否还有更多数据
  List<dynamic> _pendingList = [];   // 待派件
  List<dynamic> _completedList = []; // 已派件
  List<dynamic> _failedList = [];    // 派件失败
  bool _tabIsSelected = false;
  String _searchText = '';
  String? _deliveryDays =  ''; // 派送方式
  final TextEditingController _searchController = TextEditingController();
  late ScrollController _scrollController; // 滚动控制器，用于监听上拉加载
  int _currentPage = 1; // 当前页码
  final int _pageSize = 10; // 每页数量

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
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 处理滚动事件，实现上拉加载
  void _handleScroll() {
    if (_isLoadingMore || !_hasMoreData) return;

    // 当滚动到距离底部200像素时触发加载更多
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchMoreOrders(_getStatus(controller.tabController.index));
    }
  }

  _handleChange() {
    if (_tabIsSelected) return;
    _tabIsSelected = true;

    if (controller.tabController.indexIsChanging) {
      _clearFilters(); // 切换标签时重置筛选条件
      _currentPage = 1; // 重置页码
      _hasMoreData = true; // 重置是否有更多数据标记
      Future.microtask(() => _fetchOrders(_getStatus(controller.tabController.index), isRefresh: true));
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
      _fetchOrders(_getStatus(controller.tabController.index), isRefresh: true);
    } else if (result == '全部') {
      setState(() => _deliveryDays = null);
      _fetchOrders(_getStatus(controller.tabController.index), isRefresh: true);
    }
  }

  // 构建搜索区域（搜索框和时间选择器同一行）
  Widget _buildSearchArea() {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.grey[100],
      child: Row(
        children: [
          // 搜索框 - 占据大部分宽度
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索订单号、收件人...',
                prefixIcon: Icon(Icons.search, color: AppColors.redGradient[400]),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchText = '';
                      _searchController.clear();
                    });
                    _fetchOrders(_getStatus(controller.tabController.index), isRefresh: true);
                  },
                )
                    : null,
                // 设置红色边框 - 修复未聚焦时边框颜色不生效的问题
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none, // 默认无边框（被其他状态覆盖）
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red), // 未聚焦时的红色边框
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red.shade700), // 聚焦时的深红色边框
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 11, horizontal: 16), // 高度约42
              ),
              onChanged: (value) => _searchText = value,
              onSubmitted: (value) => _fetchOrders(_getStatus(controller.tabController.index), isRefresh: true),
            ),
          ),
          // 间隔
          SizedBox(width: 10),
          // 时间选择按钮 - 固定宽度
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: 10),
            child: ElevatedButton.icon(
              onPressed: () => _showDeliveryMethodSelector(context),
              icon: Icon(Icons.calendar_today,size: 12,),
              label: Text(
                style: TextStyle(color: AppColors.redGradient[400],fontSize: 12),
                _deliveryDays ?? '时间筛选',
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

  // 下拉刷新的回调函数
  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    final currentStatus = _getStatus(controller.tabController.index);
    await _fetchOrders(currentStatus, isRefresh: true);
  }

  // 加载更多数据
  Future<void> _fetchMoreOrders(int status) async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final response = await _authApi.DeliverManQueryDeliveryList({
        "orderStatus": status,
        "customerCode": "10010",
        "deliveryContent": _searchText,
        "deliveryDays": _getDeliveryDays(_deliveryDays),
        "page": nextPage,
        "pageSize": _pageSize,
      });

      if (response.code == 200) {
        final newData = response.data ?? [];
        _currentPage = nextPage;

        // 根据状态更新对应的列表
        switch (status) {
          case 22:
            setState(() {
              _pendingList.addAll(newData);
              _hasMoreData = newData.length == _pageSize;
            });
            break;
          case 23:
            setState(() {
              _completedList.addAll(newData);
              _hasMoreData = newData.length == _pageSize;
            });
            break;
          case 24:
            setState(() {
              _failedList.addAll(newData);
              _hasMoreData = newData.length == _pageSize;
            });
            break;
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

  // 获取订单列表
  Future<void> _fetchOrders(int status, {bool isRefresh = false}) async {
    print("_fetchOrders--------------------------------${_searchText}");
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
        "orderStatus": status,
        "customerCode": "10010",
        "deliveryContent": _searchText,
        "deliveryDays": _getDeliveryDays(_deliveryDays),
        "page": _currentPage,
        "pageSize": _pageSize,
      });
      _tabIsSelected = false;

      if (response.code == 200) {
        final data = response.data ?? [];

        // 根据状态更新对应的列表
        switch (status) {
          case 22:
            setState(() {
              _pendingList = isRefresh ? data : _pendingList;
              _hasMoreData = data.length == _pageSize;
            });
            break;
          case 23:
            setState(() {
              _completedList = isRefresh ? data : _completedList;
              _hasMoreData = data.length == _pageSize;
            });
            break;
          case 24:
            setState(() {
              _failedList = isRefresh ? data : _failedList;
              _hasMoreData = data.length == _pageSize;
            });
            break;
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
                _buildRefreshableList(_pendingList, 'pending'),
                // 已派件
                _buildRefreshableList(_completedList, 'completed'),
                // 派件失败
                _buildRefreshableList(_failedList, 'failed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建可刷新的列表
  Widget _buildRefreshableList(List<dynamic> orders, String type) {
    return LiquidPullToRefresh(
      onRefresh: _handleRefresh,
      showChildOpacityTransition: false,
      color: Colors.red, // 使用红色作为刷新指示器颜色
      backgroundColor: Colors.white,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: orders.length + (_isLoadingMore || _hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < orders.length) {
            // 显示数据项
            final order = orders[index];
            return DeliveryListItem(
              item: order,
              onTap: () => controller.navigateToDetail(order, type),
            );
          } else {
            // 显示加载更多指示器
            return _buildLoadingIndicator();
          }
        },
      ),
    );
  }

  // 构建加载更多指示器
  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: _isLoadingMore
          ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
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