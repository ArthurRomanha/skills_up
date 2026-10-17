import 'package:flutter/material.dart';

import '../controller/tarefas_controller.dart';
import '../utils/datas.dart';
import '../widgets/tarefa_tile.dart';

class AgendaPage extends StatefulWidget {
  final TarefasController controller;

  const AgendaPage({super.key, required this.controller});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  late DateTime mesVisivel;
  late DateTime selecionado;

  @override
  void initState() {
    super.initState();
    final hoje = DateTime.now();
    mesVisivel = DateTime(hoje.year, hoje.month);
    selecionado = soData(hoje);
  }

  /*----------------------------------------------------------------------------*/
  //navegacao

  void mudarMes(int delta) {
    setState(() {
      mesVisivel = DateTime(mesVisivel.year, mesVisivel.month + delta);
    });
  }

  void irParaHoje() {
    final hoje = DateTime.now();
    setState(() {
      mesVisivel = DateTime(hoje.year, hoje.month);
      selecionado = soData(hoje);
    });
  }

  Future<void> novaTarefa() async {
    final titulo = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _NovaTarefaSheet(data: selecionado),
    );

    if (titulo != null) {
      widget.controller.adicionar(titulo, selecionado);
    }
  }

  /*----------------------------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          IconButton(
            tooltip: 'Hoje',
            icon: const Icon(Icons.today),
            onPressed: irParaHoje,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: novaTarefa,
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              _calendario(context),
              const SizedBox(height: 24),
              ..._secaoDoDia(context),
            ],
          );
        },
      ),
    );
  }

  /*----------------------------------------------------------------------------*/
  //calendario

  Widget _calendario(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tema = Theme.of(context).textTheme;

    const diasSemana = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

    return GestureDetector(
      //arrastar para os lados troca o mes
      onHorizontalDragEnd: (detalhes) {
        final v = detalhes.primaryVelocity ?? 0;
        if (v < -200) mudarMes(1);
        if (v > 200) mudarMes(-1);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            //titulo do mes + setas
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${capitalizar(nomeMes(mesVisivel.month))} ${mesVisivel.year}',
                    style: tema.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => mudarMes(-1),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => mudarMes(1),
                ),
              ],
            ),

            const SizedBox(height: 8),

            //letras dos dias da semana
            Row(
              children: [
                for (final letra in diasSemana)
                  Expanded(
                    child: Center(
                      child: Text(
                        letra,
                        style: tema.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 4),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(
                key: ValueKey(mesVisivel),
                child: _grade(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _grade(BuildContext context) {
    final diasNoMes =
        DateTime(mesVisivel.year, mesVisivel.month + 1, 0).day;

    //quantas celulas vazias antes do dia 1 (domingo = 0)
    final vazios = mesVisivel.weekday % 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: vazios + diasNoMes,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (index < vazios) return const SizedBox.shrink();

        final dia = DateTime(
          mesVisivel.year,
          mesVisivel.month,
          index - vazios + 1,
        );

        return _celulaDia(context, dia);
      },
    );
  }

  Widget _celulaDia(BuildContext context, DateTime dia) {
    final cs = Theme.of(context).colorScheme;

    final ehSelecionado = mesmoDia(dia, selecionado);
    final ehHoje = mesmoDia(dia, DateTime.now());

    final total = widget.controller.totalNoDia(dia);
    final pendentes = widget.controller.pendentesNoDia(dia);

    final corTexto = ehSelecionado ? cs.onPrimary : cs.onSurface;

    //bolinha embaixo do numero: colorida = tem pendente, cinza = tudo feito
    Color? corPonto;
    if (total > 0) {
      if (ehSelecionado) {
        corPonto = cs.onPrimary;
      } else {
        corPonto = pendentes > 0 ? cs.primary : cs.outline;
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => selecionado = dia),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ehSelecionado ? cs.primary : Colors.transparent,
          border: (ehHoje && !ehSelecionado)
              ? Border.all(color: cs.primary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${dia.day}',
              style: TextStyle(
                color: corTexto,
                fontWeight:
                    (ehHoje || ehSelecionado) ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: corPonto ?? Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*----------------------------------------------------------------------------*/
  //tarefas do dia selecionado

  List<Widget> _secaoDoDia(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tema = Theme.of(context).textTheme;

    final tarefasDoDia = widget.controller.doDia(selecionado);
    final pendentes = tarefasDoDia.where((t) => !t.concluida).length;

    String resumo;
    if (tarefasDoDia.isEmpty) {
      resumo = 'Nenhuma tarefa';
    } else if (pendentes == 0) {
      resumo = 'Tudo concluído 🎉';
    } else {
      resumo = '$pendentes de ${tarefasDoDia.length} pendentes';
    }

    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dataExtenso(selecionado),
              style: tema.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              resumo,
              style: tema.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),

      if (tarefasDoDia.isEmpty)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Icon(Icons.event_available, size: 40, color: cs.outline),
              const SizedBox(height: 8),
              Text(
                'Dia livre',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        )
      else
        for (final tarefa in tarefasDoDia)
          TarefaTile(
            tarefa: tarefa,
            controller: widget.controller,
            mostrarData: false,
          ),
    ];
  }
}

/*------------------------------------------------------------------------------*/
//bottom sheet para criar tarefa direto na agenda

class _NovaTarefaSheet extends StatefulWidget {
  final DateTime data;

  const _NovaTarefaSheet({required this.data});

  @override
  State<_NovaTarefaSheet> createState() => _NovaTarefaSheetState();
}

class _NovaTarefaSheetState extends State<_NovaTarefaSheet> {
  final TextEditingController texto = TextEditingController();

  @override
  void dispose() {
    texto.dispose();
    super.dispose();
  }

  void confirmar() {
    if (texto.text.trim().isEmpty) return;
    Navigator.pop(context, texto.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nova tarefa',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            dataExtenso(widget.data),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: texto,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => confirmar(),
            decoration: InputDecoration(
              hintText: 'O que você precisa fazer?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: confirmar,
              child: const Text('Adicionar'),
            ),
          ),
        ],
      ),
    );
  }
}
