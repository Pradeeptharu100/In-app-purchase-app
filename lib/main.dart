import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:onepref/onepref.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:revenue_cat_in_app_purchase/app.dart';
import 'package:revenue_cat_in_app_purchase/components.dart';

import 'store_config.dart';

final InAppPurchase _inAppPurchase = InAppPurchase.instance;
late StreamSubscription<dynamic> _streamSubscription;
final List<ProductDetails> _products = [];
final List<ProductId> _storeProductId = [
  ProductId(id: "weekly", isConsumable: false),
];
IApEngine iApEngine = IApEngine();

void main() async {
  if (Platform.isIOS || Platform.isMacOS) {
    StoreConfig(
      store: Store.appStore,
      apiKey: appleApiKey,
    );
  } else if (Platform.isAndroid) {
    // Run the app passing --dart-define=AMAZON=true
    StoreConfig(
      store: Store.playStore,
      apiKey: googleApiKey,
    );
  }

  WidgetsFlutterBinding.ensureInitialized();
  await OnePref.init();

  await _configureSDK();

  runApp(const MagicWeatherFlutter());
}

Future<void> _configureSDK() async {
  // Enable debug logs before calling `configure`.
  await Purchases.setLogLevel(LogLevel.debug);

  /*
    - appUserID is nil, so an anonymous ID will be generated automatically by the Purchases SDK. Read more about Identifying Users here: https://docs.revenuecat.com/docs/user-ids

    - observerMode is false, so Purchases will automatically handle finishing transactions. Read more about Observer Mode here: https://docs.revenuecat.com/docs/observer-mode
    */
  PurchasesConfiguration configuration;
  if (StoreConfig.isForAmazonAppstore()) {
    configuration = AmazonConfiguration(StoreConfig.instance.apiKey)
      ..appUserID = null
      ..observerMode = false;
  } else {
    configuration = PurchasesConfiguration(StoreConfig.instance.apiKey)
      ..appUserID = null
      ..observerMode = false;
  }
  await Purchases.configure(configuration);
}
