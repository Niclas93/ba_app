import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:ba_app/globals.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const Main());
}

class Main extends StatelessWidget {
  static const String title = 'Main';

  const Main({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MainPage(),
      );
}

class MainPage extends StatefulWidget {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};

  MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final PageController _controller = PageController(
    initialPage: 2,
  );

  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? connectedDevice;
  List<BluetoothService> services = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // title: const Text(''),
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
                  value: 3,
                  child: Text('Medicine'),
                ),
                const PopupMenuItem<int>(
                  value: 4,
                  child: Text('IMU'),
                ),
                const PopupMenuItem<int>(
                  value: 5,
                  child: Text('Exit'),
                ),
              ],
            ),
          ],
        ),
        body: PageView(controller: _controller, children: [
          buildListViewOfDevices(),
          buildConnectDeviceView(),
          const Page1Widget(),
          const Page2Widget(),
          const Page3Widget(),
          const Page4Widget(),
        ]));
  }

  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        _controller.animateToPage(1,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut);
        break;
      case 1:
        _controller.animateToPage(2,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut);
        break;
      case 2:
        _controller.animateToPage(3,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut);
        break;
      case 3:
        _controller.animateToPage(4,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut);
        break;
      case 4:
        _controller.animateToPage(5,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut);
        break;
      case 5:
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Exit?'),
            content: const Text('Are you sure you want to exit the App?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                  onPressed: () {
                    setState(
                      () {
                        Navigator.pop(context, 'Yes');
                        exit(0);
                      },
                    );
                  },
                  child: const Text('Yes')),
            ],
          ),
        );
    }
  }

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
      containers.add(
        Column(
          children: [
            ListTile(
              title: Text(
                device.name == '' ? '(unknown device)' : device.name,
                style: const TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              ),
              onTap: ()  async {
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
                });
              },
            ),
            const Divider(
              color: Colors.black,
            )
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  ListView buildConnectDeviceView() {
    var deviceName = connectedDevice?.name;
    // List<Widget> characteristicsWidget = <Widget>[];
    List<Container> containers = <Container>[];
    for (BluetoothService service in services) {

      for (BluetoothCharacteristic characteristic in service.characteristics) {
        // print(value);
        containers.add(Container(
            child: ListTile(
                title: Text(
                  deviceName.toString(),
                  style: const TextStyle(fontSize: 25),
                  textAlign: TextAlign.center,
                ),
                onTap: () async {
                  characteristic.value.listen((event) {
                    //print(event.toString());
                    String values = String.fromCharCodes(event);
                    //print(values.split("/"));
                    // Update widget
                    //widget.readValues[characteristic.uuid] = value1;
                    value1 = values.split("/")[0];
                    value2 = values.split("/")[1];
                    value3 = values.split("/")[2];
                    value4 = values.split("/")[3];
                    value5 = values.split("/")[4];
                    value6 = values.split("/")[5];
                    value7 = values.split("/")[6];
                    value8 = values.split("/")[7];
                    value9 = values.split("/")[8];
                    value10 = values.split("/")[9];
                    value11 = values.split("/")[10];
                  });
                  await characteristic.setNotifyValue(true);
                })));
      }
    }



    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }
}

class Page1Widget extends StatefulWidget {
  const Page1Widget({super.key});

  @override
  Page1WidgetState createState() => Page1WidgetState();
}

