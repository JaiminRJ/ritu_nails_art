import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NailPortfolioItem {
  final int id;
  final String title;
  final String categoryName;
  final String imageUrl;
  final double price;
  final String description;

  NailPortfolioItem({
    required this.id,
    required this.title,
    required this.categoryName,
    required this.imageUrl,
    required this.price,
    this.description = '',
  });

  factory NailPortfolioItem.fromJson(Map<String, dynamic> json) {
    var rawPrice = json['price'];
    double parsedPrice = 0.0;

    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      parsedPrice = double.tryParse(rawPrice.replaceAll(',', '').trim()) ?? 0.0;
    }
    return NailPortfolioItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      categoryName: json['categoryName'] ?? 'Portfolio',
      imageUrl: json['imageUrl'] ?? '',
      price: parsedPrice,
      description: json['description']?.toString() ?? '',
    );
  }
}

class MakeupPortfolioItem {
  final int id;
  final String title;
  final String categoryName;
  final String imageUrl;
  final double price;

  MakeupPortfolioItem({
    required this.id,
    required this.title,
    required this.categoryName,
    required this.imageUrl,
    required this.price,
  });

  factory MakeupPortfolioItem.fromJson(Map<String, dynamic> json) {
    return MakeupPortfolioItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      categoryName: json['categoryName'] ?? 'Makeup',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class HairPortfolioItem {
  final int id;
  final String title;
  final String categoryName;
  final String imageUrl;
  final double price;

  HairPortfolioItem({
    required this.id,
    required this.title,
    required this.categoryName,
    required this.imageUrl,
    required this.price,
  });

  factory HairPortfolioItem.fromJson(Map<String, dynamic> json) {
    return HairPortfolioItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      categoryName: json['categoryName'] ?? 'Hair Style',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class ApiService {
  static String get _baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'https://10.0.2.2:61754/api';
    }
    return 'https://localhost:61754/api';
  }

  static http.Client get _client {
    if (kIsWeb) {
      return http.Client();
    }
    final httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    return IOClient(httpClient);
  }

  static String _resolveEndpoint(String? serviceType) {
    final type = (serviceType ?? 'nails').trim().toLowerCase();
    if (type == 'makeup') return 'MakeupApi';
    if (type == 'hair') return 'HairApi';
    return 'NailsApi';
  }

  // ==========================================
  // SESSION & ROLE MANAGEMENT
  // ==========================================
  static String? _cachedToken;
  static Map<String, dynamic>? _cachedUser;

  static const String _prefTokenKey = 'auth_token';
  static const String _prefUserKey = 'auth_user';

  /// Saves token and user details to device storage and memory cache
  static Future<void> saveAuthData({
    required String token,
    Map<String, dynamic>? user,
  }) async {
    _cachedToken = token;
    _cachedUser = user;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefTokenKey, token);
      if (user != null) {
        await prefs.setString(_prefUserKey, jsonEncode(user));
      }
    } catch (e) {
      debugPrint('SharedPreferences not available or failed: $e');
    }
  }

