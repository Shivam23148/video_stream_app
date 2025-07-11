import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  NotificationService._();

  factory NotificationService() => _instance;
  static final NotificationService _instance = NotificationService._();
  final AwesomeNotifications awesomeNotifications = AwesomeNotifications();

  Future<void> configuration() async {
    print("configuation for notification check");
    await awesomeNotifications.initialize(null, [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notification',
        channelGroupKey: 'basic_channel_group',
        channelDescription: 'Basic Instant Notification',
        defaultColor: Colors.blue,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
    ], debug: true);
  }

  void checkingPermission(BuildContext context) {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Allow Notification"),
            content: Text("Our app would like to send notification"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Don't Allow"),
              ),
              TextButton(
                onPressed: () {
                  AwesomeNotifications()
                      .requestPermissionToSendNotifications()
                      .then((value) {
                        Navigator.pop(context);
                      });
                },
                child: Text("Allow"),
              ),
            ],
          ),
        );
      }
    });
  }

  Future<void> createlocalNotification({
    required String title,
    required String body,
    String? imageUrl,
    String channel = 'basic_channel',
    Map<String, String>? payload,
  }) async {
    await awesomeNotifications.createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(10000),
        channelKey: channel,
        title: title,
        body: body,
        notificationLayout: imageUrl != null
            ? NotificationLayout.BigPicture
            : NotificationLayout.Default,
        bigPicture: imageUrl,
        payload: payload,
      ),
    );
  }

  Future<void> startListeningNotificationEvents() async {
    print("check data with start listening");

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotifcationCreatedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
    );
  }

  static Future<void> onNotifcationCreatedMethod(
    ReceivedNotification receivedNotifications,
  ) async {
    print("onNotifcationCreatedMethod");
  }

  static Future<void> onActionReceivedMethod(
    ReceivedNotification receivedNotifications,
  ) async {
    print("onActionReceivedMethod");
  }

  static Future<void> onDismissActionReceivedMethod(
    ReceivedNotification receivedNotifications,
  ) async {
    print("onDismissActionReceivedMethod");
  }

  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotifications,
  ) async {
    print("onNotificationDisplayedMethod");
  }
}
