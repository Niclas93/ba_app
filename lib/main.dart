import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';

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
        home:  MainPage(),
      );
}

class MainPage extends StatefulWidget {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final PageController _controller = PageController(
    initialPage: 1,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Platzhalter'),
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
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text('Medicine'),
                ),
              ],
            ),
          ],
        ),
        body:
      PageView(
          controller: _controller,
          children: [
            buildView(),
            Page1Widget(),
            Page2Widget(),
            Page3Widget()
          ])
    );
  }

  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        _controller.animateToPage(0, duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
        break;
      case 1:
        _controller.animateToPage(1, duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
        break;
      case 2:
        _controller.animateToPage(2, duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
        break;
      case 3:
        _controller.animateToPage(3, duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
    }
  }

  BluetoothDevice? connectedDevice;
  List<BluetoothService> services = [];
  // var nameOfConnectedDevice;

  addDeviceToList(final BluetoothDevice device) {
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
        addDeviceToList(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        addDeviceToList(result.device);
      }
    });
    widget.flutterBlue.startScan();
  }

  ListView buildListViewOfDevices() {
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
                      services = await device.discoverServices();
                    }
                    setState(() {
                      connectedDevice = device;
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

  ListView buildView() {
    if (connectedDevice != null) {
      return buildConnectDeviceView();
    }
    return buildListViewOfDevices();
  }

  ListView buildConnectDeviceView() {
    return ListView(
      padding: const EdgeInsets.all(8),
      // children: <Widget>[],
    );
  }
}

class Page1Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      child: Column(children: [
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
                      'HRV',
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
                      'HRVØ',
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
              color: Colors.black12, borderRadius: BorderRadius.circular(18)),
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
              color: Colors.black12, borderRadius: BorderRadius.circular(18)),
          child: const Center(
            child: Text(
              'EKG',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
      ]),
    );
  }
}

class Page2Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Text('Hello World'),
    );
  }
}

class Page3Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Text('Hello World'),
    );
  }
}
