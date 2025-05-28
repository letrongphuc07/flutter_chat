import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final String? note;
  final String paymentMethod;
  final String? restaurantName;
  final String? customerEmail;
  final bool isPaid;
  final String? paymentId;
  final String? deliveryTime;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.restaurantId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    this.note,
    required this.paymentMethod,
    this.restaurantName,
    this.customerEmail,
    this.isPaid = false,
    this.paymentId,
    this.deliveryTime,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  bool get canBeCancelled => status == OrderStatus.pending || status == OrderStatus.confirmed;

  bool canUpdateStatus(OrderStatus newStatus) {
    switch (status) {
      case OrderStatus.pending:
        return newStatus == OrderStatus.confirmed || newStatus == OrderStatus.cancelled;
      case OrderStatus.confirmed:
        return newStatus == OrderStatus.preparing || newStatus == OrderStatus.cancelled;
      case OrderStatus.preparing:
        return newStatus == OrderStatus.ready || newStatus == OrderStatus.cancelled;
      case OrderStatus.ready:
        return newStatus == OrderStatus.delivered || newStatus == OrderStatus.cancelled;
      case OrderStatus.delivered:
        return false;
      case OrderStatus.cancelled:
        return false;
    }
  }

  OrderModel copyWith({
    String? orderId,
    String? userId,
    String? restaurantId,
    List<OrderItem>? items,
    double? totalAmount,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
    String? note,
    String? paymentMethod,
    String? restaurantName,
    String? customerEmail,
    bool? isPaid,
    String? paymentId,
    String? deliveryTime,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      note: note ?? this.note,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      restaurantName: restaurantName ?? this.restaurantName,
      customerEmail: customerEmail ?? this.customerEmail,
      isPaid: isPaid ?? this.isPaid,
      paymentId: paymentId ?? this.paymentId,
      deliveryTime: deliveryTime ?? this.deliveryTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'restaurantId': restaurantId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status.toString(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'deliveryAddress': deliveryAddress,
      'note': note,
      'paymentMethod': paymentMethod,
      'restaurantName': restaurantName,
      'customerEmail': customerEmail,
      'isPaid': isPaid,
      'paymentId': paymentId,
      'deliveryTime': deliveryTime,
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
        (e) => e.toString() == map['status'] || e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : map['createdAt'] is String
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(), // Fallback in case of unexpected data type
      updatedAt: map['updatedAt'] != null
          ? map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : map['updatedAt'] is String
                  ? DateTime.parse(map['updatedAt'])
                  : null // Fallback for updatedAt
          : null,
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      deliveryAddress: map['deliveryAddress'] ?? '',
      note: map['note'],
      paymentMethod: map['paymentMethod'] ?? 'cash',
      restaurantName: map['restaurantName'],
      customerEmail: map['customerEmail'],
      isPaid: map['isPaid'] ?? false,
      paymentId: map['paymentId'],
      deliveryTime: map['deliveryTime'],
    );
  }

  String get statusText {
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
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.green[700]!;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}

class OrderItem {
  final String menuItemId;
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl;
  final String? note;

  OrderItem({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
    this.note,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
      'note': note,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      menuItemId: map['menuItemId'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'],
      note: map['note'],
    );
  }

  OrderItem copyWith({
    String? menuItemId,
    String? name,
    int? quantity,
    double? price,
    String? imageUrl,
    String? note,
  }) {
    return OrderItem(
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      note: note ?? this.note,
    );
  }
} 