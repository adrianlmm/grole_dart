import 'dart:html';
import 'package:intl/intl.dart' as intl;
import 'OrdenProduccion.dart';
import 'OrdenPP.dart';
import 'OrdenMP.dart';
import 'clases.dart';
import 'dart:convert';
import 'dart:async';
import 'modal_p.dart' as ModalP;


String IdOrden = "";
OrdenProduccion POrdenProduccion = new OrdenProduccion();
List<OrdenPP> ListaOrdenPP = new List<OrdenPP>();
List<OrdenMP> ListaOrdenPMP = new List<OrdenMP>();
List<Receta> Recetas = new List<Receta>();
List<Clase> ListaClases = new List<Clase>();
final InputElement inpFecha                = querySelector("#fecha");
final InputElement inpLote                 = querySelector("#lote_produccion");
final HiddenInputElement inpOrdenEtiquetas = querySelector("#inpOrdenEtiquetas");

final SelectElement inpClienteMaquila = querySelector("#inpClienteMaquila");

ButtonElement btnInfoCaliente = querySelector("#btnInfoCaliente");

int IndiceMP = 130;
StreamSubscription EventoCambiarCajas = null;
int id = 9999;

class Receta{
  int id;
  String descripcion;
}

String ObtenerIdOrden(){
  String p_query_string = window.location.search;
  String p_orden = p_query_string.split("=")[1];
  return p_orden;
}

Future<List<Map>> obtenerClientesMaquila() async{

    Completer<List<Map>> pCompleter = new Completer<List<Map>>();
    var pUrl = "http://localhost:8031/obtener_clientes_maquila";

    String pJson = await HttpRequest.getString(pUrl);

    pCompleter.complete(JSON.decode(pJson));

    return pCompleter.future;
}

llenaSelectClientesMaquila() async{

    List<Map> pListaClientesMaquila = await obtenerClientesMaquila();

    inpClienteMaquila.children.add(new Element.html("<option value='0'>Elegir Cliente</option>"));

    for (Map item in pListaClientesMaquila){

        inpClienteMaquila.children.add(new Element.html("<option value=${item["id"]}>${item["nombre"]}</option>"));

    }

}

void agregarFilaOrdenPP(OrdenPP item){

  TableElement tableOrdenPP = querySelector("#tableOrdenPP");
  TableRowElement tr = new TableRowElement()..id = "tr${item.id}";

  TableCellElement td = new TableCellElement()..text = item.producto;
  tr.children.add(td);
  td = new TableCellElement()..text = item.descripcion;
  tr.children.add(td);
  td = new TableCellElement()..text = new intl.NumberFormat("###0.00").format(item.kilos);
  tr.children.add(td);
  AnchorElement anchorCajas = new Element.html("<a href=\"#\">${new intl.NumberFormat("00000").format(item.cajas)}</a>")..id = "pp_cajas${item.id}";
  td = new TableCellElement()..children.add(anchorCajas);

  anchorCajas.onClick.listen((_){
    editaCajasProduccion(item);
  });

  tr.children.add(td);

  AnchorElement anchorEliminar = new Element.html("<a href=\"#\">x</a>")..classes.add("label")..style.color="#ffffff"..style.textDecoration="none";

  anchorEliminar.onClick.listen((_){

    eliminar_produccion(item);

  });

  td = new TableCellElement()..children.add(anchorEliminar);
  tr.children.add(td);

  tableOrdenPP.tBodies[0].children.add(tr);

}

