import 'package:flutter/material.dart';
import 'package:flutter_test_app/pages/controlador_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  //necessario para usar plugins antes do runApp
  WidgetsFlutterBinding.ensureInitialized();

  //le a preferencia de tema salva antes de abrir o app
  final prefs = await SharedPreferences.getInstance();
  final escuro = prefs.getBool('temaEscuro') ?? false;

  runApp(
    MeuApp(
      temaInicial: escuro ? ThemeMode.dark : ThemeMode.light,
    ),
  );
}

class MeuApp extends StatefulWidget {
  final ThemeMode temaInicial;

  const MeuApp({
    super.key,
    this.temaInicial = ThemeMode.light,
  });

  @override
  State<MeuApp> createState() {
    return _MeuAppState();
  }
}

class _MeuAppState extends State<MeuApp> {
  late ThemeMode tema;

  @override
  void initState() {
    super.initState();
    tema = widget.temaInicial;
  }

  Future<void> trocarTema() async {
    setState(() {
      tema = tema == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });

    //salva a escolha
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('temaEscuro', tema == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    const semente = Colors.indigo;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AppSkillsup',

      //Material 3 com paleta gerada a partir de uma cor
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: semente),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: semente,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: tema,

      home: ControladorPage(
        onToggleTheme: trocarTema,
      ),
    );
  }
}
