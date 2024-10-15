import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Utilits/global_fn.dart';

class Stockchecking extends StatefulWidget {
   final String companyId;


  const Stockchecking({Key? key, required this.companyId}) : super(key: key);
  @override
  _StockcheckingPageState createState() => _StockcheckingPageState();
}

class _StockcheckingPageState extends State<Stockchecking> {
  List<Map<String, dynamic>> companyData = [];
  List<Map<String, dynamic>> filteredCompanyData = [];

  TextEditingController searchController = TextEditingController();

  Future<void> fetchCompanyData() async {
    final String? baseUrl = await fnGetBaseUrl();
    final apiUrl = Uri.parse(
        '${baseUrl}api/Reports/iteminventory?companyId=${widget.companyId}');
    try {
      final response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          companyData =
              List<Map<String, dynamic>>.from(data['Data']['Inventory']);
          filteredCompanyData = companyData;
        });
      } else {
        print('API call failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during API call: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCompanyData();
  }

  void filterData(String query) {
    setState(() {
      filteredCompanyData = companyData
          .where((item) =>
              item['name'].toLowerCase().contains(query.toLowerCase()) ||
              item['code'].toLowerCase().contains(query.toLowerCase()) ||
              item['barcode'].toLowerCase().contains(query.toLowerCase()) ||
              item['serialno'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  late AppLocalizations appLocalizations; // Store the AppLocalizations here

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access AppLocalizations in the didChangeDependencies method
    appLocalizations = AppLocalizations.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Colors.grey,
        title: Text(
          AppLocalizations.of(context)!.stocks,
          style: TextStyle(
            fontSize: 15,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              height: 50,
              child: TextField(
                cursorColor: Colors.black45,
                controller: searchController,
                onChanged: filterData,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchname,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: filteredCompanyData.isEmpty
                  ? CircularProgressIndicator(color: Colors.black45)
                  : ListView.builder(
                      itemCount: filteredCompanyData.length,
                      itemBuilder: (ctx, index) {
                        final item = filteredCompanyData[index];
                        return GestureDetector(
                          onTap: () {
                            showTransactionDetails(item, context);
                          },
                          child: ListTile(
                            title: Text("${item['name']}"),
                            subtitle: Text(
                                "${AppLocalizations.of(context)!.barcode} ${item['barcode']}"),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void showTransactionDetails(
      Map<String, dynamic> ledgerTypeData, BuildContext context) {
    String nameText =
        "${AppLocalizations.of(context)!.name} : ${ledgerTypeData['name']}";
    String barcodeText =
        "${AppLocalizations.of(context)!.barcode} : ${ledgerTypeData['barcode']}";
    String codeText =
        "${AppLocalizations.of(context)!.code} : ${ledgerTypeData['code']}";
    String serialnoText =
        "${AppLocalizations.of(context)!.serialnum} : ${ledgerTypeData['serialno']}";
    // String hsncodeText = 'hsncode: ${ledgerTypeData['hsncode']}';
    // String srateText = 'srate : ${ledgerTypeData['srate']}';
    String mrpText =
        "${AppLocalizations.of(context)!.mrp} : ${ledgerTypeData['mrp']}";
    String stockText =
        "${AppLocalizations.of(context)!.stock} : ${ledgerTypeData['stock']}";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.details,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(nameText),
                    Text(barcodeText),
                    Text(codeText),
                    Text(serialnoText),
                    // Text(hsncodeText),
                    // Text(srateText),
                    Text(mrpText),
                    Text(stockText),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: 45,
                  width: 120,
                  child: ClipRRect(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        AppLocalizations.of(context)!.close,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
