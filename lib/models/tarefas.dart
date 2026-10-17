class Tarefa {
  String titulo;
  bool concluida;
  DateTime? data; //data da tarefa (opcional)

  Tarefa({
    required this.titulo,
    this.concluida = false,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'concluida': concluida,
      'data': data?.toIso8601String(),
    };
  }

  //tarefas antigas (sem data) continuam funcionando
  factory Tarefa.fromJson(Map<String, dynamic> json) {
    final dataTexto = json['data'] as String?;

    return Tarefa(
      titulo: json['titulo'] as String,
      concluida: (json['concluida'] as bool?) ?? false,
      data: dataTexto != null ? DateTime.tryParse(dataTexto) : null,
    );
  }
}
