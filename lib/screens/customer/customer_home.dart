import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/restaurant_service.dart';
import '../../widgets/floating_chat_button.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({Key? key}) : super(key: key);

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  List<Map<String, dynamic>> _restaurants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    try {
      final restaurants = await _restaurantService.getRestaurants();
      setState(() {
        _restaurants = restaurants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhà hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await context.read<AuthService>().signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi đăng xuất: ${e.toString()}')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildRestaurantList(),
      floatingActionButton: const FloatingChatButton(),
    );
  }

  Widget _buildRestaurantList() {
    if (_restaurants.isEmpty) {
      return const Center(
        child: Text('Không có nhà hàng nào'),
      );
    }

    return ListView.builder(
      itemCount: _restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = _restaurants[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: restaurant['imageUrl'] != null && restaurant['imageUrl'].toString().isNotEmpty
                ? CircleAvatar(
                    backgroundImage: NetworkImage(restaurant['imageUrl'].toString()),
                    onBackgroundImageError: (_, __) => const Icon(Icons.error),
                  )
                : const CircleAvatar(
                    child: Icon(Icons.restaurant),
                  ),
            title: Text(restaurant['name']?.toString() ?? 'Không có tên'),
            subtitle: Text(restaurant['address']?.toString() ?? 'Không có địa chỉ'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/restaurant-detail',
                arguments: restaurant,
              );
            },
          ),
        );
      },
    );
  }
} 