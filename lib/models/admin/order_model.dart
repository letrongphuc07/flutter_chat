import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,    // Chờ xác nhận
  confirmed,  // Đã xác nhận
  preparing,  // Đang chuẩn bị
  ready,      // Sẵn sàng
  delivered,  // Đã giao
  cancelled,  // Đã hủy
}

class OrderModel {
  final String orderId;
  final String userId;
  final String restaurantId;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.restaurantId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'restaurantId': restaurantId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      items: (map['items'] as List<dynamic>)
          .map((item) => OrderItem.fromMap(item))
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }
}

class OrderItem {
  final String menuItemId;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      menuItemId: map['menuItemId'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
    );
  }
} 