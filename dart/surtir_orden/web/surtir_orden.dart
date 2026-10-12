import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:intl/intl.dart' as intl;
import 'OrdenProduccion.dart';
import 'OrdenPP.dart';
import 'detalle_mp.dart';
import 'salida_inventario.dart';
import 'dart:json' as json;
import 'dart:async';

String IdOrden = "";
OrdenProduccion POrdenProduccion = new OrdenProduccion();
ObservableList<OrdenMP> ListaOrdenPMP = new ObservableList<OrdenMP>();
ObservableList<OrdenMP> ListaOrdenPP  = new ObservableList<OrdenMP>();
ObservableList<Produccion> ListaProduccion = new ObservableList<Produccion>();
ObservableList<DetalleMP> ListaDetalle = new ObservableList<DetalleMP>();
ObservableList<DetalleMPTarima> ListaDetalleTarima = new ObservableList<DetalleMPTarima>();
double SurtidoTotal = 0.0;
StreamSubscription EventoCostoSalida = null;
StreamSubscription EventoCostoMaquila = null;
StreamSubscription EventoValorRescate = null;
bool editable = true;

@observable String FolioSalida = "-";

String ObtenerIdOrden(){
    String p_querySelector_string = window.location.search;
    String p_orden = p_querySelector_string.split("&")[0];
    p_orden = p_orden.split("=")[1];
    return p_orden;
}

void ObtenerOrdenProduccion(String AId){
  IdOrden = AId;
  String pUrl = 'http://localhost:8031/rest/ordenp/OrdenProduccion_obtener/${AId}';
  
  HttpRequest.getString(pUrl, onProgress: null).then((data){
        POrdenProduccion = new OrdenProduccion.FromJSON(data);
        
        DespliegaEntidad(POrdenProduccion);
        print(POrdenProduccion.estado);
    }).then((String Data) {
      
        String pUrl = 'http://localhost:8031/rest/ordenp/ordenmp_obtener_lista/${POrdenProduccion.id.toString()}';
        HttpRequest.getString(pUrl, onProgress: null).then((String Data){
          
        var pLista = json.parse(Data);
        double pTotalKilos   = 0.0;
        double pTotalSurtido = 0.0;
        double pTotalCosto   = 0.0;
        double pTotalImporte = 0.0;
				
        for (var item in pLista){
	        var pOdenMP = new OrdenMP.FromMap(item);
	        ListaOrdenPMP.add(pOdenMP);
	        pTotalKilos   += pOdenMP.kilos;
	        pTotalSurtido += pOdenMP.surtido;
	        pTotalCosto   += pOdenMP.costo_salida;
	        pTotalImporte += pOdenMP.importe_salida;
        }
        
        SurtidoTotal = pTotalSurtido;
        
        document.querySelector("#TotalKilosP").innerHtml   = new intl.NumberFormat("#,##0.00").format(pTotalKilos);
        document.querySelector("#TotalSurtidoP").innerHtml = new intl.NumberFormat("#,##0.00").format(pTotalSurtido);
        document.querySelector("#TotalCostoP").innerHtml   = "";//new intl.NumberFormat("#,##0.00").format();
        document.querySelector("#TotalImporteP").innerHtml = new intl.NumberFormat("#,##0.00").format(POrdenProduccion.costo_salida);
        
        String pUrl = 'http://localhost:8031/rest/ordenp/ordenpp_obtener_lista/${POrdenProduccion.id.toString()}';
        print("..w..${pUrl}");
        return HttpRequest.getString(pUrl);
      }).then((String Data){
        
        var pLista = json.parse(Data);
        
        for (var item in pLista){
          ListaOrdenPP.add(new OrdenMP.FromMap(item));
        }
        
      }).then((String Data){
        HttpRequest.getString(pUrl, onProgress: null).then((String Data) {
              print("-------------------------------------------------------------------------");
              print(Data);
              DespliegaEntidad(POrdenProduccion);
          });         
      });
    }).then((String Data){
  
          pUrl = 'http://localhost:8031/rest/ordenp/obtener_producido_orden/${AId}';
          
          HttpRequest.getString(pUrl).then((String Data){
              print("Producido");
              print(Data);
              List pLista = json.parse(Data);
              
              double pTotalProgramado     = 0.0;
              double pTotalProducido      = 0.0;
              double pTotalCajas          = 0.0;
              double pTotalCostoMaquila   = 0.0;
              double pTotalImporteMaquila = 0.0;
              double pTotalValorRescate   = 0.0;
              double pTotalImporteRescate = 0.0;
              
              for (Map item in pLista){
                  var pProduccion = new Produccion.fromMap(item);
                  ListaProduccion.add(pProduccion);
                  pTotalProgramado     += pProduccion.programado;
                  pTotalProducido      += pProduccion.producido;
                  pTotalCajas          += pProduccion.cajas;
                  pTotalCostoMaquila   += pProduccion.costo_maquila;
                  pTotalImporteMaquila += pProduccion.importe_maquila;
                  pTotalValorRescate   += pProduccion.valor_rescate;
                  pTotalImporteRescate += pProduccion.importe_rescate;
              }
              
              document.querySelector("#TotalProgramado").innerHtml      = new intl.NumberFormat("#,##0.00").format(pTotalProgramado);
              document.querySelector("#TotalProducido").innerHtml       = new intl.NumberFormat("#,##0.00").format(pTotalProducido);
              document.querySelector("#TotalCajas").innerHtml           = pTotalCajas.toString();
              document.querySelector("#TotalCostoMaquila").innerHtml    = new intl.NumberFormat("#,##0.00").format(pTotalCostoMaquila);
              document.querySelector("#TotalImporteMaquila").innerHtml  = new intl.NumberFormat("#,##0.00").format(pTotalImporteMaquila);
              document.querySelector("#TotalValorRescate").innerHtml    = new intl.NumberFormat("#,##0.00").format(pTotalValorRescate);
              document.querySelector("#TotalImporteRescate").innerHtml  = new intl.NumberFormat("#,##0.00").format(pTotalImporteRescate);
              
              for (Produccion item in ListaProduccion){
                  try
                  {
                       item.porcentaje = (item.producido / SurtidoTotal) * 100;
                  }
                  catch(ex){
                      item.porcentaje = 0.0;
                  }
              }
              
          });
        });
}

