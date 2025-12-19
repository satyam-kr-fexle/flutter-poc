import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learningday1/model/user.dart';

class UserApiService {
  // Using DummyJSON API - has 100 users with rich data
  static const String baseUrl = 'https://dummyjson.com';

  // Fetch users with pagination
  Future<List<User>> fetchUsers({int page = 1, int perPage = 5}) async {
    try {
      // DummyJSON uses 'limit' and 'skip' for pagination
      final skip = (page - 1) * perPage;
      final response = await http.get(
        Uri.parse('$baseUrl/users?limit=$perPage&skip=$skip'),
      );

      print('API: GET $baseUrl/users?limit=$perPage&skip=$skip');
      print('API: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> usersJson = data['users'];
        print(
          'API: Fetched ${usersJson.length} users (Total: ${data['total']} available)',
        );

        return usersJson.map((json) {
          return User(
            id: json['id'] as int?,
            name: '${json['firstName']} ${json['lastName']}',
            email: json['email'] as String,
            avatar: json['image'] as String?,
          );
        }).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('API: Error fetching users: $e');
      rethrow;
    }
  }

  // Create a new user
  Future<User?> createUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': user.name.split(' ').first,
          'lastName': user.name.split(' ').length > 1
              ? user.name.split(' ').last
              : '',
          'email': user.email,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return User(
          id: data['id'] as int?,
          name: user.name,
          email: user.email,
          avatar: user.avatar,
        );
      } else {
        throw Exception('Failed to create user: ${response.statusCode}');
      }
    } catch (e) {
      print('API: Error creating user: $e');
      return null;
    }
  }

  // Update user
  Future<bool> updateUser(User user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/${user.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': user.name.split(' ').first,
          'lastName': user.name.split(' ').length > 1
              ? user.name.split(' ').last
              : '',
          'email': user.email,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('API: Error updating user: $e');
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/users/$id'));

      return response.statusCode == 200;
    } catch (e) {
      print('API: Error deleting user: $e');
      return false;
    }
  }
}
