import 'package:flutter/material.dart';

// Declara la variable pantalla global
late Size pantalla;

class TuCuartosFrios extends StatefulWidget {
  const TuCuartosFrios({super.key});

  @override
  State<TuCuartosFrios> createState() => _TuCuartosFriosState();
}

class _TuCuartosFriosState extends State<TuCuartosFrios> {
  @override
  Widget build(BuildContext context) {
    // Asigna el tamaño de la pantalla a la variable global
    pantalla = MediaQuery.of(context).size;
    //aqui se piden las o las sentencias sql
    //imagen xddd
    return inventario(
      context,
      'Url',
    );
  }
}

//aqui se piden y se acomodan las varibles
//context es para pedirl las cosas de themes
Widget inventario(
  BuildContext context,
  String url,
) {
  return Padding(
    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
    child: Container(
      height: pantalla.height,
      width: pantalla.width,
      //Decoraciones
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Color.fromARGB(255, 8, 35, 39)),
      //Contenido de la carta
      child: Row(
        children: [
          //Foto
          Container(
            width: pantalla.width * .45,
            decoration: const BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0)),
              color: Color.fromARGB(255, 8, 35, 39),
              image: DecorationImage(
                image: AssetImage('assets/img/CuartosFrios.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
            child: const Center(
                //     child: Text(
                //   'Imagen',
                //   style: TextStyle(color: Color.fromARGB(221, 255, 255, 255)),
                // )
                ),
          ),
          //Texto
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: Text(
                    'Revisa el Proceso de Enfriado',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                    //textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Supervisa continuamente el proceso de enfriado.',
                    style: TextStyle(color: Colors.white),
                    //textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
