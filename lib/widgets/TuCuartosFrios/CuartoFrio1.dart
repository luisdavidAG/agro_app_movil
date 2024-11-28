import 'package:flutter/material.dart';

class DataTableCuartoF1 extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function() fetchData;

  const DataTableCuartoF1({Key? key, required this.fetchData})
      : super(key: key);

  @override
  _DataTableCuartoF1State createState() => _DataTableCuartoF1State();
}

class _DataTableCuartoF1State extends State<DataTableCuartoF1> {
  late Future<List<Map<String, dynamic>>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = widget.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor:
                  MaterialStateColor.resolveWith((states) => Colors.blue),
              columns: data.isNotEmpty
                  ? data[0]
                      .keys
                      .map((key) => DataColumn(label: Text(key)))
                      .toList()
                  : [],
              rows: data
                  .map((row) => DataRow(
                        cells: row.values
                            .map((value) => DataCell(Text(value.toString())))
                            .toList(),
                      ))
                  .toList(),
            ),
          );
        } else {
          return const Center(child: Text("No data available"));
        }
      },
    );
  }
}
