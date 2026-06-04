import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user_model.dart';
import '../../../../core/api/api_client.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> register(UserModel user, String password);
  Future<Map<String, dynamic>> login(String email, String password);
  Future<UserModel> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> register(UserModel user, String password) async {
    try {
      final response = await apiClient.dio.post('/users/register', data: {
        'name': user.name,
        'email': user.email,
        'password': password,
        'role': user.role.name,
        'bikeModel': user.bikeModel,
      });

      if (response.statusCode == 201) {
        return UserModel.fromMap(response.data['data']['user'], '');
      } else {
        throw Exception(response.data['message'] ?? 'Failed to register');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post('/users/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final userData = response.data['data']['user'];
        
        // Save token to locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        return {
          'user': UserModel.fromMap(userData, userData['id']),
          'token': token,
        };
      } else {
        throw Exception(response.data['message'] ?? 'Failed to login');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await apiClient.dio.get('/users/profile');
      if (response.statusCode == 200) {
        final userData = response.data['data']['user'];
        return UserModel.fromMap(userData, userData['id']);
      } else {
        throw Exception('Failed to fetch profile');
      }
    } catch (e) {
      rethrow;
    }
  }
}
