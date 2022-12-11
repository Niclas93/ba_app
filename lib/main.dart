import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:ba_app/globals.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final PageController controller = PageController(
    initialPage: 2,
  );

  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? connectedDevice;
  List<BluetoothService> services = [];

  //Safe the Values with shared_preferences on local storage
  // Future<void> loadValues() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     values = prefs.getString('Values')!;
  //   });
  // }
  //
  // Future<void> saveValues() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     prefs.setString('Values', values);
  //   });
  // }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    historyTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      setState(() {
        value1History;
        value2History;
        value3History;
        hrHistory.add(FlSpot(
          DateTime.now().minute.toDouble(),
          double.parse(value1History),
        ));
        spo2History.add(FlSpot(
          DateTime.now().minute.toDouble(),
          double.parse(value2History),
        ));
        hrvHistory.add(FlSpot(
          DateTime.now().minute.toDouble(),
          double.parse(value3History),
        ));
      });
    });
    averagesTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        value1;
        value2;
        value3;
        hrDouble2 = (hrDouble2 + int.parse(value1));
        hrAverage = (hrDouble2 / hrDouble1).round().toString();
        spo2Double2 = (spo2Double2 + int.parse(value2));
        spo2Average = (spo2Double2 / spo2Double1).round().toString();
        hrvDouble2 = (hrvDouble2 + int.parse(value3));
        hrvAverage = (hrvDouble2 / hrvDouble1).round().toString();
        hrDouble1++;
        spo2Double1++;
        hrvDouble1++;
      });
    });
    return Scaffold(
        appBar: AppBar(
          title: Text(connectedDeviceName),
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
                  child: Text('Connected-Devices'),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text('Main'),
                ),
                const PopupMenuItem<int>(
                  value: 3,
                  child: Text('History'),
                ),
                const PopupMenuItem<int>(
                  value: 4,
                  child: Text('Medicine'),
                ),
                const PopupMenuItem<int>(
                  value: 5,
                  child: Text('IMU'),
                ),
                const PopupMenuItem<int>(
                  value: 6,
                  child: Text('Exit'),
                ),
              ],
            ),
          ],
        ),
        body: PageView(controller: controller, children: [
          Scaffold(
            appBar: AppBar(
              title: const Text("Bluetooth-Devices"),
            ),
            body: buildListViewOfDevices(),
          ),
          Scaffold(
            appBar: AppBar(
              title: const Text("Show Data from"),
            ),
            body: buildConnectDeviceView(),
          ),
          const Page1Widget(),
          const Page2Widget(),
          const Page3Widget(),
          const Page4Widget(),
        ]));
  }

  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        controller.animateToPage(0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut);
        break;
      case 1:
        controller.animateToPage(1,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut);
        break;
      case 2:
        controller.animateToPage(2,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut);
        break;
      case 3:
        controller.animateToPage(3,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut);
        break;
      case 4:
        controller.animateToPage(4,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut);
        break;
      case 5:
        controller.animateToPage(5,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut);
        break;
      case 6:
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

    //Safe the Values with shared_preferences on local storage
    // loadValues();

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
                  connectedDeviceName = device.name;
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
    // List<Widget> characteristicsWidget = <Widget>[];
    List<Container> containers = <Container>[];
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        // print(value);
        containers.add(Container(
            child: ListTile(
                title: Text(
                  connectedDeviceName,
                  style: const TextStyle(fontSize: 25),
                  textAlign: TextAlign.center,
                ),
                onTap: () async {
                  characteristic.value.listen((event) {
                    //print(event.toString());
                    values = String.fromCharCodes(event);
                    //print(values.split("/"));
                    value1 = values.split("/")[0];
                    value1History = values.split("/")[0];
                    value2 = values.split("/")[1];
                    value2History = values.split("/")[1];
                    value3 = values.split("/")[2];
                    value3History = values.split("/")[2];
                    value4 = values.split("/")[3];
                    value5 = values.split("/")[4];
                    value6 = values.split("/")[5];
                    value7 = values.split("/")[6];
                    value8 = values.split("/")[7];
                    value9 = values.split("/")[8];
                    value10 = values.split("/")[9];
                    value11 = values.split("/")[10];
                    value12 = values.split("/")[11];

                    //Safe the Values with shared_preferences on local storage
                    // saveValues();

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
  late Timer timer;

  @override
  Widget build(BuildContext context) {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        value1;
        value2;
        value3;
        value4;
        hrAverage;
        spo2Average;
        hrvAverage;
      });
    });
    timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        value5;
        // value12;
        ekg.add(FlSpot(
          DateTime.now().millisecond.toDouble(),
          double.parse(value5),
        ));
        if (DateTime.now().millisecond.toInt() == 0 ||
            DateTime.now().millisecond.toInt() >= 950) {
          ekg.clear();
        }
      });
    });
    return Scaffold(
        appBar: AppBar(
          title: const Text("Main"),
        ),
        body: Container(
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
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(18)),
                  child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                        const Text(
                          'HR',
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          value1,
                          style: const TextStyle(
                              fontSize: 24, color: Colors.white),
                        ),
                      ])),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  width: 170,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(18)),
                  child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                        const Text(
                          'HRØ',
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          hrAverage,
                          style: const TextStyle(
                              fontSize: 24, color: Colors.white),
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
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(18)),
                  child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                        const Text(
                          'SPO2',
                          style: TextStyle(fontSize: 24, color: Colors.cyan),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          value2,
                          style:
                              const TextStyle(fontSize: 24, color: Colors.cyan),
                        ),
                      ])),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  width: 170,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(18)),
                  child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                        const Text(
                          'SPO2Ø',
                          style: TextStyle(fontSize: 24, color: Colors.cyan),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          spo2Average,
                          style:
                              const TextStyle(fontSize: 24, color: Colors.cyan),
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
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(18)),
                  child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                        const Text(
                          'HRV',
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          value3,
                          style: const TextStyle(
                              fontSize: 24, color: Colors.white),
                        ),
                      ])),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  width: 170,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(18)),
                  child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                        const Text(
                          'HRVØ',
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          hrvAverage,
                          style: const TextStyle(
                              fontSize: 24, color: Colors.white),
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
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(18)),
              child: Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                    const Text(
                      'Temp',
                      style: TextStyle(
                          fontSize: 24, color: Colors.deepOrangeAccent),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      value4,
                      style: const TextStyle(
                          fontSize: 24, color: Colors.deepOrangeAccent),
                    ),
                  ])),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(18)),
              child: Center(
                  child: LineChart(
                LineChartData(
                  minY: 10,
                  maxY: 40,
                  minX: 0,
                  maxX: 1000,
                  backgroundColor: Colors.black,
                  lineBarsData: [
                    LineChartBarData(
                        spots: ekg,
                        isCurved: false,
                        color: Colors.green,
                        dotData: FlDotData(
                          show: false,
                        ))
                  ],
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              )),
            ),
          ]),
        ));
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
    historyTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      setState(() {
        value1History;
        value2History;
        value3History;
        hrHistory.add(FlSpot(
          DateTime.now().minute.toDouble(),
          double.parse(value1History),
        ));
        spo2History.add(FlSpot(
          DateTime.now().minute.toDouble(),
          double.parse(value2History),
        ));
        hrvHistory.add(FlSpot(
          DateTime.now().minute.toDouble(),
          double.parse(value3History),
        ));
      });
    });

    return Scaffold(
        appBar: AppBar(
          title: const Text("History"),
        ),
        body: Container(
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
                      height: 150,
                      decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(18)),
                      child: LineChart(
                        LineChartData(
                          minY: 80,
                          maxY: 200,
                          lineBarsData: [
                            LineChartBarData(
                              spots: hrHistory,
                              isCurved: false,
                            )
                          ],
                          titlesData: FlTitlesData(
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true, reservedSize: 40),
                            ),
                          ),
                        ),
                      )),
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
                      height: 150,
                      decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(18)),
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 100,
                          lineBarsData: [
                            LineChartBarData(
                              spots: spo2History,
                              isCurved: false,
                            )
                          ],
                          titlesData: FlTitlesData(
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true, reservedSize: 40),
                            ),
                          ),
                        ),
                      )),
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
                      height: 150,
                      decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(18)),
                      child: LineChart(
                        LineChartData(
                          minY: 20,
                          maxY: 120,
                          lineBarsData: [
                            LineChartBarData(
                              spots: hrvHistory,
                              isCurved: false,
                            )
                          ],
                          titlesData: FlTitlesData(
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true, reservedSize: 40),
                            ),
                          ),
                        ),
                      )),
                ])));
  }
}