void ocultaBotones(){
  document.querySelector("#btnSalida").style.display = "none";
  document.querySelector("#btnGeneraSalida").style.display = "none";
}

void DespliegaEntidad(OrdenProduccion AOrdenProduccion){
    document.querySelector("#spanId").text           = AOrdenProduccion.id.toString();
    document.querySelector("#id_orden").value        = AOrdenProduccion.descripcion;
    document.querySelector("#fecha").value           = AOrdenProduccion.fecha;
    document.querySelector("#lote_produccion").value = AOrdenProduccion.lote_produccion.toString();
    document.querySelector("#spanEstado").text       = AOrdenProduccion.estado;
    document.querySelector("#spanFolioSalida").text  = ",Salida: ${AOrdenProduccion.id_salida}";
  
   if (AOrdenProduccion.estado == "Surtido"){
      document.querySelector("#btnSalida").text = "Cerrar";
   }
   
   if (AOrdenProduccion.estado == "Cerrado"){
     document.querySelector("#btnSalida").text = "Abrir";
     
     (document.querySelector("#btnGeneraSalida") as ButtonElement).classes.remove("hiden");
   }
   
   if (AOrdenProduccion.estado == "Generado" || AOrdenProduccion.estado == "Finalizado"){
     (document.querySelector("#btnSalida") as ButtonElement).classes.add("hiden");
   }
   
   if (AOrdenProduccion.estado == "Generado" || AOrdenProduccion.estado == "Finalizado"){
   	(document.querySelector("#btnSalida") as ButtonElement).classes.add("hiden");
   }
   
   if (AOrdenProduccion.estado == "Generado"){
  	(document.querySelector("#btnEntrada") as ButtonElement).classes.remove("hiden");
   }
   
   if (!editable){
      ocultaBotones();
   }
}

OrdenProduccion ObtenerEntidad(){
  OrdenProduccion pOrdenProduccion = new OrdenProduccion();
  pOrdenProduccion.id              = int.parse(document.querySelector("#id").value);
  pOrdenProduccion.id_usuario      = int.parse(document.querySelector("#id_usuario").value);
  print("id_usuario: ${pOrdenProduccion.id_usuario}");
  pOrdenProduccion.id_tipo         = int.parse(document.querySelector("#id_tipo").value);
  pOrdenProduccion.descripcion     = document.querySelector("#id_orden").value;
  pOrdenProduccion.fecha           = document.querySelector("#fecha").value;
  pOrdenProduccion.lote_produccion = document.querySelector("#lote_produccion").value;
  pOrdenProduccion.estado          = document.querySelector("#spanEstado").text;
  
  return pOrdenProduccion;
}

