import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart' as intl;
import 'package:quickdialogs/quickdialogs.dart' as quickdialogs;
import 'modal_p.dart' as ModalP;

int idOrdenSalida = 0;
String lastErrorMessage = "";
List<Map> Detalle = new List<Map>();
int indice = 9999;
StreamSubscription EventoBotonEditar = null;
intl.NumberFormat pNumberFormat              = new intl.NumberFormat("#,##0.00");
InputElement inpClavePtoTarima               = querySelector("#inpClavePtoTarima");
InputElement btnCosultarTarimas              = querySelector("#btnCosultarTarimas");
InputElement btnCancelarCosultarTarimas      = querySelector("#btnCancelarCosultarTarimas");
InputElement inpNombrePtoTarima              = querySelector("#inpNombrePtoTarima");
SelectElement inpCamaras                     = querySelector("#inpCamaras");
final SelectElement inpTipo                  = querySelector("#inpTipo");
final InputElement inpPesoCamion             = querySelector("#inpPesoCamion");
final NumberInputElement inpTarima1          = querySelector("#inpTarima1");
final NumberInputElement inpTarima2          = querySelector("#inpTarima2");
final SelectElement inpDiasProduccion        = querySelector("#inpDiasProduccion");
TableElement tablaConsultaTarimas            = querySelector("#tablaConsultaTarimas");
final SelectElement inpClienteMaquila        = querySelector("#inpClienteMaquila");
final SelectElement inpDestino               = querySelector("#inpDestino");
final SelectElement inpClaseSalida           = querySelector("#inpClaseSalida");
final SelectElement inpValidaRangoProduccion = querySelector("#inpValidaRangoProduccion");
final InputElement inpFechaRangoInicial      = querySelector("#inpFechaRangoInicial");
final InputElement inpFechaRangoFinal        = querySelector("#inpFechaRangoFinal");
final InputElement inpDiasProduccionLinea    = querySelector("#inpDiasProduccionLinea");
final HiddenInputElement inpPuedeEditar      = querySelector("#inpPuedeEditar");
final HiddenInputElement inpFolio            = querySelector("#inpFolio");
List<int> ListaTarimas = new List<int>();
intl.NumberFormat nf = new intl.NumberFormat("###,###.00");

