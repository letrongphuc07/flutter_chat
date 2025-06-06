import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin/user_model.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user == null) {
        throw Exception('Đăng nhập thất bại: Không thể lấy thông tin người dùng');
      }

        // Get user data from Firestore
      final doc = await _firestore.collection('users').doc(result.user!.uid).get();
      
      if (!doc.exists) {
        throw Exception('Không tìm thấy thông tin người dùng trong cơ sở dữ liệu');
      }

          final Map<String, dynamic>? data = doc.data();
      if (data == null) {
        throw Exception('Dữ liệu người dùng không hợp lệ');
      }

            String roleStr = data['role']?.toString() ?? 'customer';
            
            return UserModel(
        id: result.user!.uid,
        email: data['email']?.toString() ?? result.user!.email ?? '',
              name: data['name']?.toString() ?? '',
              phoneNumber: data['phoneNumber']?.toString(),
              role: UserRole.values.firstWhere(
                (e) => e.toString().split('.').last == roleStr,
                orElse: () => UserRole.customer,
              ),
            );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Không tìm thấy tài khoản với email này.';
          break;
        case 'wrong-password':
          message = 'Mật khẩu không đúng.';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ.';
          break;
        case 'user-disabled':
          message = 'Tài khoản này đã bị vô hiệu hóa.';
          break;
        default:
          message = 'Đã xảy ra lỗi khi đăng nhập: ${e.message}';
      }
      throw Exception(message);
    } catch (e, stack) {
      print('Lỗi không xác định khi đăng nhập: $e');
      print(stack);
      throw Exception('Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.');
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(
    String name,
    String email,
    String password,
    UserRole role,
  ) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = result.user;
      if (user != null) {
        // Tạo dữ liệu user
        final Map<String, dynamic> userData = {
          'id': user.uid,
          'email': email,
          'name': name,
          'role': role.toString().split('.').last,
        };

        // Ghi vào Firestore
        await _firestore.collection('users').doc(user.uid).set(userData);

        return UserModel(
          id: user.uid,
          email: email,
          name: name,
          role: role,
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email này đã được sử dụng.';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ.';
          break;
        case 'operation-not-allowed':
          message = 'Đăng ký bằng email/password không được bật.';
          break;
        case 'weak-password':
          message = 'Mật khẩu quá yếu.';
          break;
        default:
          message = 'Đã xảy ra lỗi khi đăng ký. Vui lòng thử lại.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      throw Exception('Đã xảy ra lỗi khi đăng xuất. Vui lòng thử lại.');
    }
  }

  // Get user role
  Future<UserRole?> getUserRole() async {
    try {
      final user = currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final Map<String, dynamic>? data = doc.data();
          if (data != null) {
            String roleStr = data['role']?.toString() ?? 'customer';
            
            return UserRole.values.firstWhere(
              (e) => e.toString().split('.').last == roleStr,
              orElse: () => UserRole.customer,
            );
          }
        }
      }
      return null;
    } catch (e) {
      throw Exception('Đã xảy ra lỗi khi lấy thông tin vai trò. Vui lòng thử lại.');
    }
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == UserRole.admin;
  }

  // Check if user is restaurant owner
  Future<bool> isRestaurantOwner() async {
    final role = await getUserRole();
    return role == UserRole.restaurantOwner;
  }

  // Check if user is customer
  Future<bool> isCustomer() async {
    final role = await getUserRole();
    return role == UserRole.customer;
  }

  // Get user count
  Stream<int> getUserCount() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get restaurant count
  Stream<int> getRestaurantCount() {
    return _firestore
        .collection('restaurants')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get order count
  Stream<int> getOrderCount() {
    return _firestore
        .collection('orders')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Lấy số lượng đơn hàng trong ngày
  Stream<int> getMenuCount() {
    return _firestore
        .collection('menu_items')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
} 