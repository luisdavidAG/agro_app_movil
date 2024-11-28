import 'dart:convert';
import 'package:appgomarket/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FBCuartosFrios extends StatefulWidget {
  const FBCuartosFrios({super.key});

  @override
  State<FBCuartosFrios> createState() => _FBCuartosFriosState();
}

class _FBCuartosFriosState extends State<FBCuartosFrios> {
  final double padings_H = 40;
  late String formattedDate;

  Map<String, dynamic> palletsData = {}; // Map para almacenar los datos
  bool isLoading = true; // Indicador de carga

  @override
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

    String dayOfWeek = days[now.weekday]; // Ajuste
    String day = now.day.toString().padLeft(2, '0');
    String month = months[now.month - 1];
    String year = now.year.toString();
    formattedDate = "$dayOfWeek $day de $month $year";

    fetchTotalPallets();
  }

  Future<void> fetchTotalPallets() async {
    try {
      final url =
          AppConfig.getApiUrl("ServidorAgroFrios/CuartosFrios/CantPallet.php");
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse["success"]) {
          setState(() {
            palletsData = jsonResponse["data"][0]; // Almacena todo el mapa
            isLoading = false;
          });
        } else {
          throw Exception("Error en la consulta: ${jsonResponse["message"]}");
        }
      } else {
        throw Exception("Error en el servidor: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar datos: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size pantalla = MediaQuery.of(context).size;

    return Container(
      width: pantalla.width,
      padding: EdgeInsets.symmetric(horizontal: padings_H),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                formattedDate.split(" ")[0] + " ",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                formattedDate.substring(formattedDate.indexOf(" ") + 1),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Detalles de \nCuartos Fríos',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white),
            ),
          ),
          Container(
            height: pantalla.height * .15,
            width: pantalla.width * .40,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(15),
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF1A1A1A),
                  const Color(0xFF000000).withOpacity(0.7),
                ],
                radius: 1.5,
                center: Alignment.center,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          palletsData["total_pallets"] ?? "0",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Total De Pallets',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16),
                            ),
                            Text(
                              'Existentes',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