void agregarFilaOrdenMP(OrdenMP item){

  TableElement tableOrdenMP = querySelector("#tableOrdenMP");
  TableRowElement tr = new TableRowElement()..id = "trMP${item.id}";

  TableCellElement td = new TableCellElement()..text = item.producto;
  tr.children.add(td);
  td = new TableCellElement()..text = item.descripcion;
  tr.children.add(td);
  td = new TableCellElement()..text = new intl.NumberFormat("###0.00").format(item.kilos)..id = "mp_kilos${item.id}";
  tr.children.add(td);

  tr.children.add(td);

  AnchorElement anchorEliminar = new Element.html("<a href=\"#\">x</a>")..classes.add("label")..style.color="#ffffff"..style.textDecoration="none";
  anchorEliminar.onClick.listen((_){
    eliminar_produccion_mp(item);
  });

  td = new TableCellElement()..children.add(anchorEliminar);
  AnchorElement anchorModificar = new Element.html("<a href=\"#\"> m</a>")..classes.add("label")..style.color="#ffffff"..style.textDecoration="none";
  anchorModificar.onClick.listen((_){
    modificarMateriaPrima(item);
  });

  td.children.add(anchorModificar);
  tr.children.add(td);

  tableOrdenMP.tBodies[0].children.add(tr);

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

      var pLista = JSON.decode(Data);

      for (var item in pLista){
        OrdenPP pOrdenPP = new OrdenPP.FromMap(item);
        ListaOrdenPP.add(pOrdenPP);
        agregarFilaOrdenPP(pOrdenPP);
      }
    }).then((String Data){

      String pUrl = 'http://localhost:8031/rest/ordenp/ordenmp_obtener_lista/${POrdenProduccion.id.toString()}';
      HttpRequest.getString(pUrl, onProgress: null).then((String Data){

        var pLista = JSON.decode(Data);

        for (var item in pLista){
          OrdenMP pOrdenMP = new OrdenMP.FromMap(item);
          ListaOrdenPMP.add(pOrdenMP);
          agregarFilaOrdenMP(pOrdenMP);
        }
      }).then((String Data) => DespliegaEntidad(POrdenProduccion));
    });
  });
}

void cambiarCajas(){

}

void editaCajasProduccion(OrdenPP AItemOrden){

  ModalP.modal("mdlEditaCajas");
  (querySelector("#impCajas") as InputElement).value = AItemOrden.cajas.toString();
  querySelector("#impCajas").focus();
  (querySelector("#impCajas") as InputElement).select();

  ButtonElement btnCambiarCajas = (querySelector("#btnCambiarCajas") as ButtonElement);

  if (EventoCambiarCajas != null){
    EventoCambiarCajas.cancel();
  }

  EventoCambiarCajas = btnCambiarCajas.onClick.listen((_){

    try{
      AItemOrden.cajas = int.parse(((querySelector("#impCajas") as InputElement).value));
    }
    catch(Exception){
      AItemOrden.cajas = -1;
    }

    if (AItemOrden.cajas < 0){
      window.alert("El número de cajas no es válido");
      (querySelector("#impCajas") as InputElement).focus();
    }
    else{
      (querySelector("#pp_cajas${AItemOrden.id}") as AnchorElement).text = new intl.NumberFormat("00000").format(AItemOrden.cajas);
      ModalP.cierra_modal("mdlEditaCajas");
    }

  });
}

void despliegaMarinado(OrdenProduccion AOrdenProduccion){
  (querySelector("#inpLoteProdMarinador1") as InputElement).value = AOrdenProduccion.lote_prod_marinador_1.toString();
  (querySelector("#inpLoteProdMarinador2") as InputElement).value = AOrdenProduccion.lote_prod_marinador_2.toString();
  (querySelector("#inpProveedorMarinador1") as InputElement).value = AOrdenProduccion.proveedor_marinador_1;
  (querySelector("#inpProveedorMarinador2") as InputElement).value = AOrdenProduccion.proveedor_marinador_2;
  (querySelector("#inpProductoMarinador1") as InputElement).value  = AOrdenProduccion.producto_marinador_1;
  (querySelector("#inpProductoMarinador2") as InputElement).value  = AOrdenProduccion.producto_marinador_2;
  (querySelector("#inpLoteMarinador1") as InputElement).value = AOrdenProduccion.lote_marinador_1.toString();
  (querySelector("#inpLoteMarinador2") as InputElement).value = AOrdenProduccion.lote_marinador_2.toString();
  (querySelector("#inpFolioCertCalidad1") as InputElement).value = AOrdenProduccion.folio_certificado_calidad_1;
  (querySelector("#inpFolioCertCalidad2") as InputElement).value = AOrdenProduccion.folio_certificado_calidad_2;
}

