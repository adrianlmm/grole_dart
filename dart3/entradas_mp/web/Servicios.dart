import 'dart:convert';
import 'dart:html';
import 'dart:async';

class Servicios{

    Future<Map> obtenerEntradaMP(int AId) async{

        Completer<Map> pCompleter = new Completer<Map>();

        var pUrl = "http://localhost:8031/api/inventario/entrada_obtener/${AId}";
        String pJsonString = await HttpRequest.getString(pUrl);

        pCompleter.complete(JSON.decode(pJsonString));

        return pCompleter.future;

    }

}