  /// Clears stored user session
  static Future<void> logout() async {
    _cachedToken = null;
    _cachedUser = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefTokenKey);
      await prefs.remove(_prefUserKey);
    } catch (_) {}
  }

  /// Retrieves the current JWT token
  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedToken = prefs.getString(_prefTokenKey);
      return _cachedToken;
    } catch (_) {
      return null;
    }
  }

  /// Retrieves the stored user profile map
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    if (_cachedUser != null) return _cachedUser;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString(_prefUserKey);
      if (userString != null && userString.isNotEmpty) {
        _cachedUser = jsonDecode(userString) as Map<String, dynamic>;
      }
      return _cachedUser;
    } catch (_) {
      return null;
    }
  }

  /// Helper used by UI to check if the active user is an Admin
  static Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    if (user == null) return false;

    // Checks "roles": ["Admin", ...] or "roles": "Admin"
    final dynamic rolesData = user['roles'] ?? user['role'];
    if (rolesData is List) {
      return rolesData.any((r) => r.toString().toLowerCase() == 'admin');
    } else if (rolesData is String) {
      return rolesData.toLowerCase() == 'admin';
    }

    return false;
  }

  // ==========================================
  // AUTH - REGISTER
  // ==========================================
 // ==========================================
  // AUTH - REGISTER
  // ==========================================
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    String? mobileNumber,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/register');

    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', 
        },
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'mobileNumber': mobileNumber,
        }),
      );

      // Safe JSON decode to avoid FormatException
      dynamic responseData;
      try {
        responseData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      } catch (_) {
        debugPrint('--> Raw Backend Error: ${response.body}');
        return {
          'success': false,
          'message': 'Backend Error (${response.statusCode}): ${response.body}',
        };
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Account created successfully',
        };
      } else {
        final errorMessage = responseData is Map
            ? (responseData['message'] ?? responseData['title'] ?? 'Registration failed')
            : 'Error (${response.statusCode})';
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server: $e',
      };
    }
  }

  // ==========================================
  // AUTH - LOGIN
  // ==========================================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/login');

    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final token = responseData['token']?.toString() ?? '';
        final user = responseData['user'] is Map<String, dynamic>
            ? responseData['user'] as Map<String, dynamic>
            : <String, dynamic>{};

        // Automatically save session token & user info (including roles)
        if (token.isNotEmpty) {
          await saveAuthData(token: token, user: user);
        }

        return {
          'success': true,
          'message': responseData['message'] ?? 'Login successful',
          'token': token,
          'user': user,
        };
      } else {
        final errorMessage = responseData['message'] ??
            responseData['title'] ??
            'Invalid email or password';
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server: $e',
      };
    }
  }

  // ==========================================
  // AUTH - GOOGLE LOGIN
  // ==========================================
  static Future<Map<String, dynamic>> googleLogin({
    required String idToken,
  }) async {
    final url = Uri.parse('$_baseUrl/GoogleLogin/google-login');

    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'idToken': idToken}),
      );

      final Map<String, dynamic> responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final token = responseData['token']?.toString() ?? '';
        final user = responseData['user'] is Map<String, dynamic>
            ? responseData['user'] as Map<String, dynamic>
            : <String, dynamic>{};

        if (token.isNotEmpty) {
          await saveAuthData(token: token, user: user);
        }

        return {
          'success': true,
          'message': responseData['message'] ?? 'Login successful',
          'token': token,
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ??
              responseData['title'] ??
              'Google login failed (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server: $e',
      };
    }
  }

  // ==========================================
  // CATEGORIES - CREATE (Dynamic by serviceType)
  // ==========================================
  static Future<Map<String, dynamic>> createCategory(
    String name, {
    String? serviceType,
  }) async {
    final endpoint = _resolveEndpoint(serviceType);
    final url = Uri.parse('$_baseUrl/$endpoint/addcategories');
    final token = await getToken();
    debugPrint('--> [POST] createCategory to: $url');

    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client.post(
        url,
        headers: headers,
        body: jsonEncode({
          'Name': name.trim(),
          'DisplayOrder': 0,
          'IsActive': true,
        }),
      );

      debugPrint('--> Status Code: ${response.statusCode}');
      debugPrint('--> Response Body: ${response.body}');

      dynamic responseData;
      try {
        responseData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      } catch (_) {
        return {
          'success': false,
          'message': 'Server Error: ${response.body}',
        };
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': responseData['success'] ?? true,
          'message': responseData['message'] ?? 'Category added successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ??
              'Server returned status ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('--> createCategory error: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // ==========================================
  // CATEGORIES - FETCH (Dynamic by serviceType)
  // ==========================================
  static Future<List<Map<String, dynamic>>> fetchCategories({
    String? serviceType,
  }) async {
    final endpoint = _resolveEndpoint(serviceType);
    final url = Uri.parse('$_baseUrl/$endpoint/categories');

    try {
      final response = await _client.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final dynamic rawData = decoded['data'] ?? decoded;
        if (rawData is List) {
          return List<Map<String, dynamic>>.from(rawData);
        }
      }
    } catch (e) {
      debugPrint('Error fetching categories ($endpoint): $e');
    }
    return [];
  }

  // ==========================================
  // PORTFOLIO - FETCH (Dynamic by serviceType)
  // ==========================================
  static Future<List<NailPortfolioItem>> fetchNailArts({
    int? categoryId,
    String? serviceType,
  }) async {
    final endpoint = _resolveEndpoint(serviceType);
    final queryParams = <String, String>{};
    if (categoryId != null && categoryId > 0) {
      queryParams['categoryId'] = categoryId.toString();
    }

    final uri = Uri.parse('$_baseUrl/$endpoint')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    try {
      final response = await _client.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = decoded['data'] ?? [];
        return data.map((item) => NailPortfolioItem.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching portfolio items ($endpoint): $e');
    }
    return [];
  }

  // ==========================================
  // PORTFOLIO - UPLOAD (Dynamic by serviceType)
  // ==========================================
  static Future<Map<String, dynamic>> uploadNailArt({
    required String title,
    required int categoryId,
    required Uint8List imageBytes,
    required String filename,
    double price = 0.0,
    int durationMinutes = 60,
    String description = '',
    String? serviceType,
    String? token,
  }) async {
    final endpoint = _resolveEndpoint(serviceType);
    final url = Uri.parse('$_baseUrl/$endpoint/upload');
    debugPrint('--> Initiating upload to: $url');

    try {
      final request = http.MultipartRequest('POST', url);

      // If token wasn't directly passed, resolve it automatically from storage
      final effectiveToken = token ?? await getToken();
      if (effectiveToken != null && effectiveToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $effectiveToken';
      }
      request.headers['Accept'] = 'application/json';

      request.fields['Title'] = title;
      request.fields['CategoryId'] = categoryId.toString();
      request.fields['Price'] = price.toString();
      request.fields['DurationMinutes'] = durationMinutes.toString();
      request.fields['Description'] = description;

      final String extension = filename.contains('.')
          ? filename.split('.').last.toLowerCase()
          : 'jpeg';

      String mimeSubtype;
      switch (extension) {
        case 'png':
          mimeSubtype = 'png';
          break;
        case 'webp':
          mimeSubtype = 'webp';
          break;
        case 'gif':
          mimeSubtype = 'gif';
          break;
        case 'jpg':
        case 'jpeg':
        default:
          mimeSubtype = 'jpeg';
          break;
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'ImageFile',
          imageBytes,
          filename: filename.isEmpty ? 'upload.$mimeSubtype' : filename,
          contentType: http.MediaType('image', mimeSubtype),
        ),
      );

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('--> Response Status: ${response.statusCode}');
      debugPrint('--> Response Body: ${response.body}');

      final dynamic responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Uploaded successfully',
          'id': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ??
              'Upload failed (${response.statusCode}): ${response.body}',
        };
      }
    } catch (e) {
      debugPrint('--> Upload exception: $e');
      return {
        'success': false,
        'message': 'Failed to connect: $e',
      };
    }
  }

  // ==========================================
  // MAKEUP - DEDICATED ALIASES
  // ==========================================
  static Future<List<Map<String, dynamic>>> fetchMakeupCategories() =>
      fetchCategories(serviceType: 'Makeup');

  static Future<Map<String, dynamic>> createMakeupCategory(String name) =>
      createCategory(name, serviceType: 'Makeup');

  static Future<List<MakeupPortfolioItem>> fetchMakeupArts({int? categoryId}) async {
    final list = await fetchNailArts(categoryId: categoryId, serviceType: 'Makeup');
    return list
        .map((item) => MakeupPortfolioItem(
              id: item.id,
              title: item.title,
              categoryName: item.categoryName,
              imageUrl: item.imageUrl,
              price: item.price,
            ))
        .toList();
  }

  static Future<Map<String, dynamic>> uploadMakeupArt({
    required String title,
    required int categoryId,
    required Uint8List imageBytes,
    required String filename,
    double price = 0.0,
    int durationMinutes = 60,
    String description = '',
    String? token,
  }) =>
      uploadNailArt(
        title: title,
        categoryId: categoryId,
        imageBytes: imageBytes,
        filename: filename,
        price: price,
        durationMinutes: durationMinutes,
        description: description,
        serviceType: 'Makeup',
        token: token,
      );

  // ==========================================
  // HAIR - DEDICATED ALIASES
  // ==========================================
  static Future<List<Map<String, dynamic>>> fetchHairCategories() =>
      fetchCategories(serviceType: 'Hair');

  static Future<Map<String, dynamic>> createHairCategory(String name) =>
      createCategory(name, serviceType: 'Hair');

  static Future<List<HairPortfolioItem>> fetchHairArts({int? categoryId}) async {
    final list = await fetchNailArts(categoryId: categoryId, serviceType: 'Hair');
    return list
        .map((item) => HairPortfolioItem(
              id: item.id,
              title: item.title,
              categoryName: item.categoryName,
              imageUrl: item.imageUrl,
              price: item.price,
            ))
        .toList();
  }

  static Future<Map<String, dynamic>> uploadHairArt({
    required String title,
    required int categoryId,
    required Uint8List imageBytes,
    required String filename,
    double price = 0.0,
    int durationMinutes = 60,
    String description = '',
    String? token,
  }) =>
      uploadNailArt(
        title: title,
        categoryId: categoryId,
        imageBytes: imageBytes,
        filename: filename,
        price: price,
        durationMinutes: durationMinutes,
        description: description,
        serviceType: 'Hair',
        token: token,
      );

  // ==========================================
  // FEEDBACK - SUBMIT
  // ==========================================
  static Future<Map<String, dynamic>> submitFeedback({
    required int rating,
    required String comments,
    String? token,
  }) async {
    final url = Uri.parse('$_baseUrl/FeedbackApi');

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final effectiveToken = token ?? await getToken();
      if (effectiveToken != null && effectiveToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $effectiveToken';
      }

      final response = await _client.post(
        url,
        headers: headers,
        body: jsonEncode({
          'rating': rating,
          'comments': comments.trim(),
        }),
      );

      final Map<String, dynamic> responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Feedback submitted successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ??
              'Failed to submit feedback (${response.statusCode})',
        };
      }
    } catch (e) {
      debugPrint('Error submitting feedback: $e');
      return {
        'success': false,
        'message': 'Unable to connect to server: $e',
      };
    }
  }
}