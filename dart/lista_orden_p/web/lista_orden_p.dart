import 'dart:html';
import 'dart:json' as json;
import 'package:web_ui/web_ui.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:async';
import 'OrdenProduccion.dart';

class Clase{
  int Id;
  String Nombre;
  String Activo;
  bool Selected;
  
  Clase(this.Id, this.Nombre, this.Activo, this.Selected);
  
  
  Clase.fromMap(Map AMap){
    this.Id       = AMap['id'];
    this.Nombre   = AMap['clase'];
    this.Activo   = AMap['activo'];
    this.Selected = false;
  }
}

ObservableList<OrdenProduccion> ListaOrdenP = new ObservableList<OrdenProduccion>();
ObservableList<Clase> ListaClases = new ObservableList<Clase>();
OrdenProduccion pOrdenProduccion = null;
bool editable = true;

void llena_lista_consulta(String data){
  ListaOrdenP.clear();
  
  List p_lista = json.parse(data);
  
  String pClase = query("#inpClase").value;
  
  window.localStorage["Clase"] = pClase;
  
  for (int i = 0; i <= p_lista.length - 1; i++){
    
      OrdenProduccion item = new OrdenProduccion();
      item.id               = p_lista[i]['id'];
      item.descripcion      = p_lista[i]['descripcion'];
      item.fecha            = p_lista[i]['fecha'];
      item.fecha            = item.fecha.substring(0, 10);
      item.lote_produccion  = p_lista[i]['lote_produccion'];
      item.nombre_clase     = p_lista[i]['nombre_clase'];
      item.estado           = p_lista[i]['estado'];
      item.clase            = p_lista[i]['clase'];
      item.folio_sap        = p_lista[i]['folio_sap'];
      item.usuario          = p_lista[i]['usuario'];
      
      if (int.parse(pClase) > 0){
          if (item.clase == int.parse(pClase)){
            ListaOrdenP.add(item);
          }
      }
      else
      {
           ListaOrdenP.add(item);
      }
      
  }
}

void LlenaOrdenProduccion(){  
  
  String pFechaIni = query("#fecha").value;
  String pFechaFin = query("#fechafin").value;
  String pFiltro   = query("#filtro").value;
  
  window.localStorage["FechaInicial"] = pFechaIni;
  window.localStorage["FechaFinal"]  = pFechaFin;
  window.localStorage["Filtro"]      = pFiltro;
  
  pFechaIni = pFechaIni.replaceAll("/", "%2F");
  pFechaFin = pFechaFin.replaceAll("/", "%2F");
  
  String pUrl   = 'http://localhost:8031/rest/ordenp/OrdenProduccion_obtener_lista/${pFechaIni}/${pFechaFin}/${pFiltro}';
  
  HttpRequest.getString(pUrl).then(llena_lista_consulta);
}

void agregar(){
  
  if (!editable){
    window.alert("No tiene derecho a esta opción");
    return;
  }
	
  String pIdUsuario = document.query("#idUsuario").value;
  String pUrl = "http://localhost:8031/rest/dias_ultima_orden/${pIdUsuario}";

  HttpRequest.getString(pUrl).then((String Data){
	
	  Map pMap = json.parse(Data);
	  
	  if (pMap["dias"] > 3){
			window.alert("No puede crear nuevas ordenes porque hay ordenes abiertas de ${pMap["dias"].toString()} de antigüedad");
			return;
	  }
	  else{
		   window.location.href = "http://localhost:8031/orden_produccion?id=0";	
	  }
  });
	
}

Future tiene_derecho_modificar(){
    
    String pUsuario = "5";
    String pDerecho = "40";
    var pUrl = "http://localhost:8031/rest/usuarios/usuario_tiene_derecho/${pUsuario}/${pDerecho}";
    
    return HttpRequest.getString(pUrl);
}

Future tiene_derecho_eliminar(){
  
  String pUsuario = "4";
  String pDerecho = "40";
  var pUrl = "http://localhost:8031/rest/usuarios/usuario_tiene_derecho_eliminar_orden/${pUsuario}/${pDerecho}";
  
  return HttpRequest.getString(pUrl);
}

void modificar(OrdenProduccion item){
  if (!editable){
    window.alert("No tiene derecho a esta opción");
    return;
  }

 if (item.estado == "Eliminado"){
 	window.alert("No se puede modificar una orde eliminada");
 	return;
 }

  new Future<String>(tiene_derecho_modificar).then((String Data){
    
      bool pResult = json.parse(Data);
     
      if (pResult){
          if (item.estado != "Cerrado"){
              window.location.href = "http://localhost:8031/orden_produccion?id=${item.id.toString()}";
          }
          else{
              window.alert("No se puede modificar una orden cerrada");  
          }
      }
      else{
          window.alert("El usuario no tiene derecho a modificar ordenes de producción");
      }
  });
  
}

void surtir(OrdenProduccion item){

	if (item.estado == "Eliminado"){
		window.alert("No se puede surtir una orden eliminada");
		return;
	}

    String pFecha = document.query("#fecha").value;
    window.location.href = "http://localhost:8031/surtir_orden?id=${item.id.toString()}&fecha=${pFecha}";
}

