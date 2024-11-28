import 'package:appgomarket/config.dart';
import 'package:appgomarket/screens/Perfil_Screen.dart';
import 'package:appgomarket/screens/Tu_CuartosFrios_Screen.dart';
import 'package:appgomarket/screens/login_Screen.dart';
import 'package:appgomarket/screens/tuCuartoConserva_Screen.dart';
import 'package:appgomarket/screens/tuEmpleados_Screen.dart';
import 'package:appgomarket/screens/tuEmpresas_Screnn.dart';
import 'package:appgomarket/widgets/Empresa/Carta_Empleados.dart';
import 'package:appgomarket/widgets/TuCuartosFrios/TuCuartosFrios.dart';
import 'package:appgomarket/widgets/Empresa/Empresa.dart';
import 'package:appgomarket/widgets/TuPromociones/Carta_CuartoConserva.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class home_screen extends StatefulWidget {
  final int idUsuario; // Solo la ID del usuario logueado

  const home_screen({super.key, required this.idUsuario});

  @override
  State<home_screen> createState() => _home_screenState();
}

class _home_screenState extends State<home_screen> {
  final double padings_H = 15; // Padding horizontal general
  final double padings_V = 25; // Padding vertical general
  final double contenido_PH = 25; // Padding interno del contenido
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Map<String, dynamic> usuario; // Información actualizada del usuario
  bool isLoading = true; // Indicador de carga

  @override
  void initState() {
    super.initState();
    _obtenerInformacionUsuario(); // Carga inicial
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _obtenerInformacionUsuario(); // Recarga cada vez que la pantalla es reconstruida
  }

  Future<void> _obtenerInformacionUsuario() async {
    setState(() {
      isLoading = true; // Muestra el indicador de carga mientras obtiene datos
    });

    try {
      final url = AppConfig.getApiUrl(
          "ServidorAgroFrios/Usuario/obtener_usuario.php?id_usuario=${widget.idUsuario}");
      final uri = Uri.parse(url);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse["success"]) {
          setState(() {
            usuario =
                jsonResponse["usuario"]; // Actualiza los datos del usuario
            isLoading = false; // Finaliza la carga
          });
        } else {
          throw Exception(
              jsonResponse["message"] ?? "Error al obtener usuario");
        }
      } else {
        throw Exception("Error en el servidor: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar usuario: $e")),
      );
      setState(() {
        isLoading = false; // Asegúrate de detener el indicador de carga
      });
      //areglar este error, Se produjo una excepción.