class Page1WidgetState extends State<Page1Widget> {
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
                      children: [
                    const Text(
                      'HR',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 20),
                        Text(
                          value1,
                      style: const TextStyle(fontSize: 24),
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
                      "",
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
                      children: [
                    const Text(
                      'SPO2',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      value2,
                      style: const TextStyle(fontSize: 24),
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
                  children: [
                const Text(
                  'Temp',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 20),
                Text(
                  value3,
                  style: const TextStyle(fontSize: 24),
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
          child: Center(
            child: Text(
              value4,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
      ]),
    );
  }
}

class Page2Widget extends StatefulWidget {
  const Page2Widget({super.key});

  @override
  Page2WidgetState createState() => Page2WidgetState();
}

class Page2WidgetState extends State<Page2Widget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(18),
        child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: const Text(
                  'HR',
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(18)),
                child: const Center(
                  child: Text(
                    'HR',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: const Text(
                  'SPO2',
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(18)),
                child: const Center(
                  child: Text(
                    'SPO2',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: const Text(
                  'HRV',
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(18)),
                child: const Center(
                  child: Text(
                    'HRV',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ]));
  }
}

class Page3Widget extends StatefulWidget {
  const Page3Widget({super.key});

  @override
  Page3WidgetState createState() => Page3WidgetState();
}

class Page3WidgetState extends State<Page3Widget> {
  int usedMedicine1 = 0;
  int usedMedicine2 = 0;
  int usedMedicine3 = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(18),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
                color: Colors.black12, borderRadius: BorderRadius.circular(18)),
            child: Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: const Text(
                'Informationen über den Soldaten\n'
                ' -Allergie gegen Wespen',
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(18)),
                child: Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                      const Text(
                        'Morphium',
                        style: TextStyle(fontSize: 24),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        usedMedicine1.toString(),
                        style: const TextStyle(fontSize: 24),
                        textAlign: TextAlign.right,
                      ),
                    ])),
              ),
              Center(
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      ++usedMedicine1;
                    });
                  },
                  child: const Icon(Icons.add),
                ),
              ),
              Center(
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (usedMedicine1 == 0) {
                      } else {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Remove one EA?'),
                            content: const Text(
                                'Are you sure you want to remove one EA?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                  onPressed: () {
                                    setState(
                                      () {
                                        --usedMedicine1;
                                        Navigator.pop(context, 'Yes');
                                      },
                                    );
                                  },
                                  child: const Text('Yes')),
                            ],
                          ),
                        );
                      }
                    });
                  },
                  child: const Icon(Icons.remove),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(18)),
                child: Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                      const Text(
                        'Ketamin',
                        style: TextStyle(fontSize: 24),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        usedMedicine2.toString(),
                        style: const TextStyle(fontSize: 24),
                        textAlign: TextAlign.right,
                      ),
                    ])),
              ),
              Center(
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      ++usedMedicine2;
                    });
                  },
                  child: const Icon(Icons.add),
                ),
              ),
              Center(
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (usedMedicine2 == 0) {
                      } else {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Remove one EA?'),
                            content: const Text(
                                'Are you sure you want to remove one EA?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                  onPressed: () {
                                    setState(
                                      () {
                                        --usedMedicine2;
                                        Navigator.pop(context, 'Yes');
                                      },
                                    );
                                  },
                                  child: const Text('Yes')),
                            ],
                          ),
                        );
                      }
                    });
                  },
                  child: const Icon(Icons.remove),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(18)),
                child: Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                      const Text(
                        'Fentanyl',
                        style: TextStyle(
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        usedMedicine3.toString(),
                        style: const TextStyle(fontSize: 24),
                        textAlign: TextAlign.right,
                      ),
                    ])),
              ),
              Center(
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      ++usedMedicine3;
                    });
                  },
                  child: const Icon(Icons.add),
                ),
              ),
              Center(
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (usedMedicine3 == 0) {
                      } else {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Remove one EA?'),
                            content: const Text(
                                'Are you sure you want to remove one EA?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                  onPressed: () {
                                    setState(
                                      () {
                                        --usedMedicine3;
                                        Navigator.pop(context, 'Yes');
                                      },
                                    );
                                  },
                                  child: const Text('Yes')),
                            ],
                          ),
                        );
                      }
                    });
                  },
                  child: const Icon(Icons.remove),
                ),
              ),
            ],
          ),
        ]));
  }
}

class Page4Widget extends StatefulWidget {
  const Page4Widget({super.key});

  @override
  Page4WidgetState createState() => Page4WidgetState();
}

class Page4WidgetState extends State<Page4Widget> {
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
                        children: [
                      const Text(
                        'X',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        value6,
                        style: const TextStyle(fontSize: 24),
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
                        children: [
                      const Text(
                        'X',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        value9,
                        style: const TextStyle(fontSize: 24),
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
                        children: [
                      const Text(
                        'Y',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        value7,
                        style: const TextStyle(fontSize: 24),
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
                        children: [
                      const Text(
                        'Y',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        value10,
                        style: const TextStyle(fontSize: 24),
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
                        children: [
                      const Text(
                        'Z',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        value8,
                        style: const TextStyle(fontSize: 24),
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
                        children: [
                      const Text(
                        'Z',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        value11,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ])),
              ),
            ],
          )
        ]));
  }
}
