import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'Granja.dart';
import 'Empresa.dart';

bool permite_edicion = false;
bool modo_insercion  = true;
int pScrollY = 0;

final InputElement inpClave        = querySelector("#clave");
final InputElement inpNombre       = querySelector('#nombre');
final TableElement tablaGranjas    = querySelector("#tablaGranjas");
final ButtonElement btnNuevaGranja = querySelector("#btnNuevaGranja");

List<Granja> lista_granja = new List<Granja>();
List<Empresa> lista_empresas = null;

Future<List<Empresa>> getEmpresas() async{

    Completer<List<Empresa>> pCompleter = new Completer<List<Empresa>>();

    var pUrl = "http://localhost:8031/rest/granjas/obtener_empresas";

    String pJson = await HttpRequest.getString(pUrl);

    List<Map> pListaMap = JSON.decode(pJson);

    List<Empresa> pResult = new List<Empresa>();

    pListaMap.forEach((map) => pResult.add(new Empresa.fromMap(map)));

    print(pResult);

    pCompleter.complete(pResult);

    return pCompleter.future;
}

Future<Granja> actualizarGranja(Granja AGranja) async{

    Completer<Granja> pCompleter = new Completer<Granja>();

    var pUrl = 'http://localhost:8031/rest/granjas/granja_actualizar';
    HttpRequest pRequest = await HttpRequest.request(pUrl, method: 'PUT', sendData: AGranja.toJSON());

    Granja pGranja = new Granja.fromMap(JSON.decode(pRequest.responseText));

    pCompleter.complete(pGranja);

    return pCompleter.future;
}

Future<Granja> insertarGranja(Granja AGranja) async{

    Completer<Granja> pCompleter = new Completer<Granja>();

    var pUrl = 'http://localhost:8031/rest/granjas/granja_insertar';
    HttpRequest pRequest = await HttpRequest.request(pUrl, method: 'POST', sendData: AGranja.toJSON());

    Granja pGranja = new Granja.fromMap(JSON.decode(pRequest.responseText));

    pCompleter.complete(pGranja);

    return pCompleter.future;
}

Future<bool> eliminarGranja(Granja AGranja) async{

    Completer<bool> pCompleter = new Completer<bool>();

    if (window.confirm('¿Eliminar registro?'))   {

        var pUrl = "http://localhost:8031/rest/granjas/granja_eliminar";
        Map pData = {'clave' : AGranja.Clave};
        var req = await HttpRequest.request(pUrl, method: "DELETE", sendData: JSON.encode(pData));

        pCompleter.complete(true);
    }
    else{
        pCompleter.complete(false);
    }

    return pCompleter.future;
}

llena_tabla(){
    var body = tablaGranjas.tBodies[0];

    body.children.clear();

    lista_granja.forEach((granja) {

        body.children.add(granja.toTableRow());
        granja.onEditRow   = (granja, trResult) => actualizarGranja(granja);
        granja.onElimarRow = (granja) async => await eliminarGranja(granja);

    });

}

llena_lista(data){
  lista_granja= new List<Granja>();

  List p_lista = JSON.decode(data);

  p_lista.forEach((Map item) => lista_granja.add(new Granja.fromMap(item)));

  llena_tabla();
}

obtener_lista(){
  HttpRequest.getString('http://localhost:8031/rest/granjas/granja_obtener_lista').then(llena_lista);
}

main() async{
  obtener_lista();

  lista_empresas = await getEmpresas();

  btnNuevaGranja.onClick.listen((_){

      Granja pGranjaTmp = new Granja();
      TableRowElement tr = pGranjaTmp.toEditRow();
      tablaGranjas.tBodies[0].children.insert(0, tr);

      pGranjaTmp.onEditRow = (granja, TableRowElement trResult) async {
          Granja pGranja = await insertarGranja(granja);
          trResult.replaceWith(pGranja.toTableRow());
          pGranja.onEditRow   = (granja, tr) => actualizarGranja(granja);
          pGranja.onElimarRow = (granja) async => await eliminarGranja(granja);
      };

  });
}