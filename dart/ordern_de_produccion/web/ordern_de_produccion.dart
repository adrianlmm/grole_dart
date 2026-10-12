import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:intl/intl.dart' as intl;
import 'OrdenProduccion.dart';
import 'OrdenPP.dart';
import 'OrdenMP.dart';
import 'clases.dart';
import 'dart:json' as json;
import 'dart:async';


String IdOrden = "";
OrdenProduccion POrdenProduccion = new OrdenProduccion();
ObservableList<OrdenPP> ListaOrdenPP = new ObservableList<OrdenPP>();
ObservableList<OrdenMP> ListaOrdenPMP = new ObservableList<OrdenMP>();
ObservableList<Receta> Recetas = new ObservableList<Receta>();
ObservableList<Clase> ListaClases = new ObservableList<Clase>();
int IndiceMP = 130;
StreamSubscription EventoCambiarCajas = null;

class Receta{
  int id;
  String descripcion;
}

String ObtenerIdOrden(){
  String p_query_string = window.location.search;
  String p_orden = p_query_string.split("=")[1];
  return p_orden;
}

void ObtenerOrdenProduccion(String AId){
  String pUrl = 'http://localhost:8031/rest/ordenp/OrdenProduccion_obtener/${AId}';
  
  HttpRequest.getString(pUrl, onProgress: null).then((data){
        print(data);
        POrdenProduccion = new OrdenProduccion.FromJSON(data);
        print(POrdenProduccion.estado);
    }).then((String Data) {
      
      String pUrl = 'http://localhost:8031/rest/ordenp/ordenpp_obtener_lista/${POrdenProduccion.id.toString()}';
      HttpRequest.getString(pUrl, onProgress: null).then((String Data){
        
      var pLista = json.parse(Data);
      
      for (var item in pLista){
        ListaOrdenPP.add(new OrdenPP.FromMap(item));
      }
      }).then((String Data){
      
        String pUrl = 'http://localhost:8031/rest/ordenp/ordenmp_obtener_lista/${POrdenProduccion.id.toString()}';
        HttpRequest.getString(pUrl, onProgress: null).then((String Data){
          
          var pLista = json.parse(Data);
          
          for (var item in pLista){
            ListaOrdenPMP.add(new OrdenMP.FromMap(item));
          }
        }).then((String Data) => DespliegaEntidad(POrdenProduccion));         
      });
    });
}

void cambiarCajas(){
  
}

void editaCajasProduccion(OrdenPP AItemOrden){
  
  document.query("#mdlEditaCajas").xtag.show();
  document.query("#impCajas").value = AItemOrden.cajas.toString();
  document.query("#impCajas").focus();
  (document.query("#impCajas") as InputElement).select();
  
  ButtonElement btnCambiarCajas = (querySelector("#btnCambiarCajas") as ButtonElement);
  
  if (EventoCambiarCajas != null){
    EventoCambiarCajas.cancel();
  }
  
  EventoCambiarCajas = btnCambiarCajas.onClick.listen((_){
    
      try{
        AItemOrden.cajas = int.parse((document.query("#impCajas").value));
      }
      catch(Exception){
        AItemOrden.cajas = -1;
      }
      
      if (AItemOrden.cajas < 0){
          window.alert("El número de cajas no es válido");
          document.query("#impCajas").focus();
      }
      else{
        document.query("#mdlEditaCajas").xtag.hide();
      }
    
  });
  
  
}

void DespliegaEntidad(OrdenProduccion AOrdenProduccion){
  document.query("#id").value              = AOrdenProduccion.id.toString();
  document.query("#id_orden").value        = AOrdenProduccion.descripcion;
  document.query("#fecha").value           = AOrdenProduccion.fecha;
  document.query("#lote_produccion").value = AOrdenProduccion.lote_produccion.toString();
  document.query("#spanEstado").text       = AOrdenProduccion.estado;
  document.query("#inpClase").value        = AOrdenProduccion.clase.toString();
  document.query("#inpValida").value       = AOrdenProduccion.validar_productos;
  document.query("#inpPedimento").value    = AOrdenProduccion.pedimento.toString();
}

