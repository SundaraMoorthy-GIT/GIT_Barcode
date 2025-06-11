import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'common/database_helper.dart';
import 'common/barcode_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:git_barcode/Setting/testprint.dart';

class BarcodePage extends StatefulWidget {
  const BarcodePage({super.key});

  @override
  State<BarcodePage> createState() => _BarcodePageState();
}

class _BarcodePageState extends State<BarcodePage> {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  final TestPrint testPrint = TestPrint();
  BluetoothDevice? _savedPrinter;

  @override
  void initState() {
    super.initState();
    _loadPrinter();
  }

  Future<void> _loadPrinter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mac = prefs.getString('selected_printer_mac');
    if (mac != null) {
      List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
      for (var device in devices) {
        if (device.address == mac) {
          _savedPrinter = device;
          try {
            bool? isConnected = await bluetooth.isConnected;
            if (!isConnected!) {
              await bluetooth.connect(device);
              await Future.delayed(const Duration(seconds: 1));
            }
          } catch (e) {
            print("Failed to connect saved printer: $e");
          }
          break;
        }
      }
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _PartController = TextEditingController();
  final _qtyController = TextEditingController();
  final _inspectorController = TextEditingController();
  final _uomController = TextEditingController(text: 'Nos');

  String _selectedLineNo = '';
  String _date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String nowDateTime = DateFormat('dd-MM-yy hh:mma').format(DateTime.now());

  List<String> _lineNoList =
      List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      DateTime now = DateTime.now();
      DateTime fullDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        now.hour,
        now.minute,
        now.second,
      );
      setState(() {
        _date = DateFormat('yyyy-MM-dd HH:mm:ss').format(fullDateTime);
      });
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _selectedLineNo = '';
      _date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      _uomController.text = 'Nos';
    });
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      final barcode = BarcodeData(
        partName: _PartController.text,
        qty: int.parse(_qtyController.text),
        uom: _uomController.text,
        date: _date,
        inspector: _inspectorController.text,
        line: _selectedLineNo,
      );
      await DBHelper.insertData(barcode);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved')),
      );
      _resetForm();
    }
  }

  void _saveData_Print() async {
    if (_formKey.currentState!.validate()) {
      final barcode = BarcodeData(
        partName: _PartController.text,
        qty: int.parse(_qtyController.text),
        uom: _uomController.text,
        date: _date,
        inspector: _inspectorController.text,
        line: _selectedLineNo,
      );

      await DBHelper.insertData(barcode);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved')),
      );

      try {
        String qtyUom = '${barcode.qty} ${_uomController.text}';
        testPrint.labelPrint(barcode.partName, qtyUom, nowDateTime,
            barcode.inspector, barcode.line);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print failed: $e')),
        );
      }

      _resetForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Barcode'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Line No',
                  border: OutlineInputBorder(),
                ),
                value: _selectedLineNo.isNotEmpty ? _selectedLineNo : null,
                items: _lineNoList
                    .map((line) =>
                        DropdownMenuItem(value: line, child: Text(line)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLineNo = value!;
                  });
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Select line number'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _PartController,
                decoration: const InputDecoration(
                  labelText: 'Part Name',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
                validator: (v) => v!.isEmpty ? 'Enter Part Name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _qtyController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Enter quantity' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _uomController,
                decoration: const InputDecoration(
                  labelText: 'UOM',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _inspectorController,
                decoration: const InputDecoration(
                  labelText: 'Inspector Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Enter inspector name' : null,
              ),
              // const SizedBox(height: 12),
              // InkWell(
              //   onTap: _selectDate,
              //   child: InputDecorator(
              //     decoration: const InputDecoration(
              //       labelText: 'Date & Time',
              //       border: OutlineInputBorder(),
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text(_date),
              //         const Icon(Icons.calendar_today, color: Colors.blue),
              //       ],
              //     ),
              //   ),
              // ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _saveData,
                  child: const Text('Save', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _saveData_Print,
                  child: const Text('Print & Save',
                      style: TextStyle(fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