void programaOrdenProduccion(){
  
    if (window.confirm("¿Programar la orden de producción?") == false){
        return;
    }
  
    Map pParametros = new Map();

    String pProductos = "";
    for (OrdenMP item in ListaOrdenPP){
        pProductos += "${item.producto},";
    }
    
    pProductos = pProductos.substring(0, pProductos.length - 1);
    
    var pUrl = 'http://localhost:8031/rest/ordenp/programar_orden';
    String pData = "lote=${POrdenProduccion.lote_produccion.toString()}&productos=${pProductos}&fecha=${POrdenProduccion.fecha}&id_orden=${POrdenProduccion.id.toString()}&id_usuario=${document.querySelector("#id_usuario").value}";
    print(pData);
    
    Map<String, String> headers = new Map<String, String>();
    headers["content-type"] = "application/x-www-form-urlencoded";
    
    HttpRequest.request(pUrl, method: "POST", responseType: "application/json", sendData: pData, requestHeaders: headers).then((HttpRequest ARequest){
      
        print(ARequest.responseText);
        Map pResult = json.parse(ARequest.responseText);
        
        if (pResult["id"] == 0){
            window.alert(pResult["mensaje"]);
        }
        else{
            POrdenProduccion.estado            = "Programado";
            POrdenProduccion.id_programacion   = pResult["id"];
            document.querySelector("#spanEstado").text = "Programado";
            document.querySelector("#btnSalida").text = "DesProgramar";
            window.alert("Se programo la orden con éxito"); 
        }
    });
}

void desprogramaOrdenProduccion(){
  
  if (window.confirm("¿Desprogramar la orden de producción?") == false){
    return;
  }
  
  Map pParametros = new Map();

  String pProductos = "";
  for (OrdenMP item in ListaOrdenPP){
    pProductos += "${item.producto},";
  }
  
  pProductos = pProductos.substring(0, pProductos.length - 1);
  
  var pUrl = 'http://localhost:8031/rest/ordenp/desprogramar_orden';
  String pData = "id_orden=${POrdenProduccion.id.toString()}&id_programacion=${POrdenProduccion.id_programacion.toString()}";
  print(pData);
  
  Map<String, String> headers = new Map<String, String>();
  headers["content-type"] = "application/x-www-form-urlencoded";
  
  HttpRequest.request(pUrl, method: "POST", responseType: "application/json", sendData: pData, requestHeaders: headers).then((HttpRequest ARequest){
    
    print(ARequest.responseText);
    Map pResult = json.parse(ARequest.responseText);
    
    if (pResult["id"] == 0){
      window.alert(pResult["mensaje"]);
    }
    else{
      POrdenProduccion.estado            = "Surtido";
      document.querySelector("#spanEstado").text = "Surtido";
      document.querySelector("#btnSalida").text = "Programar";
      window.alert("Se desprogramo la orden con éxito"); 
    }
  });
}

void cerrarOrdenProduccion(){
  
  if (window.confirm("¿Cerrar la orden de producción?")){
    Map pParametros = new Map();
  
    String pData    = json.stringify(pParametros);
    String pUrl     = 'http://localhost:8031/rest/ordenp/ordenmp_cerrar/${IdOrden}';
    print(pUrl);
    Map<String, String> headers = new Map<String, String>();
    headers["content-type"] = "application/json";
    
    HttpRequest.request(pUrl, method: "PUT", requestHeaders:  headers , sendData:  pData).then((HttpRequest request){
      print(request.responseText);
      Map pResult = json.parse(request.responseText);
      print(pResult['result'].toString());
      if (pResult['result'] == 0){
          window.alert("Se cerro con éxito");
          
          String pFecha = "";
          List<String> pLista = window.location.search.split("&");
          pLista = pLista[1].split("=");
          pFecha = pLista[1];
          
          window.location.href = "/ordenes_produccion?fecha=${pFecha}";
      }
      else{
          print(pResult['mensaje'].toString());
          window.alert(pResult['mensaje'].toString());
      }
    });
  }
}

void abrirOrdenProduccion(){
  
  if (window.confirm("¿Abrir la orden de producción?")){
      Map pParametros = new Map();
    
      String pData    = json.stringify(pParametros);
      String pUrl     = 'http://localhost:8031/rest/ordenp/ordenmp_abrir/${IdOrden}';
      print(pUrl);
      Map<String, String> headers = new Map<String, String>();
      headers["content-type"] = "application/json";
      
      HttpRequest.request(pUrl, method: "PUT", requestHeaders:  headers , sendData:  pData).then((HttpRequest request){
        print(request.responseText);
        Map pResult = json.parse(request.responseText);
        print(pResult['result'].toString());
        if (pResult['result'] == 0){
            window.alert("Se abrió con éxito");
            String pFecha = "";
            List<String> pLista = window.location.search.split("&");
            pLista = pLista[1].split("=");
            pFecha = pLista[1];
            window.location.href = "/ordenes_produccion?fecha=${pFecha}";
        }
        else{
            print(pResult['mensaje'].toString());
            window.alert(pResult['mensaje'].toString());
        }
      });
  }
}

