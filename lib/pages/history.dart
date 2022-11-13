import 'package:ba_app/main.dart';
import 'package:ba_app/pages/bluetooth.dart';
import 'package:flutter/material.dart';

class History extends StatelessWidget {

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primarySwatch: Colors.blue),
    home: MainPage(),
  );
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('History'),
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
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => History()),
              (route) => false,
        );
    }
  }
}
