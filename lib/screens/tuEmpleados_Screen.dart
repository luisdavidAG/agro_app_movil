import 'dart:convert';
import 'package:appgomarket/Config.dart';
import 'package:appgomarket/screens/home_Screen.dart';
import 'package:appgomarket/widgets/Empleados/EditarEmpleado.dart';
import 'package:appgomarket/widgets/Empleados/Form_AgrEmpleados.dart';
import 'package:appgomarket/widgets/Person_Screens/FeedBack_Personal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TuEmpleadosScreen extends StatefulWidget {
  final int idUsuario;

  const TuEmpleadosScreen({super.key, required this.idUsuario});

  @override
  State<TuEmpleadosScreen> createState() => _TuEmpleadosScreenState();
}

class _TuEmpleadosScreenState extends State<TuEmpleadosScreen> {
  final double padings_H = 30;
  final double padings_V = 25;

  List<dynamic> empleados = [];
  bool isLoading = true;

  Map<String, dynamic>? usuario;
  bool isUserLoading = true;
  bool isEmployeesLoading = true;

  Future<void> cargarDatos() async {
    await obtenerInformacionUsuario();
    setState(() {
      isUserLoading = false; // Usuario cargado
    });
    await fetchEmpleados();
    setState(() {
      isEmployeesLoading = false; // Empleados cargados
    });
  }

  // Cargar información del usuario
  Future<void> obtenerInformacionUsuario() async {
    try {
      final url = AppConfig.getApiUrl(
          "ServidorAgroFrios/Usuario/obtener_usuario.php?id_usuario=${widget.idUsuario}");
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse["success"]) {
          setState(() {
            usuario = jsonResponse["usuario"];
          });
        } else {
          throw Exception("Error: ${jsonResponse["message"]}");
        }
      }
    } catch (e) {
      print("Error al cargar usuario: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar usuario: $e')),
      );
    }
  }

  // Cargar lista de empleados
  Future<void> fetchEmpleados() async {
    final url = AppConfig.getApiUrl(
        "ServidorAgroFrios/buscarEmpleados/buscar_empleados.php");
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse['success']) {
          setState(() {
            empleados = decodedResponse['data'];
            isLoading = false;
          });
        } else {
          throw Exception("Error: ${decodedResponse['message']}");
        }
      }
    } catch (e) {
      print("Error al cargar empleados: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  //eliminar empleado
  Future<bool> eliminarEmpleado(int idUsuario) async {
    try {
      final url = AppConfig.getApiUrl(
          "ServidorAgroFrios/buscarEmpleados/eliminarEmpleado.php");
      final uri = Uri.parse(url);

      final Map<String, String> data = {
        'id_usuario': idUsuario.toString(),
      };

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: data,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse["success"];
      } else {
        throw Exception("Error en el servidor: ${response.statusCode}");
      }
    } catch (e) {
      print("Error al eliminar empleado: $e");
      return false;
    }
  }

//Este es la confirmacion para eliminar
  Future<void> mostrarDialogoConfirmacion(
      BuildContext context, VoidCallback onConfirmar) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Seguro que quieres eliminar al usuario?'),
          content: const Text(
            'Esta acción es irreparable y se perderán todos los datos relacionados con este usuario.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo sin confirmar
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Color del botón de eliminar
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TuEmpleadosScreen(idUsuario: widget.idUsuario)),
                ); // Cierra el diálogo
                onConfirmar(); // Ejecuta la acción de confirmación
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    cargarDatos(); // Inicia la carga de datos
  }

  @override
  Widget build(BuildContext context) {
    Size pantalla = MediaQuery.of(context).size;
    if (isUserLoading || isEmployeesLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(), // Indicador de carga
              const SizedBox(height: 20),
              Text(
                isUserLoading
                    ? 'Cargando información del usuario...'
                    : 'Cargando empleados...',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }
    return WillPopScope(
      onWillPop: () async {
        // Reemplaza la pantalla actual con la pantalla Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => home_screen(idUsuario: widget.idUsuario),
          ),
        );
        return false;
      },
      child: Scaffold(
        body: CustomScrollView(
          //controller: _scrollController,
          slivers: [
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
                                      ? 'Tus Empleados'
                                      : 'Hola \n${usuario?["nombre"] ?? "Usuario"}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: expansionFraction < 0.5 ? 18 : 24,
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
            //FEDDBCK DE ALGO
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: FBPersonal(),
              ),
            ),

            // const SliverToBoxAdapter(
            //   child: Padding(
            //     padding: EdgeInsets.all(16.0),
            //     child: FBPersonal(),
            //   ),
            // ),

            SliverToBoxAdapter(
              child: Padding(
                //key: _searchKey,
                padding: EdgeInsets.symmetric(
                    vertical: padings_V, horizontal: padings_H),
                child: Container(
                  height: pantalla.height * .08,
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Aqui Tienes\nA Todos Tus Empleados',
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      fontFamily: AutofillHints.creditCardSecurityCode,
                      fontSize: 24,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // SliverList
            isLoading
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : empleados.isEmpty
                    ? const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            "No hay empleados registrados",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final empleado = empleados[index];
                            return InkWell(
                              onTap: () async {
                                final idEliminado =
                                    await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PerfilEmpleadoPage(
                                      empleado: empleado,
                                      heroTag: empleado['id_usuario'],
                                      idUsuario: widget.idUsuario,
                                    ),
                                  ),
                                );

                                // Si se recibió un ID eliminado, actualiza la lista
                                if (idEliminado != null) {
                                  setState(() {
                                    empleados.removeWhere((empleado) =>
                                        empleado['id_usuario'] == idEliminado);
                                  });
                                }
                              },
                              child: Card(
                                color: const Color(0xFF4790BC),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      // Avatar del empleado
                                      Column(
                                        children: [
                                          Hero(
                                            tag: empleado['id_usuario'],
                                            child: CircleAvatar(
                                              radius: 30,
                                              backgroundColor:
                                                  const Color(0xFF2b77a4),
                                              child: Text(
                                                empleado['nombre'][0]
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFF1F8E9),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // SizedBox(
                                          //   height: 30,
                                          // ),
//                                           Container(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 12, vertical: 8),
//                                             decoration: BoxDecoration(
//                                               color: empleado['Rol'] ==
//                                                       'Administrador'
//                                                   ? const Color.fromARGB(
//                                                       200,
//                                                       255,
//                                                       204,
//                                                       0) // Color amarillo si el rol es Administrador
//                                                   : const Color.fromARGB(
//                                                       255, 86, 187, 91),
// // Color azul si el rol es Empleado
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                             ),
//                                             child: Text(
//                                               empleado['Rol'] ?? "No asignado",
//                                               style: const TextStyle(
//                                                 fontSize: 14,
//                                                 color: Colors.white,
//                                               ),
//                                             ),
//                                           ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      // Información del empleado
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${empleado['nombre']} ${empleado['apellido_paterno']} ${empleado['apellido_materno']}",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFF1F8E9),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Tel: ${empleado['num_telefono'] ?? 'No registrado'}",
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFFF1F8E9)),
                                            ),
                                            // const SizedBox(height: 8),
                                            // Text(
                                            //   "Usuario: ${empleado['usuario'] ?? 'No registrado'}",
                                            //   style:
                                            //       const TextStyle(fontSize: 14),
                                            // ),
                                            // const SizedBox(height: 8),
                                            // Text(
                                            //   "Contraseña: ${empleado['usuario'] ?? 'No registrado'}",
                                            //   style:
                                            //       const TextStyle(fontSize: 14),
                                            // ),
                                            const SizedBox(height: 15),
                                          ],
                                        ),
                                      ),

                                      // Botón de eliminar
                                      Container(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            mostrarDialogoConfirmacion(
                                              context,
                                              () async {
                                                final idUsuario = empleado[
                                                            'id_usuario'] !=
                                                        null
                                                    ? int.tryParse(
                                                        empleado['id_usuario']
                                                            .toString())
                                                    : null;

                                                if (idUsuario != null) {
                                                  final eliminado =
                                                      await eliminarEmpleado(
                                                          idUsuario);

                                                  if (eliminado) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            "Empleado eliminado correctamente"),
                                                      ),
                                                    );
                                                    setState(() {
                                                      empleados.removeWhere(
                                                          (e) =>
                                                              e['id_usuario'] ==
                                                              idUsuario);
                                                    });
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          "Error al eliminar empleado: Verifica datos",
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          "Error: ID de usuario no válido"),
                                                    ),
                                                  );
                                                }
                                              },
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            'Eliminar',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: empleados.length,
                        ),
                      ),
            const SliverToBoxAdapter(
                child: SizedBox(
              height: 100,
            )),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Aquí navegas a la pantalla para agregar un nuevo empleado
            Navigator.of(context).push(
              MaterialPageRoute(
                //meti la id
                builder: (context) => FormAgrEmpleados(
                  idUsuario: widget.idUsuario,
                ),
              ),
            );
          },
          backgroundColor:
              const Color.fromARGB(255, 80, 150, 99), // Color del botón
          splashColor: const Color(0xFF4A90E2), // Efecto de clic
          tooltip:
              'Agregar Empleado', // Tooltip que aparece al mantener presionado
          elevation: 10.0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20), // Forma redondeada personalizada
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28, // Tamaño del ícono
          ),
        ),
      ),
    );
  }
}

