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
  List<String> _receivedLines = []; // List to store received lines

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
        backgroundColor: Color(0xFF4C748B),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.all(12.0),
                controller: listScrollController,
                itemCount: _receivedLines.length,
                itemBuilder: (context, index) {
                  String message = _receivedLines[index];
                  TextStyle textStyle = TextStyle(fontSize: 16.0);

                  // Check the content of the received message and apply different styles or colors
                  if (message.contains('Package') ||
                      message.contains('package')) {
                    textStyle = TextStyle(fontSize: 16.0, color: Colors.blue);
                  } else if (message.contains('Going Home')) {
                    textStyle = TextStyle(fontSize: 16.0, color: Colors.blue);
                  } else if (message.contains('RFID Status: Access Granted.')) {
                    textStyle = TextStyle(fontSize: 16.0, color: Colors.green);
                  } else if (message
                      .contains('Access denied for user with UID:')) {
                    textStyle = TextStyle(fontSize: 16.0, color: Colors.red);
                  }
                  // Add more conditions as needed to customize based on the message content

                  return Text(
                    message,
                    style: textStyle,
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: isConnected ? () => _sendMessage('1') : null,
                  child: Text('Present Package'),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF4C748B),
                  ),
                ),
                ElevatedButton(
                  onPressed: isConnected ? () => _sendMessage('2') : null,
                  child: Text('Wait For Package'),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF4C748B),
                  ),
                ),
                ElevatedButton(
                  onPressed: isConnected ? () => _sendMessage('3') : null,
                  child: Text('Go Home'),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF4C748B),
                  ),
                ),
              ],
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

  void _onDataReceived(Uint8List data) {
    setState(() {
      _messageBuffer += utf8.decode(data); // Append received data to buffer
      List<String> lines = _messageBuffer.split('\n'); // Split data into lines

      for (int i = 0; i < lines.length - 1; i++) {
        print(
            'Received: ${lines[i]}'); // Print or process each line of received data
        _receivedLines.add(lines[i]); // Add each line to the list
      }

      _messageBuffer = lines.isNotEmpty
          ? lines.last
          : ''; // Store the incomplete line, if any
    });
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.isNotEmpty) {
      int? parsedValue = int.tryParse(text);

      if (parsedValue != null && parsedValue >= 1 && parsedValue <= 3) {
        try {
          // Add the valid command to the list of received lines
          setState(() {
            _receivedLines.add('POST Device Command: $text');
          });

          // Send the command to the Arduino
          connection!.output.add(Uint8List.fromList(utf8.encode('$text\r')));
          await connection!.output.allSent;
        } catch (e) {
          print('Error sending message: $e');
        }
      } else {
        // Add a message for invalid commands to the list of received lines
        setState(() {
          _receivedLines.add('Invalid Command: $text, please use {1, 2, 3}');
        });
      }
    }
  }
}
