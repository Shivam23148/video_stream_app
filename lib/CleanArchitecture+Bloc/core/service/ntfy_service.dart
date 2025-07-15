import 'dart:async';
import 'dart:convert';

import 'package:ntavideofeedapp/main.dart';
import 'package:ntfluttery/ntfluttery.dart';
import 'package:http/http.dart' as http;

/* class NtfyService {
  final String baseUrl;
  final String topic;
  late final NtflutteryService ntflutteryService;
  StreamSubscription<(List<EventData>, List<EventData>)>? sub;
  NtfyService({required this.baseUrl, required this.topic}) {
    ntflutteryService = NtflutteryService()..addLogging(true);
  }

  Future<void> subscribe({
    required void Function(String message, EventData metdata) onMessage,
    void Function(Object error)? error,
    void Function()? onDone,
  }) async {
    print('subscribe() called');

    Future<void> _startListening() async {
      final uri = '$baseUrl/$topic/json';
      try {
        final result = await ntflutteryService.get(uri);
        print('✅ Connected, listening to stream');
        sub = result.$1.listen(
          (eventTuple) {
            final message = eventTuple.$1;
            print('📥 Received eventTuple with ${message.length} messages');
            for (final e in message) {
              final msg = e.toString();
              onMessage(msg, e);
            }
          },
          onError: error,
          onDone: onDone,
        );
      } catch (e) {
        print('🚨 Exception during subscribe: $e');
        if (error != null) error(e);
      }
    }

    _startListening();
  }

  Future<EventData> fetchLatest() async {
    final uri = '$baseUrl/$topic/json?poll=1';
    final latest = await ntflutteryService.getLatestMessage(uri);
    return latest;
  }

  Future<void> dispose() async {
    await sub?.cancel();
  }
}
 */

class NtfyService {
  final client = http.Client();
  StreamSubscription<String>? _subscription;

  void streamNtfy({required Function(Map<String, dynamic>) onMessage}) async {
    final request = http.Request(
      'GET',
      Uri.parse("http://192.168.29.228:8080/coffeeBit/json"),
    );
    final streamResponse = await client.send(request);

    streamResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
            if (line.trim().isNotEmpty) {
              final message = json.decode(line);
              logger.d('New Message: $message');
              onMessage(message);
            }
          },
          onError: (e) {
            logger.e("Error: $e");
          },
          onDone: () {
            logger.i("Stream Closed");
          },
        );
  }

  void dispose() {
    _subscription?.cancel();
    client.close();
  }
}
