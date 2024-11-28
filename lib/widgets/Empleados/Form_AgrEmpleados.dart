import 'package:appgomarket/config.dart';
import 'package:appgomarket/screens/tuEmpleados_Screen.dart';
import 'package:appgomarket/widgets/Empleados/Dropdown.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FormAgrEmpleados extends StatefulWidget {
  final int idUsuario;
  const FormAgrEmpleados({super.key, required this.idUsuario});

  @override
  State<FormAgrEmpleados> createState() => _FormAgrEmpleadosState();
}

class _FormAgrEmpleadosState extends State<FormAgrEmpleados> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _apellidoPaternoController = TextEditingController();
  final _apellidoMaternoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _usuarioController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _rolController = TextEditingController();
  //String? _puestoSeleccionado; // Almacena el puesto seleccionado

  @override
  void dispose() {
    _nameController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _telefonoController.dispose();
    _usuarioController.dispose();
    _contrasenaController.dispose();
    _rolController.dispose();
    super.dispose();
  }

  Widget _buildTextField(String hintText, TextEditingController controller,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, complete este campo';
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
        hintText: hintText,
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

  Future<void> _guardarEmpleado() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final url = AppConfig.getApiUrl(
            "ServidorAgroFrios/buscarEmpleados/insertar_empleado.php");
        final uri = Uri.parse(url);

        // Datos del formulario
        final Map<String, String> data = {
          'nombre': _nameController.text,
          'apellido_paterno': _apellidoPaternoController.text,
          'apellido_materno': _apellidoMaternoController.text,
          'num_telefono': _telefonoController.text,
          'usuario': _usuarioController.text,
          'contrasena': _contrasenaController.text,
          'rol': _rolController.text,
        };

        // Realizar solicitud POST
        final response = await http.post(uri, body: jsonEncode(data), headers: {
          "Content-Type": "application/json",
        });

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);

          if (jsonResponse["success"]) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(jsonResponse["message"])),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      TuEmpleadosScreen(idUsuario: widget.idUsuario)),
            ); // Volver a la pantalla anterior
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(jsonResponse["message"])),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Cambia el color del icono de la hamburguesa
        ),
        title: const Text(
          'Agregar Nuevo Empleado',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2b77a4),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2b77a4),
                    Color(0xFF2b77a4),
                    Color(0xFF2b77a4),
                    Color(0xFF2b77a4), // Azul
                    Color.fromARGB(255, 231, 240, 221), // Verde claro
                  ],
                  // begin: Alignment.bottomCenter,
                  end: Alignment.topRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Agrega A Tus Empleados \nA Tu Empresa",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Primero pide los datos de tu empleado.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white60,
                      ),
                    ),

                    // Sección de información personal
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
                    _buildTextField("Nombre", _nameController),
                    const SizedBox(height: 15),
                    _buildTextField(
                        "Apellido Paterno", _apellidoPaternoController),
                    const SizedBox(height: 15),
                    _buildTextField(
                        "Apellido Materno", _apellidoMaternoController),
                    const SizedBox(height: 15),

                    // Sección de contacto
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
                      "Número de Teléfono",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField("Teléfono", _telefonoController),
                    const SizedBox(height: 15),

                    // Sección de credenciales de usuario
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
                      "Usuario y Contraseña",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField("Usuario", _usuarioController),
                    const SizedBox(height: 15),
                    _buildTextField("Contraseña", _contrasenaController,
                        isPassword: true),
                    const SizedBox(height: 15),

                    // Sección de rol/desempeño
                    const Text(
                      "Desempeño",
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
                      "Rol/Puesto",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownEmpleados(
                      puesto: _rolController.text.isNotEmpty
                          ? _rolController.text
                          : "Selecciona puesto", // Mostrar el texto inicial
                      onChanged: (nuevoPuesto) {
                        setState(() {
                          _rolController.text = nuevoPuesto ??
                              ""; // Actualizar el controlador con el valor seleccionado
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    // Botones de acción
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "Cancelar",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 80, 150, 99),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: _guardarEmpleado,
                          child: const Text(
                            "Guardar",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
