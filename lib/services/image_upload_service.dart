import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart' as http_parser;

class ImageUploadService {
  late final Dio _dio;
  late final String _baseUrl;

  ImageUploadService() {
    _baseUrl = dotenv.env['BASE_URL'] ?? '';
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': '*/*'},
      ),
    );

    // Add request interceptor for debugging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          log('Request URL: ${options.baseUrl}${options.path}');
          log('Request Method: ${options.method}');
          log('Request Headers: ${options.headers}');
          if (options.data is FormData) {
            final formData = options.data as FormData;
            log(
              'FormData fields: ${formData.fields.map((e) => '${e.key}: ${e.value}').join(', ')}',
            );
            log(
              'FormData files: ${formData.files.map((e) => '${e.key}: ${e.value.filename}').join(', ')}',
            );
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          log('Response Status: ${response.statusCode}');
          log('Response Data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          log('Request Error: ${error.message}');
          if (error.response != null) {
            log('Error Response Status: ${error.response!.statusCode}');
            log('Error Response Data: ${error.response!.data}');
            log('Error Response Headers: ${error.response!.headers}');
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<Response?> uploadImages(List<File> images) async {
    // Try different field names that the API might expect
    List<String> fieldNames = [
      'images',
      'image',
      'file',
      'files',
      'upload',
      'photo',
    ];

    for (String fieldName in fieldNames) {
      try {
        log('Attempting upload with field name: $fieldName');

        FormData formData = FormData();

        // Add each image
        for (int i = 0; i < images.length; i++) {
          String fileName = images[i].path.split(Platform.pathSeparator).last;
          log('Adding file: $fileName (${images[i].lengthSync()} bytes)');

          // Determine MIME type based on file extension
          String contentType = _getContentType(fileName);
          log('File content type: $contentType');

          // Create multipart file with explicit content type
          final multipartFile = await MultipartFile.fromFile(
            images[i].path,
            filename: fileName,
            contentType: http_parser.MediaType.parse(contentType),
          );

          formData.files.add(MapEntry(fieldName, multipartFile));
        }

        log('Sending POST request to /upload/no-token');
        log('FormData files count: ${formData.files.length}');
        log('Base URL: $_baseUrl');

        final response = await _dio.post(
          '/upload/no-token',
          data: formData,
          options: Options(
            validateStatus: (status) => status! < 500,
            headers: {'Accept': 'application/json'},
          ),
        );

        if (response.statusCode == 200) {
          log('Upload successful with field name: $fieldName');
          return response;
        } else {
          log(
            'Upload failed with field name $fieldName, status: ${response.statusCode}',
          );
          // Continue to try next field name
        }
      } on DioException catch (e) {
        log('DioException with field name $fieldName: ${e.message}');
        if (e.response != null) {
          log('Error Response Status: ${e.response!.statusCode}');
          log('Error Response Data: ${e.response!.data}');
        }
        // If this is the last field name, rethrow the error
        if (fieldName == fieldNames.last) {
          rethrow;
        }
        // Otherwise continue to try next field name
      } catch (e) {
        log('Unexpected error with field name $fieldName: $e');
        if (fieldName == fieldNames.last) {
          rethrow;
        }
      }
    }

    throw Exception('All upload attempts failed');
  }

  String _getContentType(String fileName) {
    String extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'svg':
        return 'image/svg+xml';
      default:
        return 'image/jpeg'; // Default fallback
    }
  }

  // Test method to check if the API endpoint is reachable
  Future<bool> testConnection() async {
    try {
      log('Testing API connection to: $_baseUrl');
      final response = await _dio.get('/');
      log('API connection test - Status: ${response.statusCode}');
      return true;
    } catch (e) {
      log('API connection test failed: $e');
      return false;
    }
  }

  // Test what fields the API accepts
  Future<void> testEndpointFields() async {
    try {
      log('Testing endpoint fields...');

      FormData formData = FormData.fromMap({'test': 'hello world'});

      final response = await _dio.post(
        '/upload/no-token',
        data: formData,
        options: Options(validateStatus: (status) => status! < 500),
      );

      log('Endpoint test response: ${response.statusCode} - ${response.data}');
    } catch (e) {
      log('Endpoint test error: $e');
    }
  }
}
