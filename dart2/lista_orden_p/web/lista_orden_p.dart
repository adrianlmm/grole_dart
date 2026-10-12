import 'dart:html';
import 'dart:convert';
import 'package:intl/intl.dart' as intl;
import 'dart:async';
import 'OrdenProduccion.dart';

import 'package:quickdialogs/quickdialogs.dart' as ModalP;

SelectElement inpClase = querySelector("#inpClase");
SelectElement inpFiltro = querySelector("#filtro");
final ButtonElement btnConsultar = querySelector("#btnConsultar");
TableElement tablaConsulta = querySelector("#tablaConsulta");
ButtonElement btnCancelarCambioEstado = querySelector("#btnCancelarCambioEstado");
ButtonElement btnCerrarModalCambiarEstado = querySelector("#btnCerrarModalCambiarEstado");
ButtonElement btnCambiarEstado = querySelector("#btnCambiarEstado");
ButtonElement btnBusca = querySelector("#btnBusca");
ButtonElement btnCerrarModalBuscar1 = querySelector("#btnCerrarModalBuscar1");
ButtonElement btnCerrarModalBuscar2 = querySelector("#btnCerrarModalBuscar2");

ButtonElement btnAgregar = querySelector("#btnAgregar");
ButtonElement btnBuscar = querySelector("#btnBuscar");

ButtonElement inpAutorizar = querySelector("#inpAutorizar");

ButtonElement btnCerrarModalAutorizar1 = querySelector("#btnCerrarModalAutorizar1");
ButtonElement btnCerrarModalAutorizar2 = querySelector("#btnCerrarModalAutorizar2");
ButtonElement btnAutorizar = querySelector("#btnAutorizar");
PasswordInputElement inpPassword = querySelector("#inpPassword");


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

List<OrdenProduccion> ListaOrdenP = new List<OrdenProduccion>();
List<Clase> ListaClases = new List<Clase>();
OrdenProduccion pOrdenProduccion = new OrdenProduccion();

String _EstadoTmp = "";
int _IdTmp = 0;

bool editable = true;

void autorizar(OrdenProduccion AOrdenProduccion){
    window.localStorage["IdAuth"] = AOrdenProduccion.id.toString();
    ModalP.showModal("mdlAutorizar");
    inpPassword.focus();
}

Future autoriza() async{

    if (inpPassword.value.trim() != "soles32"){
        window.alert("Contraseña incorrecta");
        inpPassword.focus();
        return;
    }

    int pId = int.parse(window.localStorage["IdAuth"]);

    var pUrl = "http://localhost:8031/rest/cambiar_estado_orden_produccion/${pId}/Autorizado";

    HttpRequest pResult = await HttpRequest.request(pUrl, method: "PUT", sendData: "");

    Map pMap = JSON.decode(pResult.responseText);

    print("-----------------------");
    print(pMap);

    if (pMap["result"] == 0){
      querySelector("#tdEstado" + pId.toString()).text = "Autorizado";

      try{
        ListaOrdenP.where((x) => x.id == pId).first.estado = "Autorizado";
      }
      catch(_){

      }

      ModalP.closeModal("mdlAutorizar");
    }

}

