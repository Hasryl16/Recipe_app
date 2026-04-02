import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class AuthService {
  final UserRepository _userRepository;
  final String _baseUrl = 'http://localhost:8000'; // Match PHP server port
  String? _token;
  UserModel? _currentUser;

  AuthService(this._userRepository);

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _token = data['token'];
        _currentUser = UserModel.fromJson(data['user']);
        return {'success': true, 'user': _currentUser};
      }
      return {'success': false, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _token = data['token'];
        _currentUser = UserModel.fromJson(data['user']);
        return {'success': true, 'user': _currentUser};
      }
      return {'success': false, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateProfile(String username, String bio) async {
    if (_token == null) return {'success': false, 'message': 'Not authenticated'};
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/profile-update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'username': username,
          'bio': bio,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        // Update local user state
        if (_currentUser != null) {
          _currentUser = UserModel(
            id: _currentUser!.id,
            firebaseUid: _currentUser!.firebaseUid,
            username: username,
            bio: bio,
            profilePicture: _currentUser!.profilePicture,
            createdAt: _currentUser!.createdAt,
          );
        }
        return {'success': true};
      }
      return {'success': false, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, int>> getUserStats() async {
    if (_token == null) return {'recipe_count': 0, 'bookmark_count': 0, 'follower_count': 0};
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile-stats'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'recipe_count': data['recipe_count'] ?? 0,
        'bookmark_count': data['bookmark_count'] ?? 0,
        'follower_count': data['follower_count'] ?? 0,
      };
    } catch (e) {
      return {'recipe_count': 0, 'bookmark_count': 0, 'follower_count': 0};
    }
  }

  void logout() {
    _token = null;
    _currentUser = null;
  }

  String? get token => _token;
  UserModel? get currentUser => _currentUser;

  Future<UserModel?> getCurrentUser(String uid) {
    return _userRepository.getUserByFirebaseUid(uid);
  }
}
