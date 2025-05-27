import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../models/admin/order_model.dart';
import '../../services/order_service.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final OrderService _orderService = OrderService();

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    try {
      final loadedOrders = await _orderService.getOrders();
      orders.value = loadedOrders;
    } catch (e) {
      print('Error loading orders: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể tải danh sách đơn hàng',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Lấy danh sách đơn hàng
  Stream<List<OrderModel>> getOrders() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap({...doc.data(), 'orderId': doc.id}))
          .toList();
    });
  }

  // Lấy chi tiết đơn hàng
  Future<OrderModel?> getOrderDetails(String orderId) async {
    final doc = await _firestore.collection(_collection).doc(orderId).get();
    if (doc.exists) {
      return OrderModel.fromMap({...doc.data()!, 'orderId': doc.id});
    }
    return null;
  }

  // Thêm đơn hàng mới
  Future<String> addOrder(OrderModel order) async {
    final docRef = await _firestore.collection(_collection).add(order.toMap());
    return docRef.id;
  }

  // Cập nhật đơn hàng
  Future<void> updateOrder(OrderModel order) async {
    await _firestore
        .collection(_collection)
        .doc(order.orderId)
        .update(order.toMap());
  }

  // Xóa đơn hàng
  Future<void> deleteOrder(String orderId) async {
    await _firestore.collection(_collection).doc(orderId).delete();
  }

  // Lấy số lượng đơn hàng
  Stream<int> getOrderCount() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Lấy tổng doanh thu
  Stream<double> getTotalRevenue() {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: OrderStatus.delivered.toString())
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.fold<double>(
        0,
        (sum, doc) => sum + (doc.data()['totalAmount'] as num).toDouble(),
      );
    });
  }

  // Lấy đơn hàng theo trạng thái
  Stream<List<OrderModel>> getOrdersByStatus(OrderStatus status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status.toString())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap({...doc.data(), 'orderId': doc.id}))
          .toList();
    });
  }

  // Lấy đơn hàng theo khoảng thời gian
  Stream<List<OrderModel>> getOrdersByDateRange(DateTime startDate, DateTime endDate) {
    return _firestore
        .collection(_collection)
        .where('createdAt', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('createdAt', isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap({...doc.data(), 'orderId': doc.id}))
          .toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _orderService.updateOrderStatus(orderId, newStatus);
      await loadOrders(); // Reload orders after update
      Get.snackbar(
        'Thành công',
        'Cập nhật trạng thái đơn hàng thành công',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error updating order status: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật trạng thái đơn hàng',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

