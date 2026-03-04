import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class salespg extends StatefulWidget {

  const salespg({Key? key}) : super(key: key);

  @override
  State<salespg> createState() => _salespgState();
}

class _salespgState extends State<salespg> {
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
        backgroundColor: Colors.blueGrey,
        title: Text(AppLocalizations.of(context)!.companydetails,
          style: TextStyle(
            fontSize: 15,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("${AppLocalizations.of(context)!.cash} :"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("${AppLocalizations.of(context)!.credit} :"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("${AppLocalizations.of(context)!.retrn} :"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("${AppLocalizations.of(context)!.total} :",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
