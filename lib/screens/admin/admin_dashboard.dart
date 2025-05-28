import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../views/admin/order_list_view.dart';
import '../../views/admin/restaurant_list_view.dart';
import '../../views/admin/user_list_view.dart';
import '../../views/admin/menu_list_view.dart';
import '../../services/order_service.dart';
import '../../models/admin/order_model.dart';


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Trị Hệ Thống'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildOverviewTab(),
              const RestaurantListView(),
              UserListView(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Nhà hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Người dùng',
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng Quan Hệ Thống',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildStatCards(),
          const SizedBox(height: 24),
          const Text(
            'Đơn Hàng Gần Đây',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<OrderModel>>(
            stream: OrderService().getOrdersStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Có lỗi xảy ra'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Không có đơn hàng nào'));
              }

              final orders = snapshot.data!.take(5).toList(); // Chỉ hiển thị 5 đơn hàng gần nhất
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('Đơn hàng #${order.orderId}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Khách hàng: ${order.customerName}'),
                          Text('Tổng tiền: ${order.totalAmount.toStringAsFixed(0)} VNĐ'),
                          Text('Trạng thái: ${_getStatusText(order.status)}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ManagementScreen(
                                title: 'Chi tiết đơn hàng',
                                child: OrderListView(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        _buildStatCard(
          'Tổng Người Dùng',
          Icons.people,
          Colors.blue,
          _getStreamForTitle('users'),
          onTap: () {
            setState(() {
              _selectedIndex = 2; // Chuyển đến tab Người dùng
            });
          },
        ),
        _buildStatCard(
          'Tổng Nhà Hàng',
          Icons.restaurant,
          Colors.green,
          _getStreamForTitle('restaurants'),
          onTap: () {
            setState(() {
              _selectedIndex = 1; // Chuyển đến tab Nhà hàng
            });
          },
        ),
        _buildStatCard(
          'Tổng Đơn Hàng',
          Icons.shopping_cart,
          Colors.orange,
          _getStreamForTitle('orders'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManagementScreen(
                  title: 'Quản Lý Đơn Hàng',
                  child: OrderListView(),
                ),
              ),
            );
          },
        ),
        _buildStatCard(
          'Quản Lý Thực Đơn',
          Icons.restaurant_menu,
          Colors.purple,
          _getStreamForTitle('menu_items'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManagementScreen(
                  title: 'Quản Lý Thực Đơn',
                  child: MenuListView(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title,
      IconData icon,
      Color color,
      Stream<int> stream, {
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              StreamBuilder<int>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Lỗi', style: TextStyle(fontSize: 12));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  return Text(
                    '${snapshot.data ?? 0}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<int> _getStreamForTitle(String title) {
    switch (title) {
      case 'users':
        return _authService.getUserCount();
      case 'restaurants':
        return _authService.getRestaurantCount();
      case 'orders':
        return _authService.getOrderCount();
      case 'menu_items':
        return _authService.getMenuCount();
      default:
        return Stream.value(0);
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.preparing:
        return 'Đang chuẩn bị';
      case OrderStatus.ready:
        return 'Sẵn sàng';
      case OrderStatus.delivered:
        return 'Đã giao';
      case OrderStatus.cancelled:
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }
}

class ManagementScreen extends StatelessWidget {
  final String title;
  final Widget child;

  const ManagementScreen({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: child,
    );
  }
}