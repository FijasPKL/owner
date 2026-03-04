import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ownerapp/Pages/profilepage.dart';
import 'dart:convert';
import '../Utilits/global_fn.dart';
import 'Firstcompany.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class homepage extends StatefulWidget {
  const homepage({Key? key}) : super(key: key);

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  bool showTodayData = true;
  String selectedCategory = "Today";
  TextEditingController dateInput = TextEditingController();
  DateTime? _selectedDate;
  late List<Map<String, dynamic>> responseData;

  late AppLocalizations appLocalizations; // Store the AppLocalizations here

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access AppLocalizations in the didChangeDependencies method
    appLocalizations = AppLocalizations.of(context)!;
  }

  Future<List<Map<String, dynamic>>> getData() async {
    final String? baseUrl = await fnGetBaseUrl();
    try {
      final response = await http.get(Uri.parse('${baseUrl}api/Company/CompanyList/'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final data1 = jsonData['Data']['ResponseData']['Data1'];
        return List<Map<String, dynamic>>.from(data1);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to connect to the API');
    }
  }

  Future<void> fetchData() async {
    final String? baseUrl = await fnGetBaseUrl();
    final response = await http.get(
      Uri.parse(
          '${baseUrl}api/Company/GetOverallTrans?viewmode=full&today=2021-10-23&compid=0'),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final data = jsonData['Data']['ResponseData'] as List<dynamic>;
      responseData = List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<List<T>> chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(
          i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  List<IconData> cardIcons = [
    Icons.sailing,
    Icons.shopping_cart,
    Icons.payment,
    Icons.newspaper,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/hm2.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [

                /// ================= HEADER =================
              Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).orientation == Orientation.portrait
                    ? MediaQuery.of(context).size.height * 0.18
                    : 100, // fixed safe height for landscape
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_sharp,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.person, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => profilepg(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  /// Title Section
                  Flexible(
                    child: Column(
                      children: [
                        Text(
                          'VINTECH',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).orientation ==
                                Orientation.portrait
                                ? 28
                                : 20, // smaller in landscape
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "SOFT SOLUTIONs",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

                const SizedBox(height: 20),

                /// ================= COMPANY GRID =================
                FutureBuilder(
                  future: getData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final dataList =
                      snapshot.data as List<Map<String, dynamic>>;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: dataList.length,
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                          MediaQuery.of(context).size.width > 600 ? 3 : 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (context, index) {
                          final companyData = dataList[index];

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 5,
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EachCompany(
                                            companyName:
                                            companyData['CompanyName'],
                                            DbName: companyData['DbName'],
                                            FinYearFrom:
                                            companyData['FinYearFrom'],
                                            FinYearTo:
                                            companyData['FinYearTo'],
                                            Id: companyData['Id'].toString(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius:
                                      const BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                      child: Image.network(
                                        'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: ListTile(
                                    title: Text(
                                      companyData['CompanyName'],
                                      style:
                                      const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      companyData['Address'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),

                const SizedBox(height: 20),

                /// ================= TODAY / WEEKLY =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedCategory = "Today";
                              });
                              fetchData();
                            },
                            child: Card(
                              elevation: 5,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      width: 5,
                                      color: selectedCategory == "Today"
                                          ? Colors.black
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .today,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedCategory = "Weakly";
                              });
                              fetchData();
                            },
                            child: Card(
                              elevation: 5,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      width: 5,
                                      color: selectedCategory ==
                                          "Weakly"
                                          ? Colors.black
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .weakly,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// ================= OVERALL TITLE =================
                Text(
                  AppLocalizations.of(context)!
                      .overalltransaction,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                /// ================= TRANSACTION GRID =================
                FutureBuilder(
                  future: fetchData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final transTypeDataList = responseData;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics:
                        const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10),
                        itemCount: transTypeDataList.length,
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                          MediaQuery.of(context).size.width >
                              600
                              ? 3
                              : 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2,
                        ),
                        itemBuilder: (context, index) {
                          final item =
                          transTypeDataList[index];

                          return Card(
                            elevation: 5,
                            child: ListTile(
                              leading: Icon(
                                cardIcons[index],
                                color: Colors.blueGrey,
                              ),
                              title:
                              Text(item['TransType']),
                              onTap: () {
                                showTransactionDetails(
                                    item, context);
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showTransactionDetails(
      Map<String, dynamic> transTypeData, BuildContext context) {
    String transType = transTypeData['TransType'];

    String cashText = 'Cash: ${transTypeData['Cash']}';
    String creditText = 'Credit: ${transTypeData['Credit']}';
    String bankText = 'Bank: ${transTypeData['Card']}';
    String totalAmountText = 'TotalAmount: ${transTypeData['TotalAmount']}';

    if (transType == 'Receipt') {
      creditText = ''; // Empty text for credit
    }
    if (transType == 'Purchase') {
      bankText = ''; // Empty text for card
    }
    if (transType == 'Payment') {
      creditText = '';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(30.0), // Adjust the radius as needed
          ),
          title: Column(
            children: [
              //Text('Overall $transType Details'),
              Wrap(
                alignment: WrapAlignment.start,
                spacing: 5.0,
                children: [
                  Text(AppLocalizations.of(context)!.details),
                  Text('$transType '),
                  Text(AppLocalizations.of(context)!.overall),
                ],
              ), // Display "Details"

              Divider(
                color: Colors.blueGrey,
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(cashText),
              if (creditText.isNotEmpty) Text(creditText),
              // Add creditText only if not empty
              if (bankText.isNotEmpty) Text(bankText),
              SizedBox(
                height: double.minPositive,
              ),
              Text(
                totalAmountText,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)!.close,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}