import 'package:appgomarket/config.dart';
import 'package:appgomarket/screens/tuEmpresas_Screnn.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FormAgrEmpresa extends StatefulWidget {
  final int idUsuario;
  const FormAgrEmpresa({super.key, required this.idUsuario});

  @override
  State<FormAgrEmpresa> createState() => _FormAgrEmpresaState();
}

class _FormAgrEmpresaState extends State<FormAgrEmpresa> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _rfcController = TextEditingController();
  final _correoController = TextEditingController();
  final _representanteController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _rfcController.dispose();
    _correoController.dispose();
    _representanteController.dispose();
    super.dispose();
  }

  // Widget para crear campos de texto reutilizables con validaciones específicas
  Widget _buildTextField(String hintText, TextEditingController controller,
      {bool isEmail = false, String? validationType}) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : validationType == 'direccion'
              ? TextInputType.streetAddress
              : TextInputType.text,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Por favor, complete este campo';
        }
        value = value.trim(); // Eliminar espacios innecesarios

        // Validaciones específicas según el tipo
        switch (validationType) {
          case 'nombre':
          case 'representante':
            if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$").hasMatch(value)) {
              return 'Solo se permiten letras y espacios';
            }
            break;

          case 'direccion':
            if (!RegExp(r"^[\w\s#.,áéíóúÁÉÍÓÚñÑ-]+$").hasMatch(value)) {
              return 'Formato de dirección no válido';
            }
            break;

          case 'rfc':
            if (!RegExp(r"^[A-Z0-9]{12}$").hasMatch(value)) {
              return 'El RFC debe tener 12 caracteres \n(letras mayúsculas y números)';
            }
            break;

          case 'correo':
            if (!RegExp(r"^[^@]+@[^@]+\.[^@]+$").hasMatch(value)) {
              return 'Por favor, ingrese un correo válido';
            }
            break;

          default:
            break; // Sin validación adicional
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

  // Verificar si ya existe una empresa con el mismo nombre
  Future<bool> verificarEmpresa(String nombre) async {
    try {
      // Construir URL para la solicitud
      final url = AppConfig.getApiUrl(
          "ServidorAgroFrios/buscarEmpresas/verificar_empresa.php");
      final uri = Uri.parse(url);

      // Crear el cuerpo de la solicitud
      final Map<String, String> data = {'nombre': nombre};

      // Realizar solicitud HTTP POST
      final response = await http.post(
        uri,
        body: jsonEncode(data),
        headers: {"Content-Type": "application/json"},
      );

      // Imprimir respuesta para depuración
      print('Respuesta del servidor: ${response.body}');

      // Verificar código de estado de la respuesta
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return false; // No hay duplicados
        } else {
          // Mostrar mensaje de error en caso de duplicado
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
          return true; // Empresa duplicada
        }
      } else {
        // Error en el servidor
        throw Exception("Error en el servidor: ${response.statusCode}");
      }
    } catch (e) {
      // Manejo de errores de conexión
      print('Error de conexión: empresa $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: empresa $e")),
      );
      return true; // Asumir duplicado en caso de error
    }
  }

  Future<void> _guardarEmpresa() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final url = AppConfig.getApiUrl(
            "ServidorAgroFrios/buscarEmpresas/insertar_empresa.php");
        final uri = Uri.parse(url);

        // Datos del formulario
        final Map<String, String> data = {
          'nombre': _nombreController.text.trim(), // Elimina espacios extra
          'direccion': _direccionController.text.trim(),
          'rfc': _rfcController.text.trim(),
          'correo': _correoController.text.trim(),
          'representante': _representanteController.text.trim(),
        };

        // Realizar solicitud POST
        final response = await http.post(uri,
            body: jsonEncode(data),
            headers: {"Content-Type": "application/json"});

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);

          if (jsonResponse["success"]) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(jsonResponse["message"])),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TuEmpresasScreen(
                  idUsuario: widget.idUsuario,
                ), // Cambiar a la pantalla que corresponda
              ),
            ); // Volver a la pantalla anterior
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(jsonResponse["message"])),
            );
          }
        } else {
          throw Exception(
              "Error en el servidor:no se encuantra${response.statusCode}");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error de conexión: insertar$e")),
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
          'Agregar Nueva Empresa',
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
                      "Agrega A Tus Empresas",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Recuerda primero pedir los datos",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Sección de información personal
                    const Text(
                      "Información General",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Nombre",
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
                      "Nombre de la Empresa",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField("Nombre", _nombreController,
                        validationType: 'nombre'),
                    const SizedBox(height: 15),

                    // Sección de contacto
                    const Text(
                      "Direccion",
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
                      "Ubicacion de la Empresa",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField("Dirección", _direccionController,
                        validationType: 'direccion'),
                    const SizedBox(height: 15),

                    // Sección de credenciales de usuario
                    const Text(
                      "Informacion Fiscal",
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
                      "Clave del Registro Federal de Contribuyentes (RFC)",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField("RFC", _rfcController,
                        validationType: 'rfc'),
                    const SizedBox(height: 15),

                    // Sección de rol/desempeño
                    const Text(
                      "Informacion Contacto",
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
                      "Correro del Representante",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField("Correo Electrónico", _correoController,
                        validationType: 'correo', isEmail: true),
                    const SizedBox(height: 15),
                    // Sección de rol/desempeño
                    const Text(
                      "Representante de la Empresa",
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
                      "Nombre del Representante",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                        "Nombre del Representante", _representanteController,
                        validationType: 'representante'),

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
                          onPressed: _guardarEmpresa,
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