void llena_lista_consulta(String data){

  print(data);

  ListaOrdenP.clear();

  List p_lista = JSON.decode(data);

  String pClase = inpClase.value;

  if (pClase != "0"){
    p_lista = p_lista.where((x) => x['clase'].toString() == pClase).toList();
  }

  window.localStorage["Clase"] = pClase;

  tablaConsulta.tBodies[0].children.clear();

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

      TableRowElement tr = new TableRowElement();
      TableCellElement td = new TableCellElement()..id = "td" + item.id.toString() ..text = item.id.toString();
      tr.children.add(td);

      td = new TableCellElement();

      if (item.folio_sap == null){
        td.text = "";
      }
      else{
        td.text = item.folio_sap.toString();
      }

      tr.children.add(td);

      td = new TableCellElement()..text = item.descripcion;
      tr.children.add(td);

      td = new TableCellElement()..text = item.fecha..style.textAlign = "center";
      tr.children.add(td);

      td = new TableCellElement()..text = item.usuario..style.textAlign = "center";
      tr.children.add(td);

      td = new TableCellElement()..text = item.nombre_clase..style.textAlign = "center";
      tr.children.add(td);

      td = new TableCellElement()..id="tdEstado" + item.id.toString()..text = item.estado..style.textAlign = "center";
      tr.children.add(td);

      AnchorElement ancSurtir = new AnchorElement()..classes.add("label")..text = "Surtir"..onClick.listen((_) {
         surtir(item);
      });

      td = new TableCellElement()..style.textAlign = "center"..children.add(ancSurtir);
      td.children.add(new Element.html("<span>&nbsp;</span>"));

      AnchorElement ancModificar = new AnchorElement()..classes.add("label")..text = "m"..onClick.listen((_) {
        modificar(item);
      });

      td.children.add(ancModificar);
      td.children.add(new Element.html("<span>&nbsp;</span>"));

      AnchorElement ancEliminar = new AnchorElement()..classes.add("label")..text = "e"..onClick.listen((_) {
        eliminar(item);
      });

      td.children.add(ancEliminar);

      td.children.add(new Element.html("<span>&nbsp;</span>"));

      AnchorElement ancCambiarEstado = new AnchorElement()..classes.add("label")..text = "c"..onClick.listen((_) {
        cambiarEstado(item);
      });

      td.children.add(ancCambiarEstado);

      tr.children.add(td);

      td.children.add(new Element.html("<span>&nbsp;</span>"));

      AnchorElement ancAutorizar = new AnchorElement()..classes.add("label")..text = "a"..onClick.listen((_) {

        if (item.estado == "Cerrado"){
          autorizar(item);
        }
        else{
          window.alert("La orden debe estar cerrada");
        }

      });

      td.children.add(ancAutorizar);

      tr.children.add(td);

      tablaConsulta.tBodies[0].children.add(tr);

      ListaOrdenP.add(item);

  }

  print("***************");
  print(ListaOrdenP);
}

void LlenaOrdenProduccion(){

  String pFechaIni = (querySelector("#fecha") as InputElement).value;
  String pFechaFin = (querySelector("#fechafin") as InputElement).value;
  String pFiltro   = (querySelector("#filtro") as SelectElement).value;

  window.localStorage["FechaInicial"] = pFechaIni;
  window.localStorage["FechaFinal"]  = pFechaFin;
  window.localStorage["Filtro"]      = pFiltro;
  window.localStorage["Clase"]       = inpClase.value;

  pFechaIni = pFechaIni.replaceAll("/", "%2F");
  pFechaFin = pFechaFin.replaceAll("/", "%2F");

  String pUrl   = 'http://localhost:8031/rest/ordenp/OrdenProduccion_obtener_lista/${pFechaIni}/${pFechaFin}/${pFiltro}';

  print(pUrl);

  HttpRequest.getString(pUrl).then(llena_lista_consulta);
}

