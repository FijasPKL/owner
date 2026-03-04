import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ownerapp/Pages/homepage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'Provider/LocalProvider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? selectedLanguage = prefs.getString('languageCode');

  // Set the default locale based on the selected language or use a fallback
  Locale locale = selectedLanguage != null
      ? Locale(selectedLanguage)
      : Locale('en'); // 'en' is the fallback language

  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider()..setLocale(locale), // Provide the LocaleProvider
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _name = "admin";

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  void _loadName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? "admin";
    });
     }
  // void () async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _name = prefs.getString('name') ?? "admin";
  //   });
  // }

  // void _saveName(String newName) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('name', newName);
  // }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      locale: localeProvider.locale,
      // Remove this line
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: homepage(),
    );
  }
}
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  final Locale? overriddenLocale;

  const AppLocalizationsDelegate({this.overriddenLocale});

  @override
  bool isSupported(Locale locale) {
    // Include all the supported locales of your app here
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Use the overriddenLocale if provided, otherwise use the device's locale
    final Locale chosenLocale = overriddenLocale ?? locale;

    return AppLocalizations.delegate.load(chosenLocale); // Load translations
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
