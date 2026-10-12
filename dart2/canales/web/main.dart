import 'dart:html';
import 'dart:async';
import 'dart:convert';

final InputElement inpFechaIni   = querySelector("#inpFechaIni");
final InputElement inpFechaFin   = querySelector("#inpFechaFin");
final SelectElement inpGranja    = querySelector("#inpGranja");
final TableElement tablaConsulta = querySelector("#tablaConsulta");
final ButtonElement btnConsultar = querySelector("#btnConsultar");

List<Map> gGranjas = new List<Map>();
List<Map> gCanales = new List<Map>();

Future<List<Map>> getGranjas() async{

  Completer<List<Map>> pCompleter = new Completer<List<Map>>();

  var pUrl = "http://localhost:8031/Granjas/GetGranjas";

  String pResponseText = await HttpRequest.getString(pUrl);

  pCompleter.complete(JSON.decode(pResponseText));

  return pCompleter.future;
}

Future<List<Map>> getCanales(String AFechaIni, String AFechaFin, int AGranja) async{

  Completer<List<Map>> pCompleter = new Completer<List<Map>>();

  var pUrl = "http://localhost:8031/canales/get_canales?fecha_ini=${AFechaIni}&fecha_fin=${AFechaFin}&granja=${AGranja}";

  String pResponseText = await HttpRequest.getString(pUrl);

  pCompleter.complete(JSON.decode(pResponseText));

  return pCompleter.future;
}

String formatFecha(DateTime AFecha){

  String pResult = AFecha.day.toString().padLeft(2, "0") + "/" + AFecha.month.toString().padLeft(2, "0") + "/" + AFecha.year.toString();
  return pResult;

}

void inicializaGranjas() async{

  gGranjas = await getGranjas();

  for (Map item in gGranjas){

    inpGranja.children.add(new Element.html("<option value='${item["clave"]}'>${item["nombre"]}</option>"));

  }
}

inicializa() async{

  inpFechaIni.value = formatFecha(new DateTime.now());
  inpFechaFin.value = formatFecha(new DateTime.now());

  inicializaGranjas();

}

void llenaTabla(List<Map> ALista){

  tablaConsulta.tBodies[0].children.clear();

  int pCanales = 0;
  double pPeso = 0.0;

  for (var item in ALista){

    String pId = "${item["granja"]}${item["lote"]}${item["fecha"].runtimeType}";

    TableRowElement tr = new TableRowElement()..id = pId;
    TableCellElement td = new TableCellElement();
    td.text = formatFecha(DateTime.parse(item["fecha"]));
    td.style.textAlign = "center";
    tr.children.add(td);

    td = new TableCellElement();
    td.text = item["lote"].toString();
    td.style.textAlign = "center";
    tr.children.add(td);

    td = new TableCellElement();
    td.text = item["cantidadtotal"].toString();
    td.style.textAlign = "right";
    tr.children.add(td);

    td = new TableCellElement();
    td.text = item["pesototal"].toStringAsFixed(2);
    td.style.textAlign = "right";
    tr.children.add(td);

    td = new TableCellElement();
    td.text = item["bajas"].toString();
    td.style.textAlign = "right";
    tr.children.add(td);

    td = new TableCellElement();
    td.text = item["pesobajas"].toStringAsFixed(2);
    td.style.textAlign = "right";
    tr.children.add(td);

    tablaConsulta.tBodies[0].children.add(tr);

    pCanales += item["cantidadtotal"];
    pPeso    += item["pesototal"];
  }


  TableRowElement trf = new TableRowElement();
  trf.children.add(new TableCellElement());
  trf.children.add(new TableCellElement());
  trf.children.add(new TableCellElement());
  trf.children.add(new TableCellElement());

  TableCellElement tf = new TableCellElement();
  tf.text = pCanales.toString();
  tf.style.textAlign = "right";
  tf.style.fontWeight = "bold";
  trf.children.add(tf);

  tf = new TableCellElement();
  tf.text = pPeso.toStringAsFixed(2);
  tf.style.textAlign = "right";
  tf.style.fontWeight = "bold";
  trf.children.add(tf);

  tablaConsulta.tBodies[0].children.add(trf);

}

consultar() async{

    gCanales = await getCanales(inpFechaIni.value, inpFechaFin.value, int.parse(inpGranja.value));
    llenaTabla(gCanales);

}

main() async {

  await inicializa();

  btnConsultar.onClick.listen((e) async{

    consultar();

  });
}