library ConsultaMP;

import 'package:web_ui/web_ui.dart';

@observable
class ConsultaMP{
    int id;
    int idOrden;
    String producto;
    String descripcion;
    double kilos;
    double surtido;
    DateTime fecha;
    int idSalida;
    
    ConsultaMP.fromMap(Map AMap){
        this.id          = AMap['id'];
        this.idOrden     = AMap['id_orden'];
        this.producto    = AMap['producto'];
        this.descripcion = AMap['descripcion'];
        this.kilos       = AMap['kilos'].toDouble();
        this.surtido     = AMap['surtido'].toDouble();
        //2013-06-29 00:00:00
        String pFechaStr = AMap['fecha'];
        pFechaStr        = pFechaStr.substring(0, 10); 
        this.fecha       = DateTime.parse(pFechaStr);
        this.idSalida    = AMap['id_salida_embarques'];
    }
}