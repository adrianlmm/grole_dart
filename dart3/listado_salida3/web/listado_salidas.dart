import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart' as intl;
import 'quickdialogs.dart' as ModalP;

TableElement pTable = querySelector('#tablaOrdenes') as TableElement;
final SelectElement inpDestino = querySelector('#inpDestino');
final SelectElement inpEstado = querySelector('#inpEstado');
final SelectElement inpClienteMaquila = querySelector('#inpClienteMaquila');

var pNumberFormater = intl.NumberFormat('000000');
var pHost = '';
//var pHost = 'http://localhost:8031';

Future<dynamic> obtenerClientes() async {
  var pCompleter = Completer<dynamic>();

  var pUrl = '$pHost/rest/salidas/get_clientes';

  var pJson = await HttpRequest.getString(pUrl);

  var pResult = jsonDecode(pJson);
  pResult.sort((var s, var d) => (s['nombre'].toString().toUpperCase().compareTo(d['nombre'].toString().toUpperCase())));

  pCompleter.complete(pResult);

  return pCompleter.future;
}

Future<dynamic> obtenerClasesSalidas() async {
  var pCompleter = Completer<dynamic>();

  var pUrl = '$pHost/api/clases_salidas';

  var pJson = await HttpRequest.getString(pUrl);

  List<Map> pResult = jsonDecode(pJson);
  pResult.sort((Map s, Map d) => (s["nombre"].toString().toUpperCase().compareTo(d["nombre"].toString().toUpperCase())));

  pCompleter.complete(pResult);

  return pCompleter.future;
}

Future<dynamic> obtenerClientesMaquila() async {
  var pCompleter = new Completer<dynamic>();
  var pUrl = "$pHost/obtener_clientes_maquila";

  var pJson = await HttpRequest.getString(pUrl);

  pCompleter.complete(jsonDecode(pJson));

  return pCompleter.future;
}

llenaSelectClientesMaquila() async {
  var pListaClientesMaquila = await obtenerClientesMaquila();

  inpClienteMaquila.children.add(Element.html("<option value='0'>Todos</option>"));

  for (var item in pListaClientesMaquila) {
    inpClienteMaquila.children.add(Element.html("<option value='${item["id"]}'>${item["nombre"]}</option>"));
  }
}

void agregaFila(Map AItem) {
  print(AItem);

  var tr = new TableRowElement();

  var td = new TableCellElement()..text = AItem["fechastr"];
  td.style.textAlign = "center";
  tr.children.add(td);

  td = new TableCellElement()
    ..text = pNumberFormater.format(AItem["id"])
    ..id = "td${AItem["id"]}";
  tr.children.add(td);

  td = new TableCellElement()..text = (AItem["docnum"] ?? 0).toString();
  tr.children.add(td);

  td = new TableCellElement()..text = AItem["descripcion"];
  tr.children.add(td);
  td = new TableCellElement()..text = AItem["nombre_destino"];
  tr.children.add(td);
  td = new TableCellElement()..text = AItem["estado"];
  tr.children.add(td);
  td = new TableCellElement()..text = AItem["cliente"];
  tr.children.add(td);
  td = new TableCellElement()..text = AItem["nombre_usuario"];
  tr.children.add(td);
  td = new TableCellElement()..text = (AItem["id_salida"] ?? "").toString();
  tr.children.add(td);

  ButtonElement btnEditar = new Element.html("<button class='btn'><i class='icon-edit'></i></button>")
    ..onClick.listen((_) {
      var pUrl = "http://localhost:8031/salidas/${AItem["id"]}";
      window.location.href = pUrl;
    });

  td = new TableCellElement()..children.add(btnEditar);
  tr.children.add(td);

  ButtonElement btnEliminar = new Element.html("<button class='btn'><i class='icon-trash'></i></button>")
    ..onClick.listen((_) {
      if (window.confirm("¿Eliminar registro?")) {
        var pUrl = "$pHost/rest/salidas/eliminar/${AItem["id"]}";

        HttpRequest.getString(pUrl).then((String Data) {
          Map pResult = jsonDecode(Data);

          window.alert(pResult["mensaje"]);

          if (pResult["error"]) {
            return;
          } else {
            tr.remove();
          }
        });
      }
    })
    ..style.marginLeft = "3px";

  td.children.add(btnEliminar);

  ButtonElement btnBitacora = new Element.html("<button class='btn'><i class='icon-th'></i></button>")
    ..onClick.listen((_) {
      var pUrl = "$pHost/salidas/bitacora_embarques/${AItem["id"]}";
      window.location.href = pUrl;
    })
    ..style.marginLeft = "3px";

  td.children.add(btnBitacora);

  ButtonElement btnExcel = new Element.html("<button class='btn'><i class='icon-th-large'></i></button>")
    ..onClick.listen((_) {
      var pUrl = "$pHost/rest/salidas/obtener_salida_excel/${AItem["id"]}";
      window.location.href = pUrl;
    })
    ..style.marginLeft = '3px';

  td.children.add(btnExcel);
  tr.children.add(td);

  pTable.tBodies[0].children.add(tr);
}

