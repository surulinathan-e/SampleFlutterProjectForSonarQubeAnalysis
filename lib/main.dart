import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasko/bloc/application_bloc_observer.dart';
import 'package:tasko/bloc/bloc.dart';
import 'package:tasko/l10n/l10n.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/routes/routes.dart';
import 'package:tasko/utils/utils.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void mainApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  Bloc.observer = ApplicationBlocObserver();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    setUpPushNotification();
    super.initState();
  }

  setUpPushNotification() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      Logger.printLog('Permission granted: ${settings.authorizationStatus}');
    }

    messaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      if (notification == null) return;

      const androidChannel = AndroidNotificationChannel(
          'high_importance_channel', 'High Importance Notifications',
          description: 'This channel is used for importance notifications',
          importance: Importance.high);
      final localNotifications = FlutterLocalNotificationsPlugin();
      const iOS = DarwinInitializationSettings();
      const android = AndroidInitializationSettings('@drawable/tasko_logo');
      const settings = InitializationSettings(android: android, iOS: iOS);

      localNotifications.initialize(settings, onDidReceiveNotificationResponse:
          (NotificationResponse notificationDetails) async {
        if (navigatorKey.currentState!.mounted) {
          handleMessage(navigatorKey.currentState!.context, message.data,
              description: message.notification!.body != null &&
                      message.notification!.body!.isNotEmpty
                  ? message.notification!.body
                  : '');
        }
      });

      localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(
                androidChannel.id,
                androidChannel.name,
                channelDescription: androidChannel.description,
                icon: '@drawable/tasko_logo',
                color: primaryColor,
              ),
              iOS: const DarwinNotificationDetails()),
          payload: message.data['NavigationTo']);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (navigatorKey.currentState!.mounted) {
        handleMessage(navigatorKey.currentState!.context, message.data,
            description: message.notification!.body != null &&
                    message.notification!.body!.isNotEmpty
                ? message.notification!.body
                : '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return ScreenUtilInit(
        designSize: Size(width, height),
        minTextAdapt: true,
        splitScreenMode: true,
        useInheritedMediaQuery: true,
        builder: (context, child) {
          ScreenUtil.init(context);
          return MultiBlocProvider(
              providers: [
                BlocProvider.value(value: NavigationBloc()),
                BlocProvider.value(value: SignupBloc()),
                BlocProvider.value(value: LoginBloc()),
                BlocProvider.value(value: ForgetPasswordBloc()),
                BlocProvider.value(value: UserBloc()),
                BlocProvider.value(value: TaskBloc()),
                BlocProvider.value(value: ProjectBloc()),
                BlocProvider.value(value: PostBloc()),
                BlocProvider.value(value: AdminBloc()),
                BlocProvider.value(value: ClockBloc()),
                BlocProvider.value(value: AdminViewRecordsBloc()),
                BlocProvider.value(value: FilteringBloc()),
              ],
              child: MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: MaterialApp(
                    navigatorKey: navigatorKey,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: L10n.all,
                    locale: _locale,
                    debugShowCheckedModeBanner: false,
                    theme: ThemeData(
                      primaryColor: white,
                      primarySwatch:
                          const MaterialColor(0xFFFFFFFF, <int, Color>{
                        50: white,
                        100: white,
                        200: white,
                        300: white,
                        350: white,
                        400: white,
                        500: white,
                        600: white,
                        700: white,
                        800: white,
                        850: white,
                        900: white,
                      }),
                      appBarTheme: const AppBarTheme(
                        backgroundColor: white,
                        surfaceTintColor: white,
                      ),
                      fontFamily: 'Poppins',
                      cupertinoOverrideTheme: const CupertinoThemeData(
                        primaryColor: black,
                      ),
                      textSelectionTheme:
                          const TextSelectionThemeData(cursorColor: black),
                      inputDecorationTheme: InputDecorationTheme(
                        border: OutlineInputBorder(
                          borderRadius: borderRadius(),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: borderRadius(),
                          borderSide:
                              const BorderSide(color: transparent, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: borderRadius(),
                          borderSide: const BorderSide(color: transparent),
                        ),
                        errorStyle:
                            const TextStyle(color: redTextColor, fontSize: 15),
                      ),
                    ),
                    initialRoute: PageName.splashScreen,
                    onGenerateRoute: AppRouter().onGenerateRoute,
                  )));
        });
  }
}
