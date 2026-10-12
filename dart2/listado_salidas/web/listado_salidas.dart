import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart' as intl;
import 'modal_p.dart' as ModalP;

TableElement pTable = querySelector("#tablaOrdenes") as TableElement;
final SelectElement inpDestino = querySelector("#inpDestino");
final SelectElement inpEstado = querySelector("#inpEstado");
final SelectElement inpClienteMaquila = querySelector("#inpClienteMaquila");

var pNumberFormater = new intl.NumberFormat("000000");

Future<List<Map>> obtenerClientes() async{

    Completer<List<Map>> pCompleter = new Completer<List<Map>>();

    var pUrl = "http://localhost:8031/rest/salidas/get_clientes";

    var pJson = await HttpRequest.getString(pUrl);

    List<Map> pResult = JSON.decode(pJson);
    pResult.sort((Map s, Map d) => (s["nombre"].toString().toUpperCase().compareTo(d["nombre"].toString().toUpperCase())));

    pCompleter.complete(pResult);

    return pCompleter.future;

}

Future<List<Map>> obtenerClasesSalidas() async{

    Completer<List<Map>> pCompleter = new Completer<List<Map>>();

    var pUrl = "http://localhost:8031/api/clases_salidas";

    var pJson = await HttpRequest.getString(pUrl);

    List<Map> pResult = JSON.decode(pJson);
    pResult.sort((Map s, Map d) => (s["nombre"].toString().toUpperCase().compareTo(d["nombre"].toString().toUpperCase())));

    pCompleter.complete(pResult);

    return pCompleter.future;

}

Future<List<Map>> obtenerClientesMaquila() async{

    Completer<List<Map>> pCompleter = new Completer<List<Map>>();
    var pUrl = "http://localhost:8031/obtener_clientes_maquila";

    String pJson = await HttpRequest.getString(pUrl);

    pCompleter.complete(JSON.decode(pJson));

    return pCompleter.future;
}

llenaSelectClientesMaquila() async{

    List<Map> pListaClientesMaquila = await obtenerClientesMaquila();

    inpClienteMaquila.children.add(new Element.html("<option value='0'>Todos</option>"));

    for (Map item in pListaClientesMaquila){

        inpClienteMaquila.children.add(new Element.html("<option value='${item["id"]}'>${item["nombre"]}</option>"));

    }

}

void agregaFila(Map AItem){

    print(AItem);

    TableRowElement tr = new TableRowElement();

    TableCellElement td = new TableCellElement()..text = AItem["fechastr"];
    td.style.textAlign = "center";
    tr.children.add(td);

    td = new TableCellElement()..text = pNumberFormater.format(AItem["id"])..id="td${AItem["id"]}";
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
    
    ButtonElement btnEditar = new Element.html("<button class='btn'><i class='icon-edit'></i></button>")..onClick.listen((_){
       
        var pUrl = "http://localhost:8031/salidas/${AItem["id"]}";
        window.location.href = pUrl;
        
    });
    
    td = new TableCellElement()..children.add(btnEditar);
    tr.children.add(td);
    
    ButtonElement btnEliminar = new Element.html("<button class='btn'><i class='icon-trash'></i></button>")..onClick.listen((_){
        
        if (window.confirm("¿Eliminar registro?")){
        
            var pUrl = "http://localhost:8031/rest/salidas/eliminar/${AItem["id"]}";
            
            HttpRequest.getString(pUrl).then((String Data){
                
                Map pResult = JSON.decode(Data);
                
                window.alert(pResult["mensaje"]);
                
                if (pResult["error"]){
                    return;
                }
                else{
                    tr.remove();    
                }
            });
        }
        
    })..style.marginLeft = "3px";
    
    td.children.add(btnEliminar);
    
    ButtonElement btnBitacora = new Element.html("<button class='btn'><i class='icon-th'></i></button>")..onClick.listen((_){
            
        var pUrl = "http://localhost:8031/salidas/bitacora_embarques/${AItem["id"]}";
        window.location.href = pUrl;
            
    })..style.marginLeft = "3px";
        
    td.children.add(btnBitacora);
    tr.children.add(td);
    
    pTable.tBodies[0].children.add(tr);
    
}

