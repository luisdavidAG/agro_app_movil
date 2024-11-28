import 'package:appgomarket/Config.dart';
import 'package:appgomarket/screens/home_Screen.dart';
import 'package:appgomarket/widgets/Divider.dart';
import 'package:appgomarket/widgets/Empresa/EditarEmpresa.dart';
import 'package:appgomarket/widgets/Empresa/Form_AgrEmpresa.dart';
import 'package:appgomarket/widgets/Person_Screens/FeedBack_Empresas.dart';
import 'package:appgomarket/widgets/TuCuartosFrios/TuCuartosFrios.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TuEmpresasScreen extends StatefulWidget {
  final int idUsuario;
  const TuEmpresasScreen({super.key, required this.idUsuario});

  @override
  _TuEmpresasScreenState createState() => _TuEmpresasScreenState();
}

class _TuEmpresasScreenState extends State<TuEmpresasScreen> {
  final double paddingHorizontal = 30;
  final double paddingVertical = 25;

  List<dynamic> empresas = [];

  Map<String, dynamic>? usuario;
  bool isUserLoading = true; // Estado de carga del usuario
  bool isCompaniesLoading = true; // Estado de carga de empresas

  Future<void> cargarDatos() async {
    // Cargar información del usuario
    await obtenerInformacionUsuario();
    setState(() {
      isUserLoading = false; // Usuario cargado
    });

    // Cargar empresas
    await fetchEmpresas();
    setState(() {
      isCompaniesLoading = false; // Empresas cargadas
    });
  }

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  //eliminar empresa
  Future<bool> eliminarEmpresa(int idEmpresa) async {
    try {
      final url = AppConfig.getApiUrl(
          "ServidorAgroFrios/buscarEmpresas/eliminarEmpresa.php");
      final uri = Uri.parse(url);

      final Map<String, String> data = {
        'id_empresa': idEmpresa.toString(),
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
      print("Error al eliminar empresa: $e");
      return false;
    }
  }

  Future<void> mostrarDialogoConfirmacionEmpresa(
      BuildContext context, VoidCallback onConfirmar) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Seguro que quieres eliminar esta empresa?'),
          content: const Text(
            'Esta acción es irreversible y se perderán todos los datos asociados a esta empresa.',
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
                          TuEmpresasScreen(idUsuario: widget.idUsuario)),
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

  //obtener informacion del usuario y que cagarge al iniciar
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
        //si se regresar de trancaso te da error
      );
    }
  }

  //cargar empresas
  Future<void> fetchEmpresas() async {
    final url = AppConfig.getApiUrl(
        "ServidorAgroFrios/buscarEmpresas/buscar_empresas.php");
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        // Dentro de fetchEmpresas
        if (decodedResponse['success']) {
          setState(() {
            empresas = decodedResponse['data'];
          });
        } else {
          throw Exception("Error: ${decodedResponse['message']}");
        }
      } else {
        throw Exception("Error en la respuesta del servidor");
      }
    } catch (e) {
      setState(() {
        isCompaniesLoading = false;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size pantalla = MediaQuery.of(context).size;
    if (isUserLoading || isCompaniesLoading) {
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
                    : 'Cargando empresas...',
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
                                      ? 'Tus Empresas'
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

            //FeddBack Paralas empresas
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: FBEmpresas(),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: paddingHorizontal, vertical: paddingVertical),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        child: const Padding(
                          padding: EdgeInsets.only(
                              left: 10, bottom: 10, top: 10, right: 35),
                          child: Text(
                            'Aqui Tienes\nTus Empresas \nReguistradas',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ),
                      ),
                      Container(
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
                    ],
                  )),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (isCompaniesLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final empresa = empresas[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetalleEmpresaPage(
                              empresa: empresa,
                              heroTag: "empresa_${empresa['id_empresa']}",
                              idUsuario: widget.idUsuario,
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: "empresa_${empresa['id_empresa']}",
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          color: const Color(0xFF4790BC),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor: Colors.black,
                                          child: Icon(
                                            Icons.business,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          empresa['nombre'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        mostrarDialogoConfirmacionEmpresa(
                                          context,
                                          () async {
                                            final idEmpresa =
                                                empresa['id_empresa'] != null
                                                    ? int.tryParse(
                                                        empresa['id_empresa']
                                                            .toString())
                                                    : null;

                                            if (idEmpresa != null) {
                                              final eliminado =
                                                  await eliminarEmpresa(
                                                      idEmpresa);

                                              if (eliminado) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        "Empresa eliminada correctamente"),
                                                  ),
                                                );
                                                // Regresa a la pantalla anterior
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Error al eliminar la empresa: Verifica datos",
                                                    ),
                                                  ),
                                                );
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Error: ID de empresa no válido"),
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        minimumSize: const Size(
                                            30, 30), // Tamaño del botón
                                        padding: const EdgeInsets.all(0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              20), // Forma circular
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 20, // Tamaño del ícono
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  empresa['representante'] ??
                                      'Representante no registrado',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Correo: ${empresa['correo'] ?? 'Sin correo'}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: empresas.length,
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: paddingHorizontal, vertical: paddingVertical),
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
            ),
          ],
        ),
        // floatingActionButton: Padding(
        //   padding: const EdgeInsets.all(16),
        //   child: Container(
        //     height: 80,
        //     width: 80,
        //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(80)),
        //     child: FloatingActionButton(
        //       onPressed: () {
        //         //navega al formulario para poder agregar una nueva empresa
        //         Navigator.of(context).push(
        //           MaterialPageRoute(
        //               builder: (context) => FormAgrEmpresa(
        //                     idUsuario: widget.idUsuario,
        //                   )),
        //         );
        //       },
        //       elevation: 10.0,
        //       backgroundColor: const Color(0xFF58A73B),
        //       splashColor: const Color(0xFF4A90E2),
        //       child: const Icon(Icons.add, color: Colors.white),
        //       tooltip: 'Agregar Empresa',
        //     ),

        //   ),
        // ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Aquí navegas a la pantalla para agregar un nuevo empleado
            Navigator.of(context).push(
              MaterialPageRoute(
                //meti la id
                builder: (context) => FormAgrEmpresa(
                  idUsuario: widget.idUsuario,
                ),
              ),
            );
          },
          backgroundColor:
              const Color.fromARGB(255, 80, 150, 99), // Color del botón
          splashColor: const Color(0xFF4A90E2), // Efecto de clic
          tooltip:
              'Agregar Empresa', // Tooltip que aparece al mantener presionado
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

