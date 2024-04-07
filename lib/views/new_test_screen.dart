// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
// import 'package:revenue_cat_in_app_purchase/components.dart';
// import 'package:revenue_cat_in_app_purchase/views/paywall.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.green,
//       appBar: AppBar(
//         backgroundColor: Colors.deepPurple,
//       ),
//       body: Builder(builder: (context) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Center(
//                 child: ElevatedButton(
//                     onPressed: () async {
//                       final offerings = await Purchases.getOfferings();
//                       log('${offerings.current}');
//                     },
//                     child: const Text('See plans'))),
//           ],
//         );
//       }),
//     );
//   }

//   fetchOffers(BuildContext context) async {
//     final offerings = await PurchaseApi.fetchOffers();
//     if (offerings.isEmpty) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('No plans Found')));
//     } else {
//       final package = offerings
//           .map((offer) => offer.availablePackages)
//           .expand((pair) => pair)
//           .toList();
//       showModalBottomSheet(
//         context: context,
//         builder: (context) {
//           return Paywall(offering: package);
//         },
//       );
//     }
//     print(offerings);
//   }
// }

// class PurchaseApi {
//   static init() async {
//     await Purchases.setDebugLogsEnabled(true);
//     await Purchases.setup(googleApiKey);
//   }

//   static fetchOffers() async {
//     try {
//       final offerings = await Purchases.getOfferings();
//       final current = offerings.current;

//       return current == null ? [] : [current];
//     } catch (e) {
//       return [];
//     }
//   }

//   static purchasePackage(Package package) async {
//     try {
//       await Purchases.purchasePackage(package);
//       return true;
//     } catch (error) {
//       return false;
//     }
//   }
// }
