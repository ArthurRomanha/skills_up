import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';


/*------------------------------------------------------------------------------*/
//classe responsavel pela logica do pomodoro

class PomodoroController extends ChangeNotifier {


  PomodoroController() {

  carregarTempoEstudado();

} //carregar ja no comeco ao chamar o timer
  /*------------------------------------------------------------------------------*/
  //variavel para definir o estado

  bool estudando = true;
  bool rodando = false;
  bool iniciou = false;  //se ja foi iniciado

  int minutosEstudo = 25;
  int minutosDescanso = 5;

  int minutosEstudados = 0;
  DateTime? momentoInicio; //para guardar o tempo que começou se sair da pagina


  /*-------------------------------------------------------------------*/
  //aqui estamos formatando o tempo usando uma funcao
  //implementando tambem o timer periodc para ele diminuir

  //variavel (classe) do meu tempo(duração)
  Duration tempoRestante = const Duration(minutes: 25);
  Duration tempoInicial = const Duration(minutes: 25);
  Timer? timer; //variavel de tempo


  /*-----------------------------------------------------------------------------*/
  //funcao para o tempo diminuir

  void iniciarTimer() {

    if (rodando) return;
    //verificacao para caso apertar denovo nao danificar o timer


    momentoInicio = DateTime.now(); //pega momento do inicio
    tempoInicial = tempoRestante; //pega o tempo restante de estudo

    rodando = true;
    iniciou = true;

    //avisa a pagina que alguma coisa mudou
    notifyListeners();


    timer = Timer.periodic(
      const Duration(seconds: 1),

      (timer) async{

        //calcula quanto tempo ja passou desde o inicio
        final tempoPassado =
            DateTime.now().difference(momentoInicio!);


        //calcula quanto tempo ainda resta
        final novoTempoRestante =
            tempoInicial - tempoPassado;


        //verifica se o tempo terminou
        if (novoTempoRestante.inSeconds <= 0) {

          //se terminou o estudo, adiciona o tempo estudado
          if (estudando) {
            minutosEstudados += minutosEstudo;
            await salvarTempoEstudado(); //salvar na memoria
          }


          //troca estudo por descanso ou descanso por estudo
          estudando = !estudando;


          //define o novo tempo
          tempoRestante = estudando
              ? Duration(minutes: minutosEstudo)
              : Duration(minutes: minutosDescanso);


          //comeca a contar o novo periodo a partir de agora
          momentoInicio = DateTime.now();
          tempoInicial = tempoRestante;


          //avisa a pagina que mudou o estado
          notifyListeners();

          return;
        }


        tempoRestante = novoTempoRestante;


        //atualiza a tela
        notifyListeners();

      },
    );
  }


  /*-----------------------------------------------------------------------------*/
//implementar o pausar e continuar

void pausarTimer() {

  //calcula exatamente quanto tempo passou ate o momento da pausa
  final tempoPassado =
      DateTime.now().difference(momentoInicio!);

  //calcula exatamente quanto tempo ainda resta
  tempoRestante = tempoInicial - tempoPassado;

  //cancela o timer
  timer?.cancel();        //timer existe?


  //garante que o tempo nao fique negativo
  if (tempoRestante.isNegative) {
    tempoRestante = Duration.zero;
  }


  rodando = false;      //trocar a variavel que nao ta rodando


  //atualiza a tela
  notifyListeners();

}
  /*-----------------------------------------------------------------------------*/
  //funcao para resetar o timer

  void resetarTimer() {

    timer?.cancel();        //cancela o timer caso esteja rodando


    rodando = false;
    iniciou = false;


    //volta para o estado de estudo
    estudando = true;


    //volta o relogio para o tempo de estudo configurado
    tempoRestante = Duration(minutes: minutosEstudo);


    tempoInicial = tempoRestante;
    momentoInicio = null;


    //atualiza a tela
    notifyListeners();

  }


  /*------------------------------------------------------------*/
  //funcao para formatar o tempo estudado

  String formatarTempoEstudado(int minutos) {

    int horas = minutos ~/ 60;
    int minutosRestantes = minutos % 60;


    if (horas > 0) {
      return '${horas}h ${minutosRestantes}min';
    }


    return '$minutosRestantes min';
  }


  /*-----------------------------------------------------------------------------*/
  //funcao para formatar o tempo em 00:00

  String formatarTempo(Duration tempo) {

    String minutos =
        tempo.inMinutes.toString().padLeft(2, '0');

    String segundos =
        (tempo.inSeconds % 60).toString().padLeft(2, '0');


    return '$minutos:$segundos';
  }


  /*-----------------------------------------------------------------------------*/
  //funcao para alterar os tempos das configuracoes

  void alterarTempos(
    int novoTempoEstudo,
    int novoTempoDescanso,
  ) {

    minutosEstudo = novoTempoEstudo;
    minutosDescanso = novoTempoDescanso;


    //se ainda nao iniciou, atualizar o relogio
    if (!iniciou) {

      tempoRestante = estudando
          ? Duration(minutes: minutosEstudo)
          : Duration(minutes: minutosDescanso);

    }


    //atualiza a tela
    notifyListeners();

  }

  /*-----------------------------------------------------------------------------*/
//funcao para limpar o timer quando o controller for destruido

@override
void dispose() {

  timer?.cancel();

  super.dispose();

}

/*-----------------------------------------------------------------------------*/
//funcao para salvar o tempo estudado

Future<void> salvarTempoEstudado() async {

  final prefs = await SharedPreferences.getInstance();

  await prefs.setInt(
    'minutosEstudados',
    minutosEstudados,
  );

}

/*-----------------------------------------------------------------------------*/
//funcao para carregar o tempo estudado

Future<void> carregarTempoEstudado() async {

  final prefs = await SharedPreferences.getInstance();

  minutosEstudados =
      prefs.getInt('minutosEstudados') ?? 0;

  notifyListeners();

}
}