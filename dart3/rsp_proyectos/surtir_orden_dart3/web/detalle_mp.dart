// ignore_for_file: non_constant_identifier_names

library DetalleMP;

class DetalleMP {
  int tarimaOrigen = 0;
  String producto = "";
  String codigoBarras = "";
  double peso = 0.0;

  DetalleMP.fromMAP(Map AMap) {
    tarimaOrigen = AMap["tarima_origen"];
    producto = AMap["producto"];
    codigoBarras = AMap["codigobarras"];
    peso = AMap["peso"].toDouble();
  }
}

class DetalleMPTarima {
  int tarimaOrigen = 0;
  int cajas = 0;
  double kilos = 0.0;

  DetalleMPTarima.fromMAP(Map AMap) {
    tarimaOrigen = AMap["tarima_origen"];
    cajas = AMap["cajas"];
    kilos = AMap["kilos"].toDouble();
  }
}
