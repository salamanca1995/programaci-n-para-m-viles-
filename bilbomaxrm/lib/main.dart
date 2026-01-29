import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const BilboApp());
}

class BilboMath {
  static double calcularRM(double peso, int reps) => peso * (1 + (reps / 30));
}

class BilboApp extends StatelessWidget {
  const BilboApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bilbo Max Pro',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.orangeAccent,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        fontFamily: 'sans-serif',
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  List<Map<String, dynamic>> historialSeries = [];
  int _indiceActual = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _indiceActual);
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String? hJson = prefs.getString('historial_v4');
      if (hJson != null) {
        historialSeries = List<Map<String, dynamic>>.from(json.decode(hJson));
      }
    });
  }

  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('historial_v4', json.encode(historialSeries));
  }

  Future<void> _exportarPDF(String nombreAtleta) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("BILBO MAX PRO - REPORTE DE ENTRENAMIENTO", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.orange900)),
                pw.Text("Atleta: ${nombreAtleta.toUpperCase()}", style: const pw.TextStyle(fontSize: 14)),
                pw.Text("Fecha de emisión: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"),
                pw.Divider(thickness: 1, color: PdfColors.grey),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Fecha', 'Peso (kg)', 'Reps', 'RM Estimado'],
            data: historialSeries.map((item) => [item['fecha'], "${item['peso']} kg", item['reps'], "${item['rm']} kg"]).toList(),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.orange900),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            cellAlignment: pw.Alignment.center,
          ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: 'Sesion_Bilbo_$nombreAtleta.pdf');
  }

  void solicitarNombreYGenerar(BuildContext context) {
    TextEditingController nameController = TextEditingController(text: "ITALO SALAMANCA");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Generar Reporte de Atleta", style: TextStyle(color: Colors.orangeAccent)),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Nombre del Atleta", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("VOLVER")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exportarPDF(nameController.text);
            },
            child: const Text("DESCARGAR PDF"),
          )
        ],
      ),
    );
  }

  void _registrarSerie(double p, int r) {
    HapticFeedback.mediumImpact();
    setState(() {
      historialSeries.insert(0, {
        'fecha': "${DateTime.now().day}/${DateTime.now().month}",
        'peso': p,
        'reps': r,
        'rm': BilboMath.calcularRM(p, r).toStringAsFixed(1),
      });
    });
    _guardarDatos();
  }

  @override
  Widget build(BuildContext context) {
    final pantallas = [
      const PantallaCalculadora(),
      PantallaRegistro(onSave: _registrarSerie),
      PantallaHistorial(
        logs: historialSeries,
        onDelete: (i) {
          setState(() => historialSeries.removeAt(i));
          _guardarDatos();
        },
        onExportRapido: () => _exportarPDF("Atleta Anonimo"),
        onTerminarSesion: () => solicitarNombreYGenerar(context), 
      ),
      const PantallaSugerido(),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("BILBO MAX PRO", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.orangeAccent)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(-0.8, -0.6), radius: 1.2, colors: [Color(0xFF1E1E1E), Color(0xFF0F0F0F)])
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _indiceActual = index),
          children: pantallas,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceActual,
        onDestinationSelected: (i) {
          setState(() => _indiceActual = i);
          _pageController.animateToPage(i, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
        },
        backgroundColor: const Color(0xFF151515),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calculate_outlined), label: 'Calcular'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Nueva'),
          NavigationDestination(icon: Icon(Icons.auto_graph), label: 'Progreso'),
          NavigationDestination(icon: Icon(Icons.info_outline), label: 'Info'),
        ],
      ),
    );
  }
}

// --- PANTALLAS ---

class PantallaCalculadora extends StatefulWidget {
  const PantallaCalculadora({super.key});
  @override State<PantallaCalculadora> createState() => _PantallaCalculadoraState();
}

class _PantallaCalculadoraState extends State<PantallaCalculadora> {
  final pC = TextEditingController(text: "80");
  final rC = TextEditingController(text: "10");
  double rm = 0;

  @override Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(25, 120, 25, 25),
        child: Column(
          children: [
            GlassCard(
              child: Column(
                children: [
                  InputEstilizado(label: "PESO PARA TEST (KG)", controller: pC, step: 5),
                  const SizedBox(height: 25),
                  InputEstilizado(label: "REPETICIONES", controller: rC, step: 1),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 60)),
              onPressed: () {
                double p = double.tryParse(pC.text) ?? 0;
                int r = int.tryParse(rC.text) ?? 0;
                if (p > 0) setState(() => rm = BilboMath.calcularRM(p, r));
              },
              child: const Text("PROBAR RM", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (rm > 0) ...[
              const SizedBox(height: 30),
              Text(rm.toStringAsFixed(1), style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w900)),
              const Text("KG ESTIMADOS", style: TextStyle(letterSpacing: 4, color: Colors.orangeAccent)),
            ],
          ],
        ),
      ),
    );
  }
}

