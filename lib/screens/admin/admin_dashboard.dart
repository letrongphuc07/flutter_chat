import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../views/admin/order_list_view.dart';
import '../../views/admin/restaurant_list_view.dart';
import '../../views/admin/user_list_view.dart';
import '../../views/admin/menu_list_view.dart';


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
          SizedBox(
            //height: 400,
            //child: OrderListView(),
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