void despliegaInfoCaliente(OrdenProduccion AOrdenProduccion){
  (querySelector("#inpLoteCaliente") as InputElement).value = AOrdenProduccion.lote_caliente.toString();
  (querySelector("#inpGranjaCaliente") as InputElement).value = AOrdenProduccion.granja_caliente.toString();
  (querySelector("#inpFechaCaliente") as InputElement).value = AOrdenProduccion.fecha_caliente;
}

void DespliegaEntidad(OrdenProduccion AOrdenProduccion){

  (querySelector("#id") as HiddenInputElement).value        = AOrdenProduccion.id.toString();
  (querySelector("#id_orden") as InputElement).value        = AOrdenProduccion.descripcion;
  (querySelector("#fecha") as InputElement).value           = AOrdenProduccion.fecha;
  (querySelector("#lote_produccion") as InputElement).value = AOrdenProduccion.lote_produccion.toString();
  (querySelector("#spanEstado") as SpanElement).text        = AOrdenProduccion.estado;
  (querySelector("#inpClase") as SelectElement).value       = AOrdenProduccion.clase.toString();

  despliegaMarinado(AOrdenProduccion);
  despliegaInfoCaliente(AOrdenProduccion);

  (querySelector("#inpValida") as SelectElement).value       = AOrdenProduccion.validar_productos;
  (querySelector("#inpPedimento") as InputElement).value     = AOrdenProduccion.pedimento.toString();
  (querySelector("#inpModoCalculo") as SelectElement).value   = AOrdenProduccion.modo_calculo;

    inpClienteMaquila.value = AOrdenProduccion.id_cliente_maquila.toString();
}

OrdenProduccion ObtenerEntidad(){

  OrdenProduccion pOrdenProduccion = new OrdenProduccion();
  pOrdenProduccion.id                = int.parse((querySelector("#id") as HiddenInputElement).value);
  pOrdenProduccion.id_usuario        = int.parse((querySelector("#id_usuario") as InputElement).value);
  pOrdenProduccion.id_tipo           = int.parse((querySelector("#id_tipo") as HiddenInputElement).value);
  pOrdenProduccion.descripcion       = (querySelector("#id_orden") as InputElement).value;
  pOrdenProduccion.fecha             = (querySelector("#fecha") as InputElement).value;
  pOrdenProduccion.lote_produccion   = (querySelector("#lote_produccion") as InputElement).value;
  pOrdenProduccion.estado            = (querySelector("#spanEstado") as SpanElement).text;
  pOrdenProduccion.clase             = int.parse((querySelector("#inpClase") as SelectElement).value);
  pOrdenProduccion.validar_productos = (querySelector("#inpValida") as SelectElement).value;
  pOrdenProduccion.pedimento         = int.parse((querySelector("#inpPedimento") as InputElement).value, onError:(_) => 0);

  pOrdenProduccion.lote_prod_marinador_1 = int.parse((querySelector("#inpLoteProdMarinador1") as InputElement).value, onError: (_) => 0);
  pOrdenProduccion.lote_prod_marinador_2 = int.parse((querySelector("#inpLoteProdMarinador2") as InputElement).value, onError: (_) => 0);
  pOrdenProduccion.proveedor_marinador_1 = (querySelector("#inpProveedorMarinador1") as InputElement).value;
  pOrdenProduccion.proveedor_marinador_2 = (querySelector("#inpProveedorMarinador2") as InputElement).value;
  pOrdenProduccion.producto_marinador_1  = (querySelector("#inpProductoMarinador1") as InputElement).value;
  pOrdenProduccion.producto_marinador_2  = (querySelector("#inpProductoMarinador2") as InputElement).value;
  pOrdenProduccion.lote_marinador_1      = int.parse((querySelector("#inpLoteMarinador1") as InputElement).value, onError: (_) => 0);
  pOrdenProduccion.lote_marinador_2      = int.parse((querySelector("#inpLoteMarinador2") as InputElement).value, onError: (_) => 0);
  pOrdenProduccion.folio_certificado_calidad_1 = (querySelector("#inpFolioCertCalidad1") as InputElement).value;
  pOrdenProduccion.folio_certificado_calidad_2 = (querySelector("#inpFolioCertCalidad2") as InputElement).value;



  pOrdenProduccion.lote_caliente   = int.parse((querySelector("#inpLoteCaliente") as InputElement).value, onError: (x) => 0);
  pOrdenProduccion.granja_caliente = int.parse((querySelector("#inpGranjaCaliente") as InputElement).value, onError: (x) => 0);
  pOrdenProduccion.fecha_caliente  = (querySelector("#inpFechaCaliente") as InputElement).value;
  pOrdenProduccion.modo_calculo    = (querySelector("#inpModoCalculo") as SelectElement).value;

  try {
      pOrdenProduccion.id_cliente_maquila = int.parse(inpClienteMaquila.value);
  }
  catch(_){
      pOrdenProduccion.id_cliente_maquila = 0;
  }

  return pOrdenProduccion;
}

