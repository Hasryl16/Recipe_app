import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getUserByFirebaseUid(String uid);
  Future<void> createUser(UserModel user);
  Future<void> updateUser(UserModel user);
}

class RemoteUserRepository implements UserRepository {
  final String baseUrl;
  RemoteUserRepository({required this.baseUrl});

  @override
  Future<UserModel?> getUserByFirebaseUid(String uid) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/profile?firebase_uid=$uid'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createUser(UserModel user) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );
    } catch (e) {
      // Handle error
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    // Implement as needed
  }
}