void consultar(){
    
    String pFechaIni = (querySelector("#inpFechaInicial") as InputElement).value;
    String pFechaFin = (querySelector("#inpFechaFinal") as InputElement).value;

    window.localStorage["FechaInicial"] = pFechaIni;
    window.localStorage["FechaFinal"]  = pFechaFin;
    
    var pUrl = "http://localhost:8031/rest/salidas/obtener_lista?fecha_ini=${pFechaIni}&fecha_fin=${pFechaFin}&destino=${inpDestino.value}&estado=${inpEstado.value}&cliente=${inpClienteMaquila.value}";

    print(pUrl);
    
    HttpRequest.getString(pUrl).then((String Data){
        
        List<Map> pLista = JSON.decode(Data);
        pTable.tBodies[0].children.clear();
        
        for (Map item in pLista){
            agregaFila(item);
        }
        
    });
    
}

void buscar(){
    ModalP.modal("mdlBuscar");
    (querySelector("#inpBuscar") as InputElement).select();
    (querySelector("#inpBuscar") as InputElement).focus();
}

void buscarOrden(){
    
    var pIdOrden = (querySelector("#inpBuscar") as InputElement).value;
    
    var pUrl = "http://localhost:8031/rest/salidas/orden_salida_obtener/${pIdOrden}";
    
    pTable.tBodies[0].children.clear();
    
    HttpRequest.getString(pUrl).then((String Data){
       
        Map pOrden = JSON.decode(Data);
        
        if (pOrden["id"] != null){
            agregaFila(pOrden);
        }
        
        ModalP.cierra_modal("mdlBuscar");
        
    });
}

Future llenaDestinos() async{

    List<Map> pDestinos = await obtenerClientes();

    pDestinos.forEach((Map item){
        OptionElement pOption = new OptionElement()
            ..value = item["id"]
            ..text = item['nombre'];

        inpDestino.children.add(pOption);
    });

}

Future init() async{
    var dFormater = new intl.DateFormat("dd/MM/yyyy");
    String pFecha = dFormater.format(new DateTime.now());
    print(pFecha);
    (querySelector("#inpFechaInicial") as InputElement).value = pFecha;
    (querySelector("#inpFechaFinal") as InputElement).value = pFecha;

    if (window.localStorage.containsKey("FechaInicial")){
        String pFechaInicial = window.localStorage["FechaInicial"];
        if (pFechaInicial.trim().length > 0) {
            (querySelector("#inpFechaInicial") as InputElement).value = pFechaInicial;
        }
        else{
            window.localStorage["FechaInicial"] = pFecha;
        }
    }
    
    if (window.localStorage.containsKey("FechaFinal")){
        String pFechaFinal = window.localStorage["FechaFinal"];
        if (pFechaFinal.trim().length > 0) {
            (querySelector("#inpFechaFinal") as InputElement).value =
            window.localStorage["FechaFinal"];
        }
        else{
            window.localStorage["FechaFinal"] = pFecha;
        }
    }

    print('...');
    print((querySelector("#inpFechaInicial") as InputElement).value);
    
    (querySelector("#btnConsultar") as InputElement).onClick.listen((_){
        consultar();
    });
    
    (querySelector("#btnNuevo") as ButtonElement).onClick.listen((_){    
        window.location.href = "http://localhost:8031/salidas/0";
    });
    
    (querySelector("#btnBuscar") as ButtonElement).onClick.listen((_){    
        buscar();
    });
    
    (querySelector("#btnAceptarBusqueda") as InputElement).onClick.listen((_){    
        buscarOrden();
    });
    
    (querySelector("#btnCancelarBusqueda") as InputElement).onClick.listen((_){    
        ModalP.cierra_modal("mdlBuscar");
    });

    llenaDestinos();
    await llenaSelectClientesMaquila();
}

void main() {
    init();
    consultar();
}