void guardar(){

  POrdenProduccion = ObtenerEntidad();

  if (POrdenProduccion.id_cliente_maquila == 0){
    print("Se necesita seleccionar cliente de maquila");
    window.alert("Se necesita seleccionar cliente de maquila");
    return;
  }

  if (POrdenProduccion.descripcion.trim().length == 0){
    window.alert("Se necesita agregar una descripción");
    (querySelector("#id_orden") as InputElement).focus();
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
    var pProductos =  "";
    ListaOrdenPP.forEach((OrdenPP m) => pProductos += m.producto + ",");
    pProductos = pProductos.substring(0, pProductos.length - 1);
    print("********************************");
    var pUrlPL = "/cortes/nuevo_lp?fecha=${inpFecha.value}&lote=${inpLote.value}&productos=${pProductos}";
    print(pUrlPL);
    print('abriendo');
    window.open(pUrlPL, "this");
    window.location.href = "/ordenes_produccion";
  });
}

void cancelar(){
  if (window.confirm("¿Cancelar captura?")){
    window.location.href = "/ordenes_produccion";
  }
}

void agregar(){
  ModalP.modal("mdlAgregarProductos");
  querySelector("#pClave").focus();
}

void agregar_mp(){
  ModalP.modal("mdlAgregarProductosMP");
  (querySelector("#mClave") as InputElement).focus();
}

void agrega_receta(int AReceta, double ACantidad, OrdenPP AOrden){

  var pUrl = "http://localhost:8031/obtener_detalle_receta/${AReceta.toString()}";

  bool pAgregado = false;

  HttpRequest.getString(pUrl).then((data){

    print("detalle receta ${data}");

    print("parseando");
    List pLista = JSON.decode(data);

    print("aquí");
    print("Tamaño lista: ${pLista.length.toString()}");

    for (var item in pLista){

      print(item);

      var pData = ListaOrdenPMP.where((OrdenMP x) => x.producto == item["producto"]).toList();
      var pOrdenMP = new OrdenMP();
      pOrdenMP.id = id;
      id++;
      bool pExiste = true;

      if (pData.length > 0){
        pOrdenMP = pData.first;
      }
      else{
        pExiste = false;
      }

      pOrdenMP.producto     = item["producto"];
      pOrdenMP.descripcion  = item["descripcion"];

      HttpRequest.getString("http://localhost:8031/obtener_inventario_producto/${item['producto']}").then((data){

        double pInventario = 0.0;

        try
        {
          pInventario = JSON.decode(data);
        }
        catch(ex)
        {
          pInventario = 0.0;
        }

        item['rendimiento'] = (200 - (item['rendimiento']  * 100)) / 100;

        /*if (!(pOrdenMP.kilos + (item["rendimiento"] * ACantidad) < pInventario)){

                print("4.2");
                new Timer(new Duration(milliseconds: 300), (){
                  print("4.3");

                  window.alert("No hay suficiente inventario para el producto, ${item['producto']}, existencia ${pInventario.toString()}");
                  print("4.4");

                });
            }*/

        if (pAgregado == false){
          ListaOrdenPP.add(AOrden);
          agregarFilaOrdenPP(AOrden);
          pAgregado = true;
        }

        var x = item["rendimiento"];
        x = x * ACantidad;
        pOrdenMP.kilos    += (item["rendimiento"] * ACantidad);

        if (pExiste == false){
          ListaOrdenPMP.add(pOrdenMP);
          agregarFilaOrdenMP(pOrdenMP);
        }
      });
    }

  });
}

