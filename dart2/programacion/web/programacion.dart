import 'dart:html';
import 'dart:async';
import 'dart:convert';

final HiddenInputElement inpId            = querySelector("#inpId");
final HiddenInputElement inpIdUsuario     = querySelector("#inpIdUsuario");
final HiddenInputElement inpNombreUsuario = querySelector("#inpNombreUsuario");
final InputElement inpFechaInicial        = querySelector("#inpFechaInicial");
final InputElement inpFechaFinal          = querySelector("#inpFechaFinal");
final InputElement inpDescripcion         = querySelector("#inpDescripcion");
final TableElement tablaDetalle           = querySelector("#tablaDetalle");
final ButtonElement btnGuardar            = querySelector("#btnGuardar");
final ButtonElement btnCancelar           = querySelector("#btnCancelar");
final InputElement inpProducto0           = querySelector("#inpProducto0");
final InputElement inpDescripcion0        = querySelector("#inpDescripcion0");
final InputElement inpCajas0              = querySelector("#inpCajas0");
final InputElement inpKilos0              = querySelector("#inpKilos0");
final ButtonElement btnAgregar            = querySelector("#btnAgregar");

Map gProgramacion = null;
List<Map> gListaDetalle =  new List<Map>();
Map<int, Map> gRowTmp = new Map<int, Map>();

int pIndice = 9999999;

Future<Map> obtenerProgramacion(int AId) async {

    Completer<Map> pCompleter = new Completer<Map>();

    String pUrl = "http://localhost:8031/programacion/" + AId.toString();

    String pResultStr = await HttpRequest.getString(pUrl);

    pCompleter.complete(JSON.decode(pResultStr));

    return pCompleter.future;

}

Future<List<Map>> obtenerDetalleProgramacion(int AId) async {

  Completer<List<Map>> pCompleter = new Completer<List<Map>>();

  String pUrl = "http://localhost:8031/programacion_detalle/" + AId.toString();

  String pResultStr = await HttpRequest.getString(pUrl);

  pCompleter.complete(JSON.decode(pResultStr));

  return pCompleter.future;

}

Future<String> obtenerDescripcionProducto(String AClave) async{

  Completer<String> pCompleter = new Completer<String>();

  var pUrl = "http://localhost:8031/rest/productos/obtener_descripcion2/$AClave";

  String pResultStr = await HttpRequest.getString(pUrl);

  pCompleter.complete(JSON.decode(pResultStr));
  return pCompleter.future;
}

void despliegaEntidad(Map AData){

  inpFechaInicial.value = AData["fecha_inicial"];
  inpFechaFinal.value   = AData["fecha_final"];
  inpDescripcion.value  = AData['descripcion'];

}

Map obtenerEntidad(){

  Map pResult = new Map();

  pResult["id"]             = inpId.value;
  pResult["fecha_inicial"]  = inpFechaInicial.value;
  pResult["fecha_final"]    = inpFechaFinal.value;
  pResult["descripcion"]    = inpDescripcion.value;
  pResult["id_usuario"]     = int.parse(inpIdUsuario.value);
  pResult["nombre_usuario"] = inpNombreUsuario.value;
  pResult["detalle"]        = gListaDetalle;

  return pResult;
}

void limpiaEdits(){
    inpProducto0.value = "";
    inpDescripcion0.value = "";
    inpCajas0.value = "1";
    inpKilos0.value = "0";
}

Map obtenerDetalle(int AId){

    InputElement inpProductoTmp = querySelector("#inpProducto$AId");
    InputElement inpDescripcionTmp = querySelector("#inpDescripcion$AId");
    InputElement inpCajasTmp = querySelector("#inpCajas$AId");
    InputElement inpKilosTmp = querySelector("#inpKilos$AId");

    Map pResult = new Map();

    pResult["id"]          = AId;
    pResult["producto"]    = inpProductoTmp.value;
    pResult["descripcion"] = inpDescripcionTmp.value;
    pResult["cajas"]       = int.parse(inpCajasTmp.value);
    pResult["kilos"]       = double.parse(inpKilosTmp.value);

    return pResult;

}