class DetalleEmpresaPage extends StatelessWidget {
  final int idUsuario;
  final Map<String, dynamic> empresa;
  final String heroTag;

  const DetalleEmpresaPage({
    super.key,
    required this.empresa,
    required this.heroTag,
    required this.idUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C), // Fondo oscuro para el diseño
      body: SafeArea(
        child: Column(
          children: [
            //Parte de ariba con borde redondeado
            Container(
              decoration: const BoxDecoration(
                  color: const Color(0xFF2b77a4),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40))),
              height: pantalla.height * .45,
              width: pantalla.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //cerrar
                  Row(
                    children: [
                      TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          label: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ))
                    ],
                  ),
                  //Titulo
                  Container(
                    width: pantalla.width * .90,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalles Empresa',
                          style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'Conoce mas a fondo tus empresas',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  Hero(
                    tag: heroTag,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 0.98),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutExpo,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: Container(
                              width: pantalla.width * .90,
                              height: pantalla.height * .25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey.shade800,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      empresa['nombre'],
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Representante: ${empresa['representante'] ?? 'No registrado'}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Correo: ${empresa['correo'] ?? 'Sin correo'}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Lista inferior similar al estilo de la imagen
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF2C2C2C), // Fondo gris oscuro
                ),
                child: ListView(
                  children: [
                    _buildListItem(
                      context,
                      icon: Icons.email,
                      title: "Contacto",
                      subtitle:
                          "Correo: ${empresa['correo'] ?? 'No registrado'}",
                    ),
                    _buildListItem(
                      context,
                      icon: Icons.business,
                      title: "Dirección",
                      subtitle:
                          "Dirección: ${empresa['direccion'] ?? 'No disponible'}",
                    ),
                    _buildListItem(
                      context,
                      icon: Icons.date_range,
                      title: "RFC",
                      subtitle:
                          "Clave del Registro Federal de Contribuyentes: ${empresa['rfc'] ?? 'No disponible'}",
                    ),
                    // Botones de editar y eliminar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Navegar a la página de edición
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => EditarEmpresaPage(
                                      idUsuario: idUsuario, empresa: empresa)),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle}) {
    //Perdir un onpresed a qui y asignarle a unos una funcion
    //si pido una funcion se pone el icono, y si no pues no
    //Mas o menos asi Bool(Funcion Onpreced
    //SE ve algo asi en ( icon, string , string , onpresed = false o true)
    return Card(
      color: const Color(0xFF3A3A3A), // Fondo de las tarjetas
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade700,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        // trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
      ),
    );
  }
}