void agregar_produccion(){

  OrdenPP pOrdenPP = new OrdenPP();

  (querySelector("#pReceta") as SelectElement).disabled = true;

  pOrdenPP.producto    = (querySelector("#pClave") as InputElement).value;
  pOrdenPP.descripcion = (querySelector("#pDescripcion") as InputElement).value;
  pOrdenPP.kilos       = double.parse((querySelector("#pKilos") as InputElement).value);
  pOrdenPP.cajas       = int.parse((querySelector("#pCajas") as InputElement).value, onError:(x){return -1;});
  pOrdenPP.receta      = int.parse((querySelector("#pReceta") as SelectElement).value, onError:(x){return -1;});
  pOrdenPP.id          = id;
  id++;

  if (pOrdenPP.descripcion.trim().length == 0){
    window.alert("El producto no es válido");
    (querySelector("#pClave") as InputElement).focus();
    return;
  }

  if (pOrdenPP.kilos < 0){
    window.alert("Los kilos no son válidos");
    (querySelector("#pKilos") as InputElement).focus();
    return;
  }

  if (pOrdenPP.cajas < 0){
    window.alert("Las cajas no son válidos");
    (querySelector("#pKilos") as InputElement).focus();
    return;
  }

  if (pOrdenPP.kilos > 0 && pOrdenPP.cajas > 0){
    window.alert("Solo se puede validar cajas o kilos, ponga uno de los dos en cero");
    (querySelector("#pKilos") as InputElement).focus();
    return;
  }

  if (ListaOrdenPP.where((OrdenPP x) => x.producto == pOrdenPP.producto).length > 0){
    window.alert("El producto ya se encuentra en la lista");
    (querySelector("#pClave") as InputElement).focus();
    return;
  }

  (querySelector("#pClave") as InputElement).value       = "";
  (querySelector("#pDescripcion") as InputElement).value = "";
  (querySelector("#pKilos") as InputElement).value       = "0.0";

  (querySelector("#pClave") as InputElement).focus();

  if (pOrdenPP.receta > 0){
    agrega_receta(pOrdenPP.receta, pOrdenPP.kilos, pOrdenPP);
  }
  else{
    ListaOrdenPP.add(pOrdenPP);
    agregarFilaOrdenPP(pOrdenPP);
  }

  var pUrl = "http://localhost:8031/rest/obtener_sobrantes_producto/${pOrdenPP.producto}";

  HttpRequest.getString(pUrl).then((String AData){

    List pLista = JSON.decode(AData);

    if (pLista.length > 0){

      if (window.confirm("El producto tiene formula de producción, ¿agregar los productos?")){

        for (Map item in pLista){
          OrdenPP pOrdenPPTmp = new OrdenPP();
          pOrdenPPTmp.id          = id;
          pOrdenPPTmp.producto    = item['producto'];
          pOrdenPPTmp.descripcion = item['descripcion'];
          pOrdenPPTmp.kilos       = 0.0;
          pOrdenPPTmp.cajas       = 0;
          pOrdenPPTmp.receta      = 0;
          id++;
          ListaOrdenPP.add(pOrdenPPTmp);
          agregarFilaOrdenPP(pOrdenPPTmp);
        }

      }

    }

  });
}

