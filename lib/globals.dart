library ba_app.globals;

import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:shared_preferences/shared_preferences.dart';

String connectedDeviceName = "No Device";

String values = "-";
String value1 = "-";
String value1History = "-";
String value2 = "-";
String value2History = "-";
String value3 = "-";
String value3History = "-";
String value4 = "-";
String value5 = "-";
String value6 = "-";
String value7 = "-";
String value8 = "-";
String value9 = "-";
String value10 = "-";
String value11 = "-";
String value12 = "-";

int hrDouble1 = 1;
int spo2Double1 = 1;
int hrvDouble1 = 1;

int hrDouble2 = 0;
int spo2Double2 = 0;
int hrvDouble2 = 0;

String hrAverage = "-";
String spo2Average = "-";
String hrvAverage = "-";

List<FlSpot> hrHistory = [];
List<FlSpot> spo2History = [];
List<FlSpot> hrvHistory = [];
List<FlSpot> ekg = [];

BluetoothDevice? connectedDevice;

late Timer historyTimer;
late Timer averagesTimer;

int usedMedicine1Counter = 0;
List<String> usedMedicine1Times = [];
int usedMedicine2Counter = 0;
List<String> usedMedicine2Times = [];
int usedMedicine3Counter = 0;
List<String> usedMedicine3Times = [];

bool isTextField = false;
TextEditingController myController = TextEditingController();

