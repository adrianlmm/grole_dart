import 'dart:html';
import 'dart:async';
import 'dart:convert';

final InputElement inpFecha     = querySelector("#inpFecha");
final InputElement inpClave0    = querySelector("#inpClave0");
final InputElement inpClaveSAP0 = querySelector("#inpClaveSAP0");
final InputElement inpNombre0   = querySelector("#inpNombre0");
final InputElement inpCajas0    = querySelector("#inpCajas0");
final InputElement inpKilos0    = querySelector("#inpKilos0");
final ButtonElement btnAgregar  = querySelector("#btnAgregar");
final ButtonElement btnConsultar = querySelector("#btnConsultar");
final TableElement tablaDetalle = querySelector("#tablaDetalle");

List<Map> gProyeccion = new List<Map>();
int gID = 0;

Future<Map> obtenerProducto(String AClave) async{

  String pUrl  = "http://localhost:8031/rest/productos/obtener_descripcion?query=$AClave";
  String pJSON = await HttpRequest.getString(pUrl);

  return JSON.decode(pJSON);

}

Future<String> insertaProyeccion(Map AEntidad) async{

  String pUrl = "http://localhost:8031/rest/proyeccion/insertar";
  String pData = JSON.encode(AEntidad);

  HttpRequest pResponse = await HttpRequest.request(pUrl, method: "POST", mimeType: "applicarion/json", sendData: pData);

  return pResponse.responseText;
}

Future<String> actualizarProyeccion(Map AEntidad) async{

  String pUrl = "http://localhost:8031/rest/proyeccion/actualizar";
  String pData = JSON.encode(AEntidad);

  HttpRequest pResponse = await HttpRequest.request(pUrl, method: "POST", mimeType: "applicarion/json", sendData: pData);

  return pResponse.responseText;
}

Future<String> eliminarProyeccion(Map AEntidad) async{

  String pUrl = "http://localhost:8031/rest/proyeccion/eliminar";
  String pData = JSON.encode(AEntidad);

  HttpRequest pResponse = await HttpRequest.request(pUrl, method: "POST", mimeType: "applicarion/json", sendData: pData);

  return pResponse.responseText;
}

Future<List<Map>> obtenerLista(String AFecha) async{

  var pUrl = "http://localhost:8031/rest/lista_proyeccion?fecha=${AFecha}";
  String pJSON = await HttpRequest.getString(pUrl);

  return JSON.decode(pJSON);

}

Map obtenerEntidad(int AId){

  Map pResult = new Map();

  InputElement inpClaveTmp    = querySelector("#inpClave$AId");
  InputElement inpClaveSapTmp = querySelector("#inpClaveSAP$AId");
  InputElement inpNombreTmp   = querySelector("#inpNombre$AId");
  InputElement inpCajasTmp    = querySelector("#inpCajas$AId");
  InputElement inpKilosTmp    = querySelector("#inpCajas$AId");

  pResult["id"]          = gID;
  gID++;
  pResult["fecha"]       = inpFecha.value;
  pResult["producto"]    = inpClaveTmp.value;
  pResult["codigosap"]   = inpClaveSapTmp.value;
  pResult["descripcion"] = inpNombreTmp.value;
  pResult["cajas"]       = int.parse(inpCajasTmp.value);
  pResult["kilos"]       = double.parse(inpKilosTmp.value);
  
  return pResult;
}

TableRowElement getEditRow(){

  TableRowElement tr = document.querySelector("#trTmp");
  return tr.clone(true);

}

Map getRowValue(int AId){

  Map pResult = new Map();
  var pId = "#td$AId";
  pResult["producto"]    = (document.querySelector(pId) as TableCellElement).text;
  pResult["codigosap"]   = (querySelector("#tdCodigoSap$AId") as TableCellElement).text;
  pResult["descripcion"] = (querySelector("#tdDescripcion$AId") as TableCellElement).text;
  pResult["cajas"]       = (querySelector("#tdCajas$AId") as TableCellElement).text;
  pResult["kilos"]       = (querySelector("#tdKilos$AId") as TableCellElement).text;

  return pResult;
}

Map getRowValueEdit(int AId){

  Map pResult = new Map();
  pResult["id"]          = AId;
  pResult["producto"]    = (querySelector("#inpClave$AId") as InputElement).value;
  pResult["codigosap"]   = (querySelector("#inpClaveSAP$AId") as InputElement).value;
  pResult["descripcion"] = (querySelector("#inpNombre$AId") as InputElement).value;
  pResult["cajas"]       = int.parse((querySelector("#inpCajas$AId") as InputElement).value);
  pResult["kilos"]       = double.parse((querySelector("#inpKilos$AId") as InputElement).value);
  pResult["fecha"]       = inpFecha.value;

  return pResult;
}

