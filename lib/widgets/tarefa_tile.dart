import 'package:flutter/material.dart';

import '../controller/tarefas_controller.dart';
import '../models/tarefas.dart';
import '../utils/datas.dart';

//card de tarefa usado no To-Do e na Agenda
class TarefaTile extends StatelessWidget {
  final Tarefa tarefa;
  final TarefasController controller;

  //no To-Do mostra a data (e permite mudar); na Agenda nao precisa
  final bool mostrarData;

  const TarefaTile({
    super.key,
    required this.tarefa,
    required this.controller,
    this.mostrarData = true,
  });

  Future<void> _escolherData(BuildContext context) async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: tarefa.data ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (escolhida != null) {
      controller.definirData(tarefa, escolhida);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final atrasada = !tarefa.concluida &&
        tarefa.data != null &&
        tarefa.data!.isBefore(soData(DateTime.now()));

    final corData = atrasada ? cs.error : cs.primary;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerHigh,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 4, right: 4),
        leading: Checkbox(
          value: tarefa.concluida,
          onChanged: (_) => controller.alternar(tarefa),
        ),
        title: Text(
          tarefa.titulo,
          style: TextStyle(
            decoration: tarefa.concluida
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: tarefa.concluida ? cs.onSurface.withValues(alpha: 0.5) : null,
          ),
        ),
        subtitle: mostrarData
            ? Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _escolherData(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event, size: 16, color: corData),
                        const SizedBox(width: 4),
                        Text(
                          tarefa.data == null
                              ? 'Adicionar data'
                              : rotuloData(tarefa.data!),
                          style: TextStyle(color: corData, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => controller.remover(tarefa),
        ),
      ),
    );
  }
}
