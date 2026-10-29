
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../screens/common/video_card.dart';
import '../screens/courses/courses_screen.dart';
import 'api_service.dart';

class CourseApiService {
  // ==========================================
  // BASE URL
  // ==========================================
  static String get _baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'https://10.0.2.2:61754/api';
    }

    return 'https://localhost:61754/api';
  }

  // ==========================================
  // HTTP CLIENT
  // ==========================================
  static http.Client get _client {
    if (kIsWeb) {
      return http.Client();
    }

    final httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    return IOClient(httpClient);
  }

  static String get _endpointUrl => '$_baseUrl/CoursesApi';

  // ==========================================
  // FETCH COURSES
  // ==========================================
  static Future<List<CourseModel>> fetchCourses({
    String? category,
    bool? isOnline,
  }) async {
    final queryParams = <String, String>{};

    if (category != null && category != 'All') {
      queryParams['category'] = category;
    }

    if (isOnline != null) {
      queryParams['isOnline'] = isOnline.toString();
    }

    final uri = Uri.parse(_endpointUrl).replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    try {
      final response = await _client.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List list = decoded['data'] ?? [];

        return list.map((item) {
          final perksList = (item['perks'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              <String>[];

          return CourseModel(
            id: item['id'],
            title: item['title'] ?? '',
            category: item['category'] ?? '',
            level: item['level'] ?? 'All Levels',
            price: item['price']?.toString() ?? '',
            imageUrl: _buildFullImageUrl(item['imageUrl']),
            isOnline: item['isOnline'] ?? false,
            perks: perksList.isEmpty
                ? ['Certificate included']
                : perksList,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching courses: $e');
    }

    return [];
  }

  // ==========================================
  // FETCH VIDEOS
  // ==========================================
  static Future<List<VideoTutorial>> fetchVideos({
    String? category,
  }) async {
    final queryParams = <String, String>{};

    if (category != null && category != 'All') {
      queryParams['category'] = category;
    }

    final uri = Uri.parse('$_endpointUrl/videos').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    try {
      final response = await _client.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List list = decoded['data'] ?? [];

        return list.map((item) {
          return VideoTutorial(
            id: item['id']?.toString() ?? '',
            title: item['title'] ?? '',
            category: item['category'] ?? '',
            duration: item['duration'] ?? '',
            thumbnailUrl: _buildFullImageUrl(item['thumbnailUrl']),
            videoUrl: item['videoUrl'],
            isPremium: item['isPremium'] ?? false,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching videos: $e');
    }

    return [];
  }

  // ==========================================
  // UPLOAD COURSE
  // ==========================================
  static Future<Map<String, dynamic>> uploadCourse({
    required String title,
    required String category,
    required String level,
    required double price,
    required bool isOnline,
    required List<String> perks,
    String? imageUrl,
    Uint8List? imageBytes,
    String? filename,
  }) async {
    final url = Uri.parse('$_endpointUrl/course');

    try {
      final request = http.MultipartRequest('POST', url);

      final token = await ApiService.getToken();

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.headers['Accept'] = 'application/json';

      request.fields['Title'] = title;
      request.fields['Category'] = category;
      request.fields['Level'] = level;
      request.fields['Price'] = price.toString();
      request.fields['IsOnline'] = isOnline.toString();

      if (imageUrl != null && imageUrl.isNotEmpty) {
        request.fields['ImageUrl'] = imageUrl;
      }

      for (int i = 0; i < perks.length; i++) {
        request.fields['Perks[$i]'] = perks[i];
      }

      // Upload course image using bytes (Web compatible).
      if (imageBytes != null && imageBytes.isNotEmpty) {
        final name = (filename != null && filename.isNotEmpty)
            ? filename
            : 'course_image.jpg';

        final ext = name.contains('.')
            ? name.split('.').last.toLowerCase()
            : 'jpg';

        request.files.add(
          http.MultipartFile.fromBytes(
            'ImageFile',
            imageBytes,
            filename: name,
            contentType: http.MediaType('image', _getImageMimeType(ext)),
          ),
        );
      }

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      final dynamic responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Course published successfully',
          'id': responseData['data'],
        };
      }

      return {
        'success': false,
        'message': responseData['message'] ??
            'Server returned error code: ${response.statusCode}',
      };
    } catch (e) {
      debugPrint('Course upload exception: $e');

      return {
        'success': false,
        'message': 'Failed to connect: $e',
      };
    }
  }

  // ==========================================
  // UPLOAD VIDEO CLIP
  // ==========================================
  static Future<Map<String, dynamic>> uploadVideoClip({
    required String title,
    required String category,
    required bool isPremium,
    String? thumbnailUrl,
    String? videoUrl,
    Uint8List? thumbnailBytes,
    String? thumbnailFilename,
    Uint8List? localVideoBytes,
    String? localVideoFilename,
  }) async {
    final url = Uri.parse('$_endpointUrl/video');

    try {
      final request = http.MultipartRequest('POST', url);

      final token = await ApiService.getToken();

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.headers['Accept'] = 'application/json';

      request.fields['Title'] = title;
      request.fields['Category'] = category;
      request.fields['IsPremium'] = isPremium.toString();

      if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
        request.fields['ThumbnailUrl'] = thumbnailUrl;
      }

      if (videoUrl != null && videoUrl.isNotEmpty) {
        request.fields['VideoUrl'] = videoUrl;
      }

      // ------------------------------------------
      // THUMBNAIL UPLOAD (WEB + MOBILE)
      // ------------------------------------------
      if (thumbnailBytes != null && thumbnailBytes.isNotEmpty) {
        final name =
            (thumbnailFilename != null && thumbnailFilename.isNotEmpty)
                ? thumbnailFilename
                : 'thumb.jpg';

        final ext = name.contains('.')
            ? name.split('.').last.toLowerCase()
            : 'jpg';

        request.files.add(
          http.MultipartFile.fromBytes(
            'ThumbnailFile',
            thumbnailBytes,
            filename: name,
            contentType: http.MediaType('image', _getImageMimeType(ext)),
          ),
        );
      }

      // ------------------------------------------
      // VIDEO UPLOAD (WEB + MOBILE)
      // ------------------------------------------
      if (localVideoBytes != null && localVideoBytes.isNotEmpty) {
        final name =
            (localVideoFilename != null && localVideoFilename.isNotEmpty)
                ? localVideoFilename
                : 'video.mp4';

        final ext = name.contains('.')
            ? name.split('.').last.toLowerCase()
            : 'mp4';

        request.files.add(
          http.MultipartFile.fromBytes(
            'VideoFile',
            localVideoBytes,
            filename: name,
            contentType: http.MediaType('video', _getVideoMimeType(ext)),
          ),
        );
      }

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      final dynamic responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Video uploaded successfully',
          'id': responseData['data'],
        };
      }

      return {
        'success': false,
        'message': responseData['message'] ??
            'Server returned error code: ${response.statusCode}',
      };
    } catch (e) {
      debugPrint('Video upload exception: $e');

      return {
        'success': false,
        'message': 'Failed to connect: $e',
      };
    }
  }

  // ==========================================
  // IMAGE MIME TYPE
  // ==========================================
  static String _getImageMimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'png':
        return 'png';
      case 'webp':
        return 'webp';
      case 'gif':
        return 'gif';
      case 'bmp':
        return 'bmp';
      default:
        return 'jpeg';
    }
  }

  // ==========================================
  // VIDEO MIME TYPE
  // ==========================================
  static String _getVideoMimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'webm':
        return 'webm';
      case 'mov':
        return 'quicktime';
      case 'avi':
        return 'x-msvideo';
      case 'mkv':
        return 'x-matroska';
      case 'm4v':
        return 'x-m4v';
      default:
        return 'mp4';
    }
  }

  // ==========================================
  // BUILD FULL IMAGE URL
  // ==========================================
  static String _buildFullImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://images.unsplash.com/photo-1632345031435-8727f6897d53?w=800&q=80';
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final serverRoot = _baseUrl.replaceAll('/api', '');

    return '$serverRoot$path';
  }
}
