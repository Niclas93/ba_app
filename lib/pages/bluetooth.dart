import 'dart:math';

import 'package:ba_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class BluetoothDevices extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MainPage(),
      );
}

class MainPage extends StatefulWidget {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = [];
  var nameOfConnectedDevice;

  _addDeviceToList(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceToList(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceToList(result.device);
      }
    });
    widget.flutterBlue.startScan();
  }

  ListView _buildListViewOfDevices() {
    List<Widget> containers = <Widget>[];
    for (BluetoothDevice device in widget.devicesList) {
      containers.add(SizedBox(
        height: 50,
        child: Row(children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () async {
                    widget.flutterBlue.stopScan();
                    try {
                      await device.connect();
                    } on PlatformException catch (e) {
                      if (e.code != 'already_connected') {
                        rethrow;
                      }
                    } finally {
                      _services = await device.discoverServices();
                    }
                    setState(() {
                      _connectedDevice = device;
                      // device = nameOfConnectedDevice;
                    });
                  },
                  child: Ink(
                    child: Column(
                      children: <Widget>[
                        Text(
                          device.name == '' ? '(unknown device)' : device.name,
                          style: const TextStyle(fontSize: 25),
                        ),
                        // Text(device.id.toString()),
                      ],
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.black,
                ),
              ],
            ),
          )
        ]),
      ));
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  ListView _buildView() {
    if (_connectedDevice != null) {
      return _buildConnectDeviceView();
    }
    return _buildListViewOfDevices();
  }

  ListView _buildConnectDeviceView() {
    return ListView(
      padding: const EdgeInsets.all(8),
      // children: <Widget>[],
    );
  }

  // _namegetter() {
  //   if (nameOfConnectedDevice == "" ) {
  //     nameOfConnectedDevice = 'Not Connected';
  //   } else {
  //     return nameOfConnectedDevice;
  //   }
  // }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Platzhalter'),
          centerTitle: true,
          actions: [
            PopupMenuButton<int>(
              onSelected: (item) => onSelected(context, item),
              itemBuilder: (context) => [
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text('Bluetooth-Devices'),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text('Main'),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text('History'),
                ),
              ],
            ),
          ],
        ),
        body: _buildView(),
      );

  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => BluetoothDevices()),
        );
        break;
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => Main()),
        );
        break;
      case 2:
        // Navigator.of(context).pushAndRemoveUntil(
          // MaterialPageRoute(builder: (context) => History()),
          // (route) => false,
        // );
    }
  }
}