void guardar(){
  
  String pFecha = "";
  List<String> pLista = window.location.search.split("&");
  pLista = pLista[1].split("=");
  pFecha = pLista[1];
  
  if (POrdenProduccion.estado == "Surtido"){
      cerrarOrdenProduccion();      
  }
  else if (POrdenProduccion.estado == "Cerrado"){
      abrirOrdenProduccion();
  }
  else{
      if (window.confirm("¿Crear salida para orden de producción?")){
        Map pParametros = new Map();
        pParametros["id_usuario_embarques"] = document.querySelector("#id_usuario_embarques").value;
        pParametros["id_salida_embarques"]  = FolioSalida;
        
        String pData    = json.stringify(pParametros);
        String pUrl     = 'http://localhost:8031/rest/ordenp/ordenmp_surtir/${IdOrden}';
        print(pUrl);
        Map<String, String> headers = new Map<String, String>();
        headers["content-type"] = "application/json";
        
        HttpRequest.request(pUrl, method: "PUT", requestHeaders:  headers , sendData:  pData).then((HttpRequest request){
          print(request.responseText);
          Map pResult = json.parse(request.responseText);
          print(pResult['result'].toString());
          if (pResult['result'] == 0){
            window.alert("Se genero la salida ${pResult['salida'].toString()}");
            window.location.href = "/ordenes_produccion?fecha=${pFecha}";
          }
          else{
            print(pResult['mensaje'].toString());
            window.alert(pResult['mensaje'].toString());
          }
              
         }).then((request){
            //window.alert("Se guardo orden de producción");
           // window.location.href = "/ordenes_produccion";
         });
      }
  } 
}

void cancelar(){
  if (window.confirm("¿Cancelar captura?")){
    
    String pFecha = "";
    List<String> pLista = window.location.search.split("&");
    pLista = pLista[1].split("=");
    pFecha = pLista[1];
    
    window.location.href = "/ordenes_produccion?fecha=${pFecha}";
  }
}

void agregar(){
   document.querySelector("#mdlAgregarProductos").xtag.show();
   document.querySelector("#pClave").focus();
}

void agregar_mp(){
   document.querySelector("#mdlAgregarProductosMP").xtag.show();
   document.querySelector("#inpValorRescate").focus();
}

void capturaValorRescate(Produccion item){
  
  if (!editable){
    window.alert("No tiene derecho a modificar");
    return;
  } 
  
   document.querySelector("#mdlValorRescate").xtag.show();
   document.querySelector("#inpValorRescate").focus();
   
   ButtonElement btnElement =  document.querySelector("#btnValorRescateAceptar");
   
   if (EventoValorRescate != null){
      EventoValorRescate.cancel();
   }
   
   btnElement.onClick.listen((_){
     
      var pUrl  = "http://localhost:8031/rest/ordenp/actualiza_valor_rescate";
      Map pMap = new Map();
      
      double pValorRescate = 0.0;
      
      try{
        pValorRescate = double.parse((querySelector("#inpValorRescate") as InputElement).value);
      }
      catch(Exception){
        pValorRescate = -1.0;
      }
      
      if (pValorRescate < 0){
        window.alert("Valor de rescato no es válido");
        (querySelector("#inpValorRescate") as InputElement).focus();
        return;
      }
      
      pMap["valor_rescate"] = pValorRescate.toDouble();
      pMap["id_orden"] = item.id;
      
      String pData = json.stringify(pMap);
      
      HttpRequest.request(pUrl, method: "POST", sendData: pData).then((HttpRequest ARequest){
        
          item.valor_rescate = pValorRescate;
          document.querySelector("#mdlValorRescate").xtag.hide();
        
      });
      
     
   });
}

void GuardaValorRescate(){
  
}

void seleccionar_salida(){
  
  OrdenMP pOrdenPP = new OrdenMP(); 
  
  pOrdenPP.producto    = querySelector("#pClave").value;
  pOrdenPP.descripcion = querySelector("#pDescripcion").value;
  pOrdenPP.kilos       = double.parse(querySelector("#pKilos").value);
  
  if (pOrdenPP.descripcion.trim().length == 0){
    window.alert("El producto no es válido");
    querySelector("#pClave").focus();
    return;
  }
  
  if (pOrdenPP.kilos <= 0){
    window.alert("Los kilos no son válidos");
    querySelector("#pKilos").focus();
    return;
  }

  FolioSalida = querySelector("#pClave").value;
  
  querySelector("#pClave").value       = "";
  querySelector("#pDescripcion").value = "";
  querySelector("#pKilos").value       = "0.0";
  
  document.querySelector("#mdlAgregarProductos").xtag.hide();
  
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
  
  String pSalida = document.querySelector("#pClave").value;
  String pUrl = "http://localhost:8031/embarques/obtener_salida/${pSalida}";
  
  HttpRequest.getString(pUrl).then((data){
    
    var pMap = json.parse(data);
    
    if (pMap["codigo"] != "0"){
      
      
      (document.querySelector("#pDescripcion") as InputElement).value = pMap["concepto"];
      document.querySelector("#pKilos").value       = new intl.NumberFormat("###0.00").format(pMap["kilos"]);
    }
    else{
      window.alert("No existe la salida");
      document.querySelector("#pClave").focus();
    }
  });
}

