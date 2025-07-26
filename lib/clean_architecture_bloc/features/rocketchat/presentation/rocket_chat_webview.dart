import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/service/auth_service.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/theme/color_palette.dart';
import 'package:ntavideofeedapp/main.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RocketChatWebview extends StatefulWidget {
  const RocketChatWebview({super.key});

  @override
  State<RocketChatWebview> createState() => _RocketChatWebviewState();
}

class _RocketChatWebviewState extends State<RocketChatWebview> {
  WebViewController? controller;
  bool isLoading = true;
  bool loginSuccessful = false;

  final String chatUrl = "http://192.168.29.228:3000/home"; // Final chat screen
  String authToken = '';
  String userId = '';

  Future<bool> loginToRocketChat() async {
    final DeviceFlowAuthService deviceFlowAuthService = DeviceFlowAuthService();
    final accessToken = await deviceFlowAuthService.getAccessToken();
    logger.d("Access token is $accessToken");

    final url = Uri.parse('http://192.168.29.228:3000/api/v1/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "serviceName": "keycloak",
        "accessToken": accessToken,
        "expiresIn": 3600,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      authToken = data['authToken'];
      userId = data['userId'];
      logger.i("Rocket.Chat login success");
      return true;
    } else {
      logger.e("Rocket.Chat login failed: ${response.body}");
      return false;
    }
  }

  Future<void> loadWebviewWithAuth() async {
    final loginScript =
        """
    localStorage.setItem('Meteor.loginToken', '$authToken');
    localStorage.setItem('Meteor.userId', '$userId');
    location.reload(); // reload to apply login
  """;

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
            logger.i("Page loaded: $url");
          },
        ),
      )
      ..loadRequest(Uri.parse("http://192.168.29.228:3000/home"));

    await Future.delayed(Duration(seconds: 2)); // ensure page is loaded

    await controller?.runJavaScript(loginScript);

    setState(() {
      loginSuccessful = true;
    });
  }

  @override
  void initState() {
    super.initState();
    loginToRocketChat().then((success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserListScreen(authToken: authToken, userId: userId),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rocket.Chat")),
      body: loginSuccessful && controller != null
          ? Center(child: Text("Error"))
          : Center(child: Text("🔐 Logging into Rocket.Chat...")),
    );
  }
}

class UserListScreen extends StatefulWidget {
  final String authToken;
  final String userId;
  const UserListScreen({
    super.key,
    required this.authToken,
    required this.userId,
  });

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  Map<String, dynamic> userUnreadC = {};
  late WebSocketChannel _channel;
  bool _webSocketConnected = false;

  @override
  void initState() {
    super.initState();
    getUnreadCount();
    _connectWebSocket();
  }

  Future<List<dynamic>> listofUsers() async {
    final url = Uri.parse("http://192.168.29.228:3000/api/v1/users.list");
    final response = await http.get(
      url,
      headers: {'X-Auth-Token': widget.authToken, 'X-User-Id': widget.userId},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['users'];
    } else {
      throw Exception("Failed to load user list: ${response.body}");
    }
  }

  void getUnreadCount() async {
    final url = Uri.parse(
      'http://192.168.29.228:3000/api/v1/subscriptions.get',
    );

    final response = await http.get(
      url,
      headers: {'X-Auth-Token': widget.authToken, 'X-User-Id': widget.userId},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> updates = data['update'];

      Map<String, int> unreadMap = {};

      for (var sub in updates) {
        if (sub['name'] != null && sub['unread'] != null) {
          unreadMap[sub['name']] = sub['unread'];
        }
      }

      setState(() {
        userUnreadC = unreadMap;
      });
    } else {
      setState(() {});
      throw Exception("Failed to load unread counts: ${response.body}");
    }
  }

  void updateUnreadFromWebSocket(String username, int unread) {
    setState(() {
      userUnreadC[username] = unread;
    });
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.29.228:3000/websocket'),
    );
    _webSocketConnected = true;
    // Send initial connect message
    _channel.sink.add(
      jsonEncode({
        "msg": "connect",
        "version": "1",
        "support": ["1"],
      }),
    );

