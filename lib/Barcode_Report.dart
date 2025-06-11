import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'common/database_helper.dart';
import 'common/barcode_model.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String from = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String to = DateFormat('yyyy-MM-dd').format(DateTime.now());
  List<BarcodeData> list = [];

  @override
  void initState() {
    super.initState();
    _loadData(); // Automatically loads data on page load
  }

  void _loadData() async {
    final data = await DBHelper.getDataBetweenDates(from, to);
    setState(() => list = data);
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? DateTime.parse(from) : DateTime.parse(to),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          from = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          to = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding:
              MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Reports Filter",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: _dateBox("From date", from),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: _dateBox("To date", to),
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 12),
              // DropdownButtonFormField<String>(
              //   value: selectedCategory,
              //   decoration: const InputDecoration(
              //     labelText: "Category",
              //     border: OutlineInputBorder(),
              //   ),
              //   items: categoryList
              //       .map(
              //           (cat) => DropdownMenuItem(value: cat, child: Text(cat)))
              //       .toList(),
              //   onChanged: (value) {
              //     if (value != null) {
              //       setState(() => selectedCategory = value);
              //     }
              //   },
              // ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _loadData();
                  },
                  child: const Text("Submit", style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _dateBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Report'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child:
                  Text("No data found", style: TextStyle(color: Colors.grey)),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(list[i].partName),
                  subtitle: Text(
                      "Qty: ${list[i].qty} - ${list[i].uom}, Date: ${list[i].date}, Inspector: ${list[i].inspector}, Line: ${list[i].line}"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
