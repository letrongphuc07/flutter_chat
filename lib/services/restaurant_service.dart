import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant.dart';

class RestaurantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'restaurants';

  // Lấy thông tin nhà hàng theo ID
  Future<Map<String, dynamic>?> getRestaurantById(String restaurantId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(restaurantId).get();
      if (!doc.exists) return null;
      return {...doc.data()!, 'id': doc.id};
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin nhà hàng: $e');
    }
  }

  // Lấy danh sách nhà hàng
  Future<List<Map<String, dynamic>>> getRestaurants() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('name')
          .get();
      
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách nhà hàng: $e');
    }
  }

  // Lấy danh sách nhà hàng theo danh mục
  Future<List<Map<String, dynamic>>> getRestaurantsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('categories', arrayContains: category)
          .orderBy('name')
          .get();
      
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách nhà hàng theo danh mục: $e');
    }
  }

  // Tạo nhà hàng mới
  Future<String> createRestaurant(Map<String, dynamic> restaurantData) async {
    try {
      final docRef = await _firestore.collection(_collection).add(restaurantData);
      return docRef.id;
    } catch (e) {
      throw Exception('Lỗi khi tạo nhà hàng: $e');
    }
  }

  // Cập nhật thông tin nhà hàng
  Future<bool> updateRestaurant(String restaurantId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(restaurantId).update({
        ...data,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      throw Exception('Lỗi khi cập nhật nhà hàng: $e');
    }
  }

  // Xóa nhà hàng
  Future<bool> deleteRestaurant(String restaurantId) async {
    try {
      await _firestore.collection(_collection).doc(restaurantId).delete();
      return true;
    } catch (e) {
      throw Exception('Lỗi khi xóa nhà hàng: $e');
    }
  }

  // Tìm kiếm nhà hàng
  Future<List<Map<String, dynamic>>> searchRestaurants(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('name')
          .get();
      
      return snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .where((restaurant) =>
              restaurant['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
              restaurant['description'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tìm kiếm nhà hàng: $e');
    }
  }
} 