OrdenProduccion ObtenerEntidad(){
  OrdenProduccion pOrdenProduccion = new OrdenProduccion();
  pOrdenProduccion.id                = int.parse(document.query("#id").value);
  pOrdenProduccion.id_usuario        = int.parse(document.query("#id_usuario").value);
  pOrdenProduccion.id_tipo           = int.parse(document.query("#id_tipo").value);
  pOrdenProduccion.descripcion       = document.query("#id_orden").value;
  pOrdenProduccion.fecha             = document.query("#fecha").value;
  pOrdenProduccion.lote_produccion   = document.query("#lote_produccion").value;
  pOrdenProduccion.estado            = document.query("#spanEstado").text;
  pOrdenProduccion.clase             = int.parse(document.query("#inpClase").value);
  pOrdenProduccion.validar_productos = document.query("#inpValida").value;
  pOrdenProduccion.pedimento         = int.parse(document.query("#inpPedimento").value);
  
  return pOrdenProduccion;
}

void guardar(){
  
  POrdenProduccion = ObtenerEntidad();
  
  if (POrdenProduccion.descripcion.trim().length == 0){
    window.alert("Se necesita agregar una descripción");
    query("#id_orden").focus();
    return;
  }
  
  if (ListaOrdenPP.length == 0){
    window.alert("Se necesita agregar producción");
    return;
  }
  
  if (ListaOrdenPMP.length == 0){
    window.alert("Se necesita agregar materia prima");
    return;
  }
  
  String pData    = POrdenProduccion.ToJson();
  String pUrl     = 'http://localhost:8031/rest/ordenp/OrdenProduccion_insertar';
  String pUrlPP   = 'http://localhost:8031/rest/ordenp/ordenpp_insertar';
  String pUrlMP   = 'http://localhost:8031/rest/ordenp/ordenmp_insertar';
  String pMethod  = "POST";
  Map<String, String> headers = new Map<String, String>();
  headers["content-type"] = "application/json";
  
  if (POrdenProduccion.id > 0){
    pUrl    = 'http://localhost:8031/rest/ordenp/OrdenProduccion_actualizar/${POrdenProduccion.id}';
    print(pUrl);
    pMethod = "PUT";
  }
  
  HttpRequest.request(pUrl, method: pMethod, requestHeaders:  headers , sendData:  pData).then((HttpRequest request){
    
    OrdenProduccion pOrden = new OrdenProduccion.FromJSON(request.responseText);
    
    print(request.responseText);
    
    String pData = "[";
    String pDataMP = "[";
    
    for (int i = 0; i <= ListaOrdenPP.length - 1; i++){
         ListaOrdenPP[i].id_orden  = pOrden.id;
         pData += ListaOrdenPP[i].toJSON() + ",";
    }
    
    for (int i = 0; i <= ListaOrdenPMP.length - 1; i++){
      ListaOrdenPMP[i].id_orden = pOrden.id;
      pDataMP += ListaOrdenPMP[i].toJSON() + ",";
    }
    
    pData = pData.substring(0, pData.length - 1);
    pData += "]";
    
    pDataMP = pDataMP.substring(0, pDataMP.length - 1);
    pDataMP += "]";
    
    print("--------------------------------------");
    print("pData: " + pData);
    print("--------------------------------------");
    print(pDataMP);
    
    print(pDataMP);
    
    HttpRequest.request(pUrlPP, method: "POST", mimeType: "application/json", sendData: pData, onProgress: ((_){}) ).then((HttpRequest ARequest){
        print("...............");
        print(ARequest.responseText);
    });
        
    HttpRequest.request(pUrlMP, method: "POST", mimeType: "application/json", sendData: pDataMP, onProgress: ((_){}) ).then((HttpRequest ARequest){
      print("...............");
      print(ARequest.responseText);
    });

  }).then((request){
      window.alert("Se guardo orden de producción");
      window.location.href = "/ordenes_produccion";
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

void agrega_receta(int AReceta, double ACantidad, OrdenPP AOrden){
  
  var pUrl = "http://localhost:8031/obtener_detalle_receta/${AReceta.toString()}";
  
  bool pAgregado = false;
  
  HttpRequest.getString(pUrl).then((data){
    
    print("detalle receta ${data}");
    
    print("parseando");
    List pLista = json.parse(data);
    
    print("aquí");
    print("Tamaño lista: ${pLista.length.toString()}");
    
    for (var item in pLista){

      print(item);
      
      var pData = ListaOrdenPMP.where((OrdenMP x) => x.producto == item["producto"]).toList();
      var pOrdenMP = new OrdenMP();
      bool pExiste = true;
      
      print("1");
      
      if (pData.length > 0){
         pOrdenMP = pData.first;
      }
      else{
         pExiste = false;  
      }
      
      print("2");
      pOrdenMP.producto     = item["producto"];
      pOrdenMP.descripcion  = item["descripcion"];
      
      HttpRequest.getString("http://localhost:8031/obtener_inventario_producto/${item['producto']}").then((data){
            
            print("3");
            double pInventario = 0.0;
            
            try
            {
              pInventario = json.parse(data);
            }
            catch(ex)
            {
              pInventario = 0.0;
            }
            
            print("4");
            
            item['rendimiento'] = (200 - (item['rendimiento']  * 100)) / 100;
            
            print("4.1");
            
            /*if (!(pOrdenMP.kilos + (item["rendimiento"] * ACantidad) < pInventario)){
              
                print("4.2");
                new Timer(new Duration(milliseconds: 300), (){
                  print("4.3");
                  
                  window.alert("No hay suficiente inventario para el producto, ${item['producto']}, existencia ${pInventario.toString()}");
                  print("4.4");
                  
                });
            }*/
            
            print("5");
            
            if (pAgregado == false){
              ListaOrdenPP.add(AOrden);
              pAgregado = true;
            }
            
            print("6");
            var x = item["rendimiento"];
            x = x * ACantidad;
            pOrdenMP.kilos       += (item["rendimiento"] * ACantidad);
            
            if (pExiste == false){
              ListaOrdenPMP.add(pOrdenMP);
              
              print("7");
        }
      });
    }
    
  });
}

void agregar_produccion(){
  
  OrdenPP pOrdenPP = new OrdenPP(); 
  
  document.query("#pReceta").disabled = true;
  
  pOrdenPP.producto    = query("#pClave").value;
  pOrdenPP.descripcion = query("#pDescripcion").value;
  pOrdenPP.kilos       = double.parse(query("#pKilos").value);
  pOrdenPP.cajas       = int.parse(query("#pCajas").value, onError:(x){return -1;});
  pOrdenPP.receta      = int.parse(document.query("#pReceta").value, onError:(x){return -1;});
  
  if (pOrdenPP.descripcion.trim().length == 0){
    window.alert("El producto no es válido");
    query("#pClave").focus();
    return;
  }
  
  if (pOrdenPP.kilos < 0){
    window.alert("Los kilos no son válidos");
    query("#pKilos").focus();
    return;
  }
  
  if (pOrdenPP.cajas < 0){
    window.alert("Las cajas no son válidos");
    query("#pKilos").focus();
    return;
  }
    
  if (pOrdenPP.kilos > 0 && pOrdenPP.cajas > 0){
    window.alert("Solo se puede validar cajas o kilos, ponga uno de los dos en cero");
    query("#pKilos").focus();
    return;
  }
  
  if (ListaOrdenPP.where((OrdenPP x) => x.producto == pOrdenPP.producto).length > 0){
    window.alert("El producto ya se encuentra en la lista");
    query("#pClave").focus();
    return;
  }
  
  query("#pClave").value       = "";
  query("#pDescripcion").value = "";
  query("#pKilos").value       = "0.0";
  
  query("#pClave").focus();
  
  if (pOrdenPP.receta > 0){
    agrega_receta(pOrdenPP.receta, pOrdenPP.kilos, pOrdenPP);
  }
  else{
    ListaOrdenPP.add(pOrdenPP);
  }
  
  var pUrl = "http://localhost:8031/rest/obtener_sobrantes_producto/${pOrdenPP.producto}";
  
  HttpRequest.getString(pUrl).then((String AData){
    
      List pLista = json.parse(AData);
      
      if (pLista.length > 0){
        
        if (window.confirm("El producto tiene formula de producción, ¿agregar los productos?")){
          
          for (Map item in pLista){
              OrdenPP pOrdenPPTmp = new OrdenPP();
              pOrdenPPTmp.producto    = item['producto']; 
              pOrdenPPTmp.descripcion = item['descripcion'];
              pOrdenPPTmp.kilos       = 0.0;
              pOrdenPPTmp.cajas       = 0;
              pOrdenPPTmp.receta      = 0;
              ListaOrdenPP.add(pOrdenPPTmp);
          }
          
        }
        
      }
    
  });
}

void agregar_produccion_mp(){
  
  OrdenMP pOrdenMP = new OrdenMP(); 
  
  pOrdenMP.id          = IndiceMP;
  pOrdenMP.producto    = query("#mClave").value;
  pOrdenMP.descripcion = query("#mDescripcion").value;
  pOrdenMP.kilos       = double.parse(query("#mKilos").value);
  IndiceMP++;
  
  if (pOrdenMP.descripcion.trim().length == 0){
      window.alert("El producto no es válido");
      query("#pClave").focus();
      return;
  }
  
  if (pOrdenMP.kilos <= 0){
      window.alert("Los kilos no son válidos");
      query("#pKilos").focus();
      return;
  }
  
  if (ListaOrdenPMP.where((OrdenMP x) => x.producto == pOrdenMP.producto).length > 0){
      window.alert("El producto ya se encuentra en la lista");
      query("#pClave").focus();
      return;
  }
  
  HttpRequest.getString("http://localhost:8031/obtener_inventario_producto/${pOrdenMP.producto}").then((data){
    
      double pInventario = json.parse(data);
      
     // if (pOrdenMP.kilos < pInventario){
        ListaOrdenPMP.add(pOrdenMP);
    //  }
      //else{
      //  window.alert("No hay suficiente inventario para el producto, existencia ${pInventario.toString()}");
      //  ListaOrdenPMP.add(pOrdenM);
     // }
    
   });
  
  query("#mClave").value       = "";
  query("#mDescripcion").value = "";
  query("#mKilos").value       = "0.0";
  
  query("#mClave").focus();
}

void eliminar_produccion(item){
  
  if (window.confirm("¿Eliminar Producción?")){
    ListaOrdenPP.remove(item);
  }
  
}

void modificarMateriaPrima(OrdenMP AOrdenMP){
    document.query("#idProgramado").value  = AOrdenMP.id.toString();
    document.query("#pProgramadoMP").value = new intl.NumberFormat("#,##0.00").format((AOrdenMP.kilos));
    document.query("#mdlModificarMateriaPrima").xtag.show();
}

void cambiaProgramado(){
    int pId = int.parse(document.query("#idProgramado").value);
    String pProgramadoS = document.query("#pProgramadoMP").value;
    pProgramadoS = pProgramadoS.replaceAll(',', '');
    double pProgramado = double.parse(pProgramadoS).toDouble();
    print("aqui ${pId.toString()}");
    OrdenMP pData = ListaOrdenPMP.where((OrdenMP x) => x.id == pId).toList().first;
    pData.kilos = pProgramado;
    
    document.query("#mdlModificarMateriaPrima").xtag.hide();
}

void eliminar_produccion_mp(item){
  
  if (window.confirm("¿Eliminar Materia Prima?")){
    ListaOrdenPMP.remove(item);
  }
  
}

void despliega_producto(){
  
  String pProducto = document.query("#pClave").value;
  
  if (pProducto.length > 0){
  
    String pUrl = "http://localhost:8031/rest/productos/obtener_descripcion/${pProducto}";
    
    HttpRequest.getString(pUrl).then((data){
      
      var pMap = json.parse(data);
      
      String pCodigo = pMap["clave"];
      
      if (pMap["clave"] != "0"){
        document.query("#pDescripcion").value = pMap["descripcion"];
      }
      else{
        window.alert("No existe el producto");
        document.query("#pClave").focus();
      }
    }).then((data){
        String pUrlRecetas = "http://localhost:8031/recetas_producto/${pProducto}";
        
        print("...");
        print(pUrlRecetas);
        
        HttpRequest.getString(pUrlRecetas).then((data){
          
          Recetas.clear();
          
          document.query("#pReceta").disabled = false;
          
          List pLista = json.parse(data);
          
          if (pLista.length > 0){
            for (int i = 0; i<= pLista.length -1; i++){
              Receta pReceta = new Receta();
              pReceta.id          = pLista[i]['id'];
              pReceta.descripcion = pLista[i]['descripcion'];
              
              Recetas.add(pReceta);
            }
          }
          else{
             document.query("#pReceta").disabled = true;
          }
          
        });
    });
  }
  
}

void despliega_producto_mp(){
  
  String pProducto = document.query("#mClave").value;
  
  if (pProducto.length > 0){
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
}

void main() {
  var pUrl = "http://localhost:8031/rest/clase_ordenp_obtener_lista";
  
  HttpRequest.getString(pUrl).then((String Data){
    
    var pLista = json.parse(Data);
    
    for (Map item in pLista){
        ListaClases.add(new Clase.fromMap(item));
    }
      
    ObtenerOrdenProduccion(ObtenerIdOrden());  
  });
  
  document.query("#mdlAgregarProductos").classes.remove("hiden");
  document.query("#mdlAgregarProductosMP").classes.remove("hiden");
  document.query("#mdlModificarMateriaPrima").classes.remove("hiden");
  document.query("#mdlEditaCajas").classes.remove("hiden");
  
  Timer.run(()=>document.query("#id_orden").focus());  
}