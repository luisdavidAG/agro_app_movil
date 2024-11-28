import 'dart:ui';
import 'dart:convert';
import 'package:appgomarket/config.dart';
import 'package:appgomarket/screens/home_Screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class loginScrenn extends StatefulWidget {
  const loginScrenn({super.key});

  @override
  State<loginScrenn> createState() => _loginScrennState();
}

class _loginScrennState extends State<loginScrenn> {
  final FocusNode _usuarioFocusNode = FocusNode();
  final FocusNode _contrasenaFocusNode = FocusNode();
  bool _obscureText = true;
  bool _isLoading = false; // Estado de carga

  final _usuarioController = TextEditingController();
  final _contrasenaController = TextEditingController();

  @override
  void dispose() {
    _usuarioFocusNode.dispose();
    _contrasenaFocusNode.dispose();
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _validarYIngresar(
      BuildContext context, String usuario, String contrasena) async {
    setState(() {
      _isLoading = true; // Activar indicador de carga
    });

    try {
      final url =
          AppConfig.getApiUrl("ServidorAgroFrios/Usuario/buscar_usuario.php");
      final uri = Uri.parse(url);

      final response = await http.post(uri, body: {
        "usuario": usuario,
        "contrasena": contrasena,
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse["success"]) {
          if (jsonResponse["usuario"]["rol"] == "Dueño") {
            final idUsuario = jsonResponse["usuario"]["id_usuario"];
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => home_screen(
                  idUsuario:
                      idUsuario is int ? idUsuario : int.parse(idUsuario),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No tienes permisos para acceder.")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    jsonResponse["message"] ?? "Credenciales incorrectas.")),
          );
        }
      } else {
        throw Exception("Error en el servidor: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Desactivar indicador de carga
      });
    }
  }

  void _validarCampos() {
    final usuario = _usuarioController.text.trim();
    final contrasena = _contrasenaController.text.trim();

    if (usuario.isEmpty || contrasena.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Campos vacíos"),
          content: const Text("Por favor, completa todos los campos."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      _validarYIngresar(context, usuario, contrasena);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size pantalla = MediaQuery.of(context).size;

    return Scaffold(
        body: Stack(
      children: [
        Container(
          height: double.infinity,
          width: pantalla.width,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2b77a4), // Azul
                Color(0xFFF1F8E9), // Verde claro
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.only(top: 100, left: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola! \nBienvenido a',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Agrofrios Del Oriente',
                  style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 300),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0))),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
              child: ListView(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Campo Usuario
                      TextField(
                        focusNode: _usuarioFocusNode,
                        controller: _usuarioController,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value) {
                          FocusScope.of(context).requestFocus(
                              _contrasenaFocusNode); // Cambia al siguiente campo
                        },
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                        decoration: const InputDecoration(
                          suffixIcon: Icon(
                            Icons.check,
                            color: Color(0xFF2b77a4),
                          ),
                          labelText: 'Usuario',
                          labelStyle: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2b77a4),
                          ),
                          border: UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF2b77a4),
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF008000),
                              width: 2.0,
                            ),
                          ),
                        ),
                        cursorColor: const Color(0xFF2b77a4),
                      ),

                      const SizedBox(height: 20),

                      // Campo Contraseña
                      TextField(
                        controller: _contrasenaController,
                        focusNode: _contrasenaFocusNode,
                        obscureText: _obscureText,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                        },
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Color(0xFF2b77a4),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          labelText: 'Contraseña',
                          labelStyle: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2b77a4),
                          ),
                          border: const UnderlineInputBorder(),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF2b77a4),
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF008000),
                              width: 2.0,
                            ),
                          ),
                        ),
                        cursorColor: const Color(0xFF2b77a4),
                      ),

                      const SizedBox(height: 20.0),

                      // Botón
                      SizedBox(
                        height: 50,
                        width: pantalla.width * .40,
                        child: ElevatedButton(
                          onPressed: _validarCampos,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: const EdgeInsets.all(0),
                          ),
                          child: Ink(
                            decoration: const BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Color(0xFF2b77a4), // Azul
                                  Color(0xFFF1F8E9), // Verde claro
                                ],
                                radius: 8,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30.0)),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 50.0),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    ));
  }
}