void consultar() async {
  var btnConsultar = querySelector('#btnConsultar') as InputElement;

  try {
    btnConsultar.disabled = true;

    var pFechaIni = (querySelector('#inpFechaInicial') as InputElement).value;
    var pFechaFin = (querySelector('#inpFechaFinal') as InputElement).value;

    window.localStorage['FechaInicial'] = pFechaIni;
    window.localStorage['FechaFinal'] = pFechaFin;

    var pUrl = "$pHost/rest/salidas/obtener_lista?fecha_ini=${pFechaIni}&fecha_fin=${pFechaFin}&destino=${inpDestino.value}&estado=${inpEstado.value}&cliente=${inpClienteMaquila.value}";

    print(pUrl);

    var Data = await HttpRequest.getString(pUrl);

    var pLista = jsonDecode(Data);
    pTable.tBodies[0].children.clear();

    for (var item in pLista) {
      agregaFila(item);
    }
  } finally {
    btnConsultar.disabled = false;
  }
}

void buscar() {
  ModalP.showModal('#mdlBuscar');
  (querySelector('#inpBuscar') as InputElement).select();
  (querySelector('#inpBuscar') as InputElement).focus();
}

void buscarOrden() {
  var pIdOrden = (querySelector('#inpBuscar') as InputElement).value;

  var pUrl = '$pHost/rest/salidas/orden_salida_obtener/${pIdOrden}';

  pTable.tBodies[0].children.clear();

  HttpRequest.getString(pUrl).then((String Data) {
    Map pOrden = jsonDecode(Data);

    if (pOrden['id'] != null) {
      agregaFila(pOrden);
    }

    ModalP.cierraModal("#mdlBuscar");
  });
}

Future llenaDestinos() async {
  var pDestinos = await obtenerClientes();

  pDestinos.forEach((var item) {
    var pOption = OptionElement()
      ..value = item['id'].toString()
      ..text = item['nombre'];

    inpDestino.children.add(pOption);
  });
}

Future init() async {
  var dFormater = intl.DateFormat('dd/MM/yyyy');
  var pFecha = dFormater.format(DateTime.now());
  print(pFecha);
  (querySelector("#inpFechaInicial") as InputElement).value = pFecha;
  (querySelector("#inpFechaFinal") as InputElement).value = pFecha;

  if (window.localStorage.containsKey("FechaInicial")) {
    String pFechaInicial = window.localStorage["FechaInicial"];
    if (pFechaInicial.trim().length > 0) {
      (querySelector("#inpFechaInicial") as InputElement).value = pFechaInicial;
    } else {
      window.localStorage["FechaInicial"] = pFecha;
    }
  }

  if (window.localStorage.containsKey("FechaFinal")) {
    String pFechaFinal = window.localStorage["FechaFinal"];
    if (pFechaFinal.trim().length > 0) {
      (querySelector("#inpFechaFinal") as InputElement).value = window.localStorage["FechaFinal"];
    } else {
      window.localStorage["FechaFinal"] = pFecha;
    }
  }

  print('...');
  print((querySelector("#inpFechaInicial") as InputElement).value);

  (querySelector('#btnConsultar') as InputElement).onClick.listen((_) {
    consultar();
  });

  (querySelector("#btnNuevo") as ButtonElement).onClick.listen((_) {
    window.location.href = "$pHost/salidas/0";
  });

  (querySelector("#btnBuscar") as ButtonElement).onClick.listen((_) {
    buscar();
  });

  (querySelector("#btnAceptarBusqueda") as InputElement).onClick.listen((_) {
    buscarOrden();
  });

  (querySelector("#btnCancelarBusqueda") as InputElement).onClick.listen((_) {
    ModalP.cierraModal("#mdlBuscar");
  });

  llenaDestinos();
  await llenaSelectClientesMaquila();
}

void main() {
  init();
  consultar();
}
