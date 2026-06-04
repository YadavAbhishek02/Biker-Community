import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> register(UserModel user, String password);
  Future<Map<String, dynamic>> login(String email, String password);
  Future<UserModel> getProfile();
  Future<void> logout();
  Future<bool> isAuthenticated();
}
