import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../models/conversation_item_model.dart';
import '../models/message_row_model.dart';
import '../models/search_message_result_model.dart';
import '../services/network_caller.dart';
import '../services/urls.dart';

/// Exception class for message API errors
class MessageApiException implements Exception {
  final String message;
  final int? statusCode;
  
  MessageApiException(this.message, [this.statusCode]);
  
  @override
  String toString() => 'MessageApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Service for message-related API calls
class MessageApiService {
  /// Fetch raw message rows from inbox API
  /// 
  /// [token] - User's API token
  /// 
  /// Returns list of raw message rows (not grouped)
  /// Throws [MessageApiException] on failure
  static Future<List<MessageRowModel>> fetchInboxRows({
    required String token,
  }) async {
    final url = Urls.get_Message_API;
    final requestBody = {
      'api_token': token,
    };

    if (kDebugMode) {
      print('DEBUG MessageApiService.fetchInboxRows: POST $url');
      print('DEBUG Request Body: ${jsonEncode(requestBody)}');
    }

    try {
      final response = await NetworkCaller.postRequest(
        url: url,
        body: requestBody,
      );

      if (kDebugMode) {
        print('DEBUG MessageApiService.fetchInboxRows - Response Status: ${response.statusCode}');
        print('DEBUG Response Body: ${response.body != null ? jsonEncode(response.body) : 'null'}');
      }

      if (response.isSuccess && response.body != null) {
        final body = response.body!;
        
        if (kDebugMode) {
          print('═══════════════════════════════════════════════════════════');
          print('🔍 [fetchInboxRows] Parsing API response');
          print('   Response keys: ${body.keys.toList()}');
          print('   Has "sent": ${body.containsKey("sent")}');
          print('   Has "data": ${body.containsKey("data")}');
          print('   Has "status": ${body.containsKey("status")}');
        }
        
        // API returns either: { "sent": [ ... ] } OR { "status": true, "data": [ ... ] }
        List<dynamic> messagesList = [];
        
        if (body.containsKey('sent') && body['sent'] is List) {
          // Format 1: { "sent": [ ... ] }
          messagesList = body['sent'] as List<dynamic>;
          if (kDebugMode) {
            print('✅ [fetchInboxRows] Found "sent" array with ${messagesList.length} messages');
          }
        } else if (body.containsKey('data') && body['data'] is List && body['status'] == true) {
          // Format 2: { "status": true, "data": [ ... ] }
          messagesList = body['data'] as List<dynamic>;
          if (kDebugMode) {
            print('✅ [fetchInboxRows] Found "data" array with ${messagesList.length} messages');
          }
        } else {
          // Empty inbox or unexpected format
          if (kDebugMode) {
            print('❌ [fetchInboxRows] No "sent" or "data" array in response, returning empty list');
            print('   Response body: ${jsonEncode(body)}');
          }
          return [];
        }
        
        // Parse messages as MessageRowModel
        final rows = messagesList
            .map((item) {
              try {
                return MessageRowModel.fromJson(item);
              } catch (e) {
                if (kDebugMode) {
                  print('❌ [fetchInboxRows] Error parsing message row: $e');
                  print('   Item: ${jsonEncode(item)}');
                }
                return null;
              }
            })
            .whereType<MessageRowModel>()
            .toList();
        
        if (kDebugMode) {
          print('✅ [fetchInboxRows] Loaded ${rows.length} message rows');
          print('═══════════════════════════════════════════════════════════');
        }
        
        return rows;
      } else {
        final errorMessage = response.errorMessage ?? 'Failed to load messages';
        throw MessageApiException(errorMessage, response.statusCode);
      }
    } catch (e) {
      if (e is MessageApiException) {
        rethrow;
      } else {
        throw MessageApiException('Unexpected error: ${e.toString()}');
      }
    }
  }