class Page3Widget extends StatefulWidget {
  const Page3Widget({super.key});

  @override
  Page3WidgetState createState() => Page3WidgetState();
}

class Page3WidgetState extends State<Page3Widget> {
  @override
  void initState(){
    super.initState();
    loadUsedMedicine1Counter();
    loadUsedMedicine1Times();
    loadUsedMedicine2Counter();
    loadUsedMedicine2Times();
    loadUsedMedicine3Counter();
    loadUsedMedicine3Times();
    loadInformation();
  }

  Future<void> loadUsedMedicine1Counter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usedMedicine1Counter = (prefs.getInt('usedMedicine1counter') ?? 0);
    });
  }

  Future<void> incrementUsedMedicine1Counter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usedMedicine1Counter = (prefs.getInt('usedMedicine1counter') ?? 0) + 1;
      prefs.setInt('usedMedicine1counter', usedMedicine1Counter);
    });
  }

  Future<void> decrementUsedMedicine1Counter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usedMedicine1Counter = (prefs.getInt('usedMedicine1counter') ?? 0) - 1;
      prefs.setInt('usedMedicine1counter', usedMedicine1Counter);
    });
  }

  Future<void> loadUsedMedicine1Times() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usedMedicine1Times = prefs.getStringList('usedMedicine1Times')!;
    });
  }

  Future<void> saveUsedMedicine1Times() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setStringList('usedMedicine1Times', usedMedicine1Times);
    });
  }

  Future<void> loadUsedMedicine2Counter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usedMedicine2Counter = (prefs.getInt('usedMedicine2counter') ?? 0);
    });
  }

  Future<void> incrementUsedMedicine2Counter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usedMedicine2Counter = (prefs.getInt('usedMedicine2counter') ?? 0) + 1;
      prefs.setInt('usedMedicine2counter', usedMedicine2Counter);
    });
  }

  Future<void> decrementUsedMedicine2Counter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usedMedicine2Counter = (prefs.getInt('usedMedicine2counter') ?? 0) - 1;
      prefs.setInt('usedMedicine2counter', usedMedicine2Counter);
    });
  }

  Future<void> loadUsedMedicine2Times() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usedMedicine2Times = prefs.getStringList('usedMedicine2Times')!;
    });
  }

  Future<void> saveUsedMedicine2Times() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setStringList('usedMedicine2Times', usedMedicine2Times);
    });
  }

  Future<void> loadUsedMedicine3Counter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usedMedicine3Counter = (prefs.getInt('usedMedicine3counter') ?? 0);
    });
  }

  Future<void> incrementUsedMedicine3Counter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usedMedicine3Counter = (prefs.getInt('usedMedicine3counter') ?? 0) + 1;
      prefs.setInt('usedMedicine3counter', usedMedicine3Counter);
    });
  }

  Future<void> decrementUsedMedicine3Counter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usedMedicine3Counter = (prefs.getInt('usedMedicine3counter') ?? 0) - 1;
      prefs.setInt('usedMedicine3counter', usedMedicine3Counter);
    });
  }

  Future<void> loadUsedMedicine3Times() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usedMedicine3Times = prefs.getStringList('usedMedicine3Times')!;
    });
  }

  Future<void> saveUsedMedicine3Times() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setStringList('usedMedicine3Times', usedMedicine3Times);
    });
  }

  Future<void> loadInformation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      myController.text = prefs.getString('generalInformation')!;
    });
  }

  Future<void> saveInformation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('generalInformation', myController.text);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Medicine"),
        ),
        body: Container(
            padding: const EdgeInsets.all(18),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(18)),
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        'Informationen über den Soldaten',
                        style: TextStyle(fontSize: 15),
                        textAlign: TextAlign.left,
                      ),
                      FloatingActionButton(
                        mini: true,
                        onPressed: () {
                          setState(() {
                            if (isTextField == false) {
                              isTextField = true;
                            } else {
                              isTextField = false;
                            }
                            saveInformation();
                          });
                        },
                        child: const Icon(Icons.settings),
                      )
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    child: isTextField
                        ? TextField(
                            controller: myController,
                          )
                        : Text(myController.text),
                  )
                ]),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onDoubleTap: () {
                      showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: const Text('Time of medicine use'),
                                content: Text(usedMedicine1Times.join("\n")),
                              ));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      width: 200,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.black45,
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
                              '$usedMedicine1Counter',
                              style: const TextStyle(fontSize: 24),
                              textAlign: TextAlign.right,
                            ),
                          ])),
                    ),
                  ),
                  Center(
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Add one EA?'),
                              content: const Text(
                                  'Are you sure you want to add one EA?'),
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
                                          incrementUsedMedicine1Counter();
                                          usedMedicine1Times.add(DateTime.now().toString());
                                          saveUsedMedicine1Times();
                                          Navigator.pop(context, 'Yes');
                                        },
                                      );
                                    },
                                    child: const Text('Yes')),
                              ],
                            ),
                          );
                        });
                      },
                      child: const Icon(Icons.add),
                    ),
                  ),
                  Center(
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          if (usedMedicine1Counter == 0) {
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
                                            decrementUsedMedicine1Counter();
                                            usedMedicine1Times.removeLast();
                                            saveUsedMedicine1Times();
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
                  GestureDetector(
                    onDoubleTap: () {
                      showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: const Text('Time of medicine use'),
                                content: Text(usedMedicine2Times.join("\n")),
                              ));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      width: 200,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.black45,
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
                              '$usedMedicine2Counter',
                              style: const TextStyle(fontSize: 24),
                              textAlign: TextAlign.right,
                            ),
                          ])),
                    ),
                  ),
                  Center(
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Add one EA?'),
                              content: const Text(
                                  'Are you sure you want to add one EA?'),
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
                                          incrementUsedMedicine2Counter();
                                          usedMedicine2Times.add(DateTime.now().toString());
                                          saveUsedMedicine2Times();
                                          Navigator.pop(context, 'Yes');
                                        },
                                      );
                                    },
                                    child: const Text('Yes')),
                              ],
                            ),
                          );
                        });
                      },
                      child: const Icon(Icons.add),
                    ),
                  ),
                  Center(
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          if (usedMedicine2Counter == 0) {
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
                                            decrementUsedMedicine2Counter();
                                            usedMedicine2Times.removeLast();
                                            saveUsedMedicine2Times();
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
                  GestureDetector(
                    onDoubleTap: () {
                      showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: const Text('Time of medicine use'),
                                content: Text(usedMedicine3Times.join("\n")),
                              ));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      width: 200,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.black45,
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
                              '$usedMedicine3Counter',
                              style: const TextStyle(fontSize: 24),
                              textAlign: TextAlign.right,
                            ),
                          ])),
                    ),
                  ),
                  Center(
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Add one EA?'),
                              content: const Text(
                                  'Are you sure you want to add one EA?'),
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
                                          incrementUsedMedicine3Counter();
                                          usedMedicine3Times.add(DateTime.now().toString());
                                          saveUsedMedicine3Times();
                                          Navigator.pop(context, 'Yes');
                                        },
                                      );
                                    },
                                    child: const Text('Yes')),
                              ],
                            ),
                          );
                        });
                      },
                      child: const Icon(Icons.add),
                    ),
                  ),
                  Center(
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          if (usedMedicine3Counter == 0) {
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
                                            decrementUsedMedicine3Counter();
                                            usedMedicine3Times.removeLast();
                                            saveUsedMedicine3Times();
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
            ])));
  }
}

class Page4Widget extends StatefulWidget {
  const Page4Widget({super.key});

  @override
  Page4WidgetState createState() => Page4WidgetState();
}

class Page4WidgetState extends State<Page4Widget> {
  late Timer timer;

  @override
  Widget build(BuildContext context) {
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        value6;
        value7;
        value8;
        value9;
        value10;
        value11;
      });
    });
    return Scaffold(
        appBar: AppBar(
          title: const Text("IMU"),
        ),
        body: Container(
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
                        color: Colors.black45,
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
                        color: Colors.black45,
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
                        color: Colors.black45,
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
                        color: Colors.black45,
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
                        color: Colors.black45,
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
                        color: Colors.black45,
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
            ])));
  }
}
