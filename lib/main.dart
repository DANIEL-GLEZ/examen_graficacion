import 'package:flutter/material.dart';
// Importamos el archivo que contiene la clase de nuestra pantalla interactiva
import 'package:examen_graficacion/examengaxiola.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Quita la etiqueta 'DEBUG'
      title: 'Rive Rating App', // Nuevo título descriptivo
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      // CORRECCIÓN: Llamamos a la clase de la pantalla de calificación.
      // Eliminamos 'const' si RatingScreen es Stateful (como debería ser).
      home: const RatingScreen(),
    );
  }
}
