import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Utilits/global_fn.dart';


class LedgerDetails extends StatefulWidget {
  final String? name;
  final String code;
  final String phone;
  final String address;
  final String balanceAmnt;
  final String balanceDate;
  final String balanceType;
  final String companyId;

  LedgerDetails({
    required this.name,
    required this.code,
    required this.phone,
    required this.address,
    required this.balanceAmnt,
    required this.balanceDate,
    required this.balanceType,
    required this.companyId,
  });

  @override
  _LedgerDetailsState createState() => _LedgerDetailsState();
}

class _LedgerDetailsState extends State<LedgerDetails> {

  Map<String, dynamic> apiData = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final String? baseUrl = await fnGetBaseUrl();
    final response = await http.get(Uri.parse(
        '${baseUrl}api/Reports/ledgerbalancedetails?companyId=${widget.companyId}&ledgerid=1'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        apiData = jsonData['Data'];
      });
    } else {
      setState(() {
        apiData = {
          'MySQLMessage': {'Message': 'Failed to load data'}
        };
      });
    }
  }

  late AppLocalizations appLocalizations;


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
        backgroundColor: Colors.grey,
        leading: BackButton(),
        title: Text(
          AppLocalizations.of(context)!.ledgerdetails,
          style: TextStyle(
            fontSize: 15,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('${widget.name}', style: TextStyle(fontSize: 14)),
                          Spacer(),
                          // Text("${AppLocalizations.of(context)!.code},${item['code']}"),
                          Text("${AppLocalizations.of(context)!.balance}${widget.balanceType} ${widget.balanceAmnt}",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),

                      Text("${AppLocalizations.of(context)!.code} :${widget.code}",
                          style: TextStyle(fontSize: 14)),
                      Text("${AppLocalizations.of(context)!.phone} :${widget.phone}",
                          style: TextStyle(fontSize: 14)),
                      Text("${AppLocalizations.of(context)!.address} :${widget.address}",
                          style: TextStyle(fontSize: 14)),

                      // Add more widgets to display other data as needed
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 0, right: 200),
              child: Container(
                height: 50,
                child: Container(
                  child:  Center(
                    child: Text(
                      AppLocalizations.of(context)!.transaction,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      if (apiData['LedgerDetails'] != null)
                        Column(
                          children: apiData['LedgerDetails']
                              .map<Widget>((transaction) {
                            return Column(
                              children: [
                                Card(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          width: 3,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          Text(
                                            "${transaction['voucher']}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900),
                                          ),
                                          Spacer(),
                                          Text(
                                            " ${transaction['trans_amount']}",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(height: 15),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                " ${transaction['trans_date']}",
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                              Spacer(),
                                              Text(
                                                " ${AppLocalizations.of(context)!.vouchernum} ${transaction['voucher_no']}",
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 15),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            );
                          }).toList(),
                        )
                      else
                        Center(
                          child: CircularProgressIndicator(
                            color: Colors.black45,
                          ),
                        )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
