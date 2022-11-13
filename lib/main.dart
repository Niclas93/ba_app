import 'package:ba_app/pages/bluetooth.dart';
import 'package:ba_app/pages/history.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(Main());
}

class Main extends StatelessWidget {
  static const String title = 'Main';

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MainPage(),
      );
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(Main.title),
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
        body: Container(
          padding: const EdgeInsets.all(18),
          child: Column(

              children: [
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: const [
            //     Text(
            //       'HR',
            //       style: TextStyle(fontSize: 24),
            //     ),
            //     Text(
            //       '136',
            //       style: TextStyle(fontSize: 24),
            //     ),
            //     Text(
            //       'HRØ',
            //       style: TextStyle(fontSize: 24),
            //     ),
            //     Text(
            //       '114',
            //       style: TextStyle(fontSize: 24),
            //     ),
            //   ],
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  width: 170,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(18)),
                  child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            Text(
                              'HR',
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(width: 20),
                            Text(
                              '136',
                              style: TextStyle(fontSize: 24),
                            ),
                          ])),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  width: 170,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(18)),
                  child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            Text(
                              'HRØ',
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(width: 20),
                            Text(
                              '114',
                              style: TextStyle(fontSize: 24),
                            ),
                          ])),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  width: 170,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(18)),
                  child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            Text(
                              'SPO2',
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(width: 20),
                            Text(
                              '82%',
                              style: TextStyle(fontSize: 24),
                            ),
                          ])),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  width: 170,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(18)),
                  child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            Text(
                              'SPO2Ø',
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(width: 20),
                            Text(
                              '71%',
                              style: TextStyle(fontSize: 24),
                            ),
                          ])),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  width: 170,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(18)),
                  child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            Text(
                              'RR',
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(width: 20),
                            Text(
                              '1',
                              style: TextStyle(fontSize: 24),
                            ),
                          ])),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  width: 170,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(18)),
                  child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            Text(
                              'RRØ',
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(width: 20),
                            Text(
                              '1',
                              style: TextStyle(fontSize: 24),
                            ),
                          ])),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              width: 170,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(18)),
              child: Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Text(
                          'Temp',
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(width: 20),
                        Text(
                          '25.2',
                          style: TextStyle(fontSize: 24),
                        ),
                      ])),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(18)),
              child: const Center(
                child: Text(
                  'EKG',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ]),
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