void agregar_produccion_mp(){

  OrdenMP pOrdenMP = new OrdenMP();

  pOrdenMP.id          = id;
  pOrdenMP.producto    = (querySelector("#mClave") as InputElement).value;
  pOrdenMP.descripcion = (querySelector("#mDescripcion") as InputElement).value;
  pOrdenMP.kilos       = double.parse((querySelector("#mKilos") as InputElement).value);
  id++;

  if (pOrdenMP.descripcion.trim().length == 0){
    window.alert("El producto no es válido");
    (querySelector("#pClave") as InputElement).focus();
    return;
  }

  if (pOrdenMP.kilos <= 0){
    window.alert("Los kilos no son válidos");
    (querySelector("#pKilos") as InputElement).focus();
    return;
  }

  if (ListaOrdenPMP.where((OrdenMP x) => x.producto == pOrdenMP.producto).length > 0){
    window.alert("El producto ya se encuentra en la lista");
    (querySelector("#pClave") as InputElement).focus();
    return;
  }

  HttpRequest.getString("http://localhost:8031/obtener_inventario_producto/${pOrdenMP.producto}").then((data){

    double pInventario = JSON.decode(data);

    // if (pOrdenMP.kilos < pInventario){
    ListaOrdenPMP.add(pOrdenMP);
    agregarFilaOrdenMP(pOrdenMP);
    //  }
    //else{
    //  window.alert("No hay suficiente inventario para el producto, existencia ${pInventario.toString()}");
    //  ListaOrdenPMP.add(pOrdenM);
    // }

  });

  (querySelector("#mClave") as InputElement).value       = "";
  (querySelector("#mDescripcion") as InputElement).value = "";
  (querySelector("#mKilos") as InputElement).value       = "0.0";

  (querySelector("#mClave") as InputElement).focus();
}

void eliminar_produccion(item){

  if (window.confirm("¿Eliminar Producción?")){
    ListaOrdenPP.remove(item);
    querySelector("#tr${item.id}").remove();
  }

}

void modificarMateriaPrima(OrdenMP AOrdenMP){
  (querySelector("#idProgramado") as HiddenInputElement).value  = AOrdenMP.id.toString();
  (querySelector("#pProgramadoMP") as InputElement).value = new intl.NumberFormat("#,##0.00").format((AOrdenMP.kilos));
  ModalP.modal("mdlModificarMateriaPrima");
}

void cambiaProgramado(){
  int pId = int.parse((querySelector("#idProgramado") as HiddenInputElement).value);
  String pProgramadoS = (querySelector("#pProgramadoMP") as InputElement).value;
  pProgramadoS = pProgramadoS.replaceAll(',', '');
  double pProgramado = double.parse(pProgramadoS).toDouble();
  OrdenMP pData = ListaOrdenPMP.where((OrdenMP x) => x.id == pId).toList().first;
  pData.kilos = pProgramado;
  (querySelector("#mp_kilos${pData.id}") as TableCellElement).text = new intl.NumberFormat("###0.00").format(pData.kilos);

  ModalP.cierra_modal("mdlModificarMateriaPrima");
}

void eliminar_produccion_mp(item){

  if (window.confirm("¿Eliminar Materia Prima?")){
    ListaOrdenPMP.remove(item);
    (querySelector("#trMP${item.id}") as TableRowElement).remove();
  }

}

void agregaRecetaACombo(Receta item){
  SelectElement pInpClase = querySelector("#pReceta");
  pInpClase.children.add(new Element.html("<option value=\"${item.id}\">${item.descripcion}</option>"));
}

void despliega_producto(){

  String pProducto = (querySelector("#pClave") as InputElement).value;

  if (pProducto.length > 0){

    String pUrl = "http://localhost:8031/rest/productos/obtener_descripcion/${pProducto}";

    HttpRequest.getString(pUrl).then((data){

      var pMap = JSON.decode(data);

      String pCodigo = pMap["clave"];

      print(pMap);
      if (pMap["clave"] != "0"){
        if (pMap["puede_programar"] == "No"){
          window.alert("El producto esta inactivo");  
          (querySelector("#pClave") as InputElement).value = "";
          (querySelector("#pClave") as InputElement).focus();
          return;
        }
        (querySelector("#pDescripcion") as InputElement).value = pMap["descripcion"];
      }
      else{
        window.alert("No existe el producto");
        (querySelector("#pClave") as InputElement).value = "";
        (querySelector("#pClave") as InputElement).focus();
      }
    }).then((data){
      String pUrlRecetas = "http://localhost:8031/recetas_producto/${pProducto}";

      print("...");
      print(pUrlRecetas);

      HttpRequest.getString(pUrlRecetas).then((data){

        Recetas.clear();

        (querySelector("#pReceta") as SelectElement).disabled = false;

        List pLista = JSON.decode(data);

        (querySelector("#pReceta") as SelectElement).children..clear();
        if (pLista.length > 0){
          for (int i = 0; i<= pLista.length -1; i++){
            Receta pReceta = new Receta();
            pReceta.id          = pLista[i]['id'];
            pReceta.descripcion = pLista[i]['descripcion'];

            Recetas.add(pReceta);

            agregaRecetaACombo(pReceta);
          }
        }
        else{
          (querySelector("#pReceta") as SelectElement).disabled = true;
        }

      });
    });
  }

}

