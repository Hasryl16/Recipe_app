import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class AuthService {
  final UserRepository _userRepository;
  final String _baseUrl = 'http://localhost:8000'; // Match PHP server port
  String? _token;

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
        return {'success': true, 'user': UserModel.fromJson(data['user'])};
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
        return {'success': true, 'user': UserModel.fromJson(data['user'])};
      }
      return {'success': false, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  String? get token => _token;

  Future<UserModel?> getCurrentUser(String uid) {
    return _userRepository.getUserByFirebaseUid(uid);
  }
}