void agregar(){

  print("agregando");

  if (!editable){
    window.alert("No tiene derecho a esta opción");
    return;
  }

  String pIdUsuario = (document.querySelector("#idUsuario") as HiddenInputElement).value;
  String pUrl = "http://localhost:8031/rest/dias_ultima_orden/${pIdUsuario}";

  HttpRequest.getString(pUrl).then((String Data){

	  Map pMap = JSON.decode(Data);

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

      bool pResult = JSON.decode(Data);

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

    String pFecha = (document.querySelector("#fecha") as InputElement).value;
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

    bool pResult = JSON.decode(Data);

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
  ModalP.showModal("mdlBuscar");
  document.querySelector("#pFolio").focus();
}

void buscaFolio(){

    ModalP.closeModal("mdlBuscar");
    String pFolio = (document.querySelector("#pFolio") as InputElement).value;
    String pUrl   = 'http://localhost:8031/rest/ordenp/OrdenProduccion_obtener_lista_folio/' + pFolio;

    HttpRequest.getString(pUrl).then(llena_lista_consulta);
}

void cambiarEstado(OrdenProduccion AOrdenProduccion){

    if (!editable){
      window.alert("No tiene derecho a esta opción");
      return;
    }

	String pIdUsuario = (document.querySelector("#idUsuario") as InputElement).value;
	String pUrl = "http://localhost:8031/rest/puede_cambiar_estado/${pIdUsuario}";

	HttpRequest.getString(pUrl).then((String Data){

		String pResult = JSON.decode(Data);

		if (pResult != "Si"){
			window.alert("El usuario no tiene derecho a cambiar estados");
			return;
		}
		else{
			pOrdenProduccion = AOrdenProduccion;

      _EstadoTmp = AOrdenProduccion.estado;

      window.localStorage["Estado"] = AOrdenProduccion.estado;

      window.localStorage["Id"] = AOrdenProduccion.id.toString();

      _IdTmp = AOrdenProduccion.id;

      ModalP.showModal(("mdlCambiarEstado"));
			document.querySelector("#inpEstado").focus();
		}
	});
}

setCambiarEstado(){

	String pEstado = (document.querySelector("#inpEstado") as SelectElement).value;

  pOrdenProduccion = new OrdenProduccion();
  pOrdenProduccion.id = int.parse(window.localStorage["Id"]);
  pOrdenProduccion.estado = window.localStorage["Estado"];

	if (pEstado == pOrdenProduccion.estado){
		window.alert("No se puede cambiar al estado actual");
		return;
	}

	var pUrl = "http://localhost:8031/rest/cambiar_estado_orden_produccion/${pOrdenProduccion.id}/${pEstado}";


	HttpRequest.request(pUrl, method: "PUT", sendData: "").then((HttpRequest ARequest){
		Map pMap = JSON.decode(ARequest.responseText);

		if (pMap["result"] == 0){

      ModalP.closeModal("mdlCambiarEstado");

      String pIdtdTmp = "#tdEstado" + pOrdenProduccion.id.toString();

      print("---------------------");
      print(ListaOrdenP);

      querySelector(pIdtdTmp).text = pEstado;
			OrdenProduccion pOP = ListaOrdenP.where((OrdenProduccion x) => x.id == pOrdenProduccion.id).first;
			pOP.estado = pEstado;

		}


	});
}

void main() {

  if (window.localStorage["Filtro"] != null){
      inpFiltro.value = window.localStorage["Filtro"];
  }


  HiddenInputElement pInpEditable = document.querySelector("#inpEditable") as HiddenInputElement;
  editable = pInpEditable.value == "true";

  document.querySelector("#mdlBuscar").classes.remove("hiden");

  String pFecha = "";

  if (window.localStorage.containsKey("FechaInicial")){
      (document.querySelector("#fecha") as InputElement).value = window.localStorage["FechaInicial"];
  }
  else{
    (document.querySelector("#fecha") as InputElement).value = new intl.DateFormat("dd/MM/yyyy").format(new DateTime.now());
  }

  if (window.localStorage.containsKey("FechaFinal")){
    (document.querySelector("#fechafin") as InputElement).value = window.localStorage["FechaFinal"];
  }
  else{
    (document.querySelector("#fechafin") as InputElement).value = new intl.DateFormat("dd/MM/yyyy").format(new DateTime.now());
  }

  if (window.localStorage.containsKey("FechaFinal")){
    (document.querySelector("#filtro") as SelectElement).value = window.localStorage["Filtro"];
  }
  else{
    (document.querySelector("#filtro") as SelectElement).value = "Todos";
  }


  var pUrl = "http://localhost:8031/rest/clase_ordenp_obtener_lista";

  HttpRequest.getString(pUrl).then((String Data){

    var pLista = JSON.decode(Data);

    inpClase.children.add(new Element.html("<option value='0'>Todos</option>"));

    for (Map item in pLista){

      inpClase.children.add(new Element.html("<option value='${item["id"]}'>${item["clase"]}</option>"));

    }

    if (window.localStorage["Clase"] != null){
      inpClase.value = window.localStorage["Clase"];
    }

    LlenaOrdenProduccion();
  });

  btnConsultar.onClick.listen((_) => LlenaOrdenProduccion());

  btnCancelarCambioEstado.onClick.listen((_) => ModalP.closeModal("mdlCambiarEstado"));
  btnCerrarModalCambiarEstado.onClick.listen((_) => ModalP.closeModal("mdlCambiarEstado"));

  btnCambiarEstado.onClick.listen((_) => setCambiarEstado());
  btnAgregar.onClick.listen((_) => agregar());
  btnBusca.onClick.listen((_) => buscar());

  btnCerrarModalBuscar1.onClick.listen((_) => ModalP.closeModal("mdlBuscar"));
  btnCerrarModalBuscar2.onClick.listen((_) => ModalP.closeModal("mdlBuscar"));

  btnBuscar.onClick.listen((_) => buscaFolio());

  btnCerrarModalAutorizar1.onClick.listen((_) => ModalP.closeModal("mdlAutorizar"));
  btnCerrarModalAutorizar2.onClick.listen((_) => ModalP.closeModal("mdlAutorizar"));

  btnAutorizar.onClick.listen((_) async => autoriza());
}