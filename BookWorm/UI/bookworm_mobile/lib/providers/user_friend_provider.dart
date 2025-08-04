import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_friend.dart';
import 'base_provider.dart';

class UserFriendProvider extends BaseProvider<dynamic> {
  UserFriendProvider() : super("userfriend");

  @override
  dynamic fromJson(dynamic json) {
    return json;
  }

  String get baseUrl => BaseProvider.baseUrl!;

  Future<UserFriend> sendFriendRequest(int userId, int friendId) async {
    final url = '${baseUrl}userfriend/send-request';
    final uri = Uri.parse(url);
    
    try {
      final request = UserFriendRequest(userId: userId, friendId: friendId);
      final response = await http.post(
        uri,
        headers: createHeaders(),
        body: json.encode(request.toJson()),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return UserFriend.fromJson(data);
      }
      throw Exception('Failed to send friend request');
    } catch (e) {
      rethrow;
    }
  }

  Future<UserFriend?> updateFriendshipStatus(int userId, int friendId, int status) async {
    final url = '${baseUrl}userfriend/update-status';
    final uri = Uri.parse(url);
    
    try {
      final request = UpdateFriendshipStatusRequest(
        userId: userId,
        friendId: friendId,
        status: status,
      );
      final response = await http.put(
        uri,
        headers: createHeaders(),
        body: json.encode(request.toJson()),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserFriend.fromJson(data);
      }
      throw Exception('Failed to update friendship status');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserFriend>> getUserFriends(int userId) async {
    final url = '${baseUrl}userfriend/user/$userId/friends';
    final uri = Uri.parse(url);
    
    try {
      final response = await http.get(uri, headers: createHeaders());
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => UserFriend.fromJson(e)).toList();
      }
      throw Exception('Failed to load user friends');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserFriend>> getPendingFriendRequests(int userId) async {
    final url = '${baseUrl}userfriend/user/$userId/pending-requests';
    final uri = Uri.parse(url);
    
    try {
      final response = await http.get(uri, headers: createHeaders());
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => UserFriend.fromJson(e)).toList();
      }
      throw Exception('Failed to load pending friend requests');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserFriend>> getSentFriendRequests(int userId) async {
    final url = '${baseUrl}userfriend/user/$userId/sent-requests';
    final uri = Uri.parse(url);
    
    try {
      final response = await http.get(uri, headers: createHeaders());
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => UserFriend.fromJson(e)).toList();
      }
      throw Exception('Failed to load sent friend requests');
    } catch (e) {
      rethrow;
    }
  }

  Future<FriendshipStatus?> getFriendshipStatus(int userId, int friendId) async {
    final url = '${baseUrl}userfriend/friendship-status';
    final uri = Uri.parse(url).replace(queryParameters: {
      'userId': userId.toString(),
      'friendId': friendId.toString(),
    });
    
    try {
      final response = await http.get(uri, headers: createHeaders());
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return FriendshipStatus.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; 
      }
      throw Exception('Failed to get friendship status');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> removeFriend(int userId, int friendId) async {
    final url = '${baseUrl}userfriend/remove-friend';
    final uri = Uri.parse(url).replace(queryParameters: {
      'userId': userId.toString(),
      'friendId': friendId.toString(),
    });
    
    try {
      final response = await http.delete(uri, headers: createHeaders());
      return response.statusCode == 204;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> cancelFriendRequest(int userId, int friendId) async {
    final url = '${baseUrl}userfriend/cancel-request';
    final uri = Uri.parse(url).replace(queryParameters: {
      'userId': userId.toString(),
      'friendId': friendId.toString(),
    });
    
    try {
      final response = await http.delete(uri, headers: createHeaders());
      return response.statusCode == 204;
    } catch (e) {
      rethrow;
    }
  }
} 