    _channel.stream.listen(
      (data) {
        logger.d("WebSocket Data Received: $data");
        final message = jsonDecode(data);

        if (message['msg'] == 'connected') {
          logger.d("WebSocket connected. Authenticating...");
          _authenticateWebSocket();
        } else if (message['msg'] == 'result' && message['id'] == '1') {
          logger.d("Authenticated. Subscribing to subscription changes...");
          _subscribeToSubscriptionChanges();
        } else if (message['msg'] == 'changed' &&
            message['collection'] == 'stream-notify-user') {
          _handleSubscriptionUpdate(message);
        }
      },
      onError: (e) {
        logger.e('WebSocket error: $e');
      },
      onDone: () {
        logger.w('WebSocket connection closed');
        _reconnectWebSocket();
      },
    );
  }

  void _reconnectWebSocket() {
    if (!_webSocketConnected) {
      logger.d("Already reconnecting...");
      return;
    }
    logger.i("Attempting to reconnect WebSocket in 3 seconds...");
    _webSocketConnected = false;

    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        logger.i("Reconnecting WebSocket now...");
        _connectWebSocket();
        _webSocketConnected = true;
      }
    });
  }

  void _handleSubscriptionUpdate(dynamic message) {
    try {
      final args = message['fields']['args'];
      if (args is List && args.length > 1) {
        final update = args[1];

        final username = update['name'] ?? update['fname'];
        final unread = update['unread'] ?? 0;

        if (username != null) {
          logger.d("Updating unread count for $username: $unread");
          updateUnreadFromWebSocket(username, unread);
        } else {
          logger.e("No username found in update: ${jsonEncode(update)}");
        }
      } else {
        logger.e("Unexpected args format: ${jsonEncode(args)}");
      }
    } catch (e) {
      logger.e(
        "Error parsing unread update: $e\nFull message: ${jsonEncode(message)}",
      );
    }
  }

  void _authenticateWebSocket() {
    _channel.sink.add(
      jsonEncode({
        "msg": "method",
        "method": "login",
        "params": [
          {"resume": widget.authToken},
        ],
        "id": "1",
      }),
    );
  }

  void _subscribeToSubscriptionChanges() {
    _channel.sink.add(
      jsonEncode({
        "msg": "sub",
        "name": "stream-notify-user",
        "params": ["${widget.userId}/subscriptions-changed", false],
        "id": "2",
      }),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: listofUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              final user = snapshot.data![index];
              final username = user['username'];
              final unread = userUnreadC[username] ?? 0;
              logger.d("Rendering user: $username, unread: $unread");
              logger.d("User data is $user");

              return user['_id'] != widget.userId
                  ? Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            "$unread",
                            style: TextStyle(
                              color: unread > 0 ? Colors.red : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () async {
                          userUnreadC[username] = 0;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                authToken: widget.authToken,
                                userId: widget.userId,
                                otherUserId: user['_id'],
                                otherUsername: user['username'],
                              ),
                            ),
                          );
                        },
                        title: Text(user['username']),
                      ),
                    )
                  : null;
            },
          );
        },
      ),
    );
  }
}

//Chat screen UI

class ChatScreen extends StatefulWidget {
  final String authToken;
  final String userId;
  final String otherUserId;
  final String otherUsername;
  const ChatScreen({
    super.key,
    required this.authToken,
    required this.userId,
    required this.otherUserId,
    required this.otherUsername,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late WebSocketChannel _channel;
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  String? _roomId;
  final ScrollController _scrollController = ScrollController();
  FilePickerResult? result;

  @override
  void initState() {
    super.initState();
    _initializeChat().then((_) {
      _scollToBottom();
      markMessagesAsRead(_roomId!);
    });
  }

  Future<void> markMessagesAsRead(String roomId) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.29.228:3000/api/v1/subscriptions.read'),
        headers: {
          'X-Auth-Token': widget.authToken,
          'X-User-Id': widget.userId,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'rid': roomId}),
      );