void despliega_producto_mp(){
  
  String pProducto = document.querySelector("#mClave").value;
  String pUrl = "http://localhost:8031/rest/productos/obtener_descripcion/${pProducto}";
  
  HttpRequest.getString(pUrl).then((data){
    
    var pMap = json.parse(data);
    
    String pCodigo = pMap["clave"];
    
    if (pMap["clave"] != "0"){
      document.querySelector("#mDescripcion").value = pMap["descripcion"];
    }
    else{
      window.alert("No existe el producto");
      document.querySelector("#mClave").focus();
    }
      
  });
  
}

void detalleOrden(OrdenMP AOrdenMP){
  
  if (!editable){
    window.alert("No tiene derecho a modificar");
    return;
  }
  
  document.querySelector("#mdlAgregarCosto").xtag.show();
  document.querySelector("#mCosto").value = new intl.NumberFormat("###,0.00").format(AOrdenMP.costo_salida);
  (document.querySelector("#mCosto") as InputElement).select();
  document.querySelector("#mCosto").focus();
    
  bool pError = false;
  
  ButtonElement btnElement =  document.querySelector("#btnCostoAceptar");
  
  if (EventoCostoSalida != null){
    EventoCostoSalida.cancel();
  }
  
  EventoCostoSalida = btnElement.onClick.listen((_){
      AOrdenMP.costo_salida = double.parse(document.querySelector("#mCosto").value, (_){
          window.alert("El costo no es válido");
          document.querySelector("#mCosto").focus();
          pError = true;
      });
      
      if (!pError){
        
        AOrdenMP.importe_salida = AOrdenMP.surtido * AOrdenMP.costo_salida;
        
        String pUrl = "http://localhost:8031/rest/ordenp/actualizar_costo_salida/" + AOrdenMP.id.toString();
        String pData = '{"costo":' + AOrdenMP.costo_salida.toString() + ',"importe":' + AOrdenMP.importe_salida.toString() + '}';
        Map<String, String> headers = new Map<String, String>();
        headers["content-type"] = "application/x-www-form-urlencoded";
        
        HttpRequest.request(pUrl, method: "POST", responseType: "application/json", sendData: pData, requestHeaders: headers).then((HttpRequest ARequest){
          
            double pTotalCosto   = 0.0;
            double pTotalImporte = 0.0;
            
            for (OrdenMP item in ListaOrdenPMP){
                pTotalCosto   += item.costo_salida;
                pTotalImporte += item.importe_salida;
            }
  
            document.querySelector("#TotalCostoP").innerHtml = new intl.NumberFormat("###,0.00").format(pTotalCosto);
            document.querySelector("#TotalImporteP").innerHtml = new intl.NumberFormat("###,0.00").format(pTotalImporte);
            
            document.querySelector("#mdlAgregarCosto").xtag.hide();
          
        });        
          
      }
      
  });
}

void getCostoMaquila(){
    document.querySelector("#mdlCostoMaquila").xtag.show();
    document.querySelector("#mCostoMaquila").value = document.querySelector("#inpCostoMaquila").value;
    document.querySelector("#mCostoMaquila").focus();
    (document.querySelector("#mCostoMaquila") as InputElement).select();
}

void detalleProducido(Produccion AProduccion){

	var pUrl = "http://localhost:8031/tabla_detalle_producto_orden/${IdOrden}/${AProduccion.clave_producto}"; 

	HttpRequest.getString(pUrl).then((String Data){
	
		document.querySelector("#divDetalleProducido").innerHtml = Data;
	
	}).then((String Data) => (document.querySelector("#mdlDetalleProducido").xtag.show()));

}

