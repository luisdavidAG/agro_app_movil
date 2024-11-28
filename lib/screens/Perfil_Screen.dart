import 'package:appgomarket/config.dart';
import 'package:appgomarket/screens/editar_Perfil.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OwnerProfilePage extends StatefulWidget {
  final int idUsuario;

  const OwnerProfilePage({Key? key, required this.idUsuario}) : super(key: key);

  @override
  State<OwnerProfilePage> createState() => _OwnerProfilePageState();
}

class _OwnerProfilePageState extends State<OwnerProfilePage> {
  late Map<String, dynamic> usuario;
  bool isLoading = true; // Indicador de carga

  @override
  void initState() {
    super.initState();
    _obtenerInformacionUsuario(); // Carga inicial
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _obtenerInformacionUsuario(); // Actualizar datos al regresar a esta pantalla
  }

  Future<void> _obtenerInformacionUsuario() async {
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
                jsonResponse["usuario"]; // Guarda la información del usuario
            isLoading = false; // Deja de cargar
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
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
              flex: 2,
              child: _TopPortion(
                usuario: usuario,
              )),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    '${usuario["nombre"]} ${usuario["apellido_paterno"]} ${usuario["apellido_materno"]}',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _ProfileInfoRow(
                    usuario: usuario,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            // Navegar a la pantalla de edición y esperar a que regrese
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditarUsuarioPage(
                                  usuario: usuario,
                                  idUsuario: widget.idUsuario,
                                ),
                              ),
                            );
                            // Actualizar la información del usuario al regresar
                            _obtenerInformacionUsuario();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF4CAF50), // Verde vibrante
                                  Color(0xFF81C784), // Verde suave
                                ],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26, // Sombra tenue
                                  offset: Offset(0, 4),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  "Editar Perfil",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
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

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({Key? key, required this.usuario}) : super(key: key);

  final Map<String, dynamic> usuario;

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: 150, // Ajusta la altura según necesites
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2C5364), // Azul oscuro
            Color(0xFF0F2027), // Gris azulado oscuro
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _singleItem(
                  context,
                  "Área",
                  usuario["area"] ?? "N/A",
                ),
              ),
              const VerticalDivider(thickness: 1, color: Colors.grey),
              Expanded(
                child: _singleItem(
                  context,
                  "Rol",
                  usuario["rol"] ?? "N/A",
                ),
              ),
            ],
          ),
          const Divider(
              thickness: 1, color: Colors.grey), // Separador entre filas
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _singleItem(
                  context,
                  "Número",
                  usuario["num_telefono"] ?? "N/A",
                ),
              ),
            ],
          ),
          const Divider(
              thickness: 1, color: Colors.grey), // Separador entre filas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _singleItem(
                  context,
                  "Usuario",
                  usuario["usuario"] ?? "N/A",
                ),
              ),
              const VerticalDivider(thickness: 1, color: Colors.grey),
              Expanded(
                child: _singleItem(
                  context,
                  "Contraseña",
                  usuario["contrasena"] ?? "N/A",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _singleItem(BuildContext context, String title, String value) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.w400, fontSize: 12, color: Colors.white),
          )
        ],
      );
}

class ProfileInfoItem {
  final String title;
  final int value;
  const ProfileInfoItem(this.title, this.value);
}

class _TopPortion extends StatelessWidget {
  final Map<String, dynamic> usuario;

  const _TopPortion({Key? key, required this.usuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String initials = usuario['nombre'] != null && usuario['nombre'].isNotEmpty
        ? usuario['nombre'].substring(0, 2).toUpperCase()
        : 'NA'; // Asegúrate de manejar nombres vacíos

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 50),
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E88E5), // Azul mediano
                  Color(0xFFBBDEFB), // Azul claro
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              )),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 150,
            height: 150,
            child: CircleAvatar(
              backgroundColor: Colors.blue.shade700,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
