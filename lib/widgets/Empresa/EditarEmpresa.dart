import 'dart:async';

import 'package:appgomarket/config.dart';
//import 'package:appgomarket/screens/tuEmpleados_Screen.dart';
import 'package:appgomarket/screens/tuEmpresas_Screnn.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class EditarEmpresaPage extends StatefulWidget {
  final int idUsuario;
  final Map<String, dynamic> empresa;

  const EditarEmpresaPage(
      {super.key, required this.idUsuario, required this.empresa});

  @override
  State<EditarEmpresaPage> createState() => _EditarEmpresaPageState();
}

class _EditarEmpresaPageState extends State<EditarEmpresaPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de los campos de texto
  //ID usuario
  late TextEditingController _idEmpresaController;
  //personal
  late TextEditingController _nombreController;
  late TextEditingController _direccionController;
  late TextEditingController _rfcController;
  late TextEditingController _correoController;
  late TextEditingController _representanteControlle;

  @override
  void initState() {
    super.initState();
    // Inicializar controladores con los valores de empleado

    //ID USUARRIO
    _idEmpresaController =
        TextEditingController(text: widget.empresa['id_empresa']);
    //Personal
    _nombreController = TextEditingController(text: widget.empresa['nombre']);
    _direccionController =
        TextEditingController(text: widget.empresa['direccion']);
    _rfcController = TextEditingController(text: widget.empresa['rfc']);
    _correoController = TextEditingController(text: widget.empresa['correo']);
    //Empresa
    _representanteControlle =
        TextEditingController(text: widget.empresa['representante']);
  }

  @override
  void dispose() {
    // Limpiar controladores
    _idEmpresaController.dispose();
    _nombreController.dispose();
    _direccionController.dispose();
    _rfcController.dispose();
    _correoController.dispose();
    _representanteControlle.dispose();
    super.dispose();
  }

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

  //validar que no se parecen en otra empresa en el nombre
  // Verificar si ya existe una empresa con el mismo nombre
  // Future<bool> verificarEmpresa(String nombre) async {
  //   try {
  //     // Construir URL para la solicitud
  //     final url = AppConfig.getApiUrl(
  //         "ServidorAgroFrios/buscarEmpresas/verificar_empresa.php");
  //     final uri = Uri.parse(url);

  //     // Crear el cuerpo de la solicitud
  //     final Map<String, String> data = {'nombre': nombre};

  //     // Realizar solicitud HTTP POST
  //     final response = await http.post(
  //       uri,
  //       body: jsonEncode(data),
  //       headers: {"Content-Type": "application/json"},
  //     );

  //     // Imprimir respuesta para depuración
  //     print('Respuesta del servidor: ${response.body}');

  //     // Verificar código de estado de la respuesta
  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);
  //       if (jsonResponse['success'] == true) {
  //         return false; // No hay duplicados
  //       } else {
  //         // Mostrar mensaje de error en caso de duplicado
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text(jsonResponse['message'])),
  //         );
  //         return true; // Empresa duplicada
  //       }
  //     } else {
  //       // Error en el servidor
  //       throw Exception("Error en el servidor: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     // Manejo de errores de conexión
  //     print('Error de conexión: empresa $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error de conexión: empresa $e")),
  //     );
  //     return true; // Asumir duplicado en caso de error
  //   }
  // }

  // Función para guardar los cambios
  Future<void> _guardarCambios() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final url = AppConfig.getApiUrl(
            "ServidorAgroFrios/buscarEmpresas/update_empresa.php"); // URL de la API
        final uri = Uri.parse(url);

        // Datos que se enviarán al servidor
        final Map<String, String> data = {
          'id_empresa':
              widget.empresa['id_empresa'].toString(), // Convertir ID a String
          'nombre': _nombreController.text,
          'direccion': _direccionController.text,
          'rfc': _rfcController.text,
          'correo': _correoController.text,
          'representante': _representanteControlle.text,
        };

        // Realizar la solicitud HTTP POST
        final response = await http.post(uri, body: data);

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          if (jsonResponse["success"]) {
            // Actualización exitosa
            // Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Empresa actualizado con éxito.")),
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
      } // Volver atrás después de guardar
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
                          TuEmpresasScreen(idUsuario: widget.idUsuario)),
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

  // Widget _buildTextField(String label, TextEditingController controller) {
  //   return TextFormField(
  //     controller: controller,
  //     validator: (value) {
  //       if (value == null || value.isEmpty) {
  //         return 'Por favor, completa este campo';
  //       }
  //       return null;
  //     },
  //     style: const TextStyle(
  //       color: Colors.white70,
  //       fontSize: 16,
  //     ),
  //     decoration: InputDecoration(
  //       filled: true,
  //       fillColor: Colors.grey[800],
  //       hintText: label,
  //       hintStyle: const TextStyle(color: Colors.white60),
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(15),
  //         borderSide: BorderSide.none,
  //       ),
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(15),
  //         borderSide: const BorderSide(color: Colors.white),
  //       ),
  //       contentPadding:
  //           const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Empresa'),
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
                          _buildTextField(
                              "Correo Electrónico", _correoController,
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
                          _buildTextField("Nombre del Representante",
                              _representanteControlle,
                              validationType: 'representante'),

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