void eliminar(OrdenProduccion item){
  if (!editable){
    window.alert("No tiene derecho a esta opción");
    return;
  }
  
  if (item.estado != "Nuevo"){
      window.alert("No se pueden eliminar Ordenes que no son nuevas");
      return;
  }

  new Future<String>(tiene_derecho_eliminar).then((String Data){
    
    bool pResult = json.parse(Data);
    
    if (pResult){
      if (window.confirm("¿Eliminar Orden de Produccion?")){
          String pUrl   = 'http://localhost:8031/rest/ordenp/OrdenProduccion_eliminar/${item.id.toString()}';
          Map<String, String> headers = new Map<String, String>();
          headers["content-type"] = "application/json";
          String pData = item.ToJson();
        
          HttpRequest.request(pUrl, method: "DELETE", requestHeaders:  headers , sendData:  pData).then((HttpRequest request) => item.estado = "Eliminado");
      }
    }
    else{
        window.alert("El usuario no tiene derecho a eliminar ordenes de producción");
    }
  });
}

void buscar(){
  document.query("#mdlBuscar").xtag.show();
  document.query("#pFolio").focus(); 
}

void buscaFolio(){
  
    document.query("#mdlBuscar").xtag.hide();
    String pFolio = document.query("#pFolio").value;
    String pUrl   = 'http://localhost:8031/rest/ordenp/OrdenProduccion_obtener_lista_folio/' + pFolio;
    
    HttpRequest.getString(pUrl).then(llena_lista_consulta);
}

void cambiarEstado(OrdenProduccion AOrdenProduccion){
  
    if (!editable){
      window.alert("No tiene derecho a esta opción");
      return;
    }

	String pIdUsuario = document.query("#idUsuario").value;
	String pUrl = "http://localhost:8031/rest/puede_cambiar_estado/${pIdUsuario}";
	
	HttpRequest.getString(pUrl).then((String Data){
	
		String pResult = json.parse(Data);
		
		if (pResult != "Si"){
			window.alert("El usuario no tiene derecho a cambiar estados");
			return;
		}
		else{
			pOrdenProduccion = AOrdenProduccion;
			document.query("#mdlCambiarEstado").xtag.show();
			document.query("#inpEstado").focus();
		}
	});
}

setCambiarEstado(){
	
	String pEstado = document.query("#inpEstado").value;
	
	if (pEstado == pOrdenProduccion.estado){
		window.alert("No se puede cambiar al estado actual");
		return;
	}
	
	var pUrl = "http://localhost:8031/rest/cambiar_estado_orden_produccion/${pOrdenProduccion.id}/${pEstado}";
	
	HttpRequest.request(pUrl, method: "PUT", sendData: "").then((HttpRequest ARequest){
		Map pMap = json.parse(ARequest.responseText);
		
		window.alert(pMap["mensaje"]);
		
		if (pMap["result"] == 0){
			
			OrdenProduccion pOP = ListaOrdenP.where((OrdenProduccion x) => x.id == pOrdenProduccion.id).first;
			pOP.estado = pEstado;
		
		}
		
		document.query("#mdlCambiarEstado").xtag.hide();
	});
}

void main() {
  
  HiddenInputElement pInpEditable = document.querySelector("#inpEditable") as HiddenInputElement;
  editable = pInpEditable.value == "true";
  
  document.query("#mdlBuscar").classes.remove("hiden");
  document.query("#mdlCambiarEstado").classes.remove("hiden");
  
  String pFecha = "";
  
  if (window.localStorage.containsKey("FechaInicial")){
      (document.query("#fecha") as InputElement).value = window.localStorage["FechaInicial"];
  }
  else{
    (document.query("#fecha") as InputElement).value = new intl.DateFormat("dd/MM/yyyy").format(new DateTime.now());
  }
  
  if (window.localStorage.containsKey("FechaFinal")){
    (document.query("#fechafin") as InputElement).value = window.localStorage["FechaFinal"];
  }
  else{
    (document.query("#fechafin") as InputElement).value = new intl.DateFormat("dd/MM/yyyy").format(new DateTime.now());
  }
  
  if (window.localStorage.containsKey("FechaFinal")){
    document.query("#filtro").value = window.localStorage["Filtro"];
  }
  else{
    document.query("#filtro").value = "Todos";
  }
  
  
  var pUrl = "http://localhost:8031/rest/clase_ordenp_obtener_lista";
  
  HttpRequest.getString(pUrl).then((String Data){
    
    var pLista = json.parse(Data);
    
    ListaClases.add(new Clase(0, "Todos", "Si", true));
    
    for (Map item in pLista){
        Clase pClase = new Clase.fromMap(item);
        ListaClases.add(pClase);
        
        if (window.localStorage.containsKey("Clase")){
            if (window.localStorage["Clase"] == pClase.Id.toString()){
                ListaClases[0].Selected = false;
                pClase.Selected = true;
            }
        }
    }
    
    LlenaOrdenProduccion();
  });
}
