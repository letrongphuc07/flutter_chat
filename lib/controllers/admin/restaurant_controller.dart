import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/admin/restaurant_model.dart';

class RestaurantController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy danh sách nhà hàng
  Stream<List<RestaurantModel>> getRestaurants() {
    return _firestore
        .collection('restaurants')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RestaurantModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Lấy chi tiết nhà hàng
  Future<RestaurantModel?> getRestaurantDetails(String restaurantId) async {
    final doc = await _firestore.collection('restaurants').doc(restaurantId).get();
    if (doc.exists) {
      return RestaurantModel.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  // Thêm nhà hàng mới
  Future<void> addRestaurant(RestaurantModel restaurant) async {
    await _firestore.collection('restaurants').add(restaurant.toMap());
  }

  // Cập nhật thông tin nhà hàng
  Future<void> updateRestaurant(RestaurantModel restaurant) async {
    await _firestore
        .collection('restaurants')
        .doc(restaurant.id)
        .update(restaurant.toMap());
  }

  // Xóa nhà hàng
  Future<void> deleteRestaurant(String restaurantId) async {
    await _firestore.collection('restaurants').doc(restaurantId).delete();
  }

  // Lấy số lượng nhà hàng
  Stream<int> getRestaurantCount() {
    return _firestore
        .collection('restaurants')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
} 