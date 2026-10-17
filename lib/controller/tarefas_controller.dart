import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/tarefas.dart';
import '../utils/datas.dart';

/*------------------------------------------------------------------------------*/
//controller unico das tarefas: to-do e agenda usam a mesma lista,
//entao qualquer mudanca aparece nas duas telas automaticamente

class TarefasController extends ChangeNotifier {
  TarefasController() {
    carregar();
  }

  static const String _chave = 'tarefas'; //mesma chave de antes

  final List<Tarefa> tarefas = [];

  /*----------------------------------------------------------------------------*/
  //persistencia

  Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final listaJson = prefs.getStringList(_chave);

    if (listaJson == null) return;

    tarefas
      ..clear()
      ..addAll(
        listaJson.map(
          (item) => Tarefa.fromJson(jsonDecode(item) as Map<String, dynamic>),
        ),
      );

    notifyListeners();
  }

  Future<void> _salvar() async {
    final prefs = await SharedPreferences.getInstance();

    final listaJson = tarefas
        .map((tarefa) => jsonEncode(tarefa.toJson()))
        .toList();

    await prefs.setStringList(_chave, listaJson);
  }

  /*----------------------------------------------------------------------------*/
  //acoes

  void adicionar(String titulo, DateTime? data) {
    final texto = titulo.trim();
    if (texto.isEmpty) return;

    tarefas.add(
      Tarefa(titulo: texto, data: data == null ? null : soData(data)),
    );

    _atualizar();
  }

  void alternar(Tarefa tarefa) {
    tarefa.concluida = !tarefa.concluida;
    _atualizar();
  }

  void remover(Tarefa tarefa) {
    tarefas.remove(tarefa);
    _atualizar();
  }

  void definirData(Tarefa tarefa, DateTime? data) {
    tarefa.data = data == null ? null : soData(data);
    _atualizar();
  }

  void _atualizar() {
    notifyListeners();
    _salvar();
  }

  /*----------------------------------------------------------------------------*/
  //consultas usadas pela agenda

  List<Tarefa> doDia(DateTime dia) {
    return tarefas.where((t) => mesmoDia(t.data, dia)).toList();
  }

  int totalNoDia(DateTime dia) => doDia(dia).length;

  int pendentesNoDia(DateTime dia) {
    return doDia(dia).where((t) => !t.concluida).length;
  }
}
