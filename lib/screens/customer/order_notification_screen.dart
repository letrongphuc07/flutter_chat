import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../models/admin/order_model.dart';
import 'package:intl/intl.dart';

class OrderNotificationScreen extends StatelessWidget {
  const OrderNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    final user = _authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Thông báo đơn hàng')),
        body: Center(child: Text('Vui lòng đăng nhập để xem thông báo')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo đơn hàng'),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: OrderService().getOrdersStream().map((orders) =>
            orders.where((order) =>
                order.userId == user.uid && (order.status == OrderStatus.confirmed || order.status == OrderStatus.cancelled))
                .toList()),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error loading notification orders: ${snapshot.error}');
            return const Center(child: Text('Có lỗi xảy ra khi tải thông báo'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Không có thông báo đơn hàng nào'),
            );
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              // TODO: Build a more detailed list tile for notifications
              return ListTile(
                title: Text('Đơn hàng #${order.orderId}'),
                subtitle: Text('Trạng thái: ${order.statusText}'),
                trailing: Text(DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt)),
                // TODO: Add onTap to view order details
              );
            },
          );
        },
      ),
    );
  }
} 