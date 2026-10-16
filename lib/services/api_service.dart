import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:http_parser/http_parser.dart';

class NailPortfolioItem {
  final int id;
  final String title;
  final String categoryName;
  final String imageUrl;
  final double price;

  NailPortfolioItem({
    required this.id,
    required this.title,
    required this.categoryName,
    required this.imageUrl,
    required this.price,
  });

  factory NailPortfolioItem.fromJson(Map<String, dynamic> json) {
    var rawPrice = json['price'];
  double parsedPrice = 0.0;

  if (rawPrice is num) {
    parsedPrice = rawPrice.toDouble();
  } else if (rawPrice is String) {
    // Remove comma and parse
    parsedPrice = double.tryParse(rawPrice.replaceAll(',', '').trim()) ?? 0.0;
  }
    return NailPortfolioItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      categoryName: json['categoryName'] ?? 'Portfolio',
      imageUrl: json['imageUrl'] ?? '',
      price: parsedPrice,
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
      return 'https://10.0.2.2:7276/api';
    }
    return 'https://localhost:7276/api';
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
  // AUTH - REGISTER
  // ==========================================
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
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
        }),
      );

      final Map<String, dynamic> responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Account created successfully',
        };
      } else {
        final errorMessage = responseData['message'] ??
            responseData['title'] ??
            'Registration failed (${response.statusCode})';
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
        return {
          'success': true,
          'message': responseData['message'] ?? 'Login successful',
          'token': responseData['token'],
          'user': responseData['user'],
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
  // CATEGORIES - CREATE (Dynamic by serviceType)
  // ==========================================
  static Future<Map<String, dynamic>> createCategory(
    String name, {
    String? serviceType,
  }) async {
    final endpoint = _resolveEndpoint(serviceType);
    final url = Uri.parse('$_baseUrl/$endpoint/addcategories');
    debugPrint('--> [POST] createCategory to: $url');

    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
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

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
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
          contentType: MediaType('image', mimeSubtype),
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
}