import 'package:flutter/material.dart';

//import 'package:tiendita/widgets/TuInventario/Tu_Inventario.dart';
late Size pantalla;

class TuCuartoConserva extends StatefulWidget {
  const TuCuartoConserva({super.key});

  @override
  State<TuCuartoConserva> createState() => _TuCuartoConservaState();
}

class _TuCuartoConservaState extends State<TuCuartoConserva> {
  @override
  Widget build(BuildContext context) {
    pantalla = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        width: pantalla.width,
        height: pantalla.height * .30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Color.fromARGB(255, 8, 35, 39),
        ),
        child: Column(
          children: [
            //Esta es la promocion 1
            //TODO Hacer un ListViewBuilder donde se manden llamar solo las primeras
            //TODO 3 Promociones
            cuartos(context),
            //promociones()
          ],
        ),
      ),
    );
  }
}

//Se manda llamar el nombre, la cantidad y un precio X

//TODO VER EL VIDEO DEL LIST VIEW BUILDER
//cuando hay mas de una promocion
//por medio de un metodo en un ciclo for que vea las promociones
//y mande al list view builder. todas las promociones

//Si no manda llamar ninguna promocion que nada mas mande un widget
//que diga que no hay nada de promociones
Widget cuartos(BuildContext context) {
  return Expanded(
    child: Row(
      //aqui se generernan los widgets con las promociones
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          //height: pantalla.height * .20,
          width: pantalla.width * .45,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img/CuartosConserva.jpeg'),
              fit: BoxFit.cover,
            ),
            color: Color.fromARGB(255, 8, 35, 39),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20), topLeft: Radius.circular(20)),
          ),
          child: const Center(
              // child: Text(
              //   'Imagen',
              //   style: TextStyle(color: Colors.white),
              // ),
              ),
        ),
        const Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  'Revisa Palets en Conservación',
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
                  'Administra, observa y toma decisiones sobre pallets en conservación.',
                  style: TextStyle(color: Colors.white),
                  //textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
