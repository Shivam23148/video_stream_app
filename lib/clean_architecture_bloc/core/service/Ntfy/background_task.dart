import 'dart:convert';

import 'package:ntavideofeedapp/clean_architecture_bloc/core/service/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;

import '../../../../main.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    logger.i("Background task triggered");
    final prefs = await SharedPreferences.getInstance();
    final client = http.Client();
    try {
      final response = await client.get(
        Uri.parse("http://192.168.29.228:8080/coffeeBit/json"),
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final latestmessage = jsonDecode(response.body);
        final currentMessageJson = jsonEncode(latestmessage);
        final lastMessageJson = prefs.getString('last_message') ?? '';
        if (currentMessageJson != lastMessageJson) {
          await prefs.setString('last_message', currentMessageJson);
          await NotificationService().createlocalNotification(
            title: latestmessage['title'] ?? 'New Message',
            body: latestmessage['message'] ?? 'You have a new message',
          );
        }
      }
    } catch (e) {
      logger.e("Error in background service");
    } finally {
      client.close();
    }
    return Future.value(true);
  });
}
