// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:onepref/onepref.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
// import 'package:revenue_cat_in_app_purchase/app.dart';
// import 'package:revenue_cat_in_app_purchase/components.dart';

// import 'store_config.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:onepref/onepref.dart';
import 'package:revenue_cat_in_app_purchase/test%20data/screens/pages/dashboard.dart';
import 'package:revenue_cat_in_app_purchase/test%20data/screens/pages/menu.dart';
import 'package:revenue_cat_in_app_purchase/test%20data/screens/pages/settings.dart';
import 'package:revenue_cat_in_app_purchase/test%20data/utils/constants.dart';

final InAppPurchase _inAppPurchase = InAppPurchase.instance;
late StreamSubscription<dynamic> _streamSubscription;
final List<ProductDetails> _products = [];
final List<ProductId> _storeProductId = [
  ProductId(id: "weekly", isConsumable: false),
];
IApEngine iApEngine = IApEngine();

// void main() async {
//   if (Platform.isIOS || Platform.isMacOS) {
//     StoreConfig(
//       store: Store.appStore,
//       apiKey: appleApiKey,
//     );
//   } else if (Platform.isAndroid) {
//     // Run the app passing --dart-define=AMAZON=true
//     StoreConfig(
//       store: Store.playStore,
//       apiKey: googleApiKey,
//     );
//   }

//   WidgetsFlutterBinding.ensureInitialized();
//   await OnePref.init();

//   await _configureSDK();

//   runApp(const MagicWeatherFlutter());
// }

// Future<void> _configureSDK() async {
//   // Enable debug logs before calling `configure`.
//   await Purchases.setLogLevel(LogLevel.debug);

//   /*
//     - appUserID is nil, so an anonymous ID will be generated automatically by the Purchases SDK. Read more about Identifying Users here: https://docs.revenuecat.com/docs/user-ids

//     - observerMode is false, so Purchases will automatically handle finishing transactions. Read more about Observer Mode here: https://docs.revenuecat.com/docs/observer-mode
//     */
//   PurchasesConfiguration configuration;
//   if (StoreConfig.isForAmazonAppstore()) {
//     configuration = AmazonConfiguration(StoreConfig.instance.apiKey)
//       ..appUserID = null
//       ..observerMode = false;
//   } else {
//     configuration = PurchasesConfiguration(StoreConfig.instance.apiKey)
//       ..appUserID = null
//       ..observerMode = false;
//   }
//   await Purchases.configure(configuration);
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OnePref.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: Constants.appName,
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        themeMode: ThemeMode.dark,
        home: const MyHomePage(),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;

  final screens = [
    const Dashboard(),
    const Menu(),
    const Settings(),
  ];

  final bool _isLoaded = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            Constants.appName,
            style: TextStyle(
              color: Constants.txtColor,
            ),
          ),
        ),
        body: SafeArea(
            child: Column(
          children: [
            Expanded(child: screens[currentIndex]),
          ],
        )),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          backgroundColor: Colors.orange,
          selectedItemColor: Colors.white,
          showUnselectedLabels: false,
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() => currentIndex = index);
            // Respond to item press.
          },
          items: const [
            BottomNavigationBarItem(
              label: "Dashboard",
              icon: Icon(Icons.dashboard),
            ),
            BottomNavigationBarItem(
              label: "Store",
              icon: Icon(Icons.store),
            ),
            BottomNavigationBarItem(
              label: "Settings",
              icon: Icon(Icons.settings),
            ),
          ],
        ),
      );
}
