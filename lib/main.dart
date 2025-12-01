import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // Necesario para detectar Web (kIsWeb)

// Tus importaciones de páginas
import 'package:package_delivery_app/pages/bottomnav.dart';
import 'package:package_delivery_app/pages/home.dart';
import 'package:package_delivery_app/pages/login.dart';
import 'package:package_delivery_app/pages/onboarding.dart';
import 'package:package_delivery_app/pages/post.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      // 🌐 CONFIGURACIÓN WEB (Datos tomados de tu imagen anterior)
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyB4SDtWzTTY_2FkWrdNxqKwzOV-QwkvY2c",
          authDomain: "packagedeliveryapp-3fb65.firebaseapp.com",
          projectId: "packagedeliveryapp-3fb65",
          storageBucket: "packagedeliveryapp-3fb65.firebasestorage.app",
          messagingSenderId: "1062275798598",
          appId: "1:1062275798598:web:0380610c0c4903fa021c47",
        ),
      );
      print("Conexión exitosa a Firebase (WEB)");
    } else {
      // 📱 CONFIGURACIÓN ANDROID / IOS (Usa google-services.json)
      await Firebase.initializeApp();
      print("Conexión exitosa a Firebase (MÓVIL)");
    }
  } catch (e) {
    print("ERROR CRÍTICO: No se pudo conectar a Firebase");
    print("Detalles: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Package Delivery App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Aquí decidimos qué página mostrar al inicio.
      // Según tu código anterior, querías mostrar Bottomnav:
     //home: const Bottomnav(), 
     home: const LogIn(),
    );
  }
}