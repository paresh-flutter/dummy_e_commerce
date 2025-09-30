import '../models/user.dart';
import '../models/api/auth_dto.dart';
import 'api_client.dart';

class AuthenticationService {
  final ApiClient _apiClient = ApiClient.instance;
  User? _currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  // Get current user
  User? get currentUser => _currentUser;

  // Login with email and password
  Future<User?> login(String email, String password) async {
    try {
      final request = LoginRequestDto(email: email, password: password);
      
      // For demo purposes, we'll use a mock endpoint since Fake Store API doesn't have auth
      // In a real app, this would be your actual auth endpoint
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: request.toJson(),
      );

      if (response.data != null) {
        final authResponse = AuthResponseDto.fromJson(response.data!);
        await _apiClient.setAuthToken(authResponse.token);
        _currentUser = authResponse.user.toDomain();
        return _currentUser;
      }

      return null;
    } catch (e) {
      // Fallback to mock authentication for demo
      return _mockLogin(email, password);
    }
  }

  // Register new user
  Future<User?> register(String email, String password, String name) async {
    try {
      final request = RegisterRequestDto(
        name: name,
        email: email,
        password: password,
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/register',
        data: request.toJson(),
      );

      if (response.data != null) {
        final authResponse = AuthResponseDto.fromJson(response.data!);
        await _apiClient.setAuthToken(authResponse.token);
        _currentUser = authResponse.user.toDomain();
        return _currentUser;
      }

      return null;
    } catch (e) {
      // Fallback to mock registration for demo
      return _mockRegister(name, email, password);
    }
  }

  // Logout current user
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      await _apiClient.clearAuthToken();
      _currentUser = null;
    }
  }

  // Get current user profile
  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/auth/me');
      
      if (response.data != null) {
        final userDto = UserDto.fromJson(response.data!);
        _currentUser = userDto.toDomain();
        return _currentUser;
      }

      return null;
    } catch (e) {
      return _currentUser; // Return cached user if API fails
    }
  }

  // Mock authentication fallback
  Future<User?> _mockLogin(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock users for demo
    final mockUsers = [
      const User(id: '1', email: 'test@example.com', name: 'Test User'),
      const User(id: '2', email: 'admin@example.com', name: 'Admin User'),
    ];

    final user = mockUsers.where((u) => u.email == email).firstOrNull;
    if (user != null && password.isNotEmpty) {
      _currentUser = user;
      // Set a mock token
      await _apiClient.setAuthToken('mock_token_${user.id}');
      return _currentUser;
    }

    throw Exception('Invalid email or password');
  }

  // Mock registration fallback
  Future<User?> _mockRegister(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Simple validation
    if (!isValidEmail(email)) {
      throw Exception('Invalid email format');
    }
    if (!isValidPassword(password)) {
      throw Exception('Password must be at least 6 characters');
    }

    // Create mock user
    final userId = DateTime.now().millisecondsSinceEpoch.toString();
    _currentUser = User(
      id: userId,
      name: name,
      email: email,
    );

    // Set a mock token
    await _apiClient.setAuthToken('mock_token_$userId');
    return _currentUser;
  }

  // Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate password strength
  bool isValidPassword(String password) {
    return password.length >= 6;
  }
}
