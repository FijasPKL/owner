import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../Utilits/global_fn.dart';
import 'ledgerDetails.dart';

class DashboardPage extends StatefulWidget {
  final String companyId;
  const DashboardPage({Key? key, required this.companyId}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  List<Map<String, dynamic>> companyData = [];
  List<Map<String, dynamic>> filteredCompanyData = [];
  List<String> balanceAmntList = [];
  List<String> balanceDateList = [];

  TextEditingController searchController = TextEditingController();


  late AppLocalizations appLocalizations; // Store the AppLocalizations here

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access AppLocalizations in the didChangeDependencies method
    appLocalizations = AppLocalizations.of(context)!;
  }

  Future<void> fetchCompanyData() async {
    final String? baseUrl = await fnGetBaseUrl();
    final apiUrl = Uri.parse(
        '${baseUrl}api/Reports/ledgerbalance?companyId=${widget.companyId}');
    try {
      final response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          companyData = List<Map<String, dynamic>>.from(
              data['Data']['LedgerBalance']); // Corrected field name
          filteredCompanyData = companyData;

          if (companyData.isNotEmpty) {
            balanceAmntList = companyData
                .map((item) => item['balance_type'].toString())
                .toList();
            balanceDateList = companyData
                .map((item) => item['balance_amnt'].toString())
                .toList();
          }
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
              item['area'].toLowerCase().contains(query.toLowerCase()) ||
              item['phone'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  List<String> networkImageUrls = [
    'https://images.unsplash.com/photo-1694638275387-9971d6b19880?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwzfHx8ZW58MHx8fHx8&auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1682688759350-050208b1211c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxlZGl0b3JpYWwtZmVlZHw2fHx8ZW58MHx8fHx8&auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1682905926517-6be3768e29f0?ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxlZGl0b3JpYWwtZmVlZHwzMXx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=800&q=60',
    'https://plus.unsplash.com/premium_photo-1671644439657-789881ebbef4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwxMnx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1682685797406-97f364419b4a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxlZGl0b3JpYWwtZmVlZHwxMXx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=800&q=60',
    'https://images.unsplash.com/photo-1693850323307-b36c58092934?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1yZWxhdGVkfDJ8fHxlbnwwfHx8fHw%3D&auto=format&fit=crop&w=600&q=60'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Colors.grey,
        title:  Text(
    // Text(AppLocalizations.of(context)!.close,
          AppLocalizations.of(context)!.ledgers,
          style: TextStyle(
            fontSize: 15,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
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
                    borderSide: BorderSide(
                        color: Colors
                            .black), // Change the border color when focused
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                        color: Colors
                            .grey), // Change the border color when not focused
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: filteredCompanyData.isEmpty
                  ? CircularProgressIndicator(
                      color: Colors.black45,
                    )
                  : ListView.builder(
                      itemCount: filteredCompanyData.length,
                      itemBuilder: (ctx, index) {
                        final item = filteredCompanyData[index];
                        int imageUrlIndex = index % networkImageUrls.length;
                        Color textColor = Colors.black;
                        if (balanceAmntList[index] == 'CR') {
                          textColor = Colors.green;
                        } else if (balanceAmntList[index] == 'DR') {
                          textColor = Colors.red;
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LedgerDetails(
                                  companyId:widget.companyId,
                                  name: item['name'],
                                  code: item['code'],
                                  phone: item['phone'],
                                  address: item['address'],
                                  balanceAmnt: item['balance_amnt'],
                                  balanceDate: item['balance_date'],
                                  balanceType: item['balance_type'],
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      networkImageUrls[imageUrlIndex]),
                                ),
                                title: Text("${item['name']}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("${AppLocalizations.of(context)!.code},${item['code']}"),
                                trailing: Padding(

                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${balanceAmntList[index]} ${balanceDateList[index]}',
                                        style: TextStyle(
                                            color:
                                                textColor), // Apply text color
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
}