  /// Fetch inbox/conversation list (legacy - uses old model)
  /// 
  /// [token] - User's API token
  /// 
  /// Returns list of conversations sorted by createdAt desc
  /// Throws [MessageApiException] on failure
  static Future<List<ConversationItemModel>> fetchInbox({
    required String token,
  }) async {
    final url = Urls.get_Message_API;
    final requestBody = {
      'api_token': token,
    };

    if (kDebugMode) {
      print('DEBUG MessageApiService.fetchInbox: POST $url');
      print('DEBUG Request Body: ${jsonEncode(requestBody)}');
    }

    try {
      final response = await NetworkCaller.postRequest(
        url: url,
        body: requestBody,
      );

      if (kDebugMode) {
        print('DEBUG MessageApiService.fetchInbox - Response Status: ${response.statusCode}');
        print('DEBUG Response Body: ${response.body != null ? jsonEncode(response.body) : 'null'}');
      }

      if (response.isSuccess && response.body != null) {
        final body = response.body!;
        
        if (kDebugMode) {
          print('═══════════════════════════════════════════════════════════');
          print('🔍 [fetchInbox] Parsing API response');
          print('   Response keys: ${body.keys.toList()}');
          print('   Has "sent": ${body.containsKey("sent")}');
          print('   Has "data": ${body.containsKey("data")}');
          print('   Has "status": ${body.containsKey("status")}');
        }
        
        // API returns either: { "sent": [ ... ] } OR { "status": true, "data": [ ... ] }
        List<dynamic> messagesList = [];
        
        if (body.containsKey('sent') && body['sent'] is List) {
          // Format 1: { "sent": [ ... ] }
          messagesList = body['sent'] as List<dynamic>;
          if (kDebugMode) {
            print('✅ [fetchInbox] Found "sent" array with ${messagesList.length} messages');
          }
        } else if (body.containsKey('data') && body['data'] is List && body['status'] == true) {
          // Format 2: { "status": true, "data": [ ... ] }
          messagesList = body['data'] as List<dynamic>;
          if (kDebugMode) {
            print('✅ [fetchInbox] Found "data" array with ${messagesList.length} messages');
          }
        } else {
          // Empty inbox or unexpected format
          if (kDebugMode) {
            print('❌ [fetchInbox] No "sent" or "data" array in response, returning empty list');
            print('   Response body: ${jsonEncode(body)}');
          }
          return [];
        }
        
        // Parse messages
        final conversations = messagesList
            .map((item) {
              try {
                return ConversationItemModel.fromJson(item);
              } catch (e) {
                if (kDebugMode) {
                  print('❌ [fetchInbox] Error parsing conversation item: $e');
                  print('   Item: ${jsonEncode(item)}');
                }
                return null;
              }
            })
            .whereType<ConversationItemModel>()
            .toList();
        
        // Sort by createdAt desc (newest first)
        conversations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        if (kDebugMode) {
          print('✅ [fetchInbox] Loaded ${conversations.length} conversations');
          print('═══════════════════════════════════════════════════════════');
        }
        
        return conversations;
      } else {
        final errorMessage = response.errorMessage ?? 'Failed to load conversations';
        throw MessageApiException(errorMessage, response.statusCode);
      }
    } catch (e) {
      if (e is MessageApiException) {
        rethrow;
      } else {
        throw MessageApiException('Unexpected error: ${e.toString()}');
      }
    }
  }

  /// Fetch conversation/message history with a user
  /// 
  /// [token] - User's API token
  /// [toUserId] - ID of the user to get conversation with
  /// 
  /// Returns list of messages sorted by createdAt asc (oldest first)
  /// Throws [MessageApiException] on failure
  static Future<List<MessageModel>> fetchConversation({
    required String token,
    required int toUserId,
  }) async {
    final url = Urls.get_Single_Message_API;
    final requestBody = {
      'api_token': token,
      'to_user_id': toUserId,
    };

    if (kDebugMode) {
      print('DEBUG MessageApiService.fetchConversation: POST $url');
      print('DEBUG Request Body: ${jsonEncode(requestBody)}');
    }

    try {
      final response = await NetworkCaller.postRequest(
        url: url,
        body: requestBody,
      );

      if (kDebugMode) {
        print('DEBUG MessageApiService.fetchConversation - Response Status: ${response.statusCode}');
        print('DEBUG Response Body: ${response.body != null ? jsonEncode(response.body) : 'null'}');
      }

      if (response.isSuccess && response.body != null) {
        final body = response.body!;
        
        // API returns: { "status": true, "data": [ ... ] }
        if (body['status'] == true && body.containsKey('data') && body['data'] is List) {
          final List<dynamic> dataList = body['data'];
          final messages = dataList
              .map((item) => MessageModel.fromJson(item))
              .toList();
          
          // Sort by createdAt asc (oldest first, newest last)
          messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          
          if (kDebugMode) {
            print('DEBUG MessageApiService.fetchConversation: Loaded ${messages.length} messages');
          }
          
          return messages;
        } else {
          // Empty conversation or unexpected format
          if (kDebugMode) {
            print('DEBUG MessageApiService.fetchConversation: No "data" array or status != true, returning empty list');
          }
          return [];
        }
      } else {
        final errorMessage = response.errorMessage ?? 'Failed to load conversation';
        throw MessageApiException(errorMessage, response.statusCode);
      }
    } catch (e) {
      if (e is MessageApiException) {
        rethrow;
      } else {
        throw MessageApiException('Unexpected error: ${e.toString()}');
      }
    }
  }

