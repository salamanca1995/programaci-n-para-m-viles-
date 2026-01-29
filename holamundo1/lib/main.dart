import 'package:flutter/material.dart';

void main() {
  runApp(const HolaMundoApp());
}

class HolaMundoApp extends StatelessWidget {
  const HolaMundoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black, 
        appBar: AppBar(
          title: const Text(
            'BIENVENIDO',
            style: TextStyle(
              fontWeight: FontWeight.w900, 
              letterSpacing: 4,
              color: Colors.greenAccent,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          elevation: 10,
          shadowColor: Colors.greenAccent,
        ),
        body: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent, width: 2),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  // CORRECCIÓN AQUÍ: Usamos withValues para evitar el warning
                  color: Colors.greenAccent.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
              color: const Color(0xFF0A0A0A),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.adb, 
                  color: Colors.greenAccent,
                  size: 50,
                ),
                const SizedBox(height: 15),
                const Text(
                  '¡HOLA ITALO!', // <--- CAMBIO AQUÍ
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w900,
                    color: Colors.greenAccent,
                    letterSpacing: 2,
                  ),
                ),
                const Divider(color: Colors.greenAccent, thickness: 1, height: 40),
                const Text(
                  'ITALO AGUSTIN LIEVANO SALAMANCA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'CARNET: LS-38523-15',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.greenAccent,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'DESDE:',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const Text(
                  'REDMI NOTE 13 PRO 4G',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}