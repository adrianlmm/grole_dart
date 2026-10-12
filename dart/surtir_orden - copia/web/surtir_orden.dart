import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:intl/intl.dart' as intl;
import 'OrdenProduccion.dart';
import 'OrdenPP.dart';
import 'dart:json' as json;
import 'dart:async';

String IdOrden = "";
OrdenProduccion POrdenProduccion = new OrdenProduccion();
ObservableList<OrdenMP> ListaOrdenPMP = new ObservableList<OrdenMP>();
@observable String FolioSalida = "-";

String ObtenerIdOrden(){
  String p_query_string = window.location.search;
  String p_orden = p_query_string.split("=")[1];
  return p_orden;
}

void ObtenerOrdenProduccion(String AId){
  IdOrden = AId;
  String pUrl = 'http://localhost:8031/rest/ordenp/OrdenProduccion_obtener/${AId}';
  
  HttpRequest.getString(pUrl, onProgress: null).then((data){
        print(data);
        POrdenProduccion = new OrdenProduccion.FromJSON(data);
        print(POrdenProduccion.estado);
    }).then((String Data) {
      
      String pUrl = 'http://localhost:8031/rest/ordenp/ordenmp_obtener_lista/${POrdenProduccion.id.toString()}';
      HttpRequest.getString(pUrl, onProgress: null).then((String Data){
        
      var pLista = json.parse(Data);
      
      for (var item in pLista){
        ListaOrdenPMP.add(new OrdenMP.FromMap(item));
      }
      }).then((String Data){
        HttpRequest.getString(pUrl, onProgress: null).then((String Data) => DespliegaEntidad(POrdenProduccion));         
      });
    });
}

void DespliegaEntidad(OrdenProduccion AOrdenProduccion){
  document.query("#id").value              = AOrdenProduccion.id.toString();
  document.query("#id_orden").value        = AOrdenProduccion.descripcion;
  document.query("#fecha").value           = AOrdenProduccion.fecha;
  document.query("#lote_produccion").value = AOrdenProduccion.lote_produccion.toString();
  document.query("#spanEstado").text       = AOrdenProduccion.estado;
}

OrdenProduccion ObtenerEntidad(){
  OrdenProduccion pOrdenProduccion = new OrdenProduccion();
  pOrdenProduccion.id              = int.parse(document.query("#id").value);
  pOrdenProduccion.id_usuario      = int.parse(document.query("#id_usuario").value);
  pOrdenProduccion.id_tipo         = int.parse(document.query("#id_tipo").value);
  pOrdenProduccion.descripcion     = document.query("#id_orden").value;
  pOrdenProduccion.fecha           = document.query("#fecha").value;
  pOrdenProduccion.lote_produccion = document.query("#lote_produccion").value;
  pOrdenProduccion.estado          = document.query("#spanEstado").text;
  
  return pOrdenProduccion;
}

void guardar(){
  
  Map pParametros = new Map();
  pParametros["id_usuario_embarques"] = document.query("#id_usuario_embarques").value;
  pParametros["id_salida_embarques"]  = FolioSalida;
  
  String pData    = json.stringify(pParametros);
  String pUrl     = 'http://localhost:8031/rest/ordenp/ordenmp_surtir/${IdOrden}';
  Map<String, String> headers = new Map<String, String>();
  headers["content-type"] = "application/json";
  
  HttpRequest.request(pUrl, method: "PUT", requestHeaders:  headers , sendData:  pData).then((HttpRequest request){
    print(request.responseText);
   }).then((request){
      //window.alert("Se guardo orden de producción");
     // window.location.href = "/ordenes_produccion";
   });
}

void cancelar(){
  if (window.confirm("¿Cancelar captura?")){
    window.location.href = "/ordenes_produccion";
  }
}

void agregar(){
   document.query("#mdlAgregarProductos").xtag.show();
   document.query("#pClave").focus();
}

void agregar_mp(){
   document.query("#mdlAgregarProductosMP").xtag.show();
   document.query("#mClave").focus();
}

void seleccionar_salida(){
  
  OrdenMP pOrdenPP = new OrdenMP(); 
  
  pOrdenPP.producto    = query("#pClave").value;
  pOrdenPP.descripcion = query("#pDescripcion").value;
  pOrdenPP.kilos       = double.parse(query("#pKilos").value);
  
  if (pOrdenPP.descripcion.trim().length == 0){
    window.alert("El producto no es válido");
    query("#pClave").focus();
    return;
  }
  
  if (pOrdenPP.kilos <= 0){
    window.alert("Los kilos no son válidos");
    query("#pKilos").focus();
    return;
  }

  FolioSalida = query("#pClave").value;
  
  query("#pClave").value       = "";
  query("#pDescripcion").value = "";
  query("#pKilos").value       = "0.0";
  
  document.query("#mdlAgregarProductos").xtag.hide();
  
  String pUrl = "http://localhost:8031/embarques/obtener_detalle_productos_salida/${FolioSalida}";
  
  HttpRequest.getString(pUrl).then((String Data){
    
    var pLista = json.parse(Data);
    
    for(var item in pLista){
      OrdenMP pOrdenMp = ListaOrdenPMP.where((OrdenMP x) => x.producto == item["producto"]).toList()[0];
      
      if (pOrdenMp != null){
        pOrdenMp.surtido = item["kilos"];
      }
    }
  });
}

void eliminar_produccion(item){
  
  if (window.confirm("¿Eliminar Producción?")){
    ListaOrdenPMP.remove(item);
  }
  
}

void despliega_salida(){
  
  String pSalida = document.query("#pClave").value;
  String pUrl = "http://localhost:8031/embarques/obtener_salida/${pSalida}";
  
  HttpRequest.getString(pUrl).then((data){
    
    var pMap = json.parse(data);
    
    if (pMap["codigo"] != "0"){
      document.query("#pDescripcion").value = pMap["concepto"];
      document.query("#pKilos").value       = new intl.NumberFormat("###0.00").format(pMap["kilos"]);
    }
    else{
      window.alert("No existe la salida");
      document.query("#pClave").focus();
    }
  });
}

void despliega_producto_mp(){
  
  String pProducto = document.query("#mClave").value;
  String pUrl = "http://localhost:8031/rest/productos/obtener_descripcion/${pProducto}";
  
  HttpRequest.getString(pUrl).then((data){
    
    var pMap = json.parse(data);
    
    String pCodigo = pMap["clave"];
    
    if (pMap["clave"] != "0"){
      document.query("#mDescripcion").value = pMap["descripcion"];
    }
    else{
      window.alert("No existe el producto");
      document.query("#mClave").focus();
    }
      
  });
  
}

void main() {
  ObtenerOrdenProduccion(ObtenerIdOrden());
  
  document.query("#mdlAgregarProductos").classes.remove("hiden");
  
  Timer.run(()=>document.query("#id_orden").focus());  
}