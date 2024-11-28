import 'dart:convert';
import 'package:appgomarket/config.dart';
import 'package:appgomarket/widgets/Divider.dart';
import 'package:appgomarket/widgets/Person_Screens/FeedBack_CuartosFrios.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class TuCuartosFriosScreen extends StatefulWidget {
  final int idUsuario;

  const TuCuartosFriosScreen({super.key, required this.idUsuario});

  @override
  _TuInventarioScreenState createState() => _TuInventarioScreenState();
}

class _TuInventarioScreenState extends State<TuCuartosFriosScreen> {
  final double padings_H = 30;
  final double padings_V = 25;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _searchKey = GlobalKey();

  Map<String, dynamic>? usuario; // Información completa del usuario
  bool isLoading = true;

  Future<void> obtenerInformacionUsuario() async {
    try {
      final url = AppConfig.getApiUrl(
          "ServidorAgroFrios/Usuario/obtener_usuario.php?id_usuario=${widget.idUsuario}");
      final uri = Uri.parse(url);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse["success"]) {
          setState(() {
            usuario = jsonResponse["usuario"]; // Almacena toda la información
            isLoading = false;
          });
        } else {
          throw Exception("Error: ${jsonResponse["message"]}");
        }
      } else {
        throw Exception("Error del servidor: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar usuario: $e")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerInformacionUsuario(); // Carga inicial
  }

  @override
  Widget build(BuildContext context) {
    Size pantalla = MediaQuery.of(context).size;

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text(
                "Cargando información del usuario...",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }
    return DefaultTabController(
      length: 4, // Configuramos el número de tabs
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            // Llama nuevamente a las funciones de recarga
            await obtenerInformacionUsuario();
            setState(() {});
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFF2b77a4),
                expandedHeight: pantalla.height * 0.2,
                collapsedHeight: 100,
                floating: false,
                pinned: true,
                iconTheme: const IconThemeData(
                  color: Colors
                      .white, // Cambia el color del icono de la hamburguesa
                ),
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    double expansionFraction =
                        (constraints.maxHeight - kToolbarHeight) /
                            (pantalla.height * 0.2 - kToolbarHeight);
                    return FlexibleSpaceBar(
                      title: Row(
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 2000),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  transformHitTests: true,
                                  offset: Offset(0, -10),
                                  child: Text(
                                    expansionFraction < 0.8
                                        ? 'Tus Cuartos Fríos'
                                        : 'Hola \n${usuario?["nombre"] ?? "Usuario"}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          expansionFraction < 0.5 ? 18 : 24,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: padings_H,
                      vertical: padings_V,
                    ),
                    child: Column(
                      children: [
                        FBCuartosFrios(),
                        Padding(
                          key: _searchKey,
                          padding: EdgeInsets.symmetric(vertical: padings_V),
                          child: Container(
                            height: pantalla.height * .08,
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'Resumen De \nTus Cuartos Fríos ',
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                fontSize: 24,
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const TabBar(
                          indicatorSize: TabBarIndicatorSize.label,
                          labelColor: Color(0xFF2b77a4),
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(icon: Icon(Icons.ac_unit), text: "Cuarto 1"),
                            Tab(icon: Icon(Icons.ac_unit), text: "Cuarto 2"),
                            Tab(icon: Icon(Icons.ac_unit), text: "Cuarto 3"),
                            Tab(icon: Icon(Icons.ac_unit), text: "Cuarto 4"),
                          ],
                        ),
                        Container(
                          decoration: const BoxDecoration(
                              color: Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20))),
                          height: pantalla.height * .60,
                          width: pantalla.width,
                          child: TabBarView(
                            children: [
                              buildFutureBuilder(1), // Cuarto 1
                              buildFutureBuilder(2), // Cuarto 2
                              buildFutureBuilder(3), // Cuarto 3
                              buildFutureBuilder(4), // Cuarto 4
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  childCount: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFutureBuilder(int cuarto) {
    Future<List<Map<String, dynamic>>> fetchCuartoData(int cuarto) async {
      try {
        final url = AppConfig.getApiUrl(
            "ServidorAgroFrios/CuartosFrios/Consultar_CuartosFrios$cuarto.php");
        final uri = Uri.parse(url);
        final response = await http.get(uri);

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          if (jsonResponse["success"]) {
            return List<Map<String, dynamic>>.from(jsonResponse["data"]);
          } else {
            return []; // Devuelve una lista vacía en caso de error en la consulta
          }
        } else {
          return []; // Devuelve una lista vacía en caso de error en el servidor
        }
      } catch (e) {
        return []; // Devuelve una lista vacía en caso de excepción
      }
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchCuartoData(cuarto),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/UpsNoData_robot.json',
                  width: 200,
                  height: 200,
                ),
                const Text(
                  'No se encontraron registros \nPasa al Siguiente Cuarto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else {
          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                const Text(
                  "Registros en Cuarto",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),
                // Tabla con datos
                Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final registro = data[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FancyDivider(
                                    thickness: 6.0,
                                    radius: 20.0,
                                    gradientColors: [
                                      Color(0xFF4A90E2),
                                      Color.fromARGB(255, 102, 113, 131),
                                    ],
                                    opacity: 0.4,
                                  ),
                                  Text("Empresa",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text("Total Pallets",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text("Cajas",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text("Sobrantes",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text("Hora Entrada",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text("Hora Cambio",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text("Hora Salida",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text("Usuario",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FancyDivider(
                                    thickness: 6.0,
                                    radius: 20.0,
                                    gradientColors: [
                                      Color(0xFFE53935), // Rojo brillante
                                      Color(0xFF43A047), // Verde intenso
                                    ],
                                    opacity: 0.4,
                                  ),
                                  Text(registro['nombre_empresa'].toString()),
                                  Text(registro['total_pallets'].toString()),
                                  Text(registro['cant_cajas'].toString()),
                                  Text(registro['sobrantes'].toString()),
                                  Text(
                                    registro['hora_entrada'].toString(),
                                    style: TextStyle(
                                      color: registro['hora_entrada']
                                                  .toString()
                                                  .toLowerCase() ==
                                              "pendiente"
                                          ? Color(0xFFE53935)
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    registro['hora_cambio'].toString(),
                                    style: TextStyle(
                                      color: registro['hora_cambio']
                                                  .toString()
                                                  .toLowerCase() ==
                                              "pendiente"
                                          ? Color(0xFFE53935)
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    registro['hora_salida'].toString(),
                                    style: TextStyle(
                                      color: registro['hora_salida']
                                                  .toString()
                                                  .toLowerCase() ==
                                              "pendiente"
                                          ? Color(0xFFE53935)
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(registro['usuario'].toString()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