void costoMaquila(Produccion AProduccion){
  
  if (!editable){
     window.alert("No tiene derecho a modificar");
     return;
  }
  
  document.querySelector("#mdlCostoMaquila").xtag.show();
  document.querySelector("#mCostoMaquila").value = new intl.NumberFormat("###,0.00").format(AProduccion.costo_maquila);
  (document.querySelector("#mCostoMaquila") as InputElement).select();
  document.querySelector("#mCostoMaquila").focus();
    
  bool pError = false;
  
  ButtonElement btnElement =  document.querySelector("#btnCostoMaquilaAceptar");
  
  if (EventoCostoMaquila != null){
    EventoCostoMaquila.cancel();
  }
  
  EventoCostoMaquila = btnElement.onClick.listen((_){
      AProduccion.costo_maquila = double.parse(document.querySelector("#mCostoMaquila").value, (_){
          window.alert("El costo de la maquila no es válido");
          document.querySelector("#mCostoMaquila").focus();
          pError = true;
      });
      
      if (!pError){
        
        AProduccion.importe_maquila = AProduccion.producido * AProduccion.costo_maquila;
        
        String pUrl = "http://localhost:8031/rest/ordenp/actualizar_costo_maquila/" + AProduccion.id.toString();
        String pData = '{"costo":' + AProduccion.costo_maquila.toString() + ',"importe":' + AProduccion.importe_maquila.toString() + '}';
        Map<String, String> headers = new Map<String, String>();
        headers["content-type"] = "application/x-www-form-urlencoded";
        
        HttpRequest.request(pUrl, method: "POST", responseType: "application/json", sendData: pData, requestHeaders: headers).then((HttpRequest ARequest){
          
          double pTotalCosto   = 0.0;
          double pTotalImporte = 0.0;
          
          for (Produccion item in ListaProduccion){
            pTotalCosto   += item.costo_maquila;
            pTotalImporte += item.importe_maquila;
          }
          
          document.querySelector("#TotalCostoMaquila").innerHtml   = new intl.NumberFormat("###,0.00").format(pTotalCosto);
          document.querySelector("#TotalImporteMaquila").innerHtml = new intl.NumberFormat("###,0.00").format(pTotalImporte);
          
          document.querySelector("#mdlCostoMaquila").xtag.hide();
          
        });
          
      }
      
  });
}

void detalladoTarima(int ATarima){
  
  var pUrl = "http://localhost:8031/rest/ordenp/obtener_detalle_mp_ordenp_tarima/${IdOrden}/${ATarima.toString()}";
  print(pUrl);
  
  HttpRequest.getString(pUrl).then((String Data){
    
    print(Data);
    
    List pLista = json.parse(Data);
    
    ListaDetalle.clear();
    
    for (Map item in pLista){
        ListaDetalle.add(new DetalleMP.fromMAP(item));
    }
    
    document.querySelector("#divDetalladoTarima").classes.toggle("oculto");
  });
}

void detalleOrdenTarima(){
  
  var pUrl = "http://localhost:8031/rest/ordenp/obtener_detalle_mp_ordenp_agrupado/${IdOrden}";
  print(pUrl);
  
  ListaDetalleTarima.clear();
  
  HttpRequest.getString(pUrl).then((String Data){
    
    print(Data);
    
    List pLista = json.parse(Data);
    
    print("limpiando ista");
    
    for (Map item in pLista){
      ListaDetalleTarima.add(new DetalleMPTarima.fromMAP(item));
    }
    
    print(ListaDetalleTarima.length);
    
    document.querySelector("#divDetalleTarima").classes.toggle("oculto");
  });
}

void cerrarDetalle(){
   document.querySelector("#divDetalle").classes.toggle("oculto", true);
}

void cerrarDetalleTarima(){
   document.querySelector("#divDetalleTarima").classes.toggle("oculto", true);
}

void cerrarDetalladoTarima(){
   document.querySelector("#divDetalladoTarima").classes.toggle("oculto", true);
}

void imprimir(){
    window.open("http://localhost:8031/get_surtido_orden/${IdOrden}", "surtido", "width: 400; heigth: 400px;");
}

void ActualizaSaldosSap(){
    if (window.confirm("¿Actualizar saldos?")){
        
        String pUrl = "";
        
        for (OrdenMP item in ListaOrdenPMP){
            pUrl = "http://192.168.0.11/WebFrontEnd/inventarios/ObtenerSaldoProducto?AProducto=${item.codigosap}&AAlmacen=01&AConexion=SolesProd";
            print(pUrl);
            
            HttpRequest.getString(pUrl).then((String Data){
          
                print(Data);
                Map pMap = json.parse(Data);
                item.saldo_sap = pMap['saldo'].toDouble();
                
                Map<String, String> headers = new Map<String, String>();
                headers["content-type"] = "application/x-www-form-urlencoded";
                
                String pUrlPost = "http://localhost:8031/rest/ordenp/actualiza_saldo_sap/${item.id}";
                print(pUrlPost);
                HttpRequest.request(pUrlPost, method: "POST", responseType: "application/json", sendData: Data, requestHeaders: headers);
            });                
        }
    }
}

