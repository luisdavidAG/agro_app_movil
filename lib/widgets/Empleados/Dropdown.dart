import 'package:flutter/material.dart';

class DropdownEmpleados extends StatefulWidget {
  final String puesto;
  final ValueChanged<String?> onChanged; // Callback para comunicar cambios

  const DropdownEmpleados({
    super.key,
    required this.puesto,
    required this.onChanged,
  });

  @override
  _DropdownEmpleadosState createState() => _DropdownEmpleadosState();
}

class _DropdownEmpleadosState extends State<DropdownEmpleados> {
  String? _selectedValue; // Variable para almacenar el valor seleccionado
  final List<String> _items = ['Administrador', 'Empleado'];
  // Iconos para cada opción
  final List<IconData> _iconos = [
    Icons.person_4_rounded, // Ícono para Administrador
    Icons.personal_video_rounded, // Ícono para Empleado
  ];

  @override
  void initState() {
    super.initState();
    _selectedValue =
        widget.puesto != "Selecciona puesto" && widget.puesto.isNotEmpty
            ? widget.puesto
            : null; // Establece el valor inicial si existe
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.grey[800], // Fondo oscuro
        borderRadius: BorderRadius.circular(15), // Bordes redondeados
        border: Border.all(color: Colors.white60), // Borde tenue
      ),
      child: DropdownButton<String>(
        value: _selectedValue,
        hint: Text(
          widget.puesto.isNotEmpty ? widget.puesto : "Selecciona puesto",
          style: const TextStyle(color: Colors.white60),
        ),
        isExpanded: true,
        dropdownColor: Colors.grey[900],
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        underline: Container(), // Sin línea subrayada
        items: List.generate(_items.length, (index) {
          return DropdownMenuItem<String>(
            value: _items[index],
            child: Row(
              children: [
                Icon(
                  _iconos[index],
                  color: Colors.white, // Color del ícono
                ),
                const SizedBox(width: 10), // Espacio entre ícono y texto
                Text(
                  _items[index],
                  style: const TextStyle(color: Colors.white), // Texto claro
                ),
              ],
            ),
          );
        }),
        onChanged: (newValue) {
          setState(() {
            _selectedValue = newValue; // Actualizar el valor seleccionado
          });
          widget.onChanged(newValue); // Notificar al padre del cambio
        },
      ),
    );
  }
}
