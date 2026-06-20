import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:shoo/core/constants/hos_constants.dart';
import 'package:shoo/core/logging/hos_logger.dart';

HttpServer? _server;

Future<String?> ensureActivityMockServerStarted() async {
  if (_server != null) {
    return _baseUrl();
  }

  try {
    _server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      SHOAppConstants.activityMockServerPort,
      shared: true,
    );
    _server!.listen(_handleRequest, onError: (Object error, StackTrace stack) {
      SHOAppLogger.warn('Activity mock server error: $error');
    });
    SHOAppLogger.info(
      'Activity mock server started at ${_baseUrl()}',
    );
    return _baseUrl();
  } catch (error, stack) {
    SHOAppLogger.error('Activity mock server bind failed', error, stack);
    return null;
  }
}

Future<void> stopActivityMockServer() async {
  final server = _server;
  _server = null;
  await server?.close(force: true);
}

String _baseUrl() {
  final host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
  return 'http://$host:${SHOAppConstants.activityMockServerPort}';
}

Future<void> _handleRequest(HttpRequest request) async {
  try {
    final path = request.uri.path;
    if (request.method == 'GET' && (path == '/' || path == '/index.html')) {
      await _writeAsset(
        request,
        'assets/activity/index.html',
        ContentType('text', 'html', charset: 'utf-8'),
      );
      return;
    }
    if (request.method == 'GET' && path == '/api/v1/activity/data') {
      await _writeMockEnvelopeData(
        request,
        'assets/mock/activity_data.json',
      );
      return;
    }
    if (request.method == 'GET' && path == '/api/v1/activity/detail') {
      await _writeMockEnvelopeData(
        request,
        'assets/mock/activity_detail.json',
      );
      return;
    }
    if (request.method == 'GET' && path == '/api/v1/activity/detail/level3') {
      await _writeMockEnvelopeData(
        request,
        'assets/mock/activity_level3_detail.json',
      );
      return;
    }
    if (request.method == 'GET' && path == '/api/v1/activity/user/check') {
      await _writeMockEnvelopeData(
        request,
        'assets/mock/activity_user_check.json',
      );
      return;
    }
    if (request.method == 'GET' && path == '/api/activity/data') {
      await _writeMockEnvelopeData(
        request,
        'assets/mock/activity_data.json',
      );
      return;
    }
    if (request.method == 'GET' && path == '/api/user/check') {
      await _writeMockEnvelopeData(
        request,
        'assets/mock/activity_user_check.json',
      );
      return;
    }
    if (request.method == 'GET' && path == '/api/config/url-rules') {
      await _writeMockEnvelopeData(
        request,
        'assets/mock/activity_url_rules.json',
      );
      return;
    }
    request.response.statusCode = HttpStatus.notFound;
    request.response.write('Not Found');
  } catch (error, stack) {
    SHOAppLogger.error('Activity mock server request failed', error, stack);
    request.response.statusCode = HttpStatus.internalServerError;
    request.response.write('Internal Server Error');
  } finally {
    await request.response.close();
  }
}

Future<void> _writeAsset(
  HttpRequest request,
  String assetPath,
  ContentType contentType,
) async {
  final body = await rootBundle.loadString(assetPath);
  request.response.headers.contentType = contentType;
  request.response.write(body);
}

Future<void> _writeMockEnvelopeData(
  HttpRequest request,
  String assetPath,
) async {
  final raw = await rootBundle.loadString(assetPath);
  final envelope = jsonDecode(raw) as Map<String, dynamic>;
  final data = envelope['data'];
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode(data));
}
