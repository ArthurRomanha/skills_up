import 'package:flutter/material.dart';

import '../controller/tarefas_controller.dart';
import '../models/tarefas.dart';
import '../utils/datas.dart';
import '../widgets/tarefa_tile.dart';

class TodoPage extends StatefulWidget {
  final TarefasController controller;

  const TodoPage({super.key, required this.controller});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController textoController = TextEditingController();

  DateTime? dataSelecionada; //data escolhida para a proxima tarefa

  @override
  void dispose() {
    textoController.dispose();
    super.dispose();
  }

  Future<void> escolherData() async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (escolhida != null) {
      setState(() => dataSelecionada = escolhida);
    }
  }

  void adicionar() {
    if (textoController.text.trim().isEmpty) return;

    widget.controller.adicionar(textoController.text, dataSelecionada);

    textoController.clear();
    setState(() => dataSelecionada = null);
  }

  //pendentes primeiro, ordenadas por data (sem data por ultimo)
  List<Tarefa> listaOrdenada() {
    final lista = [...widget.controller.tarefas];

    lista.sort((a, b) {
      if (a.concluida != b.concluida) return a.concluida ? 1 : -1;
      if (a.data == null && b.data == null) return 0;
      if (a.data == null) return 1;
      if (b.data == null) return -1;
      return a.data!.compareTo(b.data!);
    });

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          children: [
            /*---------------------- campo de nova tarefa ----------------------*/
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textoController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => adicionar(),
                    decoration: InputDecoration(
                      hintText: 'Digite uma tarefa...',
                      prefixIcon: const Icon(Icons.edit_outlined),
                      filled: true,
                      fillColor: cs.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: adicionar,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /*---------------------- escolha da data ----------------------*/
            Align(
              alignment: Alignment.centerLeft,
              child: InputChip(
                avatar: const Icon(Icons.event, size: 18),
                label: Text(
                  dataSelecionada == null
                      ? 'Sem data'
                      : rotuloData(dataSelecionada!),
                ),
                onPressed: escolherData,
                onDeleted: dataSelecionada == null
                    ? null
                    : () => setState(() => dataSelecionada = null),
              ),
            ),

            const SizedBox(height: 8),

            /*---------------------- lista ----------------------*/
            Expanded(
              child: ListenableBuilder(
                listenable: widget.controller,
                builder: (context, _) {
                  final lista = listaOrdenada();

                  if (lista.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhuma tarefa ainda',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      return TarefaTile(
                        tarefa: lista[index],
                        controller: widget.controller,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
