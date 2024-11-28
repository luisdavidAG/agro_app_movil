import 'package:flutter/material.dart';

class FBEmpresas extends StatefulWidget {
  const FBEmpresas({
    super.key,
  });

  @override
  State<FBEmpresas> createState() => _FBEmpresasState();
}

class _FBEmpresasState extends State<FBEmpresas> {
  //padings
  final double padings_H = 40;
  final double padings_V = 25;
  //formato de dia
  late String formattedDate;

  //variables de las empresas
  //late TextEditingController _idempresaController;

  void initState() {
    super.initState();

    //varibales

    DateTime now = DateTime.now();
    List<String> days = [
      "Lunes",
      "Martes",
      "Miércoles",
      "Jueves",
      "Viernes",
      "Sábado",
      "Domingo",
    ];
    List<String> months = [
      "Enero",
      "Febrero",
      "Marzo",
      "Abril",
      "Mayo",
      "Junio",
      "Julio",
      "Agosto",
      "Septiembre",
      "Octubre",
      "Noviembre",
      "Diciembre"
    ];

    String dayOfWeek = days[((now.weekday - 1))];
    String day = ((now.day - 1).toString().padLeft(2, '0'));
    String month = months[now.month - 1];
    String year = now.year.toString();
    formattedDate = "$dayOfWeek $day de $month $year";
  }

  // @override
  void dispose() {
    //_idempresaController.dispose();
    super.dispose();
  }

  //Que va ir aqui

  //puedo poner el total de empresas,
  //preguntarle a chat que mas poner

  //hacer una consulta para cada una o una sola consulta, para todo pero se necesita
  //hacer una consulta para obtener informacion

  @override
  Widget build(BuildContext context) {
    Size pantalla = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        width: pantalla.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2b77a4),
              Color(0xFF2b77a4), // Azul
              Color(0xFFF1F8E9), // Verde claro
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 10,
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),

        // Contenido
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Fecha en la parte superior
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padings_H),
              child: Row(
                children: [
                  Text(
                    formattedDate.split(" ")[0] + " ",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    formattedDate.substring(formattedDate.indexOf(" ") + 1),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Título principal
            Container(
              margin: EdgeInsets.symmetric(horizontal: padings_H, vertical: 15),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Detalles de Tus Empresas',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),

            // Campos informativos
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padings_H),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(15),
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF000000).withOpacity(0.7),
                    ],
                    radius: 1.5,
                    center: Alignment.center,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: pantalla.width * .40,
                            child: const Text(
                              'Empresas',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Text(
                            '5',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 10, vertical: 10),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       SizedBox(
                    //         width: pantalla.width * .40,
                    //         child: const Text(
                    //           'Promociones Sin Uso',
                    //           style: TextStyle(
                    //             color: Colors.white,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //         ),
                    //       ),
                    //       const Text(
                    //         'Lista',
                    //         style: TextStyle(
                    //           color: Colors.white,
                    //           fontWeight: FontWeight.w500,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 10, vertical: 10),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       SizedBox(
                    //         width: pantalla.width * .40,
                    //         child: const Text(
                    //           'Promociones Recientes',
                    //           style: TextStyle(
                    //             color: Colors.white,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //         ),
                    //       ),
                    //       const Text(
                    //         'Lista',
                    //         style: TextStyle(
                    //           color: Colors.white,
                    //           fontWeight: FontWeight.w500,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
