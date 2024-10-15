import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  bool isLoading = false;
  late AppLocalizations appLocalizations; // Store the AppLocalizations here

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access AppLocalizations in the didChangeDependencies method
    appLocalizations = AppLocalizations.of(context)!;
  }

  @override
  initState() {
    super.initState();
    loadSettings();
  }

  loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUrl = prefs.getString('BaseUrl');
    setState(() {
      urlController.text = savedUrl ?? '';
    });
  }

  Future<void> _saveUrlAndIdToLocal(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('BaseUrl', url);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'images/white.jpg', // Replace with your image path
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 250,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),
                        child: Image.asset(
                          'images/BackgroundVintech.jpg',
                          // Replace with your image path
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              showURLDialog(context);
                            },
                            child: const Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'VINTECH',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.username,
                      prefixIcon: const Icon(Icons.drive_file_rename_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.password,
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Container(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              login();
                            },
                            style: ElevatedButton.styleFrom(

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child:  Text(
                              AppLocalizations.of(context)!.login,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                ),
                SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => homepage(),
                        ),
                      );
                    },
                    child: Text(AppLocalizations.of(context)!.helloWorld),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> login() async {
    setState(() {
      isLoading = true; // Set isLoading to true when login button is pressed
    });

    String username = usernameController.text;
    String password = passwordController.text;

    if (password.isNotEmpty && username.isNotEmpty) {
      try {
        var response = await http.post(
          Uri.parse(
              'http://api.demo-zatreport.vintechsoftsolutions.com/api/User/DoLogin'),
          body: {
            'Username': username,
            'Password': password,
          },
        );
        print("API Response: ${response.body}");
        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          if (responseData['Status'] == "200" &&
              responseData['Data']['ResponseData'] != null &&
              responseData['Data']['ResponseData'][0]['Username'] == username &&
              responseData['Data']['ResponseData'][0]['Password'] == password) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => homepage(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.loginfailed)));
          }
        }
      } catch (e) {
        print("Exception: $e");
      } finally {
        setState(() {
          isLoading =
              false; // Set isLoading back to false when login process is completed
        });
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.invalidlogin)));
    }
  }

  void showURLDialog(BuildContext context) async {
    BuildContext capturedContext = context;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    showDialog(
      context: capturedContext,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(AppLocalizations.of(context)!.settings),
          content: Padding(
            padding: EdgeInsets.all(5),
            child: TextField(
              controller: urlController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.url,
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                _saveUrlAndIdToLocal(urlController.text); // Save the URL to local storage
                Navigator.pop(context);
              },
              child:Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }
}
