import 'dart:async';

import 'package:appgomarket/config.dart';
import 'package:appgomarket/screens/tuEmpleados_Screen.dart';
import 'package:appgomarket/widgets/Empleados/Dropdown.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class EditarEmpleadoPage extends StatefulWidget {
  final int idUsuario;
  final Map<String, dynamic> empleado;

  const EditarEmpleadoPage(
      {super.key, required this.empleado, required this.idUsuario});

  @override
  State<EditarEmpleadoPage> createState() => _EditarEmpleadoPageState();
}

class _EditarEmpleadoPageState extends State<EditarEmpleadoPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de los campos de texto
  //ID usuario
  late TextEditingController _idUsuarioController;
  //personal
  late TextEditingController _nombreController;
  late TextEditingController _apellidoPaternoController;
  late TextEditingController _apellidoMaternoController;
  //Contacto
  late TextEditingController _telefonoController;
  //Empresa
  late TextEditingController _rolController;
  late TextEditingController _areaController;
  //Usuario
  late TextEditingController _usuario_Controller;
  late TextEditingController _contrasena_Controller;

  @override
  void initState() {
    super.initState();
    // Inicializar controladores con los valores de empleado

    //ID USUARRIO
    _idUsuarioController =
        TextEditingController(text: widget.empleado['id_usuario']);
    //Personal
    _nombreController = TextEditingController(text: widget.empleado['nombre']);
    _apellidoPaternoController =
        TextEditingController(text: widget.empleado['apellido_paterno']);
    _apellidoMaternoController =
        TextEditingController(text: widget.empleado['apellido_materno']);
    _telefonoController =
        TextEditingController(text: widget.empleado['num_telefono']);
    //Empresa
    _rolController = TextEditingController(text: widget.empleado['Rol']);
    _areaController = TextEditingController(text: widget.empleado['area']);

    //Usuario
    _usuario_Controller =
        TextEditingController(text: widget.empleado['USUARIO']);
    _contrasena_Controller =
        TextEditingController(text: widget.empleado['CONTRASENA']);
  }

  @override
  void dispose() {
    // Limpiar controladores
    _idUsuarioController.dispose();
    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _telefonoController.dispose();
    _rolController.dispose();
    _areaController.dispose();
    _usuario_Controller.dispose();
    _contrasena_Controller.dispose();
    super.dispose();
  }

  //Funciona para verificar el usuario
  Future<bool> verificarUsuario(String nombre, String apellidoPaterno,
      String apellidoMaterno, String usuario, String contrasena) async {
    try {
      final url = AppConfig.getApiUrl(
          "ServidorAgroFrios/buscarEmpleados/verificar_usuario.php");
      final uri = Uri.parse(url);

      final Map<String, String> data = {
        'nombre': nombre,
        'apellido_paterno': apellidoPaterno,
        'apellido_materno': apellidoMaterno,
        'usuario': usuario,
        'contrasena': contrasena,
      };

      final response = await http.post(uri, body: jsonEncode(data), headers: {
        "Content-Type": "application/json",
      });

      // Imprimir la respuesta para depuración
      print('Respuesta del servidor: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['success'] == true) {
            return false; // Usuario no duplicado
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(jsonResponse['message'])),
            );
            return true; // Usuario duplicado
          }
        } catch (e) {
          print('Error al decodificar JSON: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Respuesta no válida del servidor')),
          );
          return true; // Tratar como duplicado en caso de error
        }
      } else {
        print('Error en la solicitud: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error del servidor: ${response.statusCode}')),
        );
        return true; // Tratar como duplicado
      }
    } catch (e) {
      print('Error de conexión: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
      return true; // Tratar como duplicado
    }
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Llamar a verificarUsuario antes de guardar los cambios
      final usuarioDuplicado = await verificarUsuario(
        _nombreController.text,
        _apellidoPaternoController.text,
        _apellidoMaternoController.text,
        _usuario_Controller.text,
        _contrasena_Controller.text,
      );

      if (usuarioDuplicado) {
        // Si se detecta un usuario duplicado, detener el proceso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya existe un empleado con esta información.'),
          ),
        );
        return;
      }

      try {
        final url = AppConfig.getApiUrl(
            "ServidorAgroFrios/buscarEmpleados/update_empleado.php"); // URL de la API
        final uri = Uri.parse(url);

        // Datos que se enviarán al servidor
        final Map<String, String> data = {
          'id_usuario': widget.empleado['id_usuario'].toString(),
          'nombre': _nombreController.text,
          'apellido_paterno': _apellidoPaternoController.text,
          'apellido_materno': _apellidoMaternoController.text,
          'num_telefono': _telefonoController.text,
          'Rol': _rolController.text,
          'usuario': _usuario_Controller.text,
          'contrasena': _contrasena_Controller.text,
        };

        // Realizar la solicitud HTTP POST
        final response = await http.post(uri, body: data);

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          if (jsonResponse["success"]) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Usuario actualizado con éxito.")),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TuEmpleadosScreen(
                  idUsuario: widget.idUsuario,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(jsonResponse["message"] ??
                    "Error al actualizar el empleado."),
              ),
            );
          }
        } else {
          throw Exception("Error en el servidor: ${response.statusCode}");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error de conexión: $e")),
        );
      }
    }
  }

  Future<void> mostrarDialogoConfirmacion(
      BuildContext context, VoidCallback onConfirmar) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Seguro que quieres guardar los cambios?'),
          content: const Text(
            "Confirma para guardar los cambios y regresar al inicio.",
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
                backgroundColor:
                    Colors.green.shade600, // Color del botón de confirmar
              ),
              onPressed: () async {
                // Navigator.of(context).pop(); // Cierra el diálogo
                await _guardarCambios(); // Ejecuta la lógica de guardar
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TuEmpleadosScreen(idUsuario: widget.idUsuario)),
                );
              },
              child: const Text(
                'Confirmar',
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
        title: const Text('Editar Empleado'),
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
                          Color(0xFF4A90E2),
                          Color.fromARGB(255, 102, 113, 180),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Edita Características de\nTu Personal",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Actualiza la información del usuario seleccionado.",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white60,
                            ),
                          ),

                          //Contenido del formulrio,darle estilo al formulario como por seccciones
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
                          const SizedBox(height: 20),
                          _buildTextField("Nombre", _nombreController),
                          const SizedBox(height: 15),
                          _buildTextField(
                              "Apellido Paterno", _apellidoPaternoController),
                          const SizedBox(height: 15),
                          _buildTextField(
                              "Apellido Materno", _apellidoMaternoController),
                          const SizedBox(height: 15),
                          const SizedBox(height: 30),

                          // Sección: Contacto
                          const Text(
                            "Contacto y Rol En la Empresa",
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
                          const SizedBox(height: 20),
                          _buildTextField("Teléfono", _telefonoController),
                          const SizedBox(height: 15),
                          const Text(
                            "Rol",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          //Titulo del  la empresa
                          DropdownEmpleados(
                            puesto: _rolController.text,
                            onChanged: (String? value) {},
                          ),
                          //_buildTextField("Rol", _rolController),
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
                          const SizedBox(height: 20),
                          _buildTextField("Usuario", _usuario_Controller),
                          const SizedBox(height: 15),
                          _buildTextField("Contraseña", _contrasena_Controller),
                          const SizedBox(height: 30),

                          //Botones en la parte inferior
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
                                onPressed: () {
                                  mostrarDialogoConfirmacion(
                                      context, _guardarCambios);
                                },
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