void despliega_producto_mp(){

  String pProducto = (querySelector("#mClave") as InputElement).value;

  if (pProducto.length > 0){
    String pUrl = "http://localhost:8031/rest/productos/obtener_descripcion/${pProducto}";

    HttpRequest.getString(pUrl).then((data){

      var pMap = JSON.decode(data);

      String pCodigo = pMap["clave"];

      if (pMap["clave"] != "0"){
        (querySelector("#mDescripcion") as InputElement).value = pMap["descripcion"];
      }
      else{
        window.alert("No existe el producto");
        (querySelector("#mClave") as InputElement).focus();
      }

    });
  }
}

void agregaClaseACombo(Clase item){

  if (inpOrdenEtiquetas.value == "No"){
    if (item.Id == 14){
      return;
    }
  }

  SelectElement pInpClase = querySelector("#inpClase");

  pInpClase.children.add(new Element.html("<option value=\"${item.Id}\">${item.Nombre}</option>"));

}

void refrescarSurtido(){

  if (window.confirm("¿Refrescar surtido?")){

    var pUrl = "http://localhost:8031/rest/refresca_surtido_orden/${ObtenerIdOrden()}";
    print(pUrl);
    HttpRequest.request(pUrl, method: "POST", sendData: "${ObtenerIdOrden()}").then((HttpRequest request){

      window.location.reload();

    });

  }

}

