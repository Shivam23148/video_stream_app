import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ntavideofeedapp/AssetManager/assets_manager.dart';
import 'package:ntavideofeedapp/Utils/global_variable.dart';
import 'package:ntavideofeedapp/Utils/language_enum.dart';
import 'package:ntavideofeedapp/controller/language_change_controller.dart';
import 'package:ntavideofeedapp/l10n/app_localizations.dart';
import 'package:ntavideofeedapp/presentation/page/Keycloak%20Redirect/keycloak_authentication_redirect.dart';
import 'package:ntavideofeedapp/presentation/page/example.dart';
import 'package:ntavideofeedapp/routes/route_names.dart';
import 'package:ntavideofeedapp/service/auth_service.dart';
import 'package:ntavideofeedapp/service/notification_service.dart';
import 'package:ntavideofeedapp/service/ntfy_service.dart';
import 'package:provider/provider.dart';

class ExampleScreen extends StatefulWidget {
  ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final NtfyService ntfyService = NtfyService();
  List<Map<String, dynamic>> messages = [];
  List<String> gridNumberList = ['1X1', '2X2', '3X3', '4X4'];
  String dropdownValue = '2X2';
  final AuthService authService = AuthService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("Init state called");

    NotificationService().checkingPermission(context);

    NotificationService().startListeningNotificationEvents();
    ntfyService.streamNtfy(
      onMessage: (message) {
        print("Message list : ${message}");
        NotificationService().createlocalNotification(
          title: message['title'] ?? 'New Message',
          body: message['message'] ?? 'You have a new message',
          imageUrl: message['image'],
        );
        setState(() {
          messages.add(message);
          print("Message on ui is : $message");
        });
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print("Dispose called , cancelling subscription");
    ntfyService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = int.tryParse(dropdownValue.split('X').first) ?? 2;
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          Consumer<LanguageChangeController>(
            builder: (context, provider, child) {
              return PopupMenuButton(
                onSelected: (Language item) {
                  if (Language.english.name == item.name) {
                    provider.changeLanguage(Locale('en'));
                  } else {
                    print("Hindi button pressed");
                    provider.changeLanguage(Locale('hi'));
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<Language>>[
                      const PopupMenuItem(
                        value: Language.english,
                        child: Text("English"),
                      ),
                      const PopupMenuItem(
                        value: Language.hindi,
                        child: Text("Hindi"),
                      ),
                    ],
              );
            },
          ),
        ],
        leading: Builder(
          builder: (context) => DropdownButton(
            value: dropdownValue,
            elevation: 6,
            underline: SizedBox(),
            items: gridNumberList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? value) {
              // This is called when the user selects an item.
              setState(() {
                dropdownValue = value!;
              });
            },
          ),
        ),
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.exampleText),
      ),
      body: /*  Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                final msg = messages[index];
                return ListTile(
                  title: Text(msg['message'] ?? 'No message'),
                  subtitle: Text(msg['title'] ?? 'No Message'),
                );
              },
              itemCount: messages.length,
            ),
          ),
          ElevatedButton(onPressed: () {
            NotificationService().createlocalNotification(
          title: 'New Message',
          body:  'You have a new message'
        );
          }, child: Text("Send Notification")),
        ],
      ), */ Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,

              children: List.generate(crossAxisCount * crossAxisCount, (index) {
                return Center(child: Container(color: Colors.green));
              }),
            ),
          ),
          Text(
            GlobalUse.userRole,
            style: TextStyle(fontSize: MediaQuery.sizeOf(context).width * 0.2),
          ),
          ElevatedButton(
            onPressed: () async {
              await authService.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.loginRoute,
                (Route<dynamic> route) => false,
              );
            },
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }
}
