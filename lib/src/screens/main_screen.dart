import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';


import 'discovery_page.dart';
import 'selected_bonded_device_page.dart';
//import 'terminal_page.dart';
//import 'collecting_task.dart';


// import './helpers/LineChart.dart';

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

  Timer? _discoverableTimeoutTimer;
  //int _discoverableTimeoutSecondsLeft = 0;

  //BackgroundCollectingTask? _collectingTask;

  bool _autoAcceptPairingRequests = false;
  bool get isConnected => (connection?.isConnected ?? false);

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
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: const Center(child: Text('BlueSun')),
        backgroundColor: const Color(0xFF0D47A1),
=======
        title: Center(child: const Text('BlueSun')),
        backgroundColor: Color(0xFF0D47A1),
>>>>>>> 02511af (BlueSun update)
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
<<<<<<< HEAD
                    image: AssetImage('lib/assets/Sun_v3.png'),
=======
                    image: AssetImage('lib/assets/BlueSun.png'),
>>>>>>> 02511af (BlueSun update)
                    width: 250,
                  ),
                  SizedBox(width: 50),
                ],
              ),
            ),
            const Divider(),
            SwitchListTile( // Enables Bluetooth
              title: const Text('Enable Bluetooth'),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                // Do the request and update with the true value then
                future() async {
                  // async lambda seems to not working
                  if (value)
                    await FlutterBluetoothSerial.instance.requestEnable();
                  else
                    await FlutterBluetoothSerial.instance.requestDisable();
                }

                future().then((_) {
                  setState(() {});
                });
              },
              activeColor: const Color(0xFF4C748B),
            ),
            ListTile( //shows bluetooth status
              title: const Text('Bluetooth status'),
              subtitle: Text(_bluetoothState.toString()),
              trailing: ElevatedButton(
                child: const Text('Settings'),
                onPressed: () {
                  FlutterBluetoothSerial.instance.openSettings();
                },
                style: ButtonStyle(
                  backgroundColor:
<<<<<<< HEAD
                      MaterialStateProperty.all<Color>(const Color(0xFF0D47A1)),
=======
                      MaterialStateProperty.all<Color>(Color(0xFF0D47A1)),
>>>>>>> 02511af (BlueSun update)
                ),
              ),
            ),
            const Divider(),
            SwitchListTile( //Auto tries password
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
<<<<<<< HEAD
            const Divider(),
=======
            Divider(),
>>>>>>> 02511af (BlueSun update)
            //////////////////////////////////
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
<<<<<<< HEAD
                      final selectedDevice =
                          await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return const DiscoveryPage();
=======
                      final BluetoothDevice? selectedDevice =
                          await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return DiscoveryPage();
>>>>>>> 02511af (BlueSun update)
                          },
                        ),
                      );

                      if (selectedDevice != null) {
<<<<<<< HEAD
                        connection = await BluetoothConnection.toAddress(selectedDevice.address); //creates connection
                        setState(() {this.selectedDevice = selectedDevice; }); // Update selected device
                        print('Discovery -> selected ' + selectedDevice.address);    
=======
                        print(
                            'Discovery -> selected ' + selectedDevice.address);
>>>>>>> 02511af (BlueSun update)
                      } else {
                        print('Discovery -> no device selected');
                      }
                    },
                    child: const Text('Explore discovered devices'),
                    style: ButtonStyle(
                      backgroundColor:
<<<<<<< HEAD
                          MaterialStateProperty.all<Color>(const Color(0xFF0D47A1)),
                    ),
                  ), //ElevatedButton
                ), // Expanded
                
                /*
=======
                          MaterialStateProperty.all<Color>(Color(0xFF0D47A1)),
                    ),
                  ), //ElevatedButton
                ), // Expanded
>>>>>>> 02511af (BlueSun update)
                Spacer(),
                Expanded(
                    child: ElevatedButton(
                  onPressed: () async {
                    final BluetoothDevice? selectedDevice =
                        await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return SelectBondedDevicePage(
                              checkAvailability: false);
                        },
                      ),
                    );

                    if (selectedDevice != null) {
                      print('Connect -> selected ' + selectedDevice.address);
                      _startChat(context, selectedDevice);
                    } else {
                      print('Connect -> no device selected');
                    }
                  },
                  child: const Text('Connect to paired device to chat'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xFF0D47A1)),
<<<<<<< HEAD
                  ),
                ))*/
