class AppConfig {
  // Dirección IP del servidor
  static const String serverIP = "192.168.0.41";

  // Construye una URL con la dirección base
  static String getApiUrl(String direccionCarpeta) {
    return "http://$serverIP/$direccionCarpeta";
  }
}

//url para verificar empleado
//http://192.168.145.110/ServidorAgroFrios/buscarEmpleados/buscar_empleados.php
//http://192.168.0.15/ServidorAgroFrios/buscarEmpresas/buscar_empresas.php
//http://192.168.0.17/ServidorAgroFrios/CuartosFrios/CantPallet.php
//http://192.168.0.17/ServidorAgroFrios/CuartosConserva/Consultar_CuartosConserva1.php
//http://192.168.0.17/ServidorAgroFrios/CuartosConserva/Cant_pallets.php
//http://192.168.0.17/ServidorAgroFrios/buscarEmpleados/eliminarEmpleado.php
//http://192.168.0.17/ServidorAgroFrios/buscarEmpresas/verificar_empresa.php
//http://192.168.0.17/ServidorAgroFrios/buscarEmpresas/insertar_empresa.php