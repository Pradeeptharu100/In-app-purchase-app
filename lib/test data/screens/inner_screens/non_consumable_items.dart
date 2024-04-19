import 'dart:io';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:in_app_purchase/in_app_purchase.dart';
// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:onepref/onepref.dart';
import 'package:revenue_cat_in_app_purchase/main.dart';
import 'package:revenue_cat_in_app_purchase/test%20data/components/snackbar.dart';
import 'package:revenue_cat_in_app_purchase/test%20data/utils/constants.dart';

class NonConsumable extends StatefulWidget {
  const NonConsumable({super.key});

  @override
  State<NonConsumable> createState() => _NonConsumableState();
}

class _NonConsumableState extends State<NonConsumable> {
  late final List<ProductDetails> _products = <ProductDetails>[];
  IApEngine iApEngine = IApEngine();
  bool adsRemoved = false;
  bool isRestore = false;
  final List<ProductId> _productsIds = [
    ProductId(id: "non_auto_renewable1", isConsumable: false),
    ProductId(id: "normal_subscription", isConsumable: false),
    ProductId(id: "rc_premium_month", isConsumable: false),
    ProductId(id: "rc_premium_year", isConsumable: false),
    ProductId(id: "rc_test_99", isConsumable: false),
    ProductId(id: "rc_test_trail", isConsumable: false),
    ProductId(id: "weekly", isConsumable: false),
  ];

  final bool _isLoaded = false;
  @override
  void initState() {
    super.initState();

    adsRemoved = OnePref.getRemoveAds()!;

    iApEngine.inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
      //listen to the purchases
      listenPurchasedActivities(purchaseDetailsList);

      if (purchaseDetailsList.isEmpty && isRestore) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          openSnackBar(
            context: context,
            btnName: "OK",
            title: "Restore",
            message: "Oops! You do not have a purchase to restore",
            color: Colors.accents,
            bgColor: Constants.txtColor,
          );
        });
      } else if (purchaseDetailsList.isNotEmpty && isRestore) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          openSnackBar(
            context: context,
            btnName: "OK",
            title: "Restore",
            message:
                "Congrats! You got a purchase to restore, it will be restored in a sec.",
            color: Colors.accents,
            bgColor: Colors.green,
          );
        });
      }
    }, onDone: () {
      print("onDone");
    }, onError: (Object error) {
      print("onError");
    });

    //get products
    getProducts();
  }

  void getProducts() async {
    await iApEngine.getIsAvailable().then((value) async => {
          if (value)
            {
              await iApEngine.queryProducts(_productsIds).then((value) => {
                    setState(() => _products.addAll(value.productDetails)),
                    print(value.error),
                    print(value.productDetails),
                  })
            }
        });
  }

  Future<void> listenPurchasedActivities(List<PurchaseDetails> list) async {
    if (list.isNotEmpty) {
      for (var purchaseDetails in list) {
        if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          //This is for the android
          if (Platform.isAndroid &&
              iApEngine
                  .getProductIdsOnly(_productsIds)
                  .contains(purchaseDetails.productID) &&
              _productsIds
                      .where(
                          (element) => element.id == purchaseDetails.productID)
                      .first
                      .isConsumable ==
                  true) {
            final InAppPurchaseAndroidPlatformAddition androidPlatformAddition =
                iApEngine.inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();
            await androidPlatformAddition.consumePurchase(purchaseDetails).then(
                  (value) => setState(() {
                    OnePref.setRemoveAds(true);
                    adsRemoved = OnePref.getRemoveAds() ?? false;
                  }),
                );
          }

          //handles pending purchases
          if (purchaseDetails.pendingCompletePurchase) {
            await iApEngine.inAppPurchase
                .completePurchase(purchaseDetails)
                .then(
                  (value) => setState(() {
                    OnePref.setRemoveAds(true);
                    adsRemoved = OnePref.getRemoveAds() ?? false;
                  }),
                );
          }
        }
      }
    } else {
      setState(() {
        OnePref.setRemoveAds(false);
        adsRemoved = OnePref.getRemoveAds() ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: AssetImage('lib/images/rm_ads_bg.jpg'),
                fit: BoxFit.cover,
                opacity: 0.7,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OnClickAnimation(
                        onTap: () => {
                          // Navigator.of(context).pushAndRemoveUntil(
                          //     MaterialPageRoute(
                          //         builder: (context) => const MyHomePage()),
                          //     (Route<dynamic> route) => false)

                          // TODO
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      OnClickAnimation(
                        onTap: () async => {
                          await InAppPurchase.instance.restorePurchases().then(
                            (value) {
                              isRestore = true;
                              _products.clear();
                              getProducts();
                            },
                          ),
                        },
                        child: const Text(
                          "Restore",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50.0, vertical: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Text(
                              "Removed Ads ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: adsRemoved ? Colors.green : Colors.red,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  adsRemoved ? "ON" : "OFF",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    itemCount: Constants.benefitRemoveAd.length,
                    itemBuilder: (context, index) => Benefit(
                      title: Constants.benefits[index],
                      icon: Icons.check,
                      iconBackgroundColor: Colors.blue,
                      iconColor: Colors.white,
                      titleStyle: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Visibility(
                  visible: !_products.isNotEmpty,
                  child: const SizedBox(
                    height: 90,
                    width: 90,
                    child: CircularProgressIndicator(),
                  ),
                ),
                Expanded(
                  child: Visibility(
                    visible: _products.isNotEmpty,
                    child: ListView.builder(
                      itemBuilder: ((context, index) => Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 25.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.blue,
                                          width: 0.2,
                                        ),
                                      ),
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0,
                                          ),
                                          child: ListTile(
                                            title: Text(
                                              _products[index].price,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            subtitle: Text(
                                              _products[index].description,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            trailing: OnClickAnimation(
                                              onTap: () => {
                                                iApEngine.handlePurchase(
                                                    _products[index],
                                                    _productsIds)
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0)),
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 10.0,
                                                    vertical: 8.0,
                                                  ),
                                                  child: Text(
                                                    "Purchase",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ))),
                                ),
                              ],
                            ),
                          )),
                      itemCount: _products.length,
                    ),
                  ),
                ),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0),
                  child: Text(
                    "The Ad above will be used for only this screen to test the remove ad functionality.\n-----------------------\n Please note that the other ads you see, they are for the demo.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
}