main() async{
  print("Iniciando...");
  var pUrl = "http://localhost:8031/rest/clase_ordenp_obtener_lista";

  HttpRequest.getString(pUrl).then((String Data){

    var pLista = JSON.decode(Data);

    for (Map item in pLista){
      Clase pClase = new Clase.fromMap(item);
      ListaClases.add(pClase);
      agregaClaseACombo(pClase);
    }

    ObtenerOrdenProduccion(ObtenerIdOrden());
  });

  ButtonElement btnAgregarProduccion = querySelector("#btnAgregarProduccion");
  btnAgregarProduccion.onClick.listen((_){
    agregar();
  });


  ButtonElement btnCerrarEditarCajas = querySelector("#btnCerrarEditarCajas");
  btnCerrarEditarCajas.onClick.listen((_){
    ModalP.cierra_modal("mdlEditaCajas");
  });

  ButtonElement btnCerrarEditarCajas2 = querySelector("#btnCerrarEditarCajas2");
  btnCerrarEditarCajas2.onClick.listen((_){
    ModalP.cierra_modal("mdlEditaCajas");
  });

  ButtonElement btnCerrarMdlAgregarProductos = querySelector("#btnCerrarMdlAgregarProductos");
  btnCerrarMdlAgregarProductos.onClick.listen((_){

    ModalP.cierra_modal("mdlAgregarProductos");

  });

  ButtonElement btnCerrarMdlAgregarProductos2 = querySelector("#btnCerrarMdlAgregarProductos2");
  btnCerrarMdlAgregarProductos2.onClick.listen((_){

    ModalP.cierra_modal("mdlAgregarProductos");

  });

  InputElement inpClave = querySelector("#pClave");
  inpClave.onBlur.listen((_){

    despliega_producto();

  });

  ButtonElement btnAceptarAgregarProducto = querySelector("#btnAceptarAgregarProducto");
  btnAceptarAgregarProducto.onClick.listen((_){

    agregar_produccion();

  });

  ButtonElement btnCerrarMdlModificarMateriaPrima = querySelector("#btnCerrarMdlModificarMateriaPrima");
  btnCerrarMdlModificarMateriaPrima.onClick.listen((_){

    ModalP.cierra_modal("mdlModificarMateriaPrima");

  });

  ButtonElement btnCerrarMdlModificarMateriaPrima2 = querySelector("#btnCerrarMdlModificarMateriaPrima2");
  btnCerrarMdlModificarMateriaPrima2.onClick.listen((_){

    ModalP.cierra_modal("mdlModificarMateriaPrima");

  });

  ButtonElement btnCambiaProgramado = querySelector("#btnCambiaProgramado")..onClick.listen((_){
    cambiaProgramado();
  });

  ButtonElement btnAgregarMP = querySelector("#btnAgregarMP")..onClick.listen((_){
    agregar_mp();
  });

  ButtonElement btnMdlAgregarProductosMP = querySelector("#btnMdlAgregarProductosMP")..onClick.listen((_){
    ModalP.cierra_modal("mdlAgregarProductosMP");
  });

  ButtonElement btnMdlAgregarProductosMP2 = querySelector("#btnMdlAgregarProductosMP2")..onClick.listen((_){
    ModalP.cierra_modal("mdlAgregarProductosMP");
  });

  ButtonElement btnAgregarMateriaPrima = querySelector("#btnAgregarMateriaPrima")..onClick.listen((_){
    agregar_produccion_mp();
  });

  ButtonElement btnGuardar = querySelector("#btnGuardar")..onClick.listen((_){
    guardar();
  });

  ButtonElement btnCancelar = querySelector("#btnCancelar")..onClick.listen((_){
    cancelar();
  });

  ButtonElement btnRefrescarSurtido = querySelector("#btnRefrescarSurtido")..onClick.listen((_){
    refrescarSurtido();
  });

  querySelector("#mClave").onBlur.listen((_){

    despliega_producto_mp();

  });

  ButtonElement btnInfoMarinado = querySelector("#btnInfoMarinado")..onClick.listen((_){

    ModalP.modal("mdlMarinado");

  });

  ButtonElement btnCerrarMarinado = querySelector("#btnCerrarMarinado")..onClick.listen((_){

    despliegaMarinado(POrdenProduccion);
    ModalP.cierra_modal("mdlMarinado");

  });

  ButtonElement btnCerrarMarinadoButton = querySelector("#btnCerrarMarinadoButton")..onClick.listen((_){

    despliegaMarinado(POrdenProduccion);
    ModalP.cierra_modal("mdlMarinado");

  });

  ButtonElement btnMarinadoAceptar = querySelector("#btnMarinadoAceptar")..onClick.listen((_){

    POrdenProduccion = ObtenerEntidad();
    ModalP.cierra_modal("mdlMarinado");

  });

  btnInfoCaliente.onClick.listen((_) async{

    ModalP.modal("mdlInfoCaliente");

  });

  ButtonElement btnCerrarInfoCaliente2 = querySelector("#btnCerrarInfoCaliente2")..onClick.listen((_){

    ModalP.cierra_modal("mdlInfoCaliente");

  });

  ButtonElement btnCerrarInfoCaliente = querySelector("#btnCerrarInfoCaliente")..onClick.listen((_){

    ModalP.cierra_modal("mdlInfoCaliente");

  });

  ButtonElement btnInfoCalienteAceptar = querySelector("#btnInfoCalienteAceptar")..onClick.listen((_){

    POrdenProduccion = ObtenerEntidad();
    ModalP.cierra_modal("mdlInfoCaliente");

  });

  /*document.query("#mdlAgregarProductos").classes.remove("hiden");
  document.query("#mdlAgregarProductosMP").classes.remove("hiden");
  document.query("#mdlModificarMateriaPrima").classes.remove("hiden");
  document.query("#mdlEditaCajas").classes.remove("hiden");*/

  Timer.run(()=>(querySelector("#id_orden") as InputElement).focus());

    llenaSelectClientesMaquila();
}