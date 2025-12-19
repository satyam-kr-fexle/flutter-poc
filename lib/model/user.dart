class User {
  final int? id;
  final String name;
  final String email;
  final String? avatar;
  final bool needsSync; // Flag for offline-created users

  User({
    this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.needsSync = false,
  });

  // Convert User to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'needsSync': needsSync ? 1 : 0,
    };
  }

  // Create User from Map (from database)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: (map['name'] as String?) ?? 'Unknown User',
      email: (map['email'] as String?) ?? '',
      avatar: map['avatar'] as String?,
      needsSync: (map['needsSync'] ?? 0) == 1,
    );
  }

  // Convert User to JSON for API
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'avatar': avatar};
  }

  // Create User from JSON (from API)
  factory User.fromJson(Map<String, dynamic> json) {
    // Handle DummyJSON format (firstName + lastName) or direct name
    String fullName = 'Unknown User';
    if (json.containsKey('name')) {
      fullName = json['name'] as String;
    } else if (json.containsKey('firstName')) {
      fullName = '${json['firstName']} ${json['lastName'] ?? ''}'.trim();
    }

    return User(
      id: json['id'] as int?,
      name: fullName,
      email: (json['email'] as String?) ?? '',
      avatar: (json['image'] ?? json['avatar']) as String?,
      needsSync: false, // API users don't need sync
    );
  }

  // Create a copy with updated fields
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? avatar,
    bool? needsSync,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      needsSync: needsSync ?? this.needsSync,
    );
  }
}
