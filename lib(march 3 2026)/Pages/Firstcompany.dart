import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ownerapp/Pages/stockchecking.dart';
import '../Utilits/global_fn.dart';
import 'dashboard.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EachCompany extends StatefulWidget {
  final String companyName;
  final String DbName;
  final String FinYearFrom;
  final String FinYearTo;
  final String Id;

  const EachCompany({Key? key, required this.companyName, required this.DbName, required this.FinYearFrom, required this.FinYearTo, required this.Id}) : super(key: key);

  @override
  State<EachCompany> createState() => _EachCompanyState();
}

class _EachCompanyState extends State<EachCompany> {
  List<dynamic>? companyData;
  double? closingCash;
  late AppLocalizations appLocalizations; // Store the AppLocalizations here

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access AppLocalizations in the didChangeDependencies method
    appLocalizations = AppLocalizations.of(context)!;
  }
  Future<void> fetchCompanyData() async {
    final String? baseUrl = await fnGetBaseUrl();
    final url = Uri.parse(
        '${baseUrl}api/Dashboard/loaddashboard?Company=${widget.DbName}&FromDate=${widget.FinYearFrom}&ToDate=${widget.FinYearTo}&companyId=${widget.Id}');
    print(url);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          companyData = data['Data']['Dashbaord'];
          closingCash = data['Data']['Company'][0]['ClosingCash']; // Extract ClosingCash

        });
      } else {
        // Handle error
        print('API call failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle error
      print('Error during API call: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCompanyData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Image.asset(
              'images/eachpage.jpg', // Replace with your image path
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
            CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  backgroundColor: Colors.grey,
                  expandedHeight: 120.0, // Set the height of the app bar
                  pinned: true, // Make the app bar pinned
                  floating: false, // Make the app bar not float
                  snap: false, // Make the app bar not snap
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      widget.companyName,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Column(
                        children: [
                          // Display the ClosingCash
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'ClosingCash: ${closingCash != null ? closingCash.toString() : "Loading..."}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: companyData != null
                                ? ListView.builder(
                              itemCount: companyData!.length + 1,
                              shrinkWrap: true,
                              physics:
                              NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                if (index < companyData!.length) {
                                  var transaction =
                                  companyData![index];
                                  String transType =
                                  transaction['TransType'];

                                  return Card(
                                    elevation: 4,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Container(
                                      decoration:
                                      const BoxDecoration(
                                        border: Border(
                                          left: BorderSide(
                                            width: 3,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "$transType ",
                                              style: TextStyle(
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Divider(
                                                color:
                                                Colors.blueGrey),
                                            Column(
                                              children: [
                                                if (transType == 'Purchase' ||
                                                    transType == 'Sales' ||
                                                    transType == 'Payment' ||
                                                    transType == 'Receipt')
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          "${AppLocalizations.of(context)!.cash} :${transaction['Cash']}",
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          "${AppLocalizations.of(context)!.receipt} :${transaction['Receipt']}",
                                                          textAlign: TextAlign.end,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                const SizedBox(height: 8),

                                                if (transType == 'Sales' ||
                                                    transType == 'Payment' ||
                                                    transType == 'Receipt' ||
                                                    transType == 'Purchase')
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          "${AppLocalizations.of(context)!.bank} :${transaction['Card']}",
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          "${AppLocalizations.of(context)!.credit} :${transaction['Credit']}",
                                                          textAlign: TextAlign.end,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Divider(),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                "${AppLocalizations.of(context)!.totalamount} : ${transaction['TotalAmount']}",
                                                style: const TextStyle(
                                                  overflow: TextOverflow.ellipsis,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  // Render the buttons
                                  return
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        DashboardPage(companyId: widget.Id),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.book_outlined),
                                              label: Text(
                                                AppLocalizations.of(context)!.ledgers,
                                                style: const TextStyle(fontWeight: FontWeight.w900),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Stockchecking(companyId: widget.Id),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.store_mall_directory),
                                              label: Text(
                                                AppLocalizations.of(context)!.stock,
                                                style: const TextStyle(fontWeight: FontWeight.w900),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                }
                              },
                            )
                                : Center(
                              child: CircularProgressIndicator(
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


