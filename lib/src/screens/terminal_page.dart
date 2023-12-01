import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class TerminalPage extends StatefulWidget {
  final BluetoothDevice server;

  const TerminalPage({required this.server});

  @override
  _TerminalPageState createState() => _TerminalPageState();
}

class _TerminalPageState extends State<TerminalPage> {
  BluetoothConnection? connection;
  String _messageBuffer = '';

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occurred');
      print(error);
    });
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (isConnecting
            ? Text('Connecting to ${widget.server.name}...')
            : isConnected
                ? Text('Connected to ${widget.server.name}')
                : Text('Disconnected from ${widget.server.name}')),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView(
                padding: const EdgeInsets.all(12.0),
                controller: listScrollController,
                children: _buildMessageList(), // Display received messages
              ),
            ),
            Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(left: 16.0),
                    child: TextField(
                      style: const TextStyle(fontSize: 15.0),
                      controller: textEditingController,
                      decoration: InputDecoration.collapsed(
                        hintText: isConnecting
                            ? 'Wait until connected...'
                            : isConnected
                                ? 'Type your message...'
                                : 'Disconnected',
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      enabled: isConnected,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: isConnected
                        ? () => _sendMessage(textEditingController.text)
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMessageList() {
    List<Widget> messages = [];
    messages.add(
      Text(
        _messageBuffer,
        style: TextStyle(fontSize: 16.0),
      ),
    );
    return messages;
  }

  void _onDataReceived(Uint8List data) {
    setState(() {
      _messageBuffer += utf8.decode(data);
      int newlineIndex = _messageBuffer.indexOf('\n');
      while (newlineIndex != -1) {
        String line = _messageBuffer.substring(0, newlineIndex);
        print(
            'Received: $line'); // Replace with your logic for handling received data
        _messageBuffer = _messageBuffer.substring(newlineIndex + 1);
        newlineIndex = _messageBuffer.indexOf('\n');
      }
    });
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.isNotEmpty && int.tryParse(text) != null) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode('$text\r')));
        await connection!.output.allSent;
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }
}