      if (response.statusCode == 200) {
        logger.i("Marked room as read");
      } else {
        logger.e("Failed to mark as read: ${response.body}");
      }
    } catch (e) {
      logger.e("Error marking messages as read: $e");
    }
  }

  void _scollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _initializeChat() async {
    try {
      logger.d("Initializing chat...");
      _roomId = await _getOrCreateDirectMessage();
      logger.d("Room ID received: $_roomId");

      if (_roomId == null || _roomId!.isEmpty) {
        throw Exception('Failed to get valid room ID');
      }

      await _loadMessageHistory();
      _connectToWebSocket();

      setState(() => _isLoading = false);
    } catch (e, stackTrace) {
      logger.e("Error initializing chat: $e\nStackTrace: $stackTrace");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error initializing chat: $e')));
    }
  }

  Future<String> _getOrCreateDirectMessage() async {
    final response = await http.post(
      Uri.parse('http://192.168.29.228:3000/api/v1/im.create'),
      headers: {
        'X-Auth-Token': widget.authToken,
        'X-User-Id': widget.userId,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'username': widget.otherUsername}),
    );

    logger.d("DM create response: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      logger.d("Decoded DM create: $decoded");

      return decoded['room']['_id'];
    } else {
      throw Exception('Failed to create DM: ${response.body}');
    }
  }

  Future<void> _loadMessageHistory() async {
    final response = await http.get(
      Uri.parse('http://192.168.29.228:3000/api/v1/im.history?roomId=$_roomId'),
      headers: {'X-Auth-Token': widget.authToken, 'X-User-Id': widget.userId},
    );

    logger.d("History response: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      logger.d("Decoded history: $data");

      final messages = data['messages'] as List;

      setState(() {
        _messages = messages
            .map((msg) {
              try {
                logger.d("Message Model result is $msg");
                return ChatMessage.fromRocketChat(msg);
              } catch (e, st) {
                logger.e("Error parsing message: $msg\nError: $e\nStack: $st");
                return null;
              }
            })
            .whereType<ChatMessage>()
            .toList()
            .reversed
            .toList();
      });
    } else {
      throw Exception('Failed to load history: ${response.body}');
    }
  }

  void _connectToWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.29.228:3000/websocket'),
    );

    // Authenticate
    _channel.sink.add(
      jsonEncode({
        'msg': 'connect',
        'version': '1',
        'support': ['1'],
      }),
    );

    _channel.sink.add(
      jsonEncode({
        'msg': 'method',
        'method': 'login',
        'params': [
          {'resume': widget.authToken},
        ],
        'id': '1',
      }),
    );

    // Subscribe to room messages
    _channel.sink.add(
      jsonEncode({
        'msg': 'sub',
        'name': 'stream-room-messages',
        'params': [_roomId, false],
        'id': '2',
      }),
    );

    // Listen for new messages
    _channel.stream.listen((data) {
      logger.d("WebSocket incoming: $data");
      try {
        final message = jsonDecode(data);
        if (message['msg'] == 'ping') {
          _channel.sink.add(jsonEncode({'msg': 'pong'}));
          return;
        }
        if (message['msg'] == 'changed' &&
            message['collection'] == 'stream-room-messages') {
          final args = message['fields']['args'];
          logger.d("Parsed args: $args");

          if (args is List && args.isNotEmpty) {
            final chatData = args[0];

            final newMessage = ChatMessage.fromRocketChat(chatData);

            if (!_messages.any((m) => m.id == newMessage.id)) {
              setState(() {
                _messages.add(newMessage);
              });
              _scollToBottom();
            }
          } else {
            logger.w("Unexpected args format: $args");
          }
        }
      } catch (e, st) {
        logger.e("WebSocket error: $e\nStack: $st");
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('http://192.168.29.228:3000/api/v1/chat.sendMessage'),
        headers: {
          'X-Auth-Token': widget.authToken,
          'X-User-Id': widget.userId,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': {'rid': _roomId, 'msg': _messageController.text},
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final sentMessage = ChatMessage.fromRocketChat(data['message']);
        setState(() {
          _messageController.clear();
          _scollToBottom();
        });
      } else {
        throw Exception('Failed to send message: ${response.body}');
      }
    } catch (e) {
      logger.e("Failed in sending message: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    }
  }

  Future<void> uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      var uri = Uri.parse(
        'http://192.168.29.228:3000/api/v1/rooms.upload/${_roomId}',
      );
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'X-Auth-Token': widget.authToken,
        'X-User-Id': widget.userId,
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: path.basename(file.path),
        ),
      );
      var response = await request.send();
      if (response.statusCode == 200) {
        logger.d("File send successfuly");
      } else {
        logger.e("Upload failed with status code ${response.statusCode}");
      }
    } else {
      logger.i("No file Selected");
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, title: Text("Chat Screen")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _messages.isEmpty
              ? Center(
                  child: Text(
                    "No messages yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(overscroll: false),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return ChatBubble(
                          message: message,
                          isMe: message.senderId == widget.userId,
                          authToken: widget.authToken,
                          userId: widget.userId,
                        );
                      },
                    ),
                  ),
                ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () async {
                    uploadFile();
                  },
                  icon: Icon(Icons.attach_file_sharp),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message....',
                      fillColor: Colors.transparent,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    cursorColor: Colors.black,
                  ),
                ),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.arrow_forward_outlined),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String id;
  final String message;
  final DateTime createdAt;
  final String senderId;
  final String? senderUsername;

  final String? attachmentTitle;
  final String? attachmentUrl;
  final String? attachmentType;
  final int? attachmentSize;

  ChatMessage({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.senderId,
    this.senderUsername,
    this.attachmentTitle,
    this.attachmentUrl,
    this.attachmentType,
    this.attachmentSize,
  });

  factory ChatMessage.fromRocketChat(Map<String, dynamic> json) {
    try {
      logger.d("Parsing message JSON: $json");

      final ts = json['ts'];
      DateTime created;

      /* if (ts is Map && ts.containsKey('\$date')) {
        created = DateTime.parse(ts['\$date']).toLocal();
      } else if (ts is String) {
        created = DateTime.parse(ts).toLocal();
      } else {
        created = DateTime.now();
      } */
      if (ts is Map && ts.containsKey('\$date')) {
        final tsValue = ts['\$date'];
        if (tsValue is int) {
          created = DateTime.fromMillisecondsSinceEpoch(tsValue).toLocal();
        } else if (tsValue is String) {
          created = DateTime.parse(tsValue).toLocal();
        } else {
          created = DateTime.now(); // fallback
        }
      } else if (ts is String) {
        created = DateTime.parse(ts).toLocal();
      } else {
        created = DateTime.now();
      }
      String? attachmentTitle;
      String? attachmentUrl;
      String? attachmentType;
      int? attachmentSize;

      if (json['attachments'] != null &&
          json['attachments'] is List &&
          (json['attachments'] as List).isNotEmpty) {
        final attachment = json['attachments'][0];

        attachmentTitle = attachment['title'];
        attachmentUrl = attachment['title_link']; // relative path
        attachmentType = attachment['type'];
        attachmentSize = attachment['size'];
      }

      return ChatMessage(
        id: json['_id'] ?? '',
        message: json['msg'] ?? '',
        createdAt: created,
        senderId: json['u']['_id'] ?? '',
        senderUsername: json['u']['username'],
        attachmentTitle: attachmentTitle,
        attachmentUrl: attachmentUrl,
        attachmentType: attachmentType,
        attachmentSize: attachmentSize,
      );
    } catch (e, st) {
      logger.e("Error parsing ChatMessage: $e\nStack: $st\nData: $json");
      rethrow;
    }
  }
  bool get isFileMessage => (message.isEmpty && attachmentUrl != null);
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final String authToken;
  final String userId;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.authToken,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.7;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[400] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe && message.senderUsername != null)
              Text(
                message.senderUsername!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            // Show message text OR file message
            if (message.message.trim().isNotEmpty)
              Text(
                message.message,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              )
            else if (message.attachmentTitle != null)
              GestureDetector(
                onTap: () async {
                  final url =
                      "http://192.168.29.228:3000${message.attachmentUrl}";
                  try {
                    final tempDir = await getTemporaryDirectory();
                    final filePath =
                        '${tempDir.path}/${message.attachmentTitle}';

                    // Download the file
                    await Dio().download(
                      url,
                      filePath,
                      options: Options(
                        headers: {
                          'X-Auth-Token': authToken,
                          'X-User-Id': userId,
                        },
                      ),
                    );

                    // Open the file using device default app
                    await OpenFile.open(filePath);
                  } catch (e) {
                    // Handle errors here (show snackbar, toast, etc)
                    logger.e("Error opening file: $e");
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      color: isMe ? Colors.white : Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message.attachmentTitle ?? 'File',

                        style: TextStyle(
                          fontSize: 15,
                          color: isMe
                              ? AppColor.backgroundColor
                              : Colors.black87,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                "Unsupported message",
                style: TextStyle(color: isMe ? Colors.white : Colors.black),
              ),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(message.createdAt),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
