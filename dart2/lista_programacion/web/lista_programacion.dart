import 'dart:html';
import 'dart:convert';
import 'dart:async';

InputElement inpFechaInicial = querySelector("#inpFechaInicial");
InputElement inpFechaFinal   = querySelector("#inpFechaFinal");
ButtonElement btnConsulta    = querySelector("#btnConsultar");
TableElement tablaDetalle    = querySelector("#tablaDetalle");
ButtonElement btnNuevo       = querySelector("#btnNuevo");

List<Map> gListaProgramacion = null;

Future<List<Map>> obtenerLista() async{

    Completer<List<Map>> pCompleter = new Completer<List<Map>>();

    var pUrl = "http://localhost:8031/programacion/lista?fecha_ini=${inpFechaInicial.value}&fecha_fin=${inpFechaFinal.value}";

    String pResultStr = await HttpRequest.getString(pUrl);

    pCompleter.complete(JSON.decode(pResultStr));

    return pCompleter.future;
}

String formatDate(String AFecha){

  String pResult = "";
  DateTime pFecha = DateTime.parse(AFecha);

  pResult = pFecha.day.toString().padLeft(2, "0") + "/" + pFecha.month.toString().padLeft(2, "0") + "/" +
           pFecha.year.toString();

  return pResult;
}

void agregaFila(Map AData){

  TableRowElement tr = querySelector("#tr${AData["id"]}");

  bool pExiste = false;

  if (tr == null) {
    tr = new TableRowElement();
  }
  else{
    pExiste = true;
    tr.children.clear();
  }

  tr.id = "tr${AData["id"]}";

    TableCellElement td = new TableCellElement();
    td.text = AData["id"].toString().padLeft(6, "0");
    td.style.textAlign = "center";
    tr.children.add(td);

    td = new TableCellElement();
    td.text = AData["descripcion"];
    td.style.textAlign = "left";
    tr.children.add(td);

    td = new TableCellElement();
    try {
        td.text = formatDate(AData["fecha_inicial"]);
    }
    catch(_){
        td.text = AData["fecha_inicial"];
    }
    td.style.textAlign = "center";
    tr.children.add(td);

    td = new TableCellElement();
    try {
      td.text = formatDate(AData["fecha_final"]);
    }
    catch(_){
      td.text = AData["fecha_final"];
    }
    td.style.textAlign = "center";
    tr.children.add(td);

    td = new TableCellElement();
    AnchorElement ancModificar = new AnchorElement();
    ancModificar.text = "Editar";
    ancModificar.onClick.listen((_) {
        window.open("/programacion/edit/${AData["id"]}", "edit");
    });
    ancModificar.href = "#";
    td.children.add(ancModificar);

    AnchorElement ancEliminar = new AnchorElement();
    ancEliminar.text = "Eliminar";
    ancEliminar.href = "#";
    ancEliminar.onClick.listen((_) async {

      if (window.confirm("¿Eliminar Registro?")){

          var pUrl = "http://localhost:8031/programacion/eliminar/${AData["id"]}";
          var pData = "id=${AData["id"]}";
          var pRequest = await HttpRequest.request(pUrl, method: "DELETE", sendData: pData);

          window.alert("Registro Eliminado con Exito");

          tr.remove();

      }

    });
    ancEliminar.style.marginLeft = "10px";
    td.children.add(ancEliminar);

    tr.children.add(td);

    if (!pExiste) {
      tablaDetalle.tBodies[0].children.add(tr);
    }

}

Future inicializa() async{

  btnConsulta.onClick.listen((_) async{

    try {
      gListaProgramacion = await obtenerLista();
      tablaDetalle.tBodies[0].children.clear();
      print(gListaProgramacion);

      for (Map item in gListaProgramacion) {
        agregaFila(item);
      }
    }
    catch(ex){
      print(ex);
    }
  });

  btnNuevo.onClick.listen((_){

    window.open("/programacion/edit/0", "edit");

  });

  window.onMessage.listen((MessageEvent event){
      print("Mensaje recibido ok:");
      print(event.data);
      Map item = JSON.decode(event.data);
      print("item");
      print(item);
      try {
        agregaFila(item);
      }
      catch(exception, stackTrace){
        print(exception);
        print(stackTrace);
      }
  });

}

main() async{
  await inicializa();
}