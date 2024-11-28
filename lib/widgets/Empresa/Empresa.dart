import 'package:appgomarket/widgets/Divider.dart';
import 'package:flutter/material.dart';

//import 'package:tiendita/widgets/TuInventario/Tu_Inventario.dart';
late Size pantalla;

class TusEmpresas extends StatefulWidget {
  const TusEmpresas({super.key});

  @override
  State<TusEmpresas> createState() => __TuListaSurtidoStateState();
}

class __TuListaSurtidoStateState extends State<TusEmpresas> {
  @override
  Widget build(BuildContext context) {
    pantalla = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Container(
        width: pantalla.width,
        height: pantalla.height * .25,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: const Color(0xFF2b77a4),
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
            //Esta es la promocion 1
            //TODO Hacer un ListViewBuilder donde se manden llamar solo las primeras
            //TODO 3 Promociones
            listaSurtido() //promociones()
          ],
        ),
      ),
    );
  }
}

//Metodo para que cada se vaya haciendo una fila por fila
Widget listaSurtido() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Color(0xFFF4F1EB), // Fondo estilizado
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 3,
          blurRadius: 7,
          offset: Offset(0, 3), // Sombra hacia abajo
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Título principal
        SizedBox(
          width: pantalla.width * .30,
          child: const FancyDivider(
            thickness: 6.0,
            radius: 20.0,
            gradientColors: [
              Color(0xFF4A90E2),
              Color.fromARGB(255, 102, 113, 131),
            ],
            opacity: 0.4, // Aplica un nivel de opacidad
          ),
        ),

        Center(
          child: Text(
            'Conoce tus Empresas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800,
            ),
          ),
        ),
        const SizedBox(height: 16), // Espaciado entre título y contenido

        // Avatar e íconos
        const Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(
                Icons.business,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12), // Espaciado entre avatar y textos
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Empresa',
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  VerticalDivider(
                    color: Colors.blueGrey,
                    thickness: 1,
                    width: 10,
                  ),
                  Text(
                    'Encargado',
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  VerticalDivider(
                    color: Colors.blueGrey,
                    thickness: 1,
                    width: 10,
                  ),
                  Text(
                    'Rfc',
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
