import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  Future<List<OrderModel>> getOrders() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromMap({...doc.data(), 'orderId': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting orders: $e');
      rethrow;
    }
  }

  Stream<List<OrderModel>> getOrdersStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap({...doc.data(), 'orderId': doc.id}))
            .toList());
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': newStatus.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromMap({...doc.data()!, 'orderId': doc.id});
      }
      return null;
    } catch (e) {
      print('Error getting order: $e');
      rethrow;
    }
  }

  Future<String> createOrder({
    required String userId,
    required String restaurantId,
    required List<OrderItem> items,
    required double totalAmount,
    required String customerName,
    required String customerPhone,
    required String deliveryAddress,
    String? note,
    required String paymentMethod,
  }) async {
    try {
      final order = OrderModel(
        orderId: '', // Firestore sẽ tự tạo ID
        userId: userId,
        restaurantId: restaurantId,
        items: items,
        totalAmount: totalAmount,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        customerName: customerName,
        customerPhone: customerPhone,
        deliveryAddress: deliveryAddress,
        note: note,
        paymentMethod: paymentMethod,
      );

      final docRef = await _firestore.collection(_collection).add(order.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }
} 