void onClickModificar(Map AData){

  (querySelector("#btnModificarTmp${AData["id"]}") as ButtonElement).style.display = "none";
  (querySelector("#btnEliminarTmp${AData["id"]}") as ButtonElement).style.display = "none";
  (querySelector("#btnCancelarTmp${AData["id"]}") as ButtonElement).style.display = "inline";
  (querySelector("#btnAceptarTmp${AData["id"]}") as ButtonElement).style.display = "inline";

  TableRowElement trTmp = querySelector("#tr${AData["id"]}");

  Map pDataTmp = new Map();
  pDataTmp["producto"] = trTmp.children[0].text;
  pDataTmp["descripcion"] = trTmp.children[1].text;
  pDataTmp["cajas"] = trTmp.children[2].text;
  pDataTmp["kilos"] = trTmp.children[3].text;

  gRowTmp[AData["id"]] = pDataTmp;

  trTmp.children[0].children.clear();
  trTmp.children[1].children.clear();
  trTmp.children[2].children.clear();
  trTmp.children[3].children.clear();

  InputElement inpProductoTmp = new InputElement();
  inpProductoTmp.value = pDataTmp["producto"];
  inpProductoTmp.id = "inpProductoTmp${AData["id"]}";
  trTmp.children[0].children.add(inpProductoTmp);

  InputElement inpDescripcionTmp = new InputElement();
  inpDescripcionTmp.id = "inpDescripcionTmp${AData["id"]}";
  inpDescripcionTmp.value = pDataTmp["descripcion"];
  inpDescripcionTmp.readOnly = true;
  trTmp.children[1].children.add(inpDescripcionTmp);

  InputElement inpCajasTmp = new InputElement();
  inpCajasTmp.id = "inpCajasTmp${AData["id"]}";
  inpCajasTmp.value = pDataTmp["cajas"];
  inpCajasTmp.style.textAlign = "rigth";
  trTmp.children[2].children.add(inpCajasTmp);

  InputElement inpKilosTmp = new InputElement();
  inpKilosTmp.id = "inpKilosTmp${AData["id"]}";
  inpKilosTmp.value = pDataTmp["kilos"];
  inpKilosTmp.style.textAlign = "rigth";
  trTmp.children[3].children.add(inpKilosTmp);

  inpProductoTmp.onBlur.listen((_) async{
    if (inpProductoTmp.value.trim().length > 0){

      String pDescripcion = await obtenerDescripcionProducto(inpProductoTmp.value);
      if (pDescripcion == "???"){
        window.alert("No se encontro el producto");
        inpDescripcionTmp.value = "";
        inpProductoTmp.focus();
        return;
      }

      inpDescripcionTmp.value = pDescripcion;
      inpCajasTmp.focus();
    }
  });

  inpProductoTmp.focus();
}

void onClickCancelar(Map AData){

  (querySelector("#btnModificarTmp${AData["id"]}") as ButtonElement).style.display = "inline";
  (querySelector("#btnEliminarTmp${AData["id"]}") as ButtonElement).style.display = "inline";
  (querySelector("#btnAceptarTmp${AData["id"]}") as ButtonElement).style.display = "none";
  (querySelector("#btnCancelarTmp${AData["id"]}") as ButtonElement).style.display = "none";

  TableRowElement trTmp = querySelector("#tr${AData["id"]}");

  Map pDetalle = gRowTmp[AData["id"]];

  trTmp.children[0].children.clear();
  trTmp.children[1].children.clear();
  trTmp.children[2].children.clear();
  trTmp.children[3].children.clear();

  trTmp.children[0].text = pDetalle["producto"];
  trTmp.children[1].text = pDetalle["descripcion"];
  trTmp.children[2].text = pDetalle["cajas"];
  trTmp.children[3].text = pDetalle["kilos"];


}

void onClickAceptar(Map AData) {

  TableRowElement trTmp = querySelector("#tr${AData["id"]}");

  (querySelector("#btnModificarTmp${AData["id"]}") as ButtonElement).style.display = "inline";
  (querySelector("#btnEliminarTmp${AData["id"]}") as ButtonElement).style.display = "inline";
  (querySelector("#btnAceptarTmp${AData["id"]}") as ButtonElement).style.display = "none";
  (querySelector("#btnCancelarTmp${AData["id"]}") as ButtonElement).style.display = "none";

  InputElement inpProductoTmp    = querySelector("#inpProductoTmp${AData["id"]}");
  InputElement inpDescripcionTmp = querySelector("#inpDescripcionTmp${AData["id"]}");
  InputElement inpCajasTmp       = querySelector("#inpCajasTmp${AData["id"]}");
  InputElement inpKilosTmp       = querySelector("#inpKilosTmp${AData["id"]}");

  trTmp.children[0].children.clear();
  trTmp.children[1].children.clear();
  trTmp.children[2].children.clear();
  trTmp.children[3].children.clear();

  trTmp.children[0].text = inpProductoTmp.value;
  trTmp.children[1].text = inpDescripcionTmp.value;
  trTmp.children[2].text = inpCajasTmp.value;
  trTmp.children[3].text = inpKilosTmp.value;

  gListaDetalle.removeWhere((x) => x["id"] == AData["id"]);
  Map pDetalle = new Map();

  pDetalle["id"]          = AData["id"];
  pDetalle["producto"]    = inpProductoTmp.value;
  pDetalle["descripcion"] = inpDescripcionTmp.value;
  pDetalle["cajas"]       = int.parse(inpCajasTmp.value);
  pDetalle["kilos"]       = double.parse(inpKilosTmp.value);

  gListaDetalle.add(pDetalle);

}

void onClickEliminar(Map AData){

    if (window.confirm("¿Eliminar Registro?")){

      gListaDetalle.removeWhere((x) => x["id"] == AData["id"]);
      (querySelector("#tr${AData["id"]}") as TableRowElement).remove();

    }

}

