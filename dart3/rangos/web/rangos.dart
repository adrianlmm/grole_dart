import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'Rango.dart';

TableElement tablaRangos = querySelector("#tablaRangos");
List<Rango> gListaRangos = new List<Rango>();

Future<List<Rango>> getRangos() async{

    List<Rango> pListaRangoTmp = new List<Rango>();
    Completer<List<Rango>> pCompleter = new Completer<List<Rango>>();

    var pUrl = "http://localhost:8031/api/rangos";
    String pJsonStr = await HttpRequest.getString(pUrl);

    List<Map> pList = JSON.decode(pJsonStr);

    pList.forEach((Map item) => pListaRangoTmp.add(new Rango.fromMap(item)));

    pCompleter.complete(pListaRangoTmp);

    return pCompleter.future;
}

Future<String> guardaRango(Rango ARango) async{

    Completer<String> pCompleter = new Completer<String>();

    var pUrl = "http://localhost:8031/api/rango/${ARango.Clave}";

    HttpRequest request = await HttpRequest.request(pUrl, method: "POST", sendData: ARango.toJSON());

    pCompleter.complete(request.responseText);

    return pCompleter.future;
}

llenaTabla(){

    var body = tablaRangos.tBodies[0];
    body.children.clear();

    gListaRangos.forEach((Rango item){

        body.children.add(item.toTableRow());
        item.onEditRow = (rango) => guardaRango(rango);

    });

}

Future inicializa() async{

    gListaRangos = await getRangos();
    llenaTabla();
}

main() {

    inicializa();

}