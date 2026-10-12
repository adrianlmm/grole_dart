import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'Empresa.dart';

final TableElement tablaEmpresas = querySelector("#tablaEmpresas");
List<Empresa> gListaEmpresas = null;
final ButtonElement btnNuevaEmpresa = querySelector("#btnNuevaEmpresa");

Future<List<Empresa>> obtenerEmpresas() async{

    Completer<List<Empresa>> pCompleter = new Completer<List<Empresa>>();

    var pUrl = "http://localhost:8031/rest/granjas/obtener_empresas";

    String pJSON = await HttpRequest.getString(pUrl);

    List<Map> pLista = JSON.decode(pJSON);

    List<Empresa> pResult = new List<Empresa>();

    pLista.forEach((map) => pResult.add(new Empresa.fromMap(map)));

    pCompleter.complete(pResult);

    return pCompleter.future;
}

llena_tabla(){
    var body = tablaEmpresas.tBodies[0];

    body.children.clear();

    gListaEmpresas.forEach((empresa) {

        body.children.add(empresa.toTableRow());
        empresa.onEditRow   = (empresa, trResult) => insertarEmpresa(empresa);
        empresa.onElimarRow = (empresa) async => await eliminarEmpresa(empresa);

    });

}

Future<Empresa> insertarEmpresa(Empresa AEmpresa) async{

    Completer<Empresa> pCompleter = new Completer<Empresa>();

    var pUrl = 'http://localhost:8031/rest/granjas/insertar_empresa';
    HttpRequest pRequest = await HttpRequest.request(pUrl, method: 'POST', sendData: AEmpresa.toJSON());

    Empresa pEmpresa = new Empresa.fromMap(JSON.decode(pRequest.responseText));

    pCompleter.complete(pEmpresa);

    return pCompleter.future;
}

Future<bool> eliminarEmpresa(Empresa AEmpresa) async{

    Completer<bool> pCompleter = new Completer<bool>();

    if (window.confirm('¿Eliminar registro?'))   {

        var pUrl = "http://localhost:8031/rest/granjas/eliminar_empresa/${AEmpresa.Id}";
        var req = await HttpRequest.request(pUrl, method: "DELETE", sendData: AEmpresa.toJSON());

        pCompleter.complete(true);
    }
    else{
        pCompleter.complete(false);
    }

    return pCompleter.future;
}

Future main() async{
    await loadResources();
    gListaEmpresas = await obtenerEmpresas();
    llena_tabla();

    btnNuevaEmpresa.onClick.listen((_){

        Empresa pEmpresaTmp = new Empresa(0, '', 'Interna');
        TableRowElement tr = pEmpresaTmp.toEditRow();
        tablaEmpresas.tBodies[0].children.insert(0, tr);
        tr.querySelector("#inpNombre").focus();

        pEmpresaTmp.onEditRow = (empresa, TableRowElement trResult) async {
            Empresa pEmpresa = await insertarEmpresa(empresa);
            trResult.replaceWith(pEmpresa.toTableRow());
            pEmpresa.onEditRow   = (empresa, tr) => insertarEmpresa(empresa);
            pEmpresa.onElimarRow = (empresa) {
                eliminarEmpresa(empresa).then((result) => result);
            };
        };

    });
}