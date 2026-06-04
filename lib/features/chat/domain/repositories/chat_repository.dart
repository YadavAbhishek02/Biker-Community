import '../models/message_model.dart';
import '../../data/datasources/chat_remote_data_source.dart';

abstract class ChatRepository {
  Future<List<MessageModel>> getMessages(String eventId);
  Future<MessageModel> sendMessage(String eventId, String content);
}

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MessageModel>> getMessages(String eventId) async {
    return await remoteDataSource.getMessages(eventId);
  }

  @override
  Future<MessageModel> sendMessage(String eventId, String content) async {
    return await remoteDataSource.sendMessage(eventId, content);
  }
}
