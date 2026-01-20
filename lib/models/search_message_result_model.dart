import 'search_user_model.dart';
import 'message_model.dart';

/// Model for message search result
class SearchMessageResultModel {
  final SearchUserModel user;
  final MessageModel? lastMessage;

  SearchMessageResultModel({
    required this.user,
    this.lastMessage,
  });

  factory SearchMessageResultModel.fromJson(Map<String, dynamic> json) {
    return SearchMessageResultModel(
      user: SearchUserModel.fromJson(json['user'] ?? {}),
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'last_message': lastMessage?.toJson(),
    };
  }
}
