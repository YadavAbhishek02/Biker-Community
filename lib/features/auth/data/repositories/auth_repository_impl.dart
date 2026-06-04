import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserModel> register(UserModel user, String password) async {
    return await remoteDataSource.register(user, password);
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  @override
  Future<UserModel> getProfile() async {
    return await remoteDataSource.getProfile();
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  @override
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('jwt_token');
  }
}
