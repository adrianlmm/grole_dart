// ignore_for_file: non_constant_identifier_names, collection_methods_unrelated_type, prefer_is_empty
import 'dart:html';
import 'dart:convert';

HiddenInputElement inpFolio = querySelector("#inpFolio") as HiddenInputElement;
InputElement inpDescripcion = querySelector("#inpDescripcion") as InputElement;
InputElement inpClaveProducto = querySelector("#inpClaveProducto") as InputElement;
InputElement inpDescripcionProducto = querySelector("#inpDescripcionProducto") as InputElement;
InputElement inpCantidad = querySelector("#inpCantidad") as InputElement;
ButtonElement btnAgregar = querySelector("#btnAgregar") as ButtonElement;
ButtonElement btnGuardar = querySelector("#btnGuardar") as ButtonElement;
ButtonElement btnCancelar = querySelector("#btnCancelar") as ButtonElement;
TableElement tableData = querySelector("#tableData") as TableElement;

List<Map> ListaDetalle = List<Map>.empty(growable: true);
int i = 99999;
var s = <int, String>{};

void eliminaRegistro(int AId) {
  ListaDetalle.removeWhere((Map item) => item["id"] == AId);
  (querySelector("#tr$AId") as TableRowElement).remove();
}

void clearEdits() {
  inpClaveProducto.value = "";
  inpDescripcionProducto.value = "";
  inpCantidad.value = "1";
}

inpClaveBlur(_) {
  var pProducto = inpClaveProducto.value!.trim();

  if (pProducto.length > 0) {
    var pUrl = "http://localhost:8031/rest/productos/obtener_descripcion/$pProducto";

    HttpRequest.getString(pUrl).then((String Data) {
      Map pProducto = jsonDecode(Data);

      inpDescripcionProducto.value = pProducto["descripcion"];
    });
  }
}

Map obtenerFilaEntidad() {
  Map pResult = {};
  pResult["id"] = i;
  i++;
  pResult["producto"] = inpClaveProducto.value;
  pResult["descripcion"] = inpDescripcionProducto.value;
  pResult["cajas"] = inpCantidad.value;

  return pResult;
}

bool agregarFila(Map AItem) {
  int pCantidad = 0;

  try {
    pCantidad = int.parse(AItem["cajas"]!);
  } catch (_) {
    try {
      pCantidad = AItem["cajas"] as int;
    } catch (__) {
      pCantidad = 0;
    }
  }

  if (pCantidad <= 0) {
    window.alert("Cantidad no es válida");
    inpCantidad.select();
    inpCantidad.focus();
    return false;
  }

  if (ListaDetalle.where((var item) => item["producto"] == AItem["producto"]).isNotEmpty) {
    window.alert("Error, el producto ya esta en la lista");
    inpClaveProducto.select();
    inpClaveProducto.focus();
    return false;
  }

  ListaDetalle.add(AItem);

  TableRowElement tr = TableRowElement()..id = "tr${AItem["id"]}";

  var td = TableCellElement()..text = AItem["producto"].toString();
  tr.children.add(td);
  td = TableCellElement()..text = AItem["descripcion"];
  tr.children.add(td);
  td = TableCellElement()..text = AItem["cajas"].toString();
  td.id = "tdCajas${AItem['id']}";
  td.dataset['mode'] = "normal";
  tr.children.add(td);

  Element btnModificar = Element.html("<button>Editar</button>");
  btnModificar.onClick.listen((_) {
    var pTd = querySelector("#tdCajas${AItem['id']}") as TableCellElement;
    if (pTd.dataset['mode'] == "normal") {
      var inpCajasTmp = InputElement();
      inpCajasTmp.value = AItem["cajas"].toString();
      pTd.dataset['mode'] = "edit";
      btnModificar.text = "Guardar";
      pTd.children.clear();
      pTd.children.add(inpCajasTmp);
    } else {
      pTd.dataset['mode'] = "normal";
      btnModificar.text = "Editar";
      
    }
  });

  Element btnEliminar = Element.html("<button><i class='icon-trash'><i></button>");
  btnEliminar.onClick.listen((_) {
    if (window.confirm("¿Eliminar Registro?")) {
      eliminaRegistro(AItem["id"] as int);
    }
  });

  td = TableCellElement()..children.add(btnModificar);
  td.children.add(btnEliminar);
  tr.children.add(td);
  tableData.tBodies[0].children.add(tr);

  return true;
}

String ObtenerEntidad() {
  var pResult = {};
  pResult["id"] = int.parse(inpFolio.value!);
  pResult["descripcion"] = inpDescripcion.value;
  pResult["detalle"] = ListaDetalle;

  return jsonEncode(pResult);
}

void guardar() {
  String pUrl = "http://localhost:8031/insertar_estimacion_empaque";
  String pData = ObtenerEntidad();

  HttpRequest.request(pUrl, method: "POST", sendData: pData).then((HttpRequest ARequest) {
    window.location.href = "http://localhost:8031/estimacion_empaque";
  });
}

void cancelar() {
  if (window.confirm("¿Cancelar captura?")) {
    window.location.href = "http://localhost:8031/estimacion_empaque";
  }
}

void despliegaEntidad(Map AEstimacion) {
  inpDescripcion.value = AEstimacion["descripcion"];

  for (var item in AEstimacion["detalle"]) {
    agregarFila(item);
  }
}

void obtenerEstimacion() {
  var pUrl = "http://localhost:8031/rest/estimacion_empaque/${inpFolio.value}'";
  HttpRequest.getString(pUrl).then((String AData) {
    Map pEstimacion = jsonDecode(AData);
    despliegaEntidad(pEstimacion);
  });
}

void main() {
  btnAgregar.onClick.listen((_) {
    if (agregarFila(obtenerFilaEntidad())) {
      clearEdits();
      inpClaveProducto.focus();
    }
  });

  inpClaveProducto.onBlur.listen((_) {
    inpClaveBlur(_);
  });

  btnGuardar.onClick.listen((_) {
    guardar();
  });

  btnCancelar.onClick.listen((_) {
    cancelar();
  });

  obtenerEstimacion();
}
