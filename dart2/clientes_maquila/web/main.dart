import "dart:html";
import "dart:async";
import "dart:convert";
import 'package:quickdialogs/quickdialogs.dart' as QuickDialogs;


ButtonElement btnConsultar = querySelector("#btnConsultar");

TableElement tablaConsulta = querySelector("#tablaConsulta");


Future<List<Map>> getConsulta() async{

  Completer<List<Map>> pCompleter = new Completer<List<Map>>();
  String pUrl = "/obtener_clientes_maquila";

  String pResultStr = await HttpRequest.getString(pUrl);

  pCompleter.complete(JSON.decode(pResultStr));

  return pCompleter.future;

}

void agregaFila(Map item){
  bool pExiste = false;
  TableRowElement tr = querySelector("#tr${item["id"]}");
  TableCellElement td = null;

  ButtonElement btnModificar = null;
  ButtonElement btnEliminar = null;
  SpanElement span = null;

  if (tr == null){
    tr = new TableRowElement()..id = "tr${item["id"]}";
  }
  else{
    tr.children.clear();
    pExiste = true;
  }

  td = new TableCellElement()..style.textAlign = "left";
  td.text = item["id"].toString();
  tr.children.add(td);
  td = new TableCellElement()..style.textAlign = "center";

  td = new TableCellElement()..style.textAlign = "left";
  td.text = item["nombre"];
  tr.children.add(td);
  td = new TableCellElement()..style.textAlign = "center";

  btnModificar = new ButtonElement()..text = "M";
  btnModificar.onClick.listen((e){
    window.open("/edita_cliente_maquila/${item["id"]}", "edit");
  });
  td.children.add(btnModificar);
  span = new SpanElement()..text = " ";
  td.children.add(span);
  tr.children.add(td);

  btnEliminar = new ButtonElement()..text = "E";
  btnEliminar.onClick.listen((e) async{
    if (window.confirm("Eliminar registro?")){

      String pUrlDelete = "/eliminar_cliente_maquila/${item["id"]}";
      String pResultDeleteStr = await HttpRequest.getString(pUrlDelete);
      Map pResultDelete = JSON.decode(pResultDeleteStr);

      window.alert(pResultDelete["Mensaje"]);

      if (pResultDelete["Result"] == "OK"){
        (querySelector("#tr${item["id"]}") as TableRowElement).remove();
      }
    }
  });
  td.children.add(btnEliminar);
  span = new SpanElement()..text = " ";
  td.children.add(span);
  tr.children.add(td);

  if (!pExiste){
    tablaConsulta.tBodies[0].children.add(tr);
  }

}

Future despliegaConsulta() async{

  tablaConsulta.tBodies[0].children.clear();
  List<Map> pConsulta = await getConsulta();

  for (Map item in pConsulta){
    agregaFila(item);
  }

}

Future init() async{

  despliegaConsulta();

  window.onMessage.listen((MessageEvent event){
    print("Mensaje recibido:");
    print(event.data);
    Map item = JSON.decode(event.data);
    agregaFila(item);
  });

}

main(){
  init();
}