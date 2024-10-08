import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/barcode/controllers/barcode_controller.dart';
import 'package:sixvalley_vendor_app/features/notification/controllers/notification_controller.dart';
import 'package:sixvalley_vendor_app/features/order_details/controllers/order_details_controller.dart';
import 'package:sixvalley_vendor_app/features/product/widgets/cookies_widget.dart';
import 'package:sixvalley_vendor_app/features/product_details/controllers/productDetailsController.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/localization/app_localization.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/features/settings/controllers/business_controller.dart';
import 'package:sixvalley_vendor_app/features/pos/controllers/cart_controller.dart';
import 'package:sixvalley_vendor_app/features/chat/controllers/chat_controller.dart';
import 'package:sixvalley_vendor_app/features/coupon/controllers/coupon_controller.dart';
import 'package:sixvalley_vendor_app/features/delivery_man/controllers/delivery_man_controller.dart';
import 'package:sixvalley_vendor_app/features/emergency_contract/controllers/emergency_contact_controller.dart';
import 'package:sixvalley_vendor_app/features/language/controllers/language_controller.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:sixvalley_vendor_app/features/order/controllers/location_controller.dart';
import 'package:sixvalley_vendor_app/features/order/controllers/order_controller.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/review/controllers/product_review_controller.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/features/refund/controllers/refund_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_controller.dart';
import 'package:sixvalley_vendor_app/features/shipping/controllers/shipping_controller.dart';
import 'package:sixvalley_vendor_app/features/shop/controllers/shop_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/notification/models/notification_body.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/features/bank_info/controllers/bank_info_controller.dart';
import 'package:sixvalley_vendor_app/features/transaction/controllers/transaction_controller.dart';
import 'package:sixvalley_vendor_app/theme/dark_theme.dart';
import 'package:sixvalley_vendor_app/theme/light_theme.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';
import 'package:sixvalley_vendor_app/features/splash/screens/splash_screen.dart';
import 'di_container.dart' as di;
import 'notification/my_notification.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  if(Firebase.apps.isEmpty){
    if(Platform.isAndroid){
      await Firebase.initializeApp(options: const FirebaseOptions(
        apiKey: "AIzaSyCXF9AXxyIO7d6G6OgD7uUxyP_6Wx6IgCM",
        projectId: "phoringsmsbd",
        messagingSenderId: "152950504609",
        appId: "1:152950504609:android:2e8aa80428bdbdad6e84e0"
      ));
    }else {
      await Firebase.initializeApp();
    }
  }
  await FlutterDownloader.initialize(debug: true , ignoreSsl: true);
  await di.init();


  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  NotificationBody? body;

  try {
    final RemoteMessage? remoteMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (remoteMessage != null) {
      body = NotificationBody.fromJson(remoteMessage.data);
    }
  } catch(e) {
    if (kDebugMode) {
      print(e);
    }
  }

  await MyNotification.initialize(flutterLocalNotificationsPlugin);
  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => di.sl<ThemeController>()),
      ChangeNotifierProvider(create: (context) => di.sl<SplashController>()),
      ChangeNotifierProvider(create: (context) => di.sl<LanguageController>()),
      ChangeNotifierProvider(create: (context) => di.sl<LocalizationController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AuthController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ProfileController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ShopController>()),
      ChangeNotifierProvider(create: (context) => di.sl<OrderController>()),
      ChangeNotifierProvider(create: (context) => di.sl<BankInfoController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ChatController>()),
      ChangeNotifierProvider(create: (context) => di.sl<BusinessController>()),
      ChangeNotifierProvider(create: (context) => di.sl<TransactionController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AddProductController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ProductController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ProductReviewController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ShippingController>()),
      ChangeNotifierProvider(create: (context) => di.sl<DeliveryManController>()),
      ChangeNotifierProvider(create: (context) => di.sl<RefundController>()),
      ChangeNotifierProvider(create: (context) => di.sl<BottomMenuController>()),
      ChangeNotifierProvider(create: (context) => di.sl<CartController>()),
      ChangeNotifierProvider(create: (context) => di.sl<EmergencyContactController>()),
      ChangeNotifierProvider(create: (context) => di.sl<CouponController>()),
      ChangeNotifierProvider(create: (context) => di.sl<LocationController>()),
      ChangeNotifierProvider(create: (context) => di.sl<NotificationController>()),
      ChangeNotifierProvider(create: (context) => di.sl<WalletController>()),
      ChangeNotifierProvider(create: (context) => di.sl<OrderDetailsController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ProductDetailsController>()),
      ChangeNotifierProvider(create: (context) => di.sl<BarcodeController>())
    ],
    child: MyApp(body: body),
  ));
}

class MyApp extends StatelessWidget {
  final NotificationBody? body;
  const MyApp({Key? key, this.body}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    List<Locale> locals = [];
    for (var language in AppConstants.languages) {
      locals.add(Locale(language.languageCode!, language.countryCode));
    }
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: Provider.of<ThemeController>(context).darkTheme ? dark : light,
      locale: Provider.of<LocalizationController>(context).locale,
      builder:(context,child){
        return Consumer<ProductController>(
            builder: (context, productController, _){
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
              child: Stack(children: [
                child!,
                if(
                  productController.stockLimitStatus != null
                  && Provider.of<AuthController>(context, listen: false).isLoggedIn()
                  && productController.showCookies
                  && !productController.isShowCookies()
                  && (productController.stockLimitStatus?.productCount ?? 0) < 0
                )
                const Positioned.fill(child: Align(alignment: Alignment.bottomCenter, child: CookiesWidget())),
              ]),
            );
          }
        );
      },
      localizationsDelegates: const [
        AppLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: locals,
      home: SplashScreen(body: body),
    );
  }
}
class Get {
  static BuildContext? get context => navigatorKey.currentContext;
  static NavigatorState? get navigator => navigatorKey.currentState;
}
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}