// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, non_constant_identifier_names, file_names, no_logic_in_create_state, unused_import, prefer_const_declarations, unused_local_variable, prefer_final_fields, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:project/apihandler.dart';
import 'package:project/constants.dart';
import 'messagedetails.dart';

class Messagescreen extends StatefulWidget {
  final String clientRef;

  const Messagescreen({required this.clientRef, super.key});

  @override
  State<Messagescreen> createState() => _MessagescreenState();
}

class _MessagescreenState extends State<Messagescreen> {
  Future<List<Map<String, dynamic>>>? _messagesFuture;
  Map<String, String> _clientNames = {};
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _messagesFuture = ApiHandler().fetchMessages(widget.clientRef);
  }

  Future<String> _getClientName(String clientRef) async {
    if (_clientNames.containsKey(clientRef)) {
      return _clientNames[clientRef]!;
    } else {
      final name = await ApiHandler().fetchClientName(clientRef);
      setState(() {
        _clientNames[clientRef] = name;
      });
      return name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: kBackGroundColor,
        appBar: AppBar(
          title: Text(
            'Mesajlar',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          toolbarHeight: kToolbarHeight,
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _selectedTab = index;
              });
            },
            tabs: [
              Tab(text: 'Tümü'),
              Tab(text: 'Alış'),
              Tab(text: 'Satış'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _messagesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Hata: ${snapshot.error}'));
              } else if (!snapshot.hasData ||
                  snapshot.data == null ||
                  snapshot.data!.isEmpty) {
                return Center(child: Text('Mesaj bulunamadı.'));
              }

              final allMessages = snapshot.data!;
              final filteredMessages = _getFilteredMessages(allMessages);

              return ListView.builder(
                itemCount: filteredMessages.length,
                itemBuilder: (context, index) {
                  final message = filteredMessages[index];
                  final senderRef = message['SenderRef'] ?? '';

                  return FutureBuilder<String>(
                    future: _getClientName(senderRef),
                    builder: (context, nameSnapshot) {
                      final senderName = nameSnapshot.data ?? 'Bilinmiyor';
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Messagedetails(clientRef: widget.clientRef),
                            ),
                          );
                        },
                        child: _buildMessageItem(
                          context,
                          senderName,
                          message['content'] ?? 'Mesaj',
                          Icons.message,
                          Colors.blueAccent,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredMessages(
      List<Map<String, dynamic>> allMessages) {
    switch (_selectedTab) {
      case 1:
        return allMessages
            .where((message) => (message['type'] == 'alis' &&
                (message['SenderRef'] == widget.clientRef ||
                    message['AreaRef'] == widget.clientRef)))
            .toList();
      case 2:
        return allMessages
            .where((message) => (message['type'] == 'satis' &&
                (message['SenderRef'] == widget.clientRef ||
                    message['AreaRef'] == widget.clientRef)))
            .toList();
      default:
        return allMessages;
    }
  }

  Widget _buildMessageItem(BuildContext context, String title, String subtitle,
      IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
      ),
    );
  }
}
