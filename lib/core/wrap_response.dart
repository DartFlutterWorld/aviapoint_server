import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

Map<String, String> get jsonContentHeaders => const {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
      'X-Powered-By': 'aviapoint_server',
    };

Future<Response> wrapResponse(FutureOr<Response> Function() createBody) async {
  try {
    final result = await createBody();

    return result;
  } on Object catch (e, s) {
    return Response.badRequest(
      body: jsonEncode({'error': e.toString(), 'stack_trace': s.toString()}),
      headers: jsonContentHeaders,
    );
  }
}