void ActualizaCostoSap(){
  String pUrl = "";
  
  for (OrdenMP item in ListaOrdenPMP){
    
    if (item.surtido > 0){
    
        pUrl = "http://192.168.0.11/WebFrontEnd/inventarios/ObtenerCostoLineaSalida?Orden=${IdOrden.toString()}&Producto=${item.codigosap}&Empresa=SolesProd";
        
        print(pUrl);
    
        HttpRequest.getString(pUrl).then((String Data){
          double pCosto = json.parse(Data).toDouble();
          item.costo_salida = pCosto;
          item.importe_salida = pCosto * item.surtido;
          
          Map<String, String> headers = new Map<String, String>();
          headers["content-type"] = "application/x-www-form-urlencoded";
          
          String pData = '{"costo":"${pCosto.toDouble()}", "importe":"${item.importe_salida.toDouble()}"';
          
          String pUrlPost = "http://localhost:8031/rest/ordenp/actualiza_costo_linea_sap/${item.id}";
          HttpRequest.request(pUrlPost, method: "POST", responseType: "application/json", sendData: pData, requestHeaders: headers);
        });
     }
   }
  
   var pUrlCosto = "http://192.168.0.11/WebFrontEnd/inventarios/ObtenerCostoSalida?Orden=${IdOrden.toString()}&Cuenta=11100030004&Empresa=SolesProd";
   print(pUrlCosto);
   
   HttpRequest.getString(pUrlCosto).then((String Data){
      
      double pCosto = json.parse(Data);
      POrdenProduccion.costo_salida = pCosto;
      (document.querySelector("#TotalImporteP") as SpanElement).innerHtml = new intl.NumberFormat("###,0.00").format(pCosto);
      
      String pUrl = "http://localhost:8031/rest/ordenp/actualizar_costo_salida_orden/${IdOrden.toString()}";
      String pData = '{"costo": "${pCosto.toString()}" }';
      Map<String, String> headers = new Map<String, String>();
      headers["content-type"] = "application/json";
      
      HttpRequest.request(pUrl, method: "POST", responseType: "application/json", sendData: pData, requestHeaders: headers);
      
   });
}

void GeneraSalidaSap(){
  
    String pPassword = document.querySelector("#mPassword").value;
    
    if (pPassword != "551"){
        window.alert("Contraseña incorrecta");
        document.querySelector("#mPassword").focus();
        return;
    }
    
    document.querySelector("#mdlPassword").xtag.hide();
    (document.querySelector("#btnGeneraSalida") as ButtonElement).disabled = true;
  
    SalidaInventario pSalidaInventario = new SalidaInventario();
    
    pSalidaInventario.Comments         = POrdenProduccion.descripcion;
    pSalidaInventario.DocDate          = (document.querySelector("#fecha") as InputElement).value;
    pSalidaInventario.TaxDate          = pSalidaInventario.DocDate;
    pSalidaInventario.OrdenProduccion  = IdOrden;
    pSalidaInventario.Reference2       = IdOrden.toString();
    pSalidaInventario.Series           = "107";
    pSalidaInventario.FolioSalida      = POrdenProduccion.id_salida;
    
    for (OrdenMP item in ListaOrdenPMP){
          
        if (item.surtido > 0){
            LineaSalidaInventario pLinea = new LineaSalidaInventario();
            pLinea.ItemCode      = item.codigosap;
            pLinea.AccountCode   = "11100010060";
            pLinea.Quantity      = item.surtido;
            pLinea.WarehouseCode = "01";
            pLinea.CostingCode   = "PL1";
            
            pSalidaInventario.Lineas.add(pLinea);
        }
    }
    
    var pUrl = "http://192.168.0.11/webfrontend/inventarios/CrearSalida";
    Map<String, String> headers = new Map<String, String>();
    headers["content-type"] = "application/x-www-form-urlencoded";
    
    String Data = pSalidaInventario.toJSON();
    HttpRequest.request(pUrl, method: "POST", responseType: "application/json", sendData: Data, requestHeaders: headers).then((HttpRequest pRequest){
        print("-================================================-");
        print(pRequest.responseText);
        
        Map pMapResult = json.parse(pRequest.responseText);
        
        window.alert(pMapResult["Mensaje"]);
        
        if (pMapResult["Folio"] == "1"){
          
          (document.querySelector("#btnGeneraSalida") as ButtonElement).classes.add("hiden");
          (document.querySelector("#btnSalida") as ButtonElement).classes.add("hiden");

          String pUrl = 'http://localhost:8031/rest/ordenp/ordenmp_generar/${IdOrden}';
          POrdenProduccion.estado = "Generado";
          document.querySelector("#spanEstado").text = "Generado";
          
          HttpRequest.request(pUrl, method: "PUT" , responseType: "application/json").then((HttpRequest pReq){
              print(pReq.responseText);
          }).then((HttpRequest pRequest){
              ActualizaCostoSap();
          });
        }
        else{
          (document.querySelector("#btnGeneraSalida") as ButtonElement).disabled = false;
        }
        
    });
}

