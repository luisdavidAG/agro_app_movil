import 'package:flutter/material.dart';

late Size pantalla;

class Carta_Promocion extends StatefulWidget {
  const Carta_Promocion({super.key});

  @override
  State<Carta_Promocion> createState() => _Carta_PromocionState();
}

class _Carta_PromocionState extends State<Carta_Promocion> {
  final double padings_H = 30;
  final double padings_V = 25;
  late String formattedDate;

  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    List<String> days = [
      "Domingo",
      "Lunes",
      "Martes",
      "Miércoles",
      "Jueves",
      "Viernes",
      "Sábado"
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

    String dayOfWeek = days[((now.weekday) - 1)];
    String day = ((now.day - 1).toString().padLeft(2, '0'));
    String month = months[now.month - 1];
    String year = now.year.toString();
    formattedDate = "$dayOfWeek $day de $month $year";
  }

  @override
  Widget build(BuildContext context) {
    pantalla = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: padings_V),
      child: Container(
        width: pantalla.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
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
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 10,
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Contenedor para la imagen de promoción
            // TODO Arreglar el borde redondeado al imagen
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Container(
                width: pantalla.width * .3,
                height: pantalla.height * .2,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            // Contenedor para el texto
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fecha de la promoción
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Título de la promoción
                    const Text(
                      'Promoción 1',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Descripción de la promoción
                    Text(
                      'Descripción de la promoción, explicando en qué consiste y los productos que incluye. Esta sección está limitada a algunas líneas.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 15),

                    // Botones en la parte inferior
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Botón "No"
                          Container(
                            height: pantalla.height * .05,
                            child: ElevatedButton(
                              onPressed: () {
                                // Acción para el botón "No"
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black, // Fondo negro
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                      color: Color.fromARGB(120, 244, 67, 54)
                                          .withOpacity(0.8),
                                      width: 2), // Borde rojo
                                ),
                                padding: EdgeInsets
                                    .zero, // Sin padding para el gradiente
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFF44336).withOpacity(
                                          0.2), // Rojo claro con opacidad
                                      Colors
                                          .transparent, // Transparente para un efecto de degradado sutil
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20), // Padding del contenido
                                  child: const Text(
                                    'No',
                                    style: TextStyle(
                                        color: Color(0xFFF44336)), // Texto rojo
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Botón "Sí"
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Container(
                              height: pantalla.height * .05,
                              width: pantalla.width * .20,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Acción del botón
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black, // Fondo negro
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                        color: Color(0xFF4CAF50),
                                        width: 2), // Borde verde
                                  ),
                                  padding: EdgeInsets
                                      .zero, // Sin padding para el gradiente
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF4CAF50).withOpacity(
                                            0.2), // Verde claro con opacidad
                                        Colors
                                            .transparent, // Transparente para un efecto de degradado sutil
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    alignment: Alignment
                                        .center, // Padding del contenido
                                    child: Text(
                                      'Aceptar',
                                      style: TextStyle(
                                          color:
                                              Color(0xFF4CAF50)), // Texto verde
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
