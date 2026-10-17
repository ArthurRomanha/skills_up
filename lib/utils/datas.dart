//funcoes auxiliares para trabalhar com datas em portugues

const List<String> _meses = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

const List<String> _diasSemana = [
  'domingo',
  'segunda-feira',
  'terça-feira',
  'quarta-feira',
  'quinta-feira',
  'sexta-feira',
  'sábado',
];

//remove a hora, deixando so ano/mes/dia
DateTime soData(DateTime d) => DateTime(d.year, d.month, d.day);

bool mesmoDia(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String capitalizar(String texto) {
  if (texto.isEmpty) return texto;
  return texto[0].toUpperCase() + texto.substring(1);
}

String nomeMes(int mes) => _meses[mes - 1];

//weekday: segunda = 1 ... domingo = 7
String nomeDiaSemana(DateTime d) => _diasSemana[d.weekday % 7];

//ex: Sábado, 17 de outubro
String dataExtenso(DateTime d) {
  return '${capitalizar(nomeDiaSemana(d))}, ${d.day} de ${nomeMes(d.month)}';
}

//ex: Hoje, Amanhã, 17/10 ou 17/10/2027
String rotuloData(DateTime d) {
  final hoje = soData(DateTime.now());
  final amanha = DateTime(hoje.year, hoje.month, hoje.day + 1);

  if (mesmoDia(d, hoje)) return 'Hoje';
  if (mesmoDia(d, amanha)) return 'Amanhã';

  final dia = d.day.toString().padLeft(2, '0');
  final mes = d.month.toString().padLeft(2, '0');

  if (d.year != hoje.year) return '$dia/$mes/${d.year}';
  return '$dia/$mes';
}
