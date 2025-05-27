import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/admin/user_model.dart';

class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy danh sách người dùng
  Stream<List<UserModel>> getUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    });
  }

  // Lấy chi tiết người dùng
  Future<UserModel?> getUserDetails(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  // Thêm người dùng mới
  Future<void> addUser(UserModel user) async {
    await _firestore.collection('users').add(user.toMap());
  }

  // Cập nhật thông tin người dùng
  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .update(user.toMap());
  }

  // Xóa người dùng
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  // Lấy số lượng người dùng
  Stream<int> getUserCount() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
} 