class PerfilEmpleadoPage extends StatefulWidget {
  final int idUsuario;
  final Map<String, dynamic> empleado;
  final String heroTag;

  const PerfilEmpleadoPage({
    super.key,
    required this.empleado,
    required this.heroTag,
    required this.idUsuario,
  });

  @override
  State<PerfilEmpleadoPage> createState() => _PerfilEmpleadoPageState();
}

class _PerfilEmpleadoPageState extends State<PerfilEmpleadoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Poner toda la informacion Aqui Menos usuario y contraseña
      appBar: AppBar(
        title: const Text(
          "Perfil del Empleado",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2b77a4),
        iconTheme: const IconThemeData(
          color: Colors.white, // Cambia el color del icono de la hamburguesa
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF4790BC), Color(0xff006df1)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Center(
                child: Hero(
                  tag: widget.heroTag,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      widget.empleado['nombre'][0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "${widget.empleado['nombre']} ${widget.empleado['apellido_paterno']} ${widget.empleado['apellido_materno']}",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: widget.empleado['Rol'] == 'Administrador'
                              ? const Color.fromARGB(200, 255, 204,
                                  0) // Color amarillo si el rol es Administrador
                              : const Color.fromARGB(255, 86, 187, 91),
// Color azul si el rol es Empleado
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.empleado['Rol'] ?? "No asignado",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Teléfono: ${widget.empleado['num_telefono'] ?? 'No registrado'}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  //const SizedBox(height: 20),
                  // Mostrar el rol del empleado
                  const SizedBox(height: 20),
                  // Mostrar el rol del empleado
                  Text(
                    "Area: ${widget.empleado['area'] ?? 'No asignado'}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Usuario: ${widget.empleado['usuario'] ?? 'No asignado'}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Contraseña: ${widget.empleado['contrasena'] ?? 'No asignado'}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),

                  // Botones de editar y eliminar
                  Padding(
                    padding: const EdgeInsets.only(right: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Navegar a la página de edición
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditarEmpleadoPage(
                                  empleado: widget.empleado,
                                  idUsuario: widget.idUsuario,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Editar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
