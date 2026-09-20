import 'package:flutter/material.dart';

import '../controller/pomodoro_controler.dart';


class PomodoroPage extends StatefulWidget {

  final PomodoroController controller;


  const PomodoroPage({
    super.key,
    required this.controller,
  });


  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}


class _PomodoroPageState extends State<PomodoroPage> {


  /*-----------------------------------------------------------------------------*/
  //funcao para abrir as configuracoes

  void abrirConfiguracoes() {

    //variaveis temporarias para configurar os tempos
    int novoTempoEstudo = widget.controller.minutosEstudo;
    int novoTempoDescanso = widget.controller.minutosDescanso;


    showDialog(
      context: context,


      builder: (context) {

        return StatefulBuilder(

          builder: (context, setStateDialog) {

            return AlertDialog(

              title: const Text('Configurações'),


              content: Column(

                mainAxisSize: MainAxisSize.min,

                children: [


                  //tempo de estudo
                  const Text(
                    'Tempo de estudo',

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),


                  Row(

                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [


                      IconButton(

                        onPressed: () {

                          if (novoTempoEstudo <= 1) return;


                          setStateDialog(() {
                            novoTempoEstudo--;
                          });

                        },

                        icon: const Icon(Icons.remove),

                      ),


                      Text(
                        '$novoTempoEstudo min',

                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),


                      IconButton(

                        onPressed: () {

                          setStateDialog(() {
                            novoTempoEstudo++;
                          });

                        },

                        icon: const Icon(Icons.add),

                      ),

                    ],
                  ),


                  const SizedBox(height: 20),


                  //tempo de descanso
                  const Text(
                    'Tempo de descanso',

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),


                  Row(

                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [


                      IconButton(

                        onPressed: () {

                          if (novoTempoDescanso <= 1) return;


                          setStateDialog(() {
                            novoTempoDescanso--;
                          });

                        },

                        icon: const Icon(Icons.remove),

                      ),


                      Text(
                        '$novoTempoDescanso min',

                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),


                      IconButton(

                        onPressed: () {

                          setStateDialog(() {
                            novoTempoDescanso++;
                          });

                        },

                        icon: const Icon(Icons.add),

                      ),

                    ],
                  ),

                ],
              ),


              actions: [


                TextButton(

                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text('Cancelar'),

                ),


                ElevatedButton(

                  onPressed: () {

                    widget.controller.alterarTempos(
                      novoTempoEstudo,
                      novoTempoDescanso,
                    );


                    Navigator.pop(context);

                  },

                  child: const Text('Salvar'),

                ),

              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Pomodoro'),
      ),


      body: AnimatedBuilder(
       

        animation: widget.controller,
                 //"Observe esse controller e reconstrua essa parte da interface sempre que ele avisar que alguma coisa mudou."
        builder: (context, child) {

          final controller = widget.controller;


          return SingleChildScrollView(

            child: Column(

              children: [


                /*--------------------------------------------------------*/
                //conteiner do relogio 

                Align(

                  alignment: Alignment.topCenter,


                  child: Container(

                    //retangulo do timer
                    width: 350,
                    height: 280,

                    padding: const EdgeInsets.all(25),


                    decoration: BoxDecoration(

                      color: const Color(0xFF15131F),

                      borderRadius: BorderRadius.circular(25),

                    ),


                    child: Column(

                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [


                        //estado + botao de configuracao
                        Row(

                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,

                          children: [


                            Text(

                              controller.estudando
                                  ? 'Estudo'
                                  : 'Descanso',


                              style: const TextStyle(

                                color: Colors.white,

                                fontSize: 24,

                                fontWeight: FontWeight.bold,

                              ),

                            ),


                            //botao de configuracao
                            IconButton(

                              onPressed: controller.rodando
                                  ? null
                                  : abrirConfiguracoes,


                              icon: const Icon(

                                Icons.settings,

                                color: Colors.white,

                              ),

                            ),

                          ],
                        ),


                        const SizedBox(height: 20),


                        //texto do tempo
                        Text(

                          controller.formatarTempo(
                            controller.tempoRestante,
                          ),


                          style: const TextStyle(

                            color: Colors.white,

                            fontSize: 60,

                            fontWeight: FontWeight.bold,

                          ),

                        ),


                        const SizedBox(height: 25),


                        //botoes do setstate
                        Row(

                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [


                            ElevatedButton(

                              onPressed: controller.rodando
                                  ? controller.pausarTimer
                                  : controller.iniciarTimer,


                              child: Text(

                                controller.rodando
                                    ? 'Pausar'
                                    : controller.iniciou
                                        ? 'Continuar'
                                        : 'Iniciar',


                                style: const TextStyle(
                                  color: Colors.black,
                                ),

                              ),

                            ),


                            //botao resetar
                            ElevatedButton(

                              onPressed: controller.iniciou
                                  ? controller.resetarTimer
                                  : null,


                              child: const Text(

                                'Resetar',

                                style: TextStyle(
                                  color: Colors.black,
                                ),

                              ),

                            ),

                          ],
                        ),

                      ],
                    ),
                  ),
                ),


                /*-----------------------------------------------------*/
                //conteiner de instrução

                const SizedBox(height: 20),


                //bloco de instrucoes
                Container(

                  width: 350,

                  padding: const EdgeInsets.all(20),


                  decoration: BoxDecoration(

                    color: const Color.fromARGB(
                      113,
                      255,
                      243,
                      220,
                    ),

                    borderRadius: BorderRadius.circular(20),

                  ),


                  child: const Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [


                      Text(

                        'Como funciona?',

                        style: TextStyle(

                          color: Color.fromARGB(
                            255,
                            0,
                            0,
                            0,
                          ),

                          fontSize: 20,

                          fontWeight: FontWeight.bold,

                        ),

                      ),


                      SizedBox(height: 10),


                      Text(

                        '- Configure o tempo de estudo e descanso na configuração\n'
                        '- Inicie o timer. \n'
                        '- Quando o tempo acabar, o Pomodoro trocará automaticamente entre estudo e descanso.\n'
                        '- Apenas um ciclo completo do timer acumulara no tempo estudado\n'
                        "                bons estudos!",

                        style: TextStyle(

                          color: Color.fromARGB(
                            133,
                            0,
                            0,
                            0,
                          ),

                          fontSize: 15,

                        ),

                      ),

                    ],
                  ),
                ),


                /*---------------------------------------------------*/
                //conteiner do acumulador

                const SizedBox(height: 15),


                //container do acumulador
                Container(

                  width: 350,

                  padding: const EdgeInsets.all(15),


                  decoration: BoxDecoration(

                    color: const Color.fromARGB(
                      255,
                      255,
                      239,
                      219,
                    ),

                    borderRadius: BorderRadius.circular(15),

                  ),


                  child: Column(

                    children: [


                      const Text(

                        'Tempo estudado',

                        style: TextStyle(

                          color: Colors.black,

                          fontSize: 15,

                        ),

                      ),


                      const SizedBox(height: 5),


                      Text(

                        controller.formatarTempoEstudado(
                          controller.minutosEstudados,
                        ),


                        style: const TextStyle(

                          color: Colors.black,

                          fontSize: 22,

                          fontWeight: FontWeight.bold,

                        ),

                      ),

                    ],
                  ),
                ),


                /*--------------------------------------------*/

              ],
            ),
          );
        },
      ),
    );
  }
}