class BarcodeData {
  int? id;
  String partName;
  int qty;
  String uom;
  String date;
  String inspector;
  String line;

  BarcodeData(
      {this.id,
      required this.partName,
      required this.qty,
      required this.uom,
      required this.date,
      required this.inspector,
      required this.line});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'partName': partName,
      'qty': qty,
      'uom': uom,
      'date': date,
      'inspector': inspector,
      'line': line
    };
  }

  static BarcodeData fromMap(Map<String, dynamic> map) {
    return BarcodeData(
      id: map['id'],
      partName: map['partName'],
      qty: map['qty'],
      uom: map['uom'],
      date: map['date'],
      inspector: map['inspector'],
      line: map['line'],
    );
  }
}