  /// Send a message via REST API
  /// 
  /// [token] - User's API token
  /// [toUserId] - ID of the user to send message to
  /// [content] - Message content
  /// 
  /// Returns the sent message with server-assigned ID and timestamp
  /// Throws [MessageApiException] on failure
  static Future<MessageModel> sendMessage({
    required String token,
    required int toUserId,
    required String content,
  }) async {
    if (content.trim().isEmpty) {
      throw MessageApiException('Message content cannot be empty');
    }

    if (toUserId <= 0) {
      throw MessageApiException('Invalid recipient user ID');
    }

    final url = Urls.send_message;
    final requestBody = {
      'api_token': token,
      'to_user_id': toUserId,
      'message_content': content.trim(),
    };

    if (kDebugMode) {
      print('DEBUG MessageApiService.sendMessage: POST $url');
      print('DEBUG Request Body: ${jsonEncode(requestBody)}');
    }

    try {
      final response = await NetworkCaller.postRequest(
        url: url,
        body: requestBody,
      );

      if (kDebugMode) {
        print('DEBUG MessageApiService.sendMessage - Response Status: ${response.statusCode}');
        print('DEBUG Response Body: ${response.body != null ? jsonEncode(response.body) : 'null'}');
      }

      if (response.isSuccess && response.body != null) {
        final body = response.body!;
        
        // API returns: { "message": "...", "data": {...} }
        if (body.containsKey('data') && body['data'] != null) {
          final data = body['data'];
          try {
            final message = MessageModel.fromJson(data);
            
            if (kDebugMode) {
              print('DEBUG MessageApiService.sendMessage: Message sent successfully - ID: ${message.id}');
            }
            
            return message;
          } catch (e) {
            throw MessageApiException('Invalid response format: failed to parse message data', response.statusCode);
          }
        } else {
          final errorMessage = body['message']?.toString() ?? 'Failed to send message';
          throw MessageApiException(errorMessage, response.statusCode);
        }
      } else {
        final errorMessage = response.errorMessage ?? 'Network error occurred';
        throw MessageApiException(errorMessage, response.statusCode);
      }
    } catch (e) {
      if (e is MessageApiException) {
        rethrow;
      } else {
        throw MessageApiException('Unexpected error: ${e.toString()}');
      }
    }
  }

  /// Search messages/users by keyword
  /// 
  /// [token] - User's API token
  /// [keyword] - Search keyword
  /// 
  /// Returns list of search results with user and last message
  /// Throws [MessageApiException] on failure
  static Future<List<SearchMessageResultModel>> searchMessages({
    required String token,
    required String keyword,
  }) async {
    if (keyword.trim().isEmpty) {
      return [];
    }

    final url = Urls.message_search;
    final requestBody = {
      'api_token': token,
      'keyword': keyword.trim(),
    };

    if (kDebugMode) {
      print('DEBUG MessageApiService.searchMessages: POST $url');
      print('DEBUG Request Body: ${jsonEncode(requestBody)}');
    }

    try {
      final response = await NetworkCaller.postRequest(
        url: url,
        body: requestBody,
      );

      if (kDebugMode) {
        print('DEBUG MessageApiService.searchMessages - Response Status: ${response.statusCode}');
        print('DEBUG Response Body: ${response.body != null ? jsonEncode(response.body) : 'null'}');
      }

      if (response.isSuccess && response.body != null) {
        final body = response.body!;
        
        // API returns: { "status": true, "data": [ ... ] }
        if (body['status'] == true && body.containsKey('data') && body['data'] is List) {
          final List<dynamic> dataList = body['data'];
          final results = dataList
              .map((item) {
                try {
                  return SearchMessageResultModel.fromJson(item);
                } catch (e) {
                  if (kDebugMode) {
                    print('DEBUG MessageApiService.searchMessages: Error parsing result item: $e');
                    print('   Item: ${jsonEncode(item)}');
                  }
                  return null;
                }
              })
              .whereType<SearchMessageResultModel>()
              .toList();
          
          if (kDebugMode) {
            print('DEBUG MessageApiService.searchMessages: Loaded ${results.length} search results');
          }
          
          return results;
        } else {
          // Empty results or unexpected format
          if (kDebugMode) {
            print('DEBUG MessageApiService.searchMessages: No "data" array or status != true, returning empty list');
          }
          return [];
        }
      } else {
        final errorMessage = response.errorMessage ?? 'Failed to search messages';
        throw MessageApiException(errorMessage, response.statusCode);
      }
    } catch (e) {
      if (e is MessageApiException) {
        rethrow;
      } else {
        throw MessageApiException('Unexpected error: ${e.toString()}');
      }
    }
  }
}