void agregarDetalle(Map AData){

    TableRowElement tr = new TableRowElement();
    tr.id = "tr${AData["id"]}";

    TableCellElement td = new TableCellElement();
    td.text = AData["producto"];
    tr.children.add(td);

    td = new TableCellElement();
    td.text = AData["descripcion"];
    tr.children.add(td);

    td = new TableCellElement();
    td.text = AData["cajas"].toString();
    td.style.textAlign = "right";
    tr.children.add(td);

    td = new TableCellElement();
    td.text = AData["kilos"].toStringAsFixed(2);
    td.style.textAlign = "right";
    tr.children.add(td);

    td = new TableCellElement();
    td.style.textAlign = "center";

    ButtonElement btnModificarTmp = new ButtonElement();
    btnModificarTmp.id = "btnModificarTmp${AData["id"]}";
    btnModificarTmp.text = "M";
    btnModificarTmp.style.fontWeight = "bold";
    btnModificarTmp.onClick.listen((_){
      onClickModificar(AData);
    });

    ButtonElement btnEliminarTmp = new ButtonElement();
    btnEliminarTmp.id = "btnEliminarTmp${AData["id"]}";
    btnEliminarTmp.style.marginLeft = "5px";
    btnEliminarTmp.text = "E";
    btnEliminarTmp.style.fontWeight = "bold";
    btnEliminarTmp.onClick.listen((_){
      onClickEliminar(AData);
    });

    ButtonElement btnCancelarTmp = new ButtonElement();
    btnCancelarTmp.id = "btnCancelarTmp${AData["id"]}";
    btnCancelarTmp.style.display = "none";
    btnCancelarTmp.style.marginLeft = "5px";
    btnCancelarTmp.text = "X";
    btnCancelarTmp.style.fontWeight = "bold";
    btnCancelarTmp.onClick.listen((_){
      onClickCancelar(AData);
    });

    ButtonElement btnAceptarTmp = new ButtonElement();
    btnAceptarTmp.id = "btnAceptarTmp${AData["id"]}";
    btnAceptarTmp.style.marginLeft = "5px";
    btnAceptarTmp.style.display = "none";
    btnAceptarTmp.text = "G";
    btnAceptarTmp.style.fontWeight = "bold";
    btnAceptarTmp.onClick.listen((_){
      print(gListaDetalle);
      onClickAceptar(AData);
      print(gListaDetalle);
    });

    td.children.add(btnModificarTmp);
    td.children.add(btnEliminarTmp);
    td.children.add(btnAceptarTmp);
    td.children.add(btnCancelarTmp);
    tr.children.add(td);

    tablaDetalle.tBodies[0].children.add(tr);
}

Future<Map> guardar(Map AData) async{

  Completer<Map> pCompleter = new Completer<Map>();

  var pUrl = "http://localhost:8031/programacion_insertar";
  var pData = JSON.encode(AData);

  HttpRequest pResponse = await HttpRequest.request(pUrl, method: "POST", sendData: pData);

  String pResponseStr = pResponse.responseText.replaceAll("\\", "");

  pCompleter.complete(JSON.decode(pResponseStr));

  return pCompleter.future;
}

Future inicializa() async{

    gProgramacion = await obtenerProgramacion(int.parse(inpId.value));
    despliegaEntidad(gProgramacion);
    gListaDetalle = await obtenerDetalleProgramacion(int.parse(inpId.value));

    for (var item in gListaDetalle){
      item["descripcion"] = item["nombre_producto"];
      agregarDetalle(item);
    }

    btnGuardar.onClick.listen((_) async{
       Map pData = await guardar(obtenerEntidad());
       window.alert("Programación guardada con éxito, folio ${pData["id"]}");

       if (window.opener != null)
       {
           var pUri = window.location.protocol + '//' + window.location.host + '/';
           print("postmessage:" + pUri);
           var msj = JSON.encode(pData);
           print("msj:" + msj);
           window.opener.postMessage(msj, pUri);
           print("mensaje enviado");
           window.close();
       }

    });

    btnCancelar.onClick.listen((_){

      if (window.confirm("¿Cancelar Captura?")){
          window.close();
      }

    });

    btnAgregar.onClick.listen((_){

        Map pDetalle = obtenerDetalle(0);
        pDetalle["id"] = pIndice;
        pIndice++;

        gListaDetalle.add(pDetalle);
        agregarDetalle(pDetalle);

        limpiaEdits();
        inpProducto0.focus();
    });

    inpProducto0.onBlur.listen((_) async{

      if (inpProducto0.value.trim().length > 0){

          String pDescripcion = await obtenerDescripcionProducto(inpProducto0.value);
          if (pDescripcion == "???"){
              window.alert("No se encontro el producto");
              inpDescripcion0.value = "";
              inpProducto0.focus();
              return;
          }

          inpDescripcion0.value = pDescripcion;
          inpCajas0.focus();
      }

    });

}


main() async {

  await inicializa();

}
