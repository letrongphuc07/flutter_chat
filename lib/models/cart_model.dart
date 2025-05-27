import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin/menu_item_model.dart';

class CartItem {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;

  CartItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      menuItemId: map['menuItemId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  CartItem copyWith({
    String? menuItemId,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
  }) {
    return CartItem(
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class CartModel {
  final String userId;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartModel({
    required this.userId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalPrice => items.fold(0, (sum, item) => sum + item.totalPrice);

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      userId: map['userId'] as String,
      items: (map['items'] as List)
          .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  CartModel copyWith({
    String? userId,
    List<CartItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartModel(
      userId: userId ?? this.userId,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 