import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edzkool/screens/splash/splash_screen.dart';
import 'package:edzkool/utils/device_security.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized();



  final deviceCheck = await DeviceSecurity.check();

  if (!deviceCheck.safe) {

    runApp(CompromisedDeviceApp(reason: deviceCheck.reason!));

    return;

  }



  runApp(

    const ProviderScope(

      child: MyApp(),

    ),

  );

}



class CompromisedDeviceApp extends StatelessWidget {

  final String reason;

  const CompromisedDeviceApp({super.key, required this.reason});



  @override

  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      home: Scaffold(

        body: Center(

          child: Padding(

            padding: const EdgeInsets.all(24),

            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                const Icon(Icons.security, size: 64, color: Colors.red),

                const SizedBox(height: 24),

                const Text(

                  'Security Check Failed',

                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),

                ),

                const SizedBox(height: 12),

                Text(reason, textAlign: TextAlign.center),

              ],

            ),

          ),

        ),

      ),

    );

  }

}



class MyApp extends StatelessWidget {

  const MyApp({super.key});



  @override

  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'Edzkool',

      theme: ThemeData(primarySwatch: Colors.blue),

      home: const SplashScreen(),

    );

  }

}


