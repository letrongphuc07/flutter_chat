import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin/order_controller.dart';
import '../../models/admin/order_model.dart';

class OrderListView extends StatelessWidget {
  const OrderListView({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.put(OrderController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách đơn hàng'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orders.isEmpty) {
          return const Center(
            child: Text('Không có đơn hàng nào'),
          );
        }

        return ListView.builder(
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            return _buildOrderCard(order);
          },
        );
      }),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn hàng #${order.orderId}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text('Ngày đặt: ${order.createdAt.toString()}'),
            const SizedBox(height: 8),
            const Text(
              'Chi tiết đơn hàng:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.name} x${item.quantity}'),
                      Text('${item.price.toStringAsFixed(0)} VNĐ'),
                    ],
                  ),
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng tiền:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${order.totalAmount.toStringAsFixed(0)} VNĐ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String text;

    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        text = 'Chờ xác nhận';
        break;
      case OrderStatus.confirmed:
        color = Colors.blue;
        text = 'Đã xác nhận';
        break;
      case OrderStatus.preparing:
        color = Colors.purple;
        text = 'Đang chuẩn bị';
        break;
      case OrderStatus.ready:
        color = Colors.green;
        text = 'Sẵn sàng';
        break;
      case OrderStatus.delivered:
        color = Colors.green[700]!;
        text = 'Đã giao';
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        text = 'Đã hủy';
        break;
    }

    return Chip(
      label: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
} 