class PantallaRegistro extends StatefulWidget {
  final Function(double, int) onSave;
  const PantallaRegistro({super.key, required this.onSave});
  @override State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final pC = TextEditingController(text: "60");
  final rC = TextEditingController(text: "15");
  double rmActual = 0;

  @override Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(25, 120, 25, 25),
      child: Column(
        children: [
          const Text("REGISTRAR SESIÓN BILBO", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          GlassCard(
            child: Column(
              children: [
                InputEstilizado(label: "PESO BARRA", controller: pC, step: 2),
                const SizedBox(height: 20),
                InputEstilizado(label: "REPS LOGRADAS", controller: rC, step: 1),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white12, foregroundColor: Colors.orangeAccent, minimumSize: const Size(double.infinity, 60)),
            onPressed: () {
              double p = double.tryParse(pC.text) ?? 0;
              int r = int.tryParse(rC.text) ?? 0;
              if (p > 0 && r > 0) {
                widget.onSave(p, r);
                setState(() => rmActual = BilboMath.calcularRM(p, r));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Sesión guardada en el historial")));
              }
            },
            child: const Text("GUARDAR EN HISTORIAL", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          if (rmActual > 0) ...[
            const SizedBox(height: 40),
            const Text("🚀 AUXILIARES (MODO CONSERVADOR)", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 15),
            _auxCard("Press Alto", "3 x 10", rmActual * 0.50), // 50% RM
            _auxCard("Empuje Tríceps", "3 x 12", rmActual * 0.35), // 35% RM
            _auxCard("Aperturas/Fly", "3 x 15", rmActual * 0.25), // 25% RM
          ]
        ],
      ),
    );
  }
  Widget _auxCard(String n, String sr, double p) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
    child: ListTile(title: Text(n), subtitle: Text(sr), trailing: Text("${p.toStringAsFixed(1)} kg", style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w900))),
  );
}

class PantallaHistorial extends StatelessWidget {
  final List<Map<String, dynamic>> logs;
  final Function(int) onDelete;
  final VoidCallback onExportRapido;
  final VoidCallback onTerminarSesion;

  const PantallaHistorial({super.key, required this.logs, required this.onDelete, required this.onExportRapido, required this.onTerminarSesion});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("HISTORIAL Y PROGRESO", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(onPressed: onExportRapido, icon: const Icon(Icons.picture_as_pdf, color: Colors.white24, size: 20)),
          ],
        ),
        const SizedBox(height: 15),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 64)),
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text("GENERAR REPORTE ATLETA", style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: onTerminarSesion,
        ),
        const SizedBox(height: 25),
        if (logs.isNotEmpty) ...[
          Container(height: 120, child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: logs.take(6).map((e) => Container(width: 25, height: (double.parse(e['rm'])/2), decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.5), borderRadius: BorderRadius.circular(5)))).toList(),
          )),
          const SizedBox(height: 20),
        ],
        ...List.generate(logs.length, (i) => Card(
          color: Colors.white.withOpacity(0.03),
          child: ListTile(
            title: Text("${logs[i]['peso']}kg x ${logs[i]['reps']}"),
            subtitle: Text("Fecha: ${logs[i]['fecha']} | RM: ${logs[i]['rm']}kg"),
            trailing: IconButton(icon: const Icon(Icons.delete_outline, size: 18), onPressed: () => onDelete(i)),
          ),
        )),
      ],
    );
  }
}

// --- UTILS ---
class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({super.key, required this.child});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white12)), child: child);
}

class InputEstilizado extends StatelessWidget {
  final String label; final TextEditingController controller; final int step;
  const InputEstilizado({super.key, required this.label, required this.controller, required this.step});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
    Row(children: [
      IconButton(onPressed: () => controller.text = (double.parse(controller.text) - step).toStringAsFixed(0), icon: const Icon(Icons.remove_circle_outline, color: Colors.orangeAccent)),
      Expanded(child: TextField(controller: controller, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), decoration: const InputDecoration(border: InputBorder.none))),
      IconButton(onPressed: () => controller.text = (double.parse(controller.text) + step).toStringAsFixed(0), icon: const Icon(Icons.add_circle_outline, color: Colors.orangeAccent)),
    ])
  ]);
}

class PantallaSugerido extends StatelessWidget {
  const PantallaSugerido({super.key});
  @override Widget build(BuildContext context) => const Center(child: Padding(
    padding: EdgeInsets.all(30.0),
    child: Text("Recuerda: En el levantamiento adaptado, la salud del hombro es lo más importante. No fuerces los auxiliares si sientes fatiga extrema.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38)),
  ));
}