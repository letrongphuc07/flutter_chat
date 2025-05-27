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
} 