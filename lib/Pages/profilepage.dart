import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import '../Provider/LocalProvider.dart';
import 'Editprofile.dart';
import 'loginpage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class profilepg extends StatefulWidget {
  const profilepg({Key? key}) : super(key: key);

  @override
  State<profilepg> createState() => _profilepgState();
}

class _profilepgState extends State<profilepg> {
  String _name = "admin";

  @override
  void initState() {
    super.initState();
    _loadName(); // Load the user's name from SharedPreferences when the widget initializes
  }

  // Function to load the user's name from SharedPreferences
  void _loadName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? "admin";
    });
  }

  // Function to save the user's name to SharedPreferences
  void _saveName(String newName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', newName);
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Colors.grey,
        title: Text(AppLocalizations.of(context)!.profile),
      ),
      body: ListView(
        padding: EdgeInsets.all(5),
        children: [
          SizedBox(height: 16),
          Text(
            _name, // Use _name here
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.language),
            title: Row(
              children: [
                Text(AppLocalizations.of(context)!.language),
                Spacer(),
                Text("Eng"),
                Switch(
                  value: localeProvider.locale.languageCode == 'ar',
                  onChanged: (newValue) async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    if (newValue &&
                        localeProvider.locale.languageCode != 'ar') {
                      final newLocale = Locale('ar');
                      localeProvider.setLocale(newLocale);
                      await prefs.setString('languageCode', 'ar');
                    } else if (!newValue &&
                        localeProvider.locale.languageCode != 'en') {
                      final newLocale = Locale('en');
                      localeProvider.setLocale(newLocale);
                      await prefs.setString('languageCode', 'en');
                    }
                  },
                ),
                Text("Arb")
              ],
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(AppLocalizations.of(context)!.editprofile),
            onTap: () async {
              Map<String, dynamic>? updatedProfile = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    currentName: _name, // Pass the current name here
                  ),
                ),
              );

              if (updatedProfile != null) {
                setState(() {
                  // Update the profile details if they were changed
                  String newName = updatedProfile['name'];
                  _name = newName;
                  _saveName(
                      newName); // Save the updated name to SharedPreferences
                });
              }
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(AppLocalizations.of(context)!.logout),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