void PidePassword(){
  if (!window.confirm("¿Generar Salida en SAP?")){
    return;
  }
  
  document.querySelector("#mdlPassword").xtag.show();
  document.querySelector("#mPassword").focus(); 
}

void PidePassword2(){
	if (!window.confirm("¿Generar Entrada en SAP?")){
		return;
	}

	document.querySelector("#mdlPassword2").xtag.show();
	document.querySelector("#mPassword2").focus(); 
}


void GeneraEntradaSap(){

	String pPassword = document.querySelector("#mPassword2").value;
	
	if (pPassword != "soles123"){
		window.alert("Contraseña incorrecta");
		document.querySelector("#mPassword2").focus();
		return;
	}
	
	document.querySelector("#mdlPassword2").xtag.hide();
	(document.querySelector("#btnEntrada") as ButtonElement).disabled = true;
	
	SalidaInventario pSalidaInventario = new SalidaInventario();
	
	pSalidaInventario.Comments         = POrdenProduccion.descripcion;
	pSalidaInventario.DocDate          = (document.querySelector("#fecha") as InputElement).value;
	pSalidaInventario.TaxDate          = pSalidaInventario.DocDate;
	pSalidaInventario.OrdenProduccion  = IdOrden;
	pSalidaInventario.Reference2       = IdOrden.toString();
	pSalidaInventario.Series           = "107";
	pSalidaInventario.FolioSalida      = POrdenProduccion.id_salida;
	
	for (Produccion item in ListaProduccion){
	
		if (item.producido > 0){
			LineaSalidaInventario pLinea = new LineaSalidaInventario();
			pLinea.ItemCode      = item.codigosap;
			pLinea.AccountCode   = "11100010060";
			pLinea.Quantity      = item.producido;
			pLinea.WarehouseCode = "01";
			pLinea.CostingCode   = "PL1";
			
			pSalidaInventario.Lineas.add(pLinea);
		}
	}

	var pUrl = "http://192.168.0.11/webfrontend/inventarios/CrearEntrada";
	Map<String, String> headers = new Map<String, String>();
	headers["content-type"] = "application/x-www-form-urlencoded";
	
	String Data = pSalidaInventario.toJSON();
	HttpRequest.request(pUrl, method: "POST", responseType: "application/json", sendData: Data, requestHeaders: headers).then((HttpRequest pRequest){
	print("-================================================-");
	print(pRequest.responseText);
	
	Map pMapResult = json.parse(pRequest.responseText);
	
	window.alert(pMapResult["Mensaje"]);
	
	if (pMapResult["Folio"] == "1"){
	
		(document.querySelector("#btnEntrada") as ButtonElement).classes.add("hiden");
		(document.querySelector("#btnSalida") as ButtonElement).classes.add("hiden");
		
		String pUrl = 'http://localhost:8031/rest/ordenp/ordenmp_finalizar/${IdOrden}';
		POrdenProduccion.estado = "Generado";
		document.querySelector("#spanEstado").text = "Finalizado";
		
		HttpRequest.request(pUrl, method: "PUT" , responseType: "application/json").then((HttpRequest pReq){
			print(pReq.responseText);
		}).then((HttpRequest pRequest){
			ActualizaCostoSap();
		});
	}
	else{
		(document.querySelector("#btnEntrada") as ButtonElement).disabled = false;
	}
	
   });
}

void main() {
  
  HiddenInputElement pInpEditable = document.querySelector("#inpEditable") as HiddenInputElement;
  editable = pInpEditable.value == "true";
  
  ObtenerOrdenProduccion(ObtenerIdOrden());
  
  document.querySelector("#mdlAgregarProductos").classes.remove("hiden");
  document.querySelector("#mdlAgregarCosto").classes.remove("hiden");
  document.querySelector("#mdlCostoMaquila").classes.remove("hiden");
  document.querySelector("#mdlPassword").classes.remove("hiden");
  document.querySelector("#mdlPassword2").classes.remove("hiden");
  document.querySelector("#mdlDetalleProducido").classes.remove("hiden");
  document.querySelector("#mdlValorRescate").classes.remove("hiden");
  
  Timer.run(()=>document.querySelector("#id_orden").focus());  
}