Future<List<Map>> obtenerClientesMaquila() async{

    Completer<List<Map>> pCompleter = new Completer<List<Map>>();
    var pUrl = "http://localhost:8031/obtener_clientes_maquila";

    String pJson = await HttpRequest.getString(pUrl);

    pCompleter.complete(JSON.decode(pJson));

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

Future<List<Map>> obtenerClientes(String AMercado) async{

  var pUrl = "http://localhost:8031/rest/salidas/get_clientes/" + AMercado;
  var pJson = await HttpRequest.getString(pUrl);

  return JSON.decode(pJson);

}

llenaSelectClientesMaquila() async{

    List<Map> pListaClientesMaquila = await obtenerClientesMaquila();

    for (Map item in pListaClientesMaquila){

        inpClienteMaquila.children.add(new Element.html("<option value=${item["id"]}>${item["nombre"]}</option>"));

    }

}

llenaClaseSalidas() async{

    List<Map> pClaseSalidas = await obtenerClasesSalidas();

    for (Map item in pClaseSalidas){

        inpClaseSalida.children.add(new Element.html("<option value=${item["id"]}>${item["nombre"]}</option>"));

    }

}

llenaClientes() async {

  var pMercado = (querySelector("#inpTipo") as SelectElement).value;
  SelectElement pDestinoTmp = (querySelector("#inpDestino") as SelectElement);
  List<Map> pClientes = await obtenerClientes(pMercado);

  pDestinoTmp.children.clear();

  pClientes.forEach((item){

      OptionElement pOption = new OptionElement();
      pOption.value = item["id"];
      pOption.text = item["nombre"];
      pDestinoTmp.children.add(pOption);

  });

}

void agregaFila(Map AItem, {bool AEditable: true}){

    Detalle.add(AItem);

    TableElement pTabla = querySelector("#tablaDetalle");
    TableRowElement tr = new TableRowElement()..id = "tr${AItem['id']}";

    TableCellElement td = new TableCellElement()..text = AItem['producto'];
    tr.children.add(td);
    td = new TableCellElement()..text = AItem['descripcion'];
    tr.children.add(td);
    td = new TableCellElement()..text = AItem['cajas'].toString()..style.textAlign = "right";
    tr.children.add(td);
    td = new TableCellElement()..text = pNumberFormat.format(AItem['kilos'])..style.textAlign = "right";
    tr.children.add(td);
    td = new TableCellElement()..text = AItem['cajas_surtidas'].toString()..style.textAlign = "right";
    tr.children.add(td);
    td = new TableCellElement()..text = pNumberFormat.format(AItem['kilos_surtidos'])..style.textAlign = "right";
    tr.children.add(td);
    print(AItem['dias_produccion']);
    td = new TableCellElement()..text = AItem['dias_produccion'].toString()..style.textAlign = "right";
    tr.children.add(td);

    double pCumplimiento = (AItem['cajas_surtidas'] / AItem['cajas']) * 100;
    String pCumplimientoS =pNumberFormat.format(pCumplimiento) + "%";

    td = new TableCellElement()..text = pCumplimientoS..style.textAlign = "right";
    tr.children.add(td);

    td = new TableCellElement()..text = pNumberFormat.format(AItem['peso_bruto'] - AItem["kilos_surtidos"])..style.textAlign = "right";
    tr.children.add(td);
    

    if (AEditable){
        ButtonElement btnEliminar = new Element.html("<button class='btn'><i class='icon-trash'></i></button>")..onClick.listen((_){

            if (AItem["cajas_surtidas"] == 0){
                if (window.confirm("¿Eliminar registro?")){
                    Detalle.removeWhere((Map x) => x["id"] == AItem["id"]);
                    tr.remove();
                }
            }
            else{
                print("No se puede eliminar el registro porque tiene cajas surtidas");
                window.alert("No se puede eliminar el registro porque tiene cajas surtidas");
            }

        })..style.marginLeft = "5px";

        td = new TableCellElement()..children.add(btnEliminar);

        ButtonElement btnEditar = new Element.html("<button class='btn'><i class='icon-edit'></i></button>")..onClick.listen((_){

            Map pMapaTmp = Detalle.where((Map x) => x["id"] == AItem["id"]).toList().first;

            print(pMapaTmp);

            despliegaProducto(pMapaTmp);
            ModalP.modal("mdlEditar");
            (querySelector("#inpCajasEdicion") as InputElement).focus();
            (querySelector("#inpCajasEdicion") as InputElement).select();

            if (EventoBotonEditar != null){
                EventoBotonEditar.cancel();
            }

            InputElement btnEditarProducto = querySelector("#btnEditarProducto") as InputElement;

            EventoBotonEditar = btnEditarProducto.onClick.listen((_){

                int pCajas = 0;
                double pKilos = 0.0;

                try
                {
                    pCajas = int.parse((querySelector("#inpCajasEdicion") as InputElement).value);
                }
                catch(Exception){
                    pCajas = -1;
                }

                try
                {
                    pKilos = double.parse((querySelector("#inpKilosEdicion") as InputElement).value);
                }
                catch(Exception){
                    pKilos = -1.0;
                }

                if (pCajas < 0){
                    window.alert("Error, el número de cajas no es válido");
                    (querySelector("#inpCajasEdicion") as InputElement).focus();
                    return;
                }

                if (pKilos < 0){
                    window.alert("Error, el número de kilos no es válido");
                    (querySelector("#inpKilosEdicion") as InputElement).focus();
                    return;
                }

                if (pCajas > 0 && pKilos > 0){
                    window.alert("Error, solo uno cajas o kilos puede ser mayor a cero, ambos no");
                    (querySelector("#inpCajasEdicion") as InputElement).focus();
                    return;
                }

                if (pCajas == 0 && pKilos == 0){
                    window.alert("Error, debe poner cajas o kilos con un valor mayor a cero");
                    (querySelector("#inpCajasEdicion") as InputElement).focus();
                    return;
                }

                int pDiasProduccion = 0;

                try{
                  pDiasProduccion = int.parse((querySelector("#inpDiasProduccionEdicion") as InputElement).value);
                }
                catch(_){
                  pDiasProduccion = 0;
                }

                Map pMapa = Detalle.where((Map x) => x["id"] == AItem["id"]).toList().first;
                pMapa["cajas"] = pCajas;
                pMapa["kilos"] = pKilos;
                pMapa["dias_produccion"] = pDiasProduccion;
                pMapa["valida_rango_produccion"]  = (querySelector("#inpValidaRangoProduccionEdicion") as SelectElement).value;
                pMapa["fecha_produccion_inicial"] = (querySelector("#inpFechaRangoInicialEdicion") as InputElement).value;
                pMapa["fecha_produccion_final"]   = (querySelector("#inpFechaRangoFinalEdicion") as InputElement).value;                

                print(pMapa);
                despliegaProductoFila(pMapa);

                ModalP.cierra_modal("mdlEditar");

            });

        });

        btnEditar.style.marginLeft = "5px";

        td.children.add(btnEditar);
        tr.children.add(td);
    }

    pTabla.tBodies[0].children.add(tr);


}

void muestraBotonCerrar(){
    (querySelector("#btnCerrar") as ButtonElement).style.display = "inline";    
}

void ocultaBotonGuardar(){
    (querySelector("#btnGuardar") as ButtonElement).style.display = "none";
}

void despliegaEntidad(Map AItem){
    print(AItem);

    (querySelector("#inpDestino") as SelectElement).value           = AItem["destino"].toString();
    (querySelector("#inpDescripcion") as InputElement).value        = AItem["descripcion"].toString();
    (querySelector("#inpFechaEmbarque") as InputElement).value      = (AItem["fecha_embarque"] as String).substring(8, 10) + "/" + (AItem["fecha_embarque"] as String).substring(5, 7) + "/" + (AItem["fecha_embarque"] as String).substring(0, 4);
    (querySelector("#inpFechaTmp") as InputElement).value           = (querySelector("#inpFechaEmbarque") as InputElement).value;
    (querySelector("#inpValidaProductos") as SelectElement).value   = AItem["valida_productos"];
    (querySelector("#inpClaveCliente") as HiddenInputElement).value = AItem["destino"].toString();
    (querySelector("#spanFolio") as SpanElement).text               = AItem["id"].toString();
    (querySelector("#spanEstado") as SpanElement).text              = AItem["estado"];
    (querySelector("#inpIdUsuario") as InputElement).text           = AItem["id_usuario"].toString();
    inpTipo.value           = AItem["tipo"];
    inpPesoCamion.value     = AItem["peso_camion"].toString();
    inpTarima1.value        = AItem["tarima_1"].toString();
    inpTarima2.value        = AItem["tarima_2"].toString();
    inpDiasProduccion.value = AItem["dias_produccion"].toString();

    try {
        inpClienteMaquila.value = AItem["id_cliente_maquila"].toString();
    }
    catch(_){
        inpClienteMaquila.value = "1002";
    }

    if (AItem['estado'] == 'Cerrado'){
        ocultaBotonGuardar();
    }
    
    if (AItem["tipo"] == "Nacional"){
      if (int.parse(inpFolio.value, onError: (_) => 0) > 0){
        if (inpPuedeEditar.value == "No"){
          ocultaBotonGuardar();
        }
      }
    }

    int p_total_cajas = 0;
    int p_total_cajas_surtidas = 0;
    double p_total_kilos = 0.0;
    double p_total_kilos_surtidos = 0.0;
    double p_total_tara = 0.0;


    for (Map item in AItem['detalle']){

    //    if ((item['cajas_surtidas'] > 0 || item['kilos_surtidos'] > 0) && AItem['estado'] != 'Cerrado'){
            muestraBotonCerrar();
    //    }

        agregaFila(item, AEditable: item["origen"] != "tarima");
        p_total_cajas += item['cajas'];
        p_total_cajas_surtidas += item['cajas_surtidas'];
        p_total_kilos += item["kilos"];
        p_total_kilos_surtidos += item["kilos_surtidos"];
        p_total_tara += item['peso_bruto'] - item["kilos_surtidos"];
    }

    double p_cumplimiento = (p_total_cajas_surtidas / p_total_cajas) * 100;

    if (p_cumplimiento.isNaN){
      p_cumplimiento = 0.0;
    }

    String pCumplimientoS = pNumberFormat.format(p_cumplimiento) + "%";
    (querySelector("#spanCumplimiento") as SpanElement).text = pCumplimientoS;
    (querySelector("#spanTotalCajas") as SpanElement).text = p_total_cajas.toString();
    (querySelector("#spanTotalCajasSurtidas") as SpanElement).text = p_total_cajas_surtidas.toString();
    (querySelector("#spanTotalKilos") as SpanElement).text = nf.format(p_total_kilos);
    (querySelector("#spanTotalKilosSurtidos") as SpanElement).text = nf.format(p_total_kilos_surtidos);
    (querySelector("#spanTotalTara") as SpanElement).text = nf.format(p_total_tara);

    /*try {
        print("...");
        print(AItem["id_clase_salida"].toString());
        inpClaseSalida.value = "2";//AItem["id_clase_salida"].toString();
        print("...");
    }
    catch(_){
        print(_);
        inpClaseSalida.value = "1";
    }*/

    print(AItem["id_clase_salida"].toString());
    new Future.delayed(const Duration(milliseconds: 100), () => inpClaseSalida.value = AItem["id_clase_salida"].toString());

}

void llenaListaTarimasOrden(){
    var pUrl = "http://localhost:8031/rest/salidas/obtener_lista_tarimas_orden_salida/${idOrdenSalida}";

    HttpRequest.getString(pUrl).then((String Data){
        ListaTarimas = JSON.decode(Data);
    });
}

void obtenerOrdenSalida(){
    idOrdenSalida = int.parse((querySelector("#inpFolio") as HiddenInputElement).value);

    var pUrl = "http://localhost:8031/rest/salidas/orden_salida_obtener/${idOrdenSalida}";

    HttpRequest.getString(pUrl).then((String Data){

         Map pOrdenSalida = JSON.decode(Data);
         despliegaEntidad(pOrdenSalida);

    }).then((_){

        llenaListaTarimasOrden();

    });
}

Map obtenerEntidad(){
    Map pResult = new Map();
    pResult["id"] = idOrdenSalida.toString();
    pResult["descripcion"]      = (querySelector("#inpDescripcion") as InputElement).value;
    pResult["fecha_embarque"]   = (querySelector("#inpFechaEmbarque") as InputElement).value;
    pResult["valida_productos"] = (querySelector("#inpValidaProductos") as SelectElement).value;
    pResult["destino"]          = int.parse((querySelector("#inpClaveCliente") as HiddenInputElement).value);
    pResult["id_usuario"]       = (querySelector("#inpIdUsuario") as InputElement).value;
    pResult["estado"]           = "Nuevo";
    pResult["detalle"]          = Detalle;
    pResult["tarimas"]          = ListaTarimas;
    pResult["tipo"]             = inpTipo.value;

    pResult["peso_camion"]      = double.parse(inpPesoCamion.value, (n) => 0.0);

    pResult["tarima_1"]         = int.parse(inpTarima1.value, onError: (n) => 0);
    pResult["tarima_2"]         = int.parse(inpTarima2.value, onError: (n) => 0);
    pResult["dias_produccion"]  = inpDiasProduccion.value;
    pResult["id_cliente_maquila"] = int.parse(inpClienteMaquila.value);
    pResult["id_clase_salida"]    = int.parse(inpClaseSalida.value);

    if (pResult["descripcion"].trim().length == 0){
        pResult = null;
        lastErrorMessage = "Necesita capturar la descripción";
    }

    if (Detalle.length == 0){
        pResult = null;
        lastErrorMessage = "No se han capturado producto";
    }

    return pResult;
}

void guardarOrdenSalida(){

    String pMensaje = "";

    Map pEntidad = obtenerEntidad();

    print(pEntidad);

    if (pEntidad == null){
        window.alert(lastErrorMessage);
        return;
    }

    var pUrl = "http://localhost:8031/rest/salidas/orden_salida_insertar";
    var pData = JSON.encode(pEntidad);

    HttpRequest.request(pUrl, method: "POST", sendData: pData).then((HttpRequest ARequest){
        Map pResult = JSON.decode(ARequest.responseText);

        window.alert(pResult["mensaje"]);

        if (pResult["error"]){
            return;
        }
        else{
            window.location.href = "http://localhost:8031/salidas";
        }
    });
}

void limpiaEditores(){
    (querySelector("#inpProducto") as InputElement).value = "";
    (querySelector("#inpDescripcionProducto") as InputElement).value = "";
    (querySelector("#inpCajas") as InputElement).value = "1";
    (querySelector("#inpKilos") as InputElement).value = "0";
    (querySelector("#inpDiasProduccionLinea") as InputElement).value = "0";

    DateTime pToday = new DateTime.now();
    var pMes = pToday.month.toString().padLeft(2, "0");
    var pDia = pToday.day.toString().padLeft(2, "0");
    inpFechaRangoInicial.value = pDia + "/" + pMes +"/" + pToday.year.toString();
    inpFechaRangoFinal.value = pDia + "/" + pMes +"/" + pToday.year.toString();
}

void despliegaProducto(Map AItem){
    (querySelector("#inpProductoEdicion") as InputElement).value = AItem["producto"];
    (querySelector("#inpDescripcionProductoEdicion") as InputElement).value = AItem["descripcion"];
    (querySelector("#inpCajasEdicion") as InputElement).value = AItem["cajas"].toString();
    (querySelector("#inpKilosEdicion") as InputElement).value = AItem["kilos"].toString();
    (querySelector("#inpDiasProduccionEdicion") as InputElement).value = AItem["dias_produccion"].toString();
    (querySelector("#inpValidaRangoProduccionEdicion") as SelectElement).value = AItem["valida_rango_produccion"];
    (querySelector("#inpFechaRangoInicialEdicion") as InputElement).value = AItem["fecha_produccion_inicial"];
    (querySelector("#inpFechaRangoFinalEdicion") as InputElement).value = AItem["fecha_produccion_final"];
}

void despliegaProductoFila(Map AItem){

    print(AItem);
    TableRowElement tr = (querySelector("#tr${AItem["id"]}"));
    tr.cells[0].text = AItem["producto"];
    tr.cells[1].text = AItem["descripcion"];
    tr.cells[2].text = AItem["cajas"].toString();
    tr.cells[3].text = pNumberFormat.format(AItem["kilos"]);
    tr.cells[6].text = AItem["dias_produccion"].toString();
    tr.cells[7].text = pNumberFormat.format(AItem["peso_bruto"] - AItem["kilos"]).toString();

}

void agregar(){
    if (ListaTarimas.length > 0){
        window.alert("No se pueden agregar productos s ya se agregaron tarimas");
        return;
    }

    limpiaEditores();
    ModalP.modal("mdlAgregar");
    (querySelector("#inpProducto") as InputElement).focus();
}

void onBlurProducto(){
    String pProducto = (querySelector("#inpProducto") as InputElement).value;

    if (pProducto.trim().length > 0){

        String pUrl = "http://localhost:8031/rest/productos/obtener_descripcion/${pProducto}";

        HttpRequest.getString(pUrl).then((data){

            var pMap = JSON.decode(data);

            String pCodigo = pMap["clave"];

            if (pMap["clave"] != "0"){
                (querySelector("#inpDescripcionProducto") as InputElement).value = pMap["descripcion"];
                (querySelector("#inpCajas") as InputElement).focus();
            }
            else{
                window.alert("No existe el producto");
                (querySelector("#inpProducto") as InputElement).focus();
            }
        });
    }
}

void onBlurProductoConsultaTarimas(){
    String pProducto = inpClavePtoTarima.value;

    if (pProducto.trim().length > 0){

        String pUrl = "http://localhost:8031/rest/productos/obtener_descripcion/${pProducto}";

        HttpRequest.getString(pUrl).then((data){

            var pMap = JSON.decode(data);

            String pCodigo = pMap["clave"];

            if (pMap["clave"] != "0"){
                inpNombrePtoTarima.value = pMap["descripcion"];
                inpCamaras.focus();
            }
            else{
                window.alert("No existe el producto");
                inpClavePtoTarima.focus();
                inpNombrePtoTarima.value = "";
            }
        });
    }
}

void agregarProducto(){

    Map pMapa = new Map();
    pMapa["id"]             = indice;
    indice++;
    pMapa["producto"]       = (querySelector("#inpProducto") as InputElement).value.trim();
    pMapa["descripcion"]    = (querySelector("#inpDescripcionProducto") as InputElement).value;

    try{
        pMapa["cajas"]          = int.parse((querySelector("#inpCajas") as InputElement).value);
    }
    catch(_){
        pMapa["cajas"] = -1;
    }

    try{
        pMapa["kilos"]          = double.parse((querySelector("#inpKilos") as InputElement).value);
    }
    catch(_){
        pMapa["kilos"] = -1;
    }

    try{
         pMapa["dias_produccion"] = int.parse((querySelector("#inpDiasProduccionLinea") as InputElement).value);
    }
    catch(_){
         pMapa["dias_produccio"] = 0;
    }

    pMapa["cajas_surtidas"] = 0;
    pMapa["kilos_surtidos"] = 0;
    pMapa["peso_bruto"] = 0;

    if (pMapa["producto"].length == 0 || pMapa["producto"] ==  ""){
        window.alert("Error, el producto no es válido");
        (querySelector("#inpCajas") as InputElement).focus();
        return;
    }

    if (pMapa["cajas"] < 0){
        window.alert("Error, el número de cajas no es válido");
        (querySelector("#inpCajas") as InputElement).focus();
        return;
    }

    if (pMapa["kilos"] < 0){
        window.alert("Error, el número de kilos no es válido");
        (querySelector("#inpKilos") as InputElement).focus();
        return;
    }

    if (pMapa["cajas"] > 0 && pMapa["kilos"] > 0){
        window.alert("Error, solo uno cajas o kilos puede ser mayor a cero, ambos no");
        (querySelector("#inpCajas") as InputElement).focus();
        return;
    }

    if (pMapa["cajas"] == 0 && pMapa["kilos"] == 0){
        window.alert("Error, debe poner cajas o kilos con un valor mayor a cero");
        (querySelector("#inpCajas") as InputElement).focus();
        return;
    }

    if (Detalle.where((Map x) => x["producto"] == pMapa["producto"]).toList().length > 0){
        window.alert("Error, el producto ya se encuentra en la lista");
        limpiaEditores();
        (querySelector("#inpProducto") as InputElement).focus();
        return;
    }

    pMapa["valida_rango_produccion"]  = inpValidaRangoProduccion.value;
    pMapa["fecha_produccion_inicial"] = inpFechaRangoInicial.value;
    pMapa["fecha_produccion_final"]   = inpFechaRangoFinal.value;

    agregaFila(pMapa);
    limpiaEditores();
    (querySelector("#inpProducto") as InputElement).focus();

}

Future<bool> productoSinSurtir() async{

  var pUrl = "http://localhost:8031/rest/productos_sin_surtir/$idOrdenSalida";

  String pJson = await HttpRequest.getString(pUrl);

  Map pData = JSON.decode(pJson);

  if (pData["result"] == 1){

      var pInput = await quickdialogs.showDialog(pData["mensaje"] + " ¿Cerrar Orden?", "Cerrar", quickdialogs.TDialogType.ERROR, quickdialogs.TDialogButtons.YES_NO);

      if (pInput == quickdialogs.TDialogResult.YES){

          var pPassword = await quickdialogs.inputText("", "Cerrar", Password: true);

          if (pPassword == "grole55"){
            print("Correcto");
            return true;
          }
          else{
            await quickdialogs.showDialog("Contraseña incorrecta", "Error", quickdialogs.TDialogType.ERROR, quickdialogs.TDialogButtons.OK);
            return false;
          }

      }
      else{
        return false;
      }

  }

}

DateTime strToFecha(String AFecha){

   var pYear = AFecha.substring(6, 10);
   var pMes = AFecha.substring(3, 5);
   var pDia = AFecha.substring(0, 2);

   print("pYear: ${pYear}, pMes: ${pMes}, pDia: ${pDia}");

   return new DateTime(int.parse(pYear), int.parse(pMes), int.parse(pDia));
}

DateTime getFechaActual(){
   DateTime pFechaActual = new DateTime.now();
   return new DateTime(pFechaActual.year, pFechaActual.month, pFechaActual.day);
}

cerrarOrden() async{

    String pFecha = (document.getElementById("inpFechaTmp") as InputElement).value;

    DateTime pFechaTmp = strToFecha(pFecha);
    print(pFechaTmp);

    DateTime pFechaActual = getFechaActual();

    print("fechas");
    print(pFechaTmp);
    print(pFechaActual);

    pFechaTmp.compareTo(pFechaActual);

    if (pFechaTmp.compareTo(pFechaActual) < 0){
        await quickdialogs.showDialog("No se puede cerrar orden porque la fecha actual y la fecha de embarques no son iguales", "Error", quickdialogs.TDialogType.ERROR, quickdialogs.TDialogButtons.OK);
          return;
    }

    if (window.confirm("¿Cerrar la orden de salida?")){

        (document.querySelector("#btnCerrar") as ButtonElement).disabled = true;

        bool pProductosSinSurtir = await productoSinSurtir();

        if (pProductosSinSurtir == false){
          await quickdialogs.showDialog("No se puede cerrar orden si hay producto sin surtir", "Error", quickdialogs.TDialogType.ERROR, quickdialogs.TDialogButtons.OK);
          return;
        }

        var pUrl = "http://localhost:8031/rest/salidas/crear_salida_embarques/${idOrdenSalida}";

        HttpRequest.request(pUrl, method: "POST", sendData: "_").then((HttpRequest ARequest){

            (document.querySelector("#btnCerrar") as ButtonElement).disabled = false;

            Map pResult = JSON.decode(ARequest.responseText);
            window.alert(pResult['mensaje']);

            if (pResult["folio_salida"] > 0){

                var pUrl = "http://localhost:8031/rest/salidas/cambiar_estado/${idOrdenSalida}";

                Map pData = new Map();
                pData['estado'] = "Cerrado";
                String pDataJ = JSON.encode(pData);

                HttpRequest.request(pUrl, method: "PUT", sendData: pDataJ).then((_){

                }).then((HttpRequest ARequest){
                    (querySelector("#btnGuardar") as ButtonElement).style.display = "none";
                    (querySelector("#btnCerrar") as ButtonElement).style.display = "none";
                    (querySelector("#spanEstado") as SpanElement).text = "Cerrado";
                });

            }
        });
    }

}

void agregarTarimas(){

    if (ListaTarimas.length == 0 && Detalle.length > 0){
        window.alert("No se pueden agregar tarimas porque ya existen productos");
        return;
    }

    ModalP.modal("mdlConsultaTarimas");
    inpClavePtoTarima.focus();
}

void llenaCamaras(){
    var pUrl = "http://localhost:8031/camaras/obtener_lista";

    HttpRequest.getString(pUrl).then((String Data){

        List<Map> pListaCamaras = JSON.decode(Data);

        for (Map item in pListaCamaras){

            inpCamaras.children.add(new Element.html('<option value="${item["id"]}">${item["descripcion"]}</option>'));
        }

    });
}

void agregaTarimaDetalle(Map ATarima){

    Map item = null;
    try{
        item = Detalle.where((Map x) => x["producto"] == ATarima["producto"]).toList().first;
    }
    catch(_){
        item = null;
    }

    if (item == null){
        Map pItem = new Map();
        pItem['id'] = indice;
        indice++;
        pItem["producto"]    = ATarima["producto"];
        pItem["descripcion"] = ATarima["descripcion"];
        pItem["cajas"]       = ATarima["cajas"];
        pItem["kilos"]       = ATarima["kilos"];
        pItem["cajas_surtidas"] = 0;
        pItem["kilos_surtidos"] = 0.0;
        pItem["origen"] = "tarima";
        agregaFila(pItem, AEditable: false);
    }
    else
    {
        item["producto"]    = ATarima["producto"];
        item["descripcion"] = ATarima["descripcion"];
        item["cajas"] += ATarima["cajas"];
        item["kilos"] += ATarima["kilos"];
        item["origen"] = "tarima";
        despliegaProductoFila(item);
    }

}

void remueveTarimaDetalle(Map ATarima){

    Map item = null;
    try{
        item = Detalle.where((Map x) => x["producto"] == ATarima["producto"]).toList().first;
    }
    catch(_){
        item = null;
    }

    if (item != null){

        item["producto"]    = ATarima["producto"];
        item["descripcion"] = ATarima["descripcion"];
        item["cajas"] -= ATarima["cajas"];
        item["kilos"] -= ATarima["kilos"];
        despliegaProductoFila(item);

        if (item["cajas"] == 0 && item["kilos"] <= 1.0){
            Detalle.removeWhere((Map x) => x["id"] == item["id"]);
            TableRowElement tr = querySelector("#tr${item["id"]}");
            tr.remove();
        }
    }

}

void llenaTablaConsultaTarimas(){

    tablaConsultaTarimas.tBodies[0].children.clear();

    var pUrl =  "http://localhost:8031/rest/salidas/obtener_consulta_tarimas/${inpCamaras.value}/${inpClavePtoTarima.value}/${idOrdenSalida}";

    HttpRequest.getString(pUrl).then((String Data){

       List<Map> pLista = JSON.decode(Data);

       for (Map item in pLista){

           TableRowElement tr = new TableRowElement()..id = "trt${item["folio"]}";

           CheckboxInputElement chkFolio = new CheckboxInputElement();

           if (ListaTarimas.where((int x) => x == item["folio"]).length > 0){
               chkFolio.checked = true;
           }

           chkFolio.onClick.listen((_){

               if (chkFolio.checked){
                   ListaTarimas.add(item["folio"]);
                   agregaTarimaDetalle(item);
               }
               else{
                   ListaTarimas.removeWhere((int x) => x == item["folio"]);
                   remueveTarimaDetalle(item);
               }

           });

           TableCellElement td = new TableCellElement()..children.add(chkFolio);
           tr.children.add(td);
           td = new TableCellElement()..text = "${item["folio"]}";
           tr.children.add(td);
           td = new TableCellElement()..text = "${item["descripcion"]}";
           tr.children.add(td);
           td = new TableCellElement()..text = "${item["cajas"]}";
           tr.children.add(td);
           td = new TableCellElement()..text = "${pNumberFormat.format(item["kilos"])}";
           tr.children.add(td);
           td = new TableCellElement()..text = "${item["dias_produccion"]}";
           tr.children.add(td);

           tablaConsultaTarimas.tBodies[0].children.add(tr);
       }

    });

}

Future init() async{

    Completer pCompleter = new Completer();

    (querySelector("#btnGuardar") as ButtonElement).onClick.listen((_){
        guardarOrdenSalida();
    });

    (querySelector("#btnCancelar") as ButtonElement).onClick.listen((_){
        if (window.confirm("¿Cancelar captura de salida?")){
            window.location.href = "http://localhost:8031/salidas";
        }
    });

    (querySelector("#btnAgregar") as ButtonElement).onClick.listen((_){
        agregar();        
    });

    (querySelector("#btnAgregarTarimas") as ButtonElement).onClick.listen((_){
        agregarTarimas();
    });

    btnCosultarTarimas.onClick.listen((_){
       llenaTablaConsultaTarimas();
    });

    btnCancelarCosultarTarimas.onClick.listen((_){
        ModalP.cierra_modal("mdlConsultaTarimas");
    });

    (querySelector("#inpProducto") as InputElement).onBlur.listen((_){
        onBlurProducto();
    });

    inpClavePtoTarima.onBlur.listen((_){
        onBlurProductoConsultaTarimas();
    });

    (querySelector("#btnAgregarProducto") as InputElement).onClick.listen((_){
        agregarProducto();
    });

    (querySelector("#btnCancelarCaptura") as InputElement).onClick.listen((_){
        ModalP.cierra_modal("mdlAgregar");
    });

    (querySelector("#btnCancelarEdicion") as InputElement).onClick.listen((_){
        ModalP.cierra_modal("mdlEditar");
    });

    (querySelector("#btnCerrar") as ButtonElement).onClick.listen((_) async{
        await cerrarOrden();
    });

    inpValidaRangoProduccion.onChange.listen((z){

      if (inpValidaRangoProduccion.value == "Si"){
          inpDiasProduccionLinea.value = "0";
      }


    });

    llenaCamaras();
    await llenaSelectClientesMaquila();
    await llenaClaseSalidas();
    await llenaClientes();
    inpDestino.onChange.listen((x){

      (querySelector("#inpClaveCliente") as HiddenInputElement).value = inpDestino.value;

    });
    pCompleter.complete();
    return pCompleter.future;
}

main() async{
    await init();
    obtenerOrdenSalida();
    inpTipo.onChange.listen((_) async{
        await llenaClientes();
        if (inpTipo.value == "Nacional"){
            if (int.parse(inpFolio.value, onError: (_) => 0) > 0){
              if (inpPuedeEditar.value == "No"){
                ocultaBotonGuardar();
              }
        }
        }
        else{
          (querySelector("#btnGuardar") as ButtonElement).style.display = "inline";
        }
    });
}