void agregarFila(Map AItem){

  TableRowElement tr = new TableRowElement();
  tr.id = "tr${AItem["id"]}";

  TableCellElement td = new TableCellElement();
  td.id = "td${AItem["id"]}";
  td.text = AItem["producto"];
  tr.children.add(td);

  td = new TableCellElement();
  td.text = AItem["codigosap"];
  td.id = "tdCodigoSap${AItem["id"]}";
  tr.children.add(td);

  td = new TableCellElement();
  td.id = "tdDescripcion${AItem["id"]}";
  td.text = AItem["descripcion"];
  tr.children.add(td);

  td = new TableCellElement();
  td.id = "tdCajas${AItem["id"]}";
  td.text = AItem["cajas"].toString();
  td.style.textAlign = "right";
  tr.children.add(td);

  td = new TableCellElement();
  td.id = "tdKilos${AItem["id"]}";
  td.text = AItem["kilos"].toStringAsFixed(2);
  td.style.textAlign = "right";
  tr.children.add(td);

  ButtonElement btnEliminarTmp  = new ButtonElement()..text = "E"..style.fontWeight = "bold";
  ButtonElement btnModificarTmp = new ButtonElement()..text = "M"..style.fontWeight = "bold";
  ButtonElement btnGuardarTmp   = new ButtonElement()..text = "G"..style.fontWeight = "bold";
  ButtonElement btnCancelarTmp  = new ButtonElement()..text = "X"..style.fontWeight = "bold";

  btnGuardarTmp.style.display  = "none";
  btnCancelarTmp.style.display = "none";

  td = new TableCellElement();
  td.children.add(btnEliminarTmp);
  td.children.add(new SpanElement()..text = "  ");
  td.children.add(btnModificarTmp);
  td.children.add(new SpanElement()..text = "  ");
  td.children.add(btnGuardarTmp);
  td.children.add(new SpanElement()..text = "  ");
  td.children.add(btnCancelarTmp);
  tr.children.add(td);
  
  tablaDetalle.tBodies[0].children.add(tr);

  btnEliminarTmp.onClick.listen((_) async{

    if (window.confirm("¿Eliminar registro?")){

        TableCellElement pTdTmp = querySelector("#td${AItem["id"]}");
        var pLista = gProyeccion.where((x) => x["producto"] == pTdTmp.text).toList();
        await eliminarProyeccion(pLista.first);
        tr.remove();
        gProyeccion.removeWhere((x) => x["producto"] == pTdTmp.text);

    }

  });

  Map pValuesTmp = getRowValue(AItem["id"]);

  btnModificarTmp.onClick.listen((_) {

      btnGuardarTmp.style.display   = "inline";
      btnCancelarTmp.style.display  = "inline";
      btnEliminarTmp.style.display  = "none";
      btnModificarTmp.style.display = "none";

      TableRowElement trTmp = getEditRow();
      TableCellElement tdProducto = (querySelector("#td${AItem["id"]}") as TableCellElement);
      TextInputElement inpProducto = trTmp.children[0].children[0];
      inpProducto.id = "inpClave${AItem["id"]}";
      inpProducto.value = pValuesTmp["producto"];
      tdProducto.children.clear();
      tdProducto.children.add(inpProducto);

      inpProducto.onBlur.listen((_) => onBlurClave(AItem["id"]));

      TableCellElement tdCodigoSap = (querySelector("#tdCodigoSap${AItem["id"]}") as TableCellElement);
      TextInputElement inpCodigoSap = trTmp.children[1].children[0];
      inpCodigoSap.id = "inpClaveSAP${AItem["id"]}";
      inpCodigoSap.value = pValuesTmp["codigosap"];
      inpCodigoSap.readOnly = true;
      tdCodigoSap.children.clear();
      tdCodigoSap.children.add(inpCodigoSap);

      TableCellElement tdDescripcion = (querySelector("#tdDescripcion${AItem["id"]}") as TableCellElement);
      TextInputElement inpDescripcion = trTmp.children[2].children[0];
      inpDescripcion.id = "inpNombre${AItem["id"]}";
      inpDescripcion.value = pValuesTmp["descripcion"];
      inpDescripcion.readOnly = true;
      tdDescripcion.children.clear();
      tdDescripcion.children.add(inpDescripcion);

      TableCellElement tdCajas = (querySelector("#tdCajas${AItem["id"]}") as TableCellElement);
      TextInputElement inpCajas = trTmp.children[3].children[0];
      inpCajas.id = "inpCajas${AItem["id"]}";
      inpCajas.value = pValuesTmp["cajas"];
      tdCajas.children.clear();
      tdCajas.children.add(inpCajas);

      TableCellElement tdKilos = (querySelector("#tdKilos${AItem["id"]}") as TableCellElement);
      TextInputElement inpKilos = trTmp.children[4].children[0];
      inpKilos.id = "inpKilos${AItem["id"]}";
      inpKilos.value = pValuesTmp["kilos"];
      tdKilos.children.clear();
      tdKilos.children.add(inpKilos);

      inpProducto.focus();
      inpProducto.select();

  });

  btnCancelarTmp.onClick.listen((_){

    TableCellElement tdProducto = (querySelector("#td${AItem["id"]}") as TableCellElement);
    tdProducto.children.clear();
    tdProducto.text = pValuesTmp["producto"];

    TableCellElement tdCodigoSap = (querySelector("#tdCodigoSap${AItem["id"]}") as TableCellElement);
    tdCodigoSap.children.clear();
    tdCodigoSap.text = pValuesTmp["codigosap"];

    TableCellElement tdDescripcion = (querySelector("#tdDescripcion${AItem["id"]}") as TableCellElement);
    tdDescripcion.children.clear();
    tdDescripcion.text = pValuesTmp["descripcion"];

    TableCellElement tdCajas = (querySelector("#tdCajas${AItem["id"]}") as TableCellElement);
    tdCajas.children.clear();
    tdCajas.text = pValuesTmp["cajas"];

    TableCellElement tdKilos = (querySelector("#tdKilos${AItem["id"]}") as TableCellElement);
    tdKilos.children.clear();
    tdKilos.text =pValuesTmp["kilos"];

    btnGuardarTmp.style.display   = "none";
    btnCancelarTmp.style.display  = "none";
    btnEliminarTmp.style.display  = "inline";
    btnModificarTmp.style.display = "inline";

  });

  btnGuardarTmp.onClick.listen((_) async{

    Map pValueTmp = getRowValueEdit(AItem["id"]);

    await actualizarProyeccion(pValueTmp);

    TableCellElement tdProducto = (querySelector("#td${AItem["id"]}") as TableCellElement);
    tdProducto.children.clear();
    tdProducto.text = pValueTmp["producto"];

    TableCellElement tdCodigoSap = (querySelector("#tdCodigoSap${AItem["id"]}") as TableCellElement);
    tdCodigoSap.children.clear();
    tdCodigoSap.text = pValueTmp["codigosap"];

    TableCellElement tdDescripcion = (querySelector("#tdDescripcion${AItem["id"]}") as TableCellElement);
    tdDescripcion.children.clear();
    tdDescripcion.text = pValueTmp["descripcion"];

    TableCellElement tdCajas = (querySelector("#tdCajas${AItem["id"]}") as TableCellElement);
    tdCajas.children.clear();
    tdCajas.text = pValueTmp["cajas"];

    TableCellElement tdKilos = (querySelector("#tdKilos${AItem["id"]}") as TableCellElement);
    tdKilos.children.clear();
    tdKilos.text = pValueTmp["kilos"].toStringAsFixed(2);

    btnGuardarTmp.style.display   = "none";
    btnCancelarTmp.style.display  = "none";
    btnEliminarTmp.style.display  = "inline";
    btnModificarTmp.style.display = "inline";

  });
}

