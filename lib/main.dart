import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bim493_barcode_store/db/app_database.dart';
import 'package:bim493_barcode_store/providers/product_provider.dart';
import 'package:bim493_barcode_store/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure DB is created/opened before app starts (safe & useful)
  await AppDatabase.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BIM 493 Store',
        theme: ThemeData(useMaterial3: true),
        home: const HomeScreen(),
      ),
    );
  }
}
