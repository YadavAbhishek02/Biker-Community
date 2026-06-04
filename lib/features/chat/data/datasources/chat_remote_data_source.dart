import '../../../../core/api/api_client.dart';
import '../../domain/models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<MessageModel>> getMessages(String eventId);
  Future<MessageModel> sendMessage(String eventId, String content);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient apiClient;

  ChatRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<MessageModel>> getMessages(String eventId) async {
    final response = await apiClient.dio.get('/events/$eventId/messages');
    if (response.statusCode == 200) {
      final List data = response.data['data'];
      return data.map((m) => MessageModel.fromMap(m)).toList();
    } else {
      throw Exception('Failed to fetch messages');
    }
  }

  @override
  Future<MessageModel> sendMessage(String eventId, String content) async {
    final response = await apiClient.dio.post(
      '/events/$eventId/messages',
      data: {'content': content},
    );
    if (response.statusCode == 201) {
      return MessageModel.fromMap(response.data['data']);
    } else {
      throw Exception('Failed to send message');
    }
  }
}
