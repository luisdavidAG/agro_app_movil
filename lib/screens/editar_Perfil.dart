import 'package:appgomarket/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditarUsuarioPage extends StatefulWidget {
  final int idUsuario;
  final Map<String, dynamic> usuario;

  const EditarUsuarioPage(
      {super.key, required this.usuario, required this.idUsuario});

  @override
  State<EditarUsuarioPage> createState() => _EditarUsuarioPageState();
}

class _EditarUsuarioPageState extends State<EditarUsuarioPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de los campos
  late TextEditingController _nombreController;
  late TextEditingController _apellidoPaternoController;
  late TextEditingController _apellidoMaternoController;
  late TextEditingController _telefonoController;
  late TextEditingController _usuarioController;
  late TextEditingController _contrasenaController;

  @override
  void initState() {
    super.initState();
    // Inicializar controladores con los datos del usuario
    _nombreController = TextEditingController(text: widget.usuario['nombre']);
    _apellidoPaternoController =
        TextEditingController(text: widget.usuario['apellido_paterno']);
    _apellidoMaternoController =
        TextEditingController(text: widget.usuario['apellido_materno']);
    _telefonoController =
        TextEditingController(text: widget.usuario['num_telefono']);
    _usuarioController = TextEditingController(text: widget.usuario['usuario']);
    _contrasenaController =
        TextEditingController(text: widget.usuario['contrasena']);
  }

  @override
  void dispose() {
    // Limpiar controladores
    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _telefonoController.dispose();
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  //metodo de guardar
  Future<void> _guardarCambios() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final url = AppConfig.getApiUrl(
            "ServidorAgroFrios/Usuario/update_perfil.php"); // URL de la API
        final uri = Uri.parse(url);

        // Datos que se enviarán al servidor
        final Map<String, String> data = {
          'id_usuario':
              widget.usuario['id_usuario'].toString(), // Convertir ID a String
          'nombre': _nombreController.text,
          'apellido_paterno': _apellidoPaternoController.text,
          'apellido_materno': _apellidoMaternoController.text,
          'num_telefono': _telefonoController.text,
          'usuario': _usuarioController.text,
          'contrasena': _contrasenaController.text,
        };

        // Realizar la solicitud HTTP POST
        final response = await http.post(uri, body: data);

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          if (jsonResponse["success"]) {
            // Actualización exitosa
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Usuario actualizado con éxito.")),
            );
            // Cierra la pantalla
          } else {
            // Error en la actualización
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(jsonResponse["message"] ?? "Error al actualizar.")),
            );
          }
        } else {
          // Error del servidor
          throw Exception("Error en el servidor: ${response.statusCode}");
        }
      } catch (e) {
        // Manejo de errores
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error de conexión: $e")),
        );
      }
    }
  }

  Widget _buildPhoneTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        final rawNumber = value?.replaceAll('-', '');
        if (rawNumber == null || rawNumber.isEmpty) {
          return 'Por favor, completa este campo';
        }
        if (rawNumber.length != 10) {
          return 'El número de teléfono debe tener 10 dígitos';
        }
        return null;
      },
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[800],
        hintText: label,
        hintStyle: const TextStyle(color: Colors.white60),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, completa este campo';
        }
        return null;
      },
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[800],
        hintText: label,
        hintStyle: const TextStyle(color: Colors.white60),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Tu Usuario',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white, // Cambia el color del icono de la hamburguesa
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1E88E5), // Azul mediano
                          Color(0xFFBBDEFB), // Azul claro
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Edita Información de\nTu Usuario",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "Actualiza los datos básicos del usuario.",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sección: Información Personal
                              const Text(
                                "Información Personal",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(
                                thickness: 2,
                                color: Colors.white24,
                              ),
                              const Text(
                                "Nombre y Apellidos",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 15),
                              _buildTextField("Nombre", _nombreController),
                              const SizedBox(height: 15),
                              _buildTextField("Apellido Paterno",
                                  _apellidoPaternoController),
                              const SizedBox(height: 15),
                              _buildTextField("Apellido Materno",
                                  _apellidoMaternoController),

                              const SizedBox(height: 30),

                              // Sección: Contacto
                              const Text(
                                "Contacto",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(
                                thickness: 2,
                                color: Colors.white24,
                              ),
                              const Text(
                                "Numero de Telefono",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 15),
                              _buildPhoneTextField(
                                  "Teléfono", _telefonoController),

                              const SizedBox(height: 30),

                              // Sección: Credenciales de Usuario
                              const Text(
                                "Credenciales de Usuario",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(
                                thickness: 2,
                                color: Colors.white24,
                              ),
                              const Text(
                                "Usuario y Contraeña",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 15),
                              _buildTextField("Usuario", _usuarioController),
                              const SizedBox(height: 15),
                              _buildTextField(
                                  "Contraseña", _contrasenaController),

                              const SizedBox(height: 30),
                            ],
                          ),
                          // Botones
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[700],
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  "Cancelar",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _guardarCambios,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  "Guardar",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
          ),
        ],
      ),
    );
  }
}