onBlurClave(int AId) async{

  InputElement inpClaveTmp    = querySelector("#inpClave$AId");

  if (inpClaveTmp.value.trim().length > 0){
      InputElement inpClaveSapTmp = querySelector("#inpClaveSAP$AId");
      InputElement inpNombreTmp   = querySelector("#inpNombre$AId");
      InputElement inpCajasTmp    = querySelector("#inpCajas$AId");

      Map pProducto = await obtenerProducto(inpClaveTmp.value);

      inpClaveSapTmp.value = pProducto["clavesap"];
      inpNombreTmp.value   = pProducto["descripcion"];
      inpCajasTmp.focus();
      inpCajasTmp.select();
  }

}

void limpiaEdits(){

  inpClave0.value    = "";
  inpClaveSAP0.value = "";
  inpNombre0.value   = "";
  inpCajas0.value    = "1";
  inpKilos0.value    = "1";
  inpClave0.focus();

}

init() async{
  Completer<int> pCompleter = new Completer<int>();
  var pFecha = new DateTime.now();
  inpFecha.value = pFecha.day.toString().padLeft(2, "0") + "/" + pFecha.month.toString().padLeft(2, "0") + "/" + pFecha.year.toString();
  inpClave0.onBlur.listen((_) async => onBlurClave(0));
  btnAgregar.onClick.listen((_) {
   
    Map pEntidad = obtenerEntidad(0);

    if (gProyeccion.where((x) => x["producto"] == pEntidad["producto"]).length > 0){
      window.alert("Error, el producto ya está en la lista");
      return;
    }

    gProyeccion.add(pEntidad);

    insertaProyeccion(pEntidad);
    agregarFila(pEntidad);

    limpiaEdits();

  });

  btnConsultar.onClick.listen((_) async{
    tablaDetalle.tBodies[0].children.clear();
    gProyeccion = await obtenerLista(inpFecha.value);
    gProyeccion.forEach((item) => agregarFila(item));
  });
  
  pCompleter.complete(1);
  return pCompleter.future;
}

main() async{
  await init();
  gProyeccion = await obtenerLista(inpFecha.value);
  gProyeccion.forEach((item) => agregarFila(item));
}
