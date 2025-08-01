class UserFriend {
  final int id;
  final int userId;
  final String userName;
  final String userPhotoUrl;
  final int friendId;
  final String friendName;
  final String friendPhotoUrl;
  final int status; 
  final DateTime requestedAt;

  UserFriend({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.friendId,
    required this.friendName,
    required this.friendPhotoUrl,
    required this.status,
    required this.requestedAt,
  });

  factory UserFriend.fromJson(Map<String, dynamic> json) => UserFriend(
        id: json['id'],
        userId: json['userId'],
        userName: json['userName'] ?? '',
        userPhotoUrl: json['userPhotoUrl'] ?? '',
        friendId: json['friendId'],
        friendName: json['friendName'] ?? '',
        friendPhotoUrl: json['friendPhotoUrl'] ?? '',
        status: json['status'],
        requestedAt: DateTime.parse(json['requestedAt']),
      );
}

class FriendshipStatus {
  final int userId;
  final int friendId;
  final int status;
  final DateTime requestedAt;

  FriendshipStatus({
    required this.userId,
    required this.friendId,
    required this.status,
    required this.requestedAt,
  });

  factory FriendshipStatus.fromJson(Map<String, dynamic> json) => FriendshipStatus(
        userId: json['userId'],
        friendId: json['friendId'],
        status: json['status'],
        requestedAt: DateTime.parse(json['requestedAt']),
      );
}

class UserFriendRequest {
  final int userId;
  final int friendId;

  UserFriendRequest({
    required this.userId,
    required this.friendId,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'friendId': friendId,
      };
}

class UpdateFriendshipStatusRequest {
  final int userId;
  final int friendId;
  final int status; // 0=Pending, 1=Accepted, 2=Declined, 3=Blocked

  UpdateFriendshipStatusRequest({
    required this.userId,
    required this.friendId,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'friendId': friendId,
        'status': status,
      };
} 