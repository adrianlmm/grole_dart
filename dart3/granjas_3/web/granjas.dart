// ignore_for_file: non_constant_identifier_names

import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'granja.dart';
import 'empresa.dart';

bool permite_edicion = false;
bool modo_insercion = true;
int pScrollY = 0;

final InputElement inpClave = querySelector("#clave") as InputElement;
final InputElement inpNombre = querySelector('#nombre') as InputElement;
final TableElement tablaGranjas = querySelector("#tablaGranjas") as TableElement;
final ButtonElement btnNuevaGranja = querySelector("#btnNuevaGranja") as ButtonElement;
final pHost = "";

List<Granja> lista_granja = <Granja>[];
var lista_empresas = <Empresa>[];

Future<List<Empresa>> getEmpresas() async {
  Completer<List<Empresa>> pCompleter = Completer<List<Empresa>>();

  var pUrl = "$pHost/rest/granjas/obtener_empresas";

  String pJson = await HttpRequest.getString(pUrl);

  var pListaMap = jsonDecode(pJson);

  var pResult = <Empresa>[];

  for (var map in pListaMap) {
    pResult.add(Empresa.fromMap(map));
  }

  print(pResult);

  pCompleter.complete(pResult);

  return pCompleter.future;
}

Future<Granja> actualizarGranja(Granja AGranja) async {
  Completer<Granja> pCompleter = Completer<Granja>();

  var pUrl = '$pHost/rest/granjas/granja_actualizar';
  HttpRequest pRequest = await HttpRequest.request(pUrl, method: 'PUT', sendData: AGranja.toJSON());

  Granja pGranja = Granja.fromMap(jsonDecode(pRequest.responseText!));

  pCompleter.complete(pGranja);

  return pCompleter.future;
}

Future<Granja> insertarGranja(Granja AGranja) async {
  Completer<Granja> pCompleter = Completer<Granja>();

  var pUrl = '$pHost/rest/granjas/granja_insertar';
  HttpRequest pRequest = await HttpRequest.request(pUrl, method: 'POST', sendData: AGranja.toJSON());

  Granja pGranja = Granja.fromMap(jsonDecode(pRequest.responseText!));

  pCompleter.complete(pGranja);

  return pCompleter.future;
}

Future<bool> eliminarGranja(Granja AGranja) async {
  Completer<bool> pCompleter = Completer<bool>();

  if (window.confirm('¿Eliminar registro?')) {
    var pUrl = "$pHost/rest/granjas/granja_eliminar";
    Map pData = {'clave': AGranja.Clave};
    var req = await HttpRequest.request(pUrl, method: "DELETE", sendData: jsonEncode(pData));

    pCompleter.complete(true);
  } else {
    pCompleter.complete(false);
  }

  return pCompleter.future;
}

llena_tabla() {
  var body = tablaGranjas.tBodies[0];

  body.children.clear();

  lista_granja.forEach((granja) {
    body.children.add(granja.toTableRow());
    granja.editRowEvent = (granja, trResult) => actualizarGranja(granja);
    granja.eliminarRowEvent = (granja) {
      eliminarGranja(granja);
      return true;
    };
  });
}

llena_lista(data) {
  lista_granja = <Granja>[];

  var p_lista = jsonDecode(data);

  for (var item in p_lista) {
    lista_granja.add(Granja.fromMap(item));
  }

  llena_tabla();
}

Future obtener_lista() async {
  var pData = await HttpRequest.getString('$pHost/rest/granjas/granja_obtener_lista');
  llena_lista(pData);
}

main() async {
  lista_empresas = await getEmpresas();
  await obtener_lista();

  btnNuevaGranja.onClick.listen((_) {
    Granja pGranjaTmp = Granja();
    TableRowElement tr = pGranjaTmp.toEditRow();
    tablaGranjas.tBodies[0].children.insert(0, tr);

    pGranjaTmp.editRowEvent = (granja, TableRowElement trResult) async {
      Granja pGranja = await insertarGranja(granja);
      trResult.replaceWith(pGranja.toTableRow());
      pGranja.editRowEvent = (granja, tr) => actualizarGranja(granja);
      pGranja.eliminarRowEvent = (granja) {
        eliminarGranja(granja);
        return true;
      };
    };
  });
}
