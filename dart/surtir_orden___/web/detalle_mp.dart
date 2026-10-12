library DetalleMP;
import 'package:web_ui/web_ui.dart';

@observable
class DetalleMP{
    int tarimaOrigen;
    String producto;
    String codigoBarras;
    double peso;
 
    DetalleMP.fromMAP(Map AMap){
        this.tarimaOrigen = AMap["tarima_origen"];
        this.producto     = AMap["producto"];
        this.codigoBarras = AMap["codigobarras"];
        this.peso         = AMap["peso"].toDouble();
    }
}

@observable
class DetalleMPTarima{
  int tarimaOrigen;
  int cajas;
  double kilos;
  
  DetalleMPTarima.fromMAP(Map AMap){
    this.tarimaOrigen = AMap["tarima_origen"];
    this.cajas        = AMap["cajas"];
    this.kilos        = AMap["kilos"].toDouble();
  }
}