// FlutterError (This widget has been unmounted, so the State no longer has a context (and should be considered defunct).
// Consider canceling any active work during "dispose" or using the "mounted" getter to determine if the State is still active.)
    }
  }

  void _confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cerrar Sesión"),
          content: const Text("¿Estás seguro de que deseas cerrar sesión?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const loginScrenn()),
                ); // Redirige al login
              },
              child: const Text("Sí"),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _mostrarMensajeSalir(BuildContext context) async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Salir de la aplicación"),
        content: const Text("¿Estás seguro de que deseas salir?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // No salir
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Salir
            child: const Text("Sí"),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    Size pantalla = MediaQuery.of(context).size;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()), // Indicador de carga
      );
    }

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _mostrarMensajeSalir(context);
        return shouldPop;
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _drawer(), // Drawer actualizado
        body: CustomScrollView(
          slivers: [
            // SliverAppBar
            SliverAppBar(
              backgroundColor: const Color(0xFF2b77a4),
              expandedHeight: pantalla.height * 0.2,
              collapsedHeight: 100,
              floating: false,
              pinned: true,
              iconTheme: const IconThemeData(
                color:
                    Colors.white, // Cambia el color del icono de la hamburguesa
              ),
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double expansionFraction =
                      (constraints.maxHeight - kToolbarHeight) /
                          (pantalla.height * 0.2 - kToolbarHeight);
                  return FlexibleSpaceBar(
                    title: Row(
                      children: [
                        Text(
                          expansionFraction < 0.8
                              ? 'Agrofrios Del Oriente'
                              : 'Hola, \n${usuario["nombre"]}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: expansionFraction < 0.5 ? 14 : 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // SliverList para las secciones
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  // Sección de Tus Cuartos Fríos
                  _buildSection(
                    context,
                    pantalla,
                    title: 'Tus Cuartos Fríos',
                    widget: const TuCuartosFrios(),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TuCuartosFriosScreen(idUsuario: widget.idUsuario),
                      ),
                    ),
                  ),
                  // Sección de Tus Cuartos de Conserva
                  _buildSection(
                    context,
                    pantalla,
                    title: 'Tus Cuartos de Conserva',
                    widget: const TuCuartoConserva(),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TuCuartoConservaScreen(idUsuario: widget.idUsuario),
                      ),
                    ),
                  ),

                  // Sección de Tus Empleados
                  _buildSection(
                    context,
                    pantalla,
                    title: 'Tus Empleados',
                    widget: const TuEmpleados(),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TuEmpleadosScreen(idUsuario: widget.idUsuario),
                      ),
                    ),
                  ),
                  // Sección de Tus Empresas
                  _buildSection(
                    context,
                    pantalla,
                    title: 'Tus Empresas',
                    widget: const TusEmpresas(),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TuEmpresasScreen(
                          idUsuario: widget.idUsuario,
                        ),
                      ),
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

  Widget _drawer() {
    return Drawer(
      child: Column(
        children: [
          // TODO Cambiar el nombre y el correo según los datos del usuario logueado
          UserAccountsDrawerHeader(
            accountName: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Text(
                '${usuario["nombre"]} ${usuario["apellido_paterno"]} ${usuario["apellido_materno"]}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            accountEmail: Text(
              'Usuario: ${usuario["usuario"]}', // Usuario dinámico
              style: const TextStyle(fontSize: 16),
            ),
            currentAccountPicture: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OwnerProfilePage(idUsuario: widget.idUsuario),
                  ),
                ).then((actualizar) {
                  if (actualizar == true) {
                    // Si el perfil indica que hubo cambios, recarga los datos
                    _obtenerInformacionUsuario();
                  }
                });
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2b77a4), // Azul
                  Color(0xFFF1F8E9), // Verde claro
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
          // Lista de opciones del menú
          Expanded(
            child: ListView.separated(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(
                    _menuIcons[index],
                    color: const Color(0xFF2b77a4), // Color del ícono
                  ),
                  onTap: () {
                    _scaffoldKey.currentState
                        ?.openEndDrawer(); // Cierra el Drawer
                    if (_menuItems[index] == 'Cerrar Sesión') {
                      _confirmarCerrarSesion(
                          context); // Llama al diálogo de confirmación
                    } else if (_menuItems[index] == 'Cuartos Fríos') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TuCuartosFriosScreen(idUsuario: widget.idUsuario),
                        ),
                      );
                    } else if (_menuItems[index] == 'Cuartos Conserva') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TuCuartoConservaScreen(
                                idUsuario: widget.idUsuario)),
                      );
                    } else if (_menuItems[index] == 'Personal') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                TuEmpleadosScreen(idUsuario: widget.idUsuario)),
                      );
                    } else if (_menuItems[index] == 'Empresas') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                TuEmpresasScreen(idUsuario: widget.idUsuario)),
                      );
                    } else if (_menuItems[index] == 'Perfil') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OwnerProfilePage(idUsuario: widget.idUsuario),
                        ),
                      ).then((actualizar) {
                        if (actualizar == true) {
                          // Si el perfil indica que hubo cambios, recarga los datos
                          _obtenerInformacionUsuario();
                        }
                      });
                    }
                  },
                  title: Text(
                    _menuItems[index],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(
                thickness: 1,
                height: 1,
                color: Color.fromARGB(150, 158, 158, 158),
                endIndent: 5.0,
                indent: 20.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Lista de opciones del menú lateral
  final List<String> _menuItems = <String>[
    'Perfil',
    'Cuartos Fríos',
    'Cuartos Conserva',
    'Personal',
    'Empresas',
    'Cerrar Sesión'
  ];

  final List<IconData> _menuIcons = <IconData>[
    Icons.person,
    Icons.inventory,
    Icons.ac_unit_outlined,
    Icons.list,
    Icons.business,
    Icons.logout
  ];

  Widget _buildSection(
    BuildContext context,
    Size pantalla, {
    required String title,
    required Widget widget,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: pantalla.height * .30,
      width: pantalla.width,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Container(
              height: pantalla.height * .08,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: onPressed,
              child: widget,
            ),
          ),
        ],
      ),
    );
  }
}
