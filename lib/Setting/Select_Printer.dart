import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:git_barcode/Setting/testprint.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectPrinterPage extends StatefulWidget {
  @override
  _SelectPrinterPageState createState() => _SelectPrinterPageState();
}

class _SelectPrinterPageState extends State<SelectPrinterPage> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  TestPrint testPrint = TestPrint();

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  String? _selectedMac;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializePrinterData();
  }

  @override
  void dispose() {
    bluetooth.disconnect();
    super.dispose();
  }

  Future<void> _initializePrinterData() async {
    await _initBluetooth();
    await _loadSelectedPrinter();
  }

  Future<void> _initBluetooth() async {
    try {
      List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
      setState(() => _devices = devices);
    } catch (e) {
      print("Bluetooth error: $e");
    }
  }

  Future<void> _loadSelectedPrinter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mac = prefs.getString('selected_printer_mac');
    setState(() => _selectedMac = mac);

    if (mac != null) {
      for (var d in _devices) {
        if (d.address == mac) {
          _selectedDevice = d;

          try {
            bool? isConnected = await bluetooth.isConnected;

            if (!isConnected!) {
              await bluetooth.connect(d);
              await Future.delayed(Duration(seconds: 1));
            }

            await _checkConnection(d);
          } catch (e) {
            print("Error connecting to saved printer: $e");
            setState(() => _isConnected = false);
          }
          break;
        }
      }
    }
  }

  Future<void> _saveSelectedPrinter(BluetoothDevice device) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_printer_mac', device.address!);
    setState(() {
      _selectedMac = device.address;
      _selectedDevice = device;
    });
    await _connectToDevice(device);
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      bool? alreadyConnected = await bluetooth.isConnected;
      if (!alreadyConnected!) {
        await bluetooth.connect(device);
      }
      await _checkConnection(device);
    } catch (e) {
      print("Connection failed: $e");
      setState(() => _isConnected = false);
    }
  }

  Future<void> _checkConnection(BluetoothDevice device) async {
    bool? connected = await bluetooth.isConnected;

    setState(() {
      _isConnected = connected ?? false;
    });
  }

  Future<void> _connectPrintOnly() async {
    if (_selectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No device selected")),
      );
      return;
    }

    try {
      bool? isConnected = await bluetooth.isConnected;

      if (!isConnected!) {
        await bluetooth.connect(_selectedDevice!);
        await Future.delayed(Duration(seconds: 1));
      }

      testPrint.labelPrint(
          "1234567890", "50 Nos", "09/06/2025", "Xavier", "01");
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      print("Print failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to connect or print")),
      );
    }
  }

  Widget _buildPrinterItem(BluetoothDevice device) {
    bool isSelected = device.address == _selectedMac;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.blue.shade300, width: 1.5),
      ),
      child: ListTile(
        title: Text(device.name ?? "Unknown"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(device.address ?? ""),
            if (isSelected)
              Text(
                _isConnected ? "Status: Connected" : "Status: Not Connected",
                style: TextStyle(
                  color: _isConnected ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: Colors.blue)
            : Icon(Icons.bluetooth, color: Colors.blue),
        onTap: () => _saveSelectedPrinter(device),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Printer"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _initBluetooth),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _devices.isEmpty
                ? Center(child: Text("No paired devices found."))
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _devices.length,
                    itemBuilder: (context, index) =>
                        _buildPrinterItem(_devices[index]),
                  ),
          ),
          if (_selectedDevice != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                ),
                icon: Icon(Icons.print, color: Colors.white),
                label:
                    Text("Test Print", style: TextStyle(color: Colors.white)),
                onPressed: _connectPrintOnly,
              ),
            ),
        ],
      ),
    );
  }
}
