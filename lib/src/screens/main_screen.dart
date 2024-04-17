import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'discovery_page.dart';
import 'selected_bonded_device_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  BluetoothConnection? connection;
  BluetoothDevice? selectedDevice;

  int temp = 0;
  String position = 'N/A';

  Timer? _discoverableTimeoutTimer;
  //int _discoverableTimeoutSecondsLeft = 0;

  //BackgroundCollectingTask? _collectingTask;

  bool _autoAcceptPairingRequests = false;

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);
  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        //_discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    //_collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();

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
        title: const Center(child: Text('BlueSun')),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: Row(
                children: [
                  SizedBox(width: 50),
                  Image(
                    image: AssetImage('lib/assets/Sun_v3.png'),
                    width: 250,
                  ),
                  SizedBox(width: 50),
                ],
              ),
            ),
            const Divider(),
            SwitchListTile(
              // Enables Bluetooth
              title: const Text('Enable Bluetooth'),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                // Do the request and update with the true value then
                future() async {
                  // async lambda seems to not working
                  if (value) {
                    await FlutterBluetoothSerial.instance.requestEnable();
                  } else {
                    await FlutterBluetoothSerial.instance.requestDisable();
                  }
                }

                future().then((_) {
                  setState(() {});
                });
              },
              activeColor: const Color(0xFF4C748B),
            ),
            ListTile(
              //shows bluetooth status
              title: const Text('Bluetooth status'),
              subtitle: Text(_bluetoothState.toString()),
              trailing: ElevatedButton(
                child: const Text('Settings'),
                onPressed: () {
                  FlutterBluetoothSerial.instance.openSettings();
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xFF0D47A1)),
                ),
              ),
            ),
            const Divider(),
            SwitchListTile(
              //Auto tries password
              title: const Text('Auto-try specific pin when pairing'),
              subtitle: const Text('Pin 1234'),
              value: _autoAcceptPairingRequests,
              onChanged: (bool value) {
                setState(() {
                  _autoAcceptPairingRequests = value;
                });
                if (value) {
                  FlutterBluetoothSerial.instance.setPairingRequestHandler(
                      (BluetoothPairingRequest request) {
                    print("Trying to auto-pair with Pin 1234");
                    if (request.pairingVariant == PairingVariant.Pin) {
                      return Future.value("1234");
                    }
                    return Future.value(null);
                  });
                } else {
                  FlutterBluetoothSerial.instance
                      .setPairingRequestHandler(null);
                }
              },
              activeColor: const Color(0xFF4C748B),
            ),
            const Divider(),
            //////////////////////////////////
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                  onPressed: () async {
                    final BluetoothDevice? selectedDevice =
                        await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return const SelectBondedDevicePage(
                              checkAvailability: false);
                        },
                      ),
                    );

                    if (selectedDevice != null) {
                      connection = await BluetoothConnection.toAddress(
                          selectedDevice.address); //creates connection
                      connection?.input?.listen((Uint8List data) {
                        _onDataReceived(data);
                      });
                      setState(() {
                        this.selectedDevice = selectedDevice;
                      }); // Update selected device
                      print('Connected to ->  ' + selectedDevice.address);
                    } else {
                      print('Connected to -> no device selected');
                    }
                  },
                  child: const Text('Connect to paired device'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFF0D47A1)),
                  ),
                ))
              ],
            ),
            /////////////////////////////////////

            if (selectedDevice != null && connection!.isConnected) ...[
              //checks if device is connected
              const Divider(),
              ListTile(
                // Interior temp
                title: const Text('Interior Temperature'), //Temperature Needed
                trailing: Container(
                  child: Text('$temp'+'°F'),
                ),
              ),
              const Divider(),
              ListTile(
                // Sunshade Position
                title: const Text('SunShade Position'),
                trailing: Container(
                  child: Text(position),
                ),
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    //Extend Button
                    child: ElevatedButton(
                      onPressed: () => _sendMessage('1'),
                      child: const Text('Extend'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFF0D47A1)),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Expanded(
                    //Retract Button
                    child: ElevatedButton(
                      onPressed: () => _sendMessage('2'),
                      child: const Text('Retract'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFF0D47A1)),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    //Extend Button
                    child: ElevatedButton(
                      onPressed: () async {
                        await connection?.finish(); //creates connection
                        setState(() {
                          this.selectedDevice = null;
                        }); // Update selected device
                      },
                      child: const Text('Disconnect'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFF0D47A1)),
                      ),
                    ), //ElevatedButton\
                  ), // Expanded
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _messageBuffer = '';

  void _onDataReceived(Uint8List data) {
    setState(() {
      _messageBuffer += ascii.decode(data); // Append received data to buffer
      List<String> lines = _messageBuffer.split('\n'); // Split data into lines
      int? parsedData = 0;

      for (int i = 0; i < lines.length - 1; i++) {
        print('Received: ${lines[i]}'); // Print or process each line of received data

        parsedData = int.tryParse(lines[i]);

        if (parsedData != null) {
          temp = int.parse(lines[i]);
        } else {
          position = lines[i];
        }
      }

      _messageBuffer = lines.isNotEmpty
          ? lines.last
          : ''; // Store the incomplete line, if any
    });
  }

  void _sendMessage(String text) async {
    text = text.trim();

    if (text.isNotEmpty) {
      try {
        // Add the valid command to the list of received lines
        print('app->Pic Command: $text');

        // Send the command to the HC-05
        connection!.output.add(ascii.encode(text));

        await connection!.output.allSent;
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

}