=======
                  ),
                ))
              ],
            ),
            /////////////////////////////////////

            Divider(),
            ListTile(
              title: const Text('Interior Temperature'), //Temperature Needed
              trailing: Container(
                child: const Text('Something'),
              ),
            ),
            Divider(),
            ListTile(
              title: const Text('SunShade Position'),
              trailing: Container(
                child: const Text('Something'),
              ),
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final BluetoothDevice? selectedDevice =
                          await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return DiscoveryPage();
                          },
                        ),
                      );

                      if (selectedDevice != null) {
                        print(
                            'Discovery -> selected ' + selectedDevice.address);
                      } else {
                        print('Discovery -> no device selected');
                      }
                    },
                    child: const Text('Expand'),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xFF0D47A1)),
                    ),
                  ), //ElevatedButton
                ), // Expanded
                Spacer(),
                Expanded(
                    child: ElevatedButton(
                  onPressed: () async {
                    final BluetoothDevice? selectedDevice =
                        await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return SelectBondedDevicePage(
                              checkAvailability: false);
                        },
                      ),
                    );

                    if (selectedDevice != null) {
                      print('Connect -> selected ' + selectedDevice.address);
                      _startChat(context, selectedDevice);
                    } else {
                      print('Connect -> no device selected');
                    }
                  },
                  child: const Text('Retract'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xFF0D47A1)),
                  ),
                ))
>>>>>>> 02511af (BlueSun update)
              ],
            ),
            /////////////////////////////////////
            ///
            if (selectedDevice != null && connection!.isConnected) ...[ //checks if device is connected
              const Divider(),
              ListTile( // Interior temp
                title: const Text('Interior Temperature'), //Temperature Needed
                trailing: Container( //change????
                  child: const Text('Something'),
                ),
              ),
              const Divider(),
              ListTile( // Sunshade Position
                title: const Text('SunShade Position'),
                trailing: Container( //change????
                  child: const Text('Something'),
                ),
              ),
              const Divider(),
              Row(
                children: [
                  Expanded( //Extend Button
                    child: ElevatedButton(
                      onPressed: () => _sendMessage('1'),
                      child: const Text('Extend'),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(const Color(0xFF0D47A1)),
                      ),
                    ), //ElevatedButton
                  ), // Expanded
                  const Spacer(),
                  Expanded( //Retract Button
                      child: ElevatedButton(
                      onPressed: () => _sendMessage('2'),
                    child: const Text('Retract'),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(const Color(0xFF0D47A1)),
                    ),
                  ))
                ],
              ),
              /* */
              const Divider(),
              Row(
                children: [
                  Expanded( //Extend Button
                    child: ElevatedButton(
                      onPressed: () async{
                        await connection?.finish(); //creates connection
                        setState(() {this.selectedDevice = null; }); // Update selected device
                      },
                      child: const Text('Disconnect'),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(const Color(0xFF0D47A1)),
                      ),
                    ),//ElevatedButton\
                  ), // Expanded
                ],
              ),
              
            ],
          ],
        ),
      ),
    );
  }

  // Future<void> _startBackgroundTask(
  //   BuildContext context,
  //   BluetoothDevice server,
  // ) async {
  //   try {
  //     _collectingTask = await BackgroundCollectingTask.connect(server);
  //     await _collectingTask!.start();
  //   } catch (ex) {
  //     _collectingTask?.cancel();
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text('Error occured while connecting'),
  //           content: Text("${ex.toString()}"),
  //           actions: <Widget>[
  //             new TextButton(
  //               child: new Text("Close"),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }


  
  String _messageBuffer = '';
  List<String> _receivedLines = [];
  final TextEditingController textEditingController = TextEditingController();


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

      // if (parsedValue != null && parsedValue >= 1 && parsedValue <= 3) {
        try {
          // Add the valid command to the list of received lines
          // setState(() {
          //   _receivedLines.add('POST Device Command: $text');
          // });

          // Send the command to the HC-05
          connection!.output.add(Uint8List.fromList(utf8.encode('$text\r')));
          await connection!.output.allSent;
        } catch (e) {
          print('Error sending message: $e');
        }
      // } else {
      //   // Add a message for invalid commands to the list of received lines
      //   setState(() {
      //     _receivedLines.add('Invalid Command: $text, please use {1, 2, 3}');
      //   });
      // }
    }
  }
<<<<<<< HEAD


=======
>>>>>>> 02511af (BlueSun update)
}