import 'package:flutter/material.dart';

import 'inicio_page.dart';
import 'todo_page.dart';
import 'agenda_page.dart';
import 'pomodoro_page.dart';
import 'perfil_page.dart';
import '../controller/pomodoro_controler.dart';
import '../controller/tarefas_controller.dart';

class ControladorPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const ControladorPage({super.key, required this.onToggleTheme});

  @override
  State<ControladorPage> createState() => _ControladorPageState();
}

class _ControladorPageState extends State<ControladorPage> {
  int currentIndex = 0;

  //controller do pomodoro
  final PomodoroController pomodoroController = PomodoroController();

  //controller das tarefas (compartilhado entre To-Do e Agenda)
  final TarefasController tarefasController = TarefasController();

  @override
  void dispose() {
    pomodoroController.dispose();
    tarefasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const InicioPage(),
      TodoPage(controller: tarefasController),
      AgendaPage(controller: tarefasController),
      PomodoroPage(controller: pomodoroController),
      PerfilPage(onToggleTheme: widget.onToggleTheme),
    ];

    return Scaffold(
      //indexedstack mantem o estado de cada aba (ex: mes aberto na agenda)
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'To-Do',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Pomodoro',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
