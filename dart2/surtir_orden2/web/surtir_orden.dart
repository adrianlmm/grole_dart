import 'dart:html';
import 'package:intl/intl.dart' as intl;
import 'OrdenProduccion.dart';
import 'OrdenPP.dart';
import 'detalle_mp.dart';
import 'salida_inventario.dart';
import 'dart:convert';
import 'dart:async';
import 'modal_p.dart' as ModalP;

String IdOrden = "";
OrdenProduccion POrdenProduccion = new OrdenProduccion();
List<OrdenMP> ListaOrdenPMP = new List<OrdenMP>();
List<OrdenMP> ListaOrdenPP  = new List<OrdenMP>();
List<Produccion> ListaProduccion = new List<Produccion>();
List<DetalleMP> ListaDetalle = new List<DetalleMP>();
List<DetalleMPTarima> ListaDetalleTarima = new List<DetalleMPTarima>();

final HiddenInputElement inpPassword = querySelector("#inpPassword");

double SurtidoTotal = 0.0;
StreamSubscription EventoCostoSalida = null;
StreamSubscription EventoCostoMaquila = null;
StreamSubscription EventoValorRescate = null;
bool editable = true;

double pTotalKilos   = 0.0;
double pTotalSurtido = 0.0;
double pTotalCosto   = 0.0;
double pTotalImporte = 0.0;

double pTotalProgramado     = 0.0;
double pTotalProducidoT     = 0.0;
double pTotalCajas          = 0.0;
double pTotalCostoMaquila   = 0.0;
double pTotalImporteMaquila = 0.0;
double pTotalValorRescate   = 0.0;
double pTotalImporteRescate = 0.0;

String FolioSalida = "-";

String ObtenerIdOrden(){
    String p_querySelector_string = window.location.search;
    String p_orden = p_querySelector_string.split("&")[0];
    p_orden = p_orden.split("=")[1];
    return p_orden;
}

void agregaFilaMPrima(OrdenMP item){

    TableElement tableMP = querySelector("#tableMPrima");

    TableRowElement tr = new TableRowElement()..id = item.id.toString();
    TableCellElement td = new TableCellElement()..text = item.producto;
    tr.children.add(td);
    td = new TableCellElement()..text = item.codigosap;
    tr.children.add(td);
    td = new TableCellElement()..text = item.descripcion;
    tr.children.add(td);
    td = new TableCellElement()..text = new intl.NumberFormat("#,##0.00").format(item.kilos)..style.textAlign = "right";
    tr.children.add(td);
    td = new TableCellElement()..text = new intl.NumberFormat("#,##0.00").format(item.surtido)..style.textAlign = "right";
    tr.children.add(td);
    td = new TableCellElement()..text = item.cajas.toString()..style.textAlign = "right";
    tr.children.add(td);
    td = new TableCellElement()..text = new intl.NumberFormat("#,##0.00").format(item.saldo_sap)..style.textAlign = "right"..id = "mp_saldo_sap${item.id}";
    tr.children.add(td);
    td = new TableCellElement()..text = new intl.NumberFormat("#,##0.00").format(item.costo_salida)..style.textAlign = "right"..id = "mp_costo${item.id}";
    tr.children.add(td);
    td = new TableCellElement()..text = new intl.NumberFormat("#,##0.00").format(item.importe_salida)..style.textAlign = "right"..id = "mp_importe_costo${item.id}";
    tr.children.add(td);

    String pHtmlBtn = "<button class='btn edit_btn'><i class='icon-list'></i></button>";
    ButtonElement btn = new Element.html(pHtmlBtn)..id = 'btnDetalleOrden${item.id.toString()}'..onClick.listen((_){
        detalleOrden(item);
    });

    td = new TableCellElement()..children.add(btn);
    tr.children.add(td);

    tableMP.tBodies[0].children.add(tr);
}

void actualizaFilaMPrima(OrdenMP item){

  (querySelector("#mp_costo${item.id}") as TableCellElement).text = new intl.NumberFormat("#,##0.00").format(item.costo_salida);
  (querySelector("#mp_importe_costo${item.id}") as TableCellElement).text = new intl.NumberFormat("#,##0.00").format(item.importe_salida);
  (querySelector("#mp_saldo_sap${item.id}") as TableCellElement).text = new intl.NumberFormat("#,##0.00").format(item.saldo_sap);

}

void agregaFilaProducido(Produccion item){

  TableElement tableMP = querySelector("#tablaProducido");

  TableRowElement tr = new TableRowElement()..id = item.id.toString();

  TableCellElement td = new TableCellElement()..text = item.factura.toString();
  tr.children.add(td);
  td = new TableCellElement()..text = item.clave_producto;
  tr.children.add(td);
  td = new TableCellElement()..text = item.codigosap;
  tr.children.add(td);
  td = new TableCellElement()..text = item.nombre_producto;
  tr.children.add(td);
  td = new TableCellElement()..text = new intl.NumberFormat("#,##0.00").format(item.programado)..style.textAlign = "right";
  tr.children.add(td);
  td = new TableCellElement()..text = new intl.NumberFormat("#,##0.00").format(item.producido)..style.textAlign = "right";
  tr.children.add(td);
  td = new TableCellElement()..text = new intl.NumberFormat("#,##0.00").format(item.porcentaje)..style.textAlign = "right";
  tr.children.add(td);

  AnchorElement pCajas = new Element.html("<a href=\"#\">${item.cajas}</a>");

  pCajas.onClick.listen((_){

    detalleProducido(item);

  });

  td = new TableCellElement()..style.textAlign = "right"..id = "pp_cajas${item.id}"..children.add(pCajas);
  tr.children.add(td);
  td = new TableCellElement()..text = new intl.NumberFormat("#,##0.00").format(item.costo_maquila)..style.textAlign = "right"..id = "pp_costo_maquila${item.id}";
  tr.children.add(td);
  td = new TableCellElement()..text = new intl.NumberFormat("#,##0.00").format(item.importe_maquila)..style.textAlign = "right"..id = "pp_importe_maquila${item.id}";
  tr.children.add(td);
  AnchorElement pValorRescate = new Element.html("<a href=\"#\">${new intl.NumberFormat("#,##0.00").format(item.valor_rescate)}</a>");

  pValorRescate.onClick.listen((_){

    capturaValorRescate(item);

  });

  td = new TableCellElement()..style.textAlign = "right"..id = "pp_valor_rescate${item.id}"..children.add(pValorRescate);
  tr.children.add(td);

  td = new TableCellElement()..text = new intl.NumberFormat("#,##0.00").format(item.importe_rescate)..style.textAlign = "right"..id = "pp_importe_rescate${item.id}";
  tr.children.add(td);

  td = new TableCellElement()..style.textAlign = "right"..text = new intl.NumberFormat("#,##0.00").format(item.costo_pto_terminado);
  tr.children.add(td);

  td = new TableCellElement()..style.textAlign = "right"..text = new intl.NumberFormat("#,##0.00").format(item.importe);
  tr.children.add(td);

  String pHtmlBtn = "<button class='btn edit_btn'><i class='icon-list'></i></button>";
  ButtonElement btn = new Element.html(pHtmlBtn)..id = 'btnCostoMaquila${item.id.toString()}'..onClick.listen((_){
      costoMaquila(item);
  });

  td = new TableCellElement()..children.add(btn);
  tr.children.add(td);


  tableMP.tBodies[0].children.add(tr);
}

void actualizaFilaProduccion(Produccion item){
  (querySelector("#pp_costo_maquila${item.id}") as TableCellElement).text = new intl.NumberFormat("#,##0.00").format(item.costo_maquila);
  (querySelector("#pp_importe_maquila${item.id}") as TableCellElement).text = new intl.NumberFormat("#,##0.00").format(item.importe_maquila);
  TableCellElement pCellValorRescate = (querySelector("#pp_valor_rescate${item.id}") as TableCellElement);
  (pCellValorRescate.children[0] as AnchorElement).text = new intl.NumberFormat("#,##0.00").format(item.valor_rescate);
  (querySelector("#pp_importe_rescate${item.id}") as TableCellElement).text = new intl.NumberFormat("#,##0.00").format(item.importe_rescate);
}

void ObtenerOrdenProduccion(String AId){
  IdOrden = AId;
  String pUrl = 'http://localhost:8031/rest/ordenp/OrdenProduccion_obtener/${AId}';

  HttpRequest.getString(pUrl, onProgress: null).then((data){
        POrdenProduccion = new OrdenProduccion.FromJSON(data);

        DespliegaEntidad(POrdenProduccion);
        //print(POrdenProduccion.estado);
    }).then((String Data) {

        String pUrl = 'http://localhost:8031/rest/ordenp/ordenmp_obtener_lista/${POrdenProduccion.id.toString()}';
        HttpRequest.getString(pUrl, onProgress: null).then((String Data){

        var pLista = JSON.decode(Data);

        for (var item in pLista){
          var pOdenMP = new OrdenMP.FromMap(item);
          ListaOrdenPMP.add(pOdenMP);

            agregaFilaMPrima(pOdenMP);

            pTotalKilos   += pOdenMP.kilos;
            pTotalSurtido += pOdenMP.surtido;
            pTotalCosto   += pOdenMP.costo_salida;
            pTotalImporte += pOdenMP.importe_salida;
        }

        SurtidoTotal = pTotalSurtido;

        document.querySelector("#TotalKilosP").innerHtml   = new intl.NumberFormat("#,##0.00").format(pTotalKilos);
        document.querySelector("#TotalSurtidoP").innerHtml = new intl.NumberFormat("#,##0.00").format(pTotalSurtido);
        document.querySelector("#TotalCostoP").innerHtml   = new intl.NumberFormat("#,##0.00").format(pTotalCosto);


        document.querySelector("#TotalImporteP").innerHtml = new intl.NumberFormat("#,##0.00").format(pTotalImporte);

        if (POrdenProduccion.costo_salida > 0){
          pTotalImporte = POrdenProduccion.costo_salida;
          document.querySelector("#TotalImporteP").innerHtml = new intl.NumberFormat("#,##0.00").format(POrdenProduccion.costo_salida);
        }
        else{

          var pUrlCosto = "http://localhost/WebFrontEnd/inventarios/ObtenerCostoSalida?Orden=${IdOrden.toString()}&Cuenta=11100030001&Empresa=SolesProd";
          //print(pUrlCosto);

          HttpRequest.getString(pUrlCosto).then((String Data){

            double pCosto = JSON.decode(Data).toDouble();
            pTotalImporte = pCosto;
            POrdenProduccion.costo_salida = pCosto;
            (document.querySelector("#TotalImporteP") as SpanElement).innerHtml = new intl.NumberFormat("###,0.00").format(pCosto);

            String pUrl = "http://localhost:8031/rest/ordenp/actualizar_costo_salida_orden/${IdOrden.toString()}";
            String pData = '{"costo": "${pCosto.toString()}" }';
            Map<String, String> headers = new Map<String, String>();
            headers["content-type"] = "application/json";

            HttpRequest.request(pUrl, method: "POST", responseType: "application/json", sendData: pData, requestHeaders: headers);

          });

        }

        String pUrl = 'http://localhost:8031/rest/ordenp/ordenpp_obtener_lista/${POrdenProduccion.id.toString()}';
        //print("..w..${pUrl}");
        return HttpRequest.getString(pUrl);
      }).then((String Data){

        var pLista = JSON.decode(Data);

        for (var item in pLista){
            OrdenMP pItem = new OrdenMP.FromMap(item);
            ListaOrdenPP.add(pItem);
        }

      }).then((String Data){
        HttpRequest.getString(pUrl, onProgress: null).then((String Data) {
              //print("-------------------------------------------------------------------------");
              //print(Data);
              DespliegaEntidad(POrdenProduccion);
          });
      });
    }).then((String Data){

          pUrl = 'http://localhost:8031/rest/ordenp/obtener_producido_orden/${AId}';

          HttpRequest.getString(pUrl).then((String Data){
              //print("Producido");
              //print(Data);
              List pLista = JSON.decode(Data);

              double pTotalProducido = 0.0;

              for (Map item in pLista){
                  var pProduccion = new Produccion.fromMap(item);

                  print("Modo calculo:");
                  print(POrdenProduccion.modo_calculo);

                  if (POrdenProduccion.modo_calculo == "Diferencia"){
                      print("Diferencia");
                      pProduccion.importe_maquila = pProduccion.costo_maquila * (pProduccion.producido - SurtidoTotal);

                  }

                  pTotalProgramado     += pProduccion.programado;
                  pTotalCajas          += pProduccion.cajas;
                  pTotalCostoMaquila   += pProduccion.costo_maquila;
                  pTotalImporteMaquila += pProduccion.importe_maquila;
                  pTotalValorRescate   += pProduccion.valor_rescate;
                  pTotalProducidoT     += pProduccion.producido;

                  if (pProduccion.importe_maquila == 0){
                     pTotalImporteRescate += pProduccion.importe_rescate;
                  }
                  else{
                     pTotalProducido += pProduccion.producido;
                  }

                  if (pProduccion.costo_maquila > 0){

                      String pUrl = "http://localhost:8031/rest/ordenp/actualizar_costo_maquila/${pProduccion.id}";
                      String pData = '{"costo":' + pProduccion.costo_maquila.toString() + ',"importe":' + pProduccion.importe_maquila.toString() + '}';
                      Map<String, String> headers = new Map<String, String>();
                      headers["content-type"] = "application/x-www-form-urlencoded";

                      HttpRequest.request(pUrl, method: "POST", responseType: "application/json", sendData: pData, requestHeaders: headers).then((HttpRequest ARequest){
                            //print(ARequest.responseText);
                      });

                  }
              }

              new Future.delayed(new Duration(seconds: 5)).then((_){

                for (Map item in pLista){
                    var pProduccion = new Produccion.fromMap(item);
                    
                    pProduccion.costo_pto_terminado = ((pTotalImporteMaquila + pTotalImporte) - pTotalImporteRescate) / (pTotalProducido);
                    
                    pProduccion.importe = pProduccion.producido * pProduccion.costo_pto_terminado;
                    agregaFilaProducido(pProduccion);
                    ListaProduccion.add(pProduccion);
                }
                
                document.querySelector("#TotalProgramado").innerHtml      = new intl.NumberFormat("#,##0.00").format(pTotalProgramado);
                document.querySelector("#TotalProducido").innerHtml       = new intl.NumberFormat("#,##0.00").format(pTotalProducidoT);
                document.querySelector("#TotalCajas").innerHtml           = pTotalCajas.toString();
                document.querySelector("#TotalCostoMaquila").innerHtml    = new intl.NumberFormat("#,##0.00").format(pTotalCostoMaquila);
                document.querySelector("#TotalImporteMaquila").innerHtml  = new intl.NumberFormat("#,##0.00").format(pTotalImporteMaquila);
                document.querySelector("#TotalValorRescate").innerHtml    = new intl.NumberFormat("#,##0.00").format(pTotalValorRescate);
                document.querySelector("#TotalImporteRescate").innerHtml  = new intl.NumberFormat("#,##0.00").format(pTotalImporteRescate);

                for (Produccion item in ListaProduccion){
                    try
                    {
                         item.porcentaje = (item.producido / SurtidoTotal) * 100;
                    }
                    catch(ex){
                        item.porcentaje = 0.0;
                    }
                }


              });

              
          });
     });
}

void ocultaBotones(){
  document.querySelector("#btnSalida").style.display = "none";
  document.querySelector("#btnGeneraSalida").style.display = "none";
}

void DespliegaEntidad(OrdenProduccion AOrdenProduccion){
    (document.querySelector("#spanId") as SpanElement).text            = AOrdenProduccion.id.toString();
    (document.querySelector("#id_orden")  as InputElement).value       = AOrdenProduccion.descripcion;
    (document.querySelector("#fecha") as InputElement).value           = AOrdenProduccion.fecha;
    (document.querySelector("#lote_produccion") as InputElement).value = AOrdenProduccion.lote_produccion.toString();
    (document.querySelector("#spanEstado") as SpanElement).text        = AOrdenProduccion.estado;
    (document.querySelector("#spanFolioSalida") as SpanElement).text   = ",Salida: ${AOrdenProduccion.id_salida}";

   if (AOrdenProduccion.estado == "Surtido"){
      document.querySelector("#btnSalida").text = "Cerrar";
   }

   if (AOrdenProduccion.estado == "Autorizado"){
     document.querySelector("#btnSalida").text = "Abrir";

     (document.querySelector("#btnGeneraSalida") as ButtonElement).classes.remove("hiden");
     //(document.querySelector("#btnGeneraPoliza") as ButtonElement).classes.remove("hiden");
   }

   if (AOrdenProduccion.estado == "Generado" || AOrdenProduccion.estado == "Finalizado"){
     (document.querySelector("#btnSalida") as ButtonElement).classes.add("hiden");
   }

   if (AOrdenProduccion.estado == "Generado" || AOrdenProduccion.estado == "Finalizado"){
    (document.querySelector("#btnSalida") as ButtonElement).classes.add("hiden");
   }

   if (AOrdenProduccion.estado == "Generado"){
    (document.querySelector("#btnEntrada") as ButtonElement).classes.remove("hiden");
   }

   if (!editable){
      ocultaBotones();
   }
}

OrdenProduccion ObtenerEntidad(){
  OrdenProduccion pOrdenProduccion = new OrdenProduccion();
  pOrdenProduccion.id              = int.parse((querySelector("#id") as HiddenInputElement).value);
  pOrdenProduccion.id_usuario      = int.parse((querySelector("#id_usuario") as HiddenInputElement).value);
  print("id_usuario: ${pOrdenProduccion.id_usuario}");
  pOrdenProduccion.id_tipo         = int.parse((querySelector("#id_tipo") as HiddenInputElement).value);
  pOrdenProduccion.descripcion     = (querySelector("#id_orden") as InputElement).value;
  pOrdenProduccion.fecha           = (querySelector("#fecha") as InputElement).value;
  pOrdenProduccion.lote_produccion = (querySelector("#lote_produccion") as InputElement).value;
  pOrdenProduccion.estado          = document.querySelector("#spanEstado").text;

  return pOrdenProduccion;
}

void programaOrdenProduccion(){

    if (window.confirm("¿Programar la orden de producción?") == false){
        return;
    }

    Map pParametros = new Map();

    String pProductos = "";
    for (OrdenMP item in ListaOrdenPP){
        pProductos += "${item.producto},";
    }

    pProductos = pProductos.substring(0, pProductos.length - 1);

    var pUrl = 'http://localhost:8031/rest/ordenp/programar_orden';
    String pData = "lote=${POrdenProduccion.lote_produccion.toString()}&productos=${pProductos}&fecha=${POrdenProduccion.fecha}&id_orden=${POrdenProduccion.id.toString()}&id_usuario=${(querySelector("#id_usuario") as HiddenInputElement).value}";
    print(pData);

    Map<String, String> headers = new Map<String, String>();
    headers["content-type"] = "application/x-www-form-urlencoded";

    HttpRequest.request(pUrl, method: "POST", responseType: "application/json", sendData: pData, requestHeaders: headers).then((HttpRequest ARequest){

        print(ARequest.responseText);
        Map pResult = JSON.decode(ARequest.responseText);

        if (pResult["id"] == 0){
            window.alert(pResult["mensaje"]);
        }
        else{
            POrdenProduccion.estado            = "Programado";
            POrdenProduccion.id_programacion   = pResult["id"];
            document.querySelector("#spanEstado").text = "Programado";
            document.querySelector("#btnSalida").text = "DesProgramar";
            window.alert("Se programo la orden con éxito");
        }
    });
}

void desprogramaOrdenProduccion(){

  if (window.confirm("¿Desprogramar la orden de producción?") == false){
    return;
  }

  Map pParametros = new Map();

  String pProductos = "";
  for (OrdenMP item in ListaOrdenPP){
    pProductos += "${item.producto},";
  }

  pProductos = pProductos.substring(0, pProductos.length - 1);

  var pUrl = 'http://localhost:8031/rest/ordenp/desprogramar_orden';
  String pData = "id_orden=${POrdenProduccion.id.toString()}&id_programacion=${POrdenProduccion.id_programacion.toString()}";
  print(pData);

  Map<String, String> headers = new Map<String, String>();
  headers["content-type"] = "application/x-www-form-urlencoded";

  HttpRequest.request(pUrl, method: "POST", responseType: "application/json", sendData: pData, requestHeaders: headers).then((HttpRequest ARequest){

    print(ARequest.responseText);
    Map pResult = JSON.decode(ARequest.responseText);

    if (pResult["id"] == 0){
      window.alert(pResult["mensaje"]);
    }
    else{
      POrdenProduccion.estado            = "Surtido";
      document.querySelector("#spanEstado").text = "Surtido";
      document.querySelector("#btnSalida").text = "Programar";
      window.alert("Se desprogramo la orden con éxito");
    }
  });
}

void cerrarOrdenProduccion(){

  if (window.confirm("¿Cerrar la orden de producción?")){
    Map pParametros = new Map();

    String pData    = JSON.encode(pParametros);
    String pUrl     = 'http://localhost:8031/rest/ordenp/ordenmp_cerrar/${IdOrden}';
    print(pUrl);
    Map<String, String> headers = new Map<String, String>();
    headers["content-type"] = "application/json";

    HttpRequest.request(pUrl, method: "PUT", requestHeaders:  headers , sendData:  pData).then((HttpRequest request){
      print(request.responseText);
      Map pResult = JSON.decode(request.responseText);
      print(pResult['result'].toString());
      if (pResult['result'] == 0){
          window.alert("Se cerro con éxito");

          String pFecha = "";
          List<String> pLista = window.location.search.split("&");
          pLista = pLista[1].split("=");
          pFecha = pLista[1];

          window.location.href = "/ordenes_produccion?fecha=${pFecha}";
      }
      else{
          print(pResult['mensaje'].toString());
          window.alert(pResult['mensaje'].toString());
      }
    });
  }
}

void abrirOrdenProduccion(){

  if (window.confirm("¿Abrir la orden de producción?")){
      Map pParametros = new Map();

      String pData    = JSON.encode(pParametros);
      String pUrl     = 'http://localhost:8031/rest/ordenp/ordenmp_abrir/${IdOrden}';
      print(pUrl);
      Map<String, String> headers = new Map<String, String>();
      headers["content-type"] = "application/json";

      HttpRequest.request(pUrl, method: "PUT", requestHeaders:  headers , sendData:  pData).then((HttpRequest request){
        print(request.responseText);
        Map pResult = JSON.decode(request.responseText);
        print(pResult['result'].toString());
        if (pResult['result'] == 0){
            window.alert("Se abrió con éxito");
            String pFecha = "";
            List<String> pLista = window.location.search.split("&");
            pLista = pLista[1].split("=");
            pFecha = pLista[1];
            window.location.href = "/ordenes_produccion?fecha=${pFecha}";
        }
        else{
            print(pResult['mensaje'].toString());
            window.alert(pResult['mensaje'].toString());
        }
      });
  }
}

void guardar(){

  String pFecha = "";
  List<String> pLista = window.location.search.split("&");
  pLista = pLista[1].split("=");
  pFecha = pLista[1];

  if (POrdenProduccion.estado == "Surtido"){
      cerrarOrdenProduccion();
  }
  else if (POrdenProduccion.estado == "Cerrado"){
      abrirOrdenProduccion();
  }
  else{
      if (window.confirm("¿Crear salida para orden de producción?")){
        Map pParametros = new Map();
        pParametros["id_usuario_embarques"] = (querySelector("#id_usuario_embarques") as HiddenInputElement).value;
        pParametros["id_salida_embarques"]  = FolioSalida;

        String pData    = JSON.encode(pParametros);
        String pUrl     = 'http://localhost:8031/rest/ordenp/ordenmp_surtir/${IdOrden}';
        print(pUrl);
        Map<String, String> headers = new Map<String, String>();
        headers["content-type"] = "application/json";

        HttpRequest.request(pUrl, method: "PUT", requestHeaders:  headers , sendData:  pData).then((HttpRequest request){
          print(request.responseText);
          Map pResult = JSON.decode(request.responseText);
          print(pResult['result'].toString());
          if (pResult['result'] == 0){
            window.alert("Se genero la salida ${pResult['salida'].toString()}");
            window.location.href = "/ordenes_produccion?fecha=${pFecha}";
          }
          else{
            print(pResult['mensaje'].toString());
            window.alert(pResult['mensaje'].toString());
          }

         }).then((request){
            //window.alert("Se guardo orden de producción");
           // window.location.href = "/ordenes_produccion";
         });
      }
  }
}

void cancelar(){
  if (window.confirm("¿Cancelar captura?")){

    String pFecha = "";
    List<String> pLista = window.location.search.split("&");
    pLista = pLista[1].split("=");
    pFecha = pLista[1];

    window.location.href = "/ordenes_produccion?fecha=${pFecha}";
  }
}

void capturaValorRescate(Produccion item){

  if (!editable){
    window.alert("No tiene derecho a modificar");
    return;
  }

   ModalP.modal("mdlValorRescate");
   document.querySelector("#inpValorRescate").focus();

   ButtonElement btnElement =  document.querySelector("#btnValorRescateAceptar");

   if (EventoValorRescate != null){
      EventoValorRescate.cancel();
   }

   btnElement.onClick.listen((_){

      var pUrl  = "http://localhost:8031/rest/ordenp/actualiza_valor_rescate";
      Map pMap = new Map();

      double pValorRescate = 0.0;

      try{
        pValorRescate = double.parse((querySelector("#inpValorRescate") as InputElement).value);
      }
      catch(Exception){
        pValorRescate = -1.0;
      }

      if (pValorRescate < 0){
          window.alert("Valor de rescato no es válido");
          (querySelector("#inpValorRescate") as InputElement).focus();
          return;
      }

      pMap["valor_rescate"] = pValorRescate.toDouble();
      pMap["id_orden"] = item.id;

      String pData = JSON.encode(pMap);

      HttpRequest.request(pUrl, method: "POST", sendData: pData).then((HttpRequest ARequest){

          item.valor_rescate = pValorRescate;
          item.importe_rescate = pValorRescate * item.producido;
          ModalP.cierra_modal("mdlValorRescate");
          actualizaFilaProduccion(item);

      });

   });
}

void GuardaValorRescate(){

}

void seleccionar_salida(){

  OrdenMP pOrdenPP = new OrdenMP();

  pOrdenPP.producto    = (querySelector("#pClave") as InputElement).value;
  pOrdenPP.descripcion = (querySelector("#pDescripcion") as InputElement).value;
  pOrdenPP.kilos       = double.parse((querySelector("#pKilos") as InputElement).value);

  if (pOrdenPP.descripcion.trim().length == 0){
    window.alert("El producto no es válido");
    querySelector("#pClave").focus();
    return;
  }

  if (pOrdenPP.kilos <= 0){
    window.alert("Los kilos no son válidos");
    querySelector("#pKilos").focus();
    return;
  }

  FolioSalida = (querySelector("#pClave") as InputElement).value;

  (querySelector("#pClave") as InputElement).value       = "";
  (querySelector("#pDescripcion") as InputElement).value = "";
  (querySelector("#pKilos") as InputElement).value       = "0.0";

  document.querySelector("#mdlAgregarProductos").xtag.hide();

  String pUrl = "http://localhost:8031/embarques/obtener_detalle_productos_salida/${FolioSalida}";

  HttpRequest.getString(pUrl).then((String Data){

    var pLista = JSON.decode(Data);

    for(var item in pLista){
      OrdenMP pOrdenMp = ListaOrdenPMP.where((OrdenMP x) => x.producto == item["producto"]).toList()[0];

      if (pOrdenMp != null){
        pOrdenMp.surtido = item["kilos"];
      }
    }
  });
}

void eliminar_produccion(item){

  if (window.confirm("¿Eliminar Producción?")){
    ListaOrdenPMP.remove(item);
  }

}

void despliega_salida(){

  String pSalida = (querySelector("#pClave") as InputElement).value;
  String pUrl = "http://localhost:8031/embarques/obtener_salida/${pSalida}";

  HttpRequest.getString(pUrl).then((data){

    var pMap = JSON.decode(data);

    if (pMap["codigo"] != "0"){


      (querySelector("#pDescripcion") as InputElement).value = pMap["concepto"];
      (querySelector("#pKilos") as InputElement).value       = new intl.NumberFormat("###0.00").format(pMap["kilos"]);
    }
    else{
      window.alert("No existe la salida");
      document.querySelector("#pClave").focus();
    }
  });
}

void despliega_producto_mp(){

  String pProducto = (querySelector("#mClave") as InputElement).value;
  String pUrl = "http://localhost:8031/rest/productos/obtener_descripcion/${pProducto}";

  HttpRequest.getString(pUrl).then((data){

    var pMap = JSON.decode(data);

    String pCodigo = pMap["clave"];

    if (pMap["clave"] != "0"){
      (querySelector("#mDescripcion") as InputElement).value = pMap["descripcion"];
    }
    else{
      window.alert("No existe el producto");
      document.querySelector("#mClave").focus();
    }

  });

}

void detalleOrden(OrdenMP AOrdenMP){

  if (!editable){
    window.alert("No tiene derecho a modificar");
    return;
  }


  ModalP.modal("mdlAgregarCosto");


  (querySelector("#mCosto") as InputElement).value = new intl.NumberFormat("###,0.00").format(AOrdenMP.costo_salida);
  (document.querySelector("#mCosto") as InputElement).select();
  document.querySelector("#mCosto").focus();

  bool pError = false;

  ButtonElement btnElement =  document.querySelector("#btnCostoAceptar");

  if (EventoCostoSalida != null){
    EventoCostoSalida.cancel();
  }

  EventoCostoSalida = btnElement.onClick.listen((_){
      AOrdenMP.costo_salida = double.parse((querySelector("#mCosto") as InputElement).value, (_){
          window.alert("El costo no es válido");
          document.querySelector("#mCosto").focus();
          pError = true;
      });

      if (!pError){

        AOrdenMP.importe_salida = AOrdenMP.surtido * AOrdenMP.costo_salida;

        String pUrl = "http://localhost:8031/rest/ordenp/actualizar_costo_salida/" + AOrdenMP.id.toString();
        String pData = '{"costo":' + AOrdenMP.costo_salida.toString() + ',"importe":' + AOrdenMP.importe_salida.toString() + '}';
        Map<String, String> headers = new Map<String, String>();
        headers["content-type"] = "application/x-www-form-urlencoded";

        HttpRequest.request(pUrl, method: "POST", responseType: "application/json", sendData: pData, requestHeaders: headers).then((HttpRequest ARequest){

            actualizaFilaMPrima(AOrdenMP);

            double pTotalCosto   = 0.0;
            double pTotalImporte = 0.0;

            for (OrdenMP item in ListaOrdenPMP){
                pTotalCosto   += item.costo_salida;
                pTotalImporte += item.importe_salida;
            }

            document.querySelector("#TotalCostoP").innerHtml = new intl.NumberFormat("###,0.00").format(pTotalCosto);
            document.querySelector("#TotalImporteP").innerHtml = new intl.NumberFormat("###,0.00").format(pTotalImporte);

            ModalP.cierra_modal("mdlAgregarCosto");

        });

      }

  });
}

void detalleProducido(Produccion AProduccion){

  var pUrl = "http://localhost:8031/tabla_detalle_producto_orden/${IdOrden}/${AProduccion.clave_producto}";

  HttpRequest.getString(pUrl).then((String Data){

    document.querySelector("#divDetalleProducido").innerHtml = Data;

  }).then((String Data) => (ModalP.modal("mdlDetalleProducido")));

}

void costoMaquila(Produccion AProduccion){

  if (!editable){
     window.alert("No tiene derecho a modificar");
     return;
  }

  ModalP.modal("mdlCostoMaquila");
  (querySelector("#mCostoMaquila") as InputElement).value = new intl.NumberFormat("###,0.00").format(AProduccion.costo_maquila);
  (querySelector("#mCostoMaquila") as InputElement).select();
  (querySelector("#mCostoMaquila") as InputElement).focus();

  bool pError = false;

  ButtonElement btnElement =  document.querySelector("#btnCostoMaquilaAceptar");

  if (EventoCostoMaquila != null){
    EventoCostoMaquila.cancel();
  }

  EventoCostoMaquila = btnElement.onClick.listen((_){
      AProduccion.costo_maquila = double.parse((querySelector("#mCostoMaquila") as InputElement).value, (_){
          window.alert("El costo de la maquila no es válido");
          document.querySelector("#mCostoMaquila").focus();
          pError = true;
      });

      if (!pError){

        AProduccion.importe_maquila = AProduccion.producido * AProduccion.costo_maquila;

        String pUrl = "http://localhost:8031/rest/ordenp/actualizar_costo_maquila/" + AProduccion.id.toString();
        String pData = '{"costo":' + AProduccion.costo_maquila.toString() + ',"importe":' + AProduccion.importe_maquila.toString() + '}';
        Map<String, String> headers = new Map<String, String>();
        headers["content-type"] = "application/x-www-form-urlencoded";

        HttpRequest.request(pUrl, method: "POST", responseType: "application/json", sendData: pData, requestHeaders: headers).then((HttpRequest ARequest){

          double pTotalCosto   = 0.0;
          double pTotalImporte = 0.0;

          for (Produccion item in ListaProduccion){
            pTotalCosto   += item.costo_maquila;
            pTotalImporte += item.importe_maquila;
          }

          document.querySelector("#TotalCostoMaquila").innerHtml   = new intl.NumberFormat("###,0.00").format(pTotalCosto);
          document.querySelector("#TotalImporteMaquila").innerHtml = new intl.NumberFormat("###,0.00").format(pTotalImporte);

          ModalP.cierra_modal("mdlCostoMaquila");

          actualizaFilaProduccion(AProduccion);

        });

      }

  });
}

void agregarFilaDetalladoTarima(DetalleMP item){

    TableElement tablaDetalladoTarima = querySelector("#tablaDetalladoTarima");
    TableRowElement tr = new TableRowElement();

    TableCellElement td = new TableCellElement()..text = item.tarimaOrigen.toString()..style.textAlign = "center";
    tr.children.add(td);
    td = new TableCellElement()..text = item.producto..style.textAlign = "center";
    tr.children.add(td);
    td = new TableCellElement()..text = item.codigoBarras..style.textAlign = "center";
    tr.children.add(td);
    td = new TableCellElement()..text = new intl.NumberFormat("#,##0.00").format(item.peso)..style.textAlign = "right";
    tr.children.add(td);

    tablaDetalladoTarima.tBodies[0].children.add(tr);

}

void detalladoTarima(int ATarima){

  var pUrl = "http://localhost:8031/rest/ordenp/obtener_detalle_mp_ordenp_tarima/${IdOrden}/${ATarima.toString()}";
  print(pUrl);

  HttpRequest.getString(pUrl).then((String Data){

    print(Data);

    List pLista = JSON.decode(Data);

    ListaDetalle.clear();

    TableElement tablaDetalladoTarima = querySelector("#tablaDetalladoTarima");
    tablaDetalladoTarima.tBodies[0].children.clear();

    for (Map item in pLista){
        DetalleMP pItem = new DetalleMP.fromMAP(item);
        ListaDetalle.add(pItem);
        agregarFilaDetalladoTarima(pItem);
    }

    document.querySelector("#divDetalladoTarima").classes.toggle("oculto");
  });
}

void agregarFilaDetalleTarima(DetalleMPTarima item){

   TableElement tableDetalleTarima = querySelector("#tableDetalleTarima");
   TableRowElement tr = new TableRowElement();

   TableCellElement td = new TableCellElement()..text = item.tarimaOrigen.toString()..style.textAlign = "center";
   tr.children.add(td);

   AnchorElement anchorCajas = new Element.html("<a href=\"#\">${item.cajas.toString()}</a>");

   anchorCajas.onClick.listen((_){
      detalladoTarima(item.tarimaOrigen);
   });

   td = new TableCellElement()..children.add(anchorCajas)..style.textAlign = "right";
   tr.children.add(td);
   td = new TableCellElement()..text = new intl.NumberFormat("#,##0.00").format(item.kilos)..style.textAlign = "right";
   tr.children.add(td);

   tableDetalleTarima.tBodies[0].children.add(tr);

}

void detalleOrdenTarima(){

  var pUrl = "http://localhost:8031/rest/ordenp/obtener_detalle_mp_ordenp_agrupado/${IdOrden}";
  print(pUrl);

  ListaDetalleTarima.clear();

  HttpRequest.getString(pUrl).then((String Data){

    print(Data);

    List pLista = JSON.decode(Data);

    print("limpiando lista");

    TableElement tableDetalleTarima = querySelector("#tableDetalleTarima");
    tableDetalleTarima.tBodies[0].children.clear();

    for (Map item in pLista){
        var pDetalleTarima = new DetalleMPTarima.fromMAP(item);
        ListaDetalleTarima.add(pDetalleTarima);
        agregarFilaDetalleTarima(pDetalleTarima);
    }

    print(ListaDetalleTarima.length);

    ModalP.modal("divDetalleTarima");
  });
}

void cerrarDetalle(){
   document.querySelector("#divDetalle").classes.toggle("oculto", true);
}

void cerrarDetalleTarima(){
   ModalP.cierra_modal("divDetalleTarima");
}

void cerrarDetalladoTarima(){
   document.querySelector("#divDetalladoTarima").classes.toggle("oculto", true);
}

void imprimir(){
    window.open("http://localhost:8031/get_surtido_orden/${IdOrden}", "surtido", "width: 400; heigth: 400px;");
}

void ActualizaSaldosSap(){
    if (window.confirm("¿Actualizar saldos?")){

        String pUrl = "";

        for (OrdenMP item in ListaOrdenPMP){
            pUrl = "http://192.168.0.11/WebFrontEnd/inventarios/ObtenerSaldoProducto?AProducto=${item.codigosap}&AAlmacen=01&AConexion=SolesProd";
            print(pUrl);

            HttpRequest.getString(pUrl).then((String Data){

                print(Data);
                Map pMap = JSON.decode(Data);
                item.saldo_sap = pMap['saldo'].toDouble();

                Map<String, String> headers = new Map<String, String>();
                headers["content-type"] = "application/x-www-form-urlencoded";

                String pUrlPost = "http://localhost:8031/rest/ordenp/actualiza_saldo_sap/${item.id}";
                print(pUrlPost);
                HttpRequest.request(pUrlPost, method: "POST", responseType: "application/json", sendData: Data, requestHeaders: headers);

                actualizaFilaMPrima(item);

            });
        }
    }
}

void ActualizaCostoSap(){
  String pUrl = "";

  for (OrdenMP item in ListaOrdenPMP){

    if (item.surtido > 0){

        pUrl = "http://192.168.0.11/WebFrontEnd/inventarios/ObtenerCostoLineaSalida?Orden=${IdOrden.toString()}&Producto=${item.codigosap}&Empresa=SolesProd";

        print(pUrl);

        HttpRequest.getString(pUrl).then((String Data){
          double pCosto = JSON.decode(Data).toDouble();
          item.costo_salida = pCosto;
          item.importe_salida = pCosto * item.surtido;

          actualizaFilaMPrima(item);

          Map<String, String> headers = new Map<String, String>();
          headers["content-type"] = "application/x-www-form-urlencoded";

          String pData = '{"costo":"${pCosto.toDouble()}", "importe":"${item.importe_salida.toDouble()}"';

          String pUrlPost = "http://localhost:8031/rest/ordenp/actualiza_costo_linea_sap/${item.id}";
          HttpRequest.request(pUrlPost, method: "POST", responseType: "application/json", sendData: pData, requestHeaders: headers);
        });
     }
   }

   var pUrlCosto = "http://192.168.0.11/WebFrontEnd/inventarios/ObtenerCostoSalida?Orden=${IdOrden.toString()}&Cuenta=11100030001&Empresa=SolesProd";
   print(pUrlCosto);

   HttpRequest.getString(pUrlCosto).then((String Data){

      double pCosto = JSON.decode(Data);
      POrdenProduccion.costo_salida = pCosto;
      (document.querySelector("#TotalImporteP") as SpanElement).innerHtml = new intl.NumberFormat("###,0.00").format(pCosto);

      String pUrl = "http://localhost:8031/rest/ordenp/actualizar_costo_salida_orden/${IdOrden.toString()}";
      String pData = '{"costo": "${pCosto.toString()}" }';
      Map<String, String> headers = new Map<String, String>();
      headers["content-type"] = "application/json";

      HttpRequest.request(pUrl, method: "POST", responseType: "application/json", sendData: pData, requestHeaders: headers);

   });
}

void GeneraSalidaSap(){

    print("Generando salida");

    String pPassword = (querySelector("#mPassword") as InputElement).value;

    if (pPassword != inpPassword.value){
        window.alert("Contraseña incorrecta");
        document.querySelector("#mPassword").focus();
        return;
    }

     ModalP.cierra_modal("mdlPassword");
    (document.querySelector("#btnGeneraSalida") as ButtonElement).disabled = true;

    SalidaInventario pSalidaInventario = new SalidaInventario();

    pSalidaInventario.Comments         = POrdenProduccion.descripcion;
    pSalidaInventario.DocDate          = (document.querySelector("#fecha") as InputElement).value;
    pSalidaInventario.TaxDate          = pSalidaInventario.DocDate;
    pSalidaInventario.OrdenProduccion  = IdOrden;
    pSalidaInventario.Reference2       = IdOrden.toString();
    pSalidaInventario.Series           = "107";
    pSalidaInventario.FolioSalida      = POrdenProduccion.id_salida;

    for (OrdenMP item in ListaOrdenPMP){

        if (item.surtido > 0){
            LineaSalidaInventario pLinea = new LineaSalidaInventario();
            pLinea.ItemCode      = item.codigosap;
            pLinea.AccountCode   = "11100010060";
            pLinea.Quantity      = item.surtido;
            pLinea.WarehouseCode = "01";
            pLinea.CostingCode   = "PL1";
            pLinea.LineTotal     = item.surtido;

            pSalidaInventario.Lineas.add(pLinea);
        }
    }

    var pUrl = "http://localhost/webfrontend/inventarios/CrearSalida";
    Map<String, String> headers = new Map<String, String>();

    String Data = pSalidaInventario.toJSON();
    
    print("Data");
    print(Data);
    
    HttpRequest.request(pUrl, method: "POST", responseType: "application/json", sendData: Data, requestHeaders: headers).then((HttpRequest pRequest){
        print("-================================================-");
        print(pRequest.responseText);

        Map pMapResult = JSON.decode(pRequest.responseText);

        window.alert(pMapResult["Mensaje"]);

        if (pMapResult["Folio"] == "1"){

          (document.querySelector("#btnGeneraSalida") as ButtonElement).classes.add("hiden");
          (document.querySelector("#btnSalida") as ButtonElement).classes.add("hiden");

          String pUrl = 'http://localhost:8031/rest/ordenp/ordenmp_generar/${IdOrden}';
          POrdenProduccion.estado = "Generado";
          document.querySelector("#spanEstado").text = "Generado";

          HttpRequest.request(pUrl, method: "PUT" , responseType: "application/json").then((HttpRequest pReq){
              print(pReq.responseText);
          }).then((HttpRequest pRequest){
              ActualizaCostoSap();
          }).then((_){

              if (window.confirm("¿Generar Poliza?")){

                  GeneraPolizaSap();

              }

          });
        }
        else{
          (document.querySelector("#btnGeneraSalida") as ButtonElement).disabled = false;
        }

    });
}

void GeneraPolizaSap(){

    var pMemo = "Orden de prod: "  + IdOrden  + ", Fecha: " +  POrdenProduccion.fecha;

    var pUrl = "http://localhost:8043/api/FacturasSAP/NuevaPolizaContable?Orden=${IdOrden}&CuentaCredito=21030010025&ImporteCredito=${pTotalImporteMaquila.toStringAsFixed(2)}&CuentaDebito=11100010060&ImporteDebito=${pTotalImporteMaquila.toStringAsFixed(2)}&Memo=${pMemo}&Fecha=${POrdenProduccion.fecha}&Usuario=${(querySelector("#id_usuario") as HiddenInputElement).value}&NombreConexion=SolesProd";

    HttpRequest.getString(pUrl).then((String Data){

        window.alert(Data);

    });
}

void PidePassword(){

  if (POrdenProduccion.estado != "Autorizado"){
      window.alert("La orden debe estar autorizada");
      return;
  }

  if (!window.confirm("¿Generar Salida en SAP?")){
      return;
  }

  ModalP.modal("mdlPassword");
  document.querySelector("#mPassword").focus();
}

void PidePassword2(){

  if (POrdenProduccion.estado != "Generado"){
    window.alert("La orden debe estar generada");
    return;
  }

  if (!window.confirm("¿Generar Entrada en SAP?")){
    return;
  }

  ModalP.modal("mdlPassword2");
  document.querySelector("#mPassword2").focus();
}

void GeneraEntradaSap(){

  String pPassword = (querySelector("#mPassword2") as InputElement).value;

  if (pPassword != inpPassword.value){
    window.alert("Contraseña incorrecta");
    document.querySelector("#mPassword2").focus();
    return;
  }

  ModalP.cierra_modal("mdlPassword2");
  (document.querySelector("#btnEntrada") as ButtonElement).disabled = true;

  SalidaInventario pSalidaInventario = new SalidaInventario();

  pSalidaInventario.Comments         = POrdenProduccion.descripcion;
  pSalidaInventario.DocDate          = (document.querySelector("#fecha") as InputElement).value;
  pSalidaInventario.TaxDate          = pSalidaInventario.DocDate;
  pSalidaInventario.OrdenProduccion  = IdOrden;
  pSalidaInventario.Reference2       = IdOrden.toString();
  pSalidaInventario.Series           = "103";
  pSalidaInventario.FolioSalida      = POrdenProduccion.id_salida;

  for (Produccion item in ListaProduccion){

    if (item.producido > 0){
      LineaSalidaInventario pLinea = new LineaSalidaInventario();
      pLinea.ItemCode      = item.codigosap;
      pLinea.AccountCode   = "11100010060";
      pLinea.Quantity      = item.producido;
      pLinea.WarehouseCode = "01";
      pLinea.CostingCode   = "PL1";

      if (item.costo_maquila > 0){
        pLinea.LineTotal     = item.importe;
      }
      else{
        pLinea.LineTotal     = item.importe_rescate;
      }

      pSalidaInventario.Lineas.add(pLinea);
    }
  }

  var pUrl = "http://localhost/webfrontend/inventarios/CrearEntrada";
  Map<String, String> headers = new Map<String, String>();
  headers["content-type"] = "application/x-www-form-urlencoded";

  String Data = pSalidaInventario.toJSON();
  HttpRequest.request(pUrl, method: "POST", responseType: "application/json", sendData: Data, requestHeaders: headers).then((HttpRequest pRequest){

      print("-================================================-");
      print(pRequest.responseText);

      Map pMapResult = JSON.decode(pRequest.responseText);

      window.alert(pMapResult["Mensaje"]);

      if (pMapResult["Folio"] == "1"){

        (document.querySelector("#btnEntrada") as ButtonElement).classes.add("hiden");
        (document.querySelector("#btnSalida") as ButtonElement).classes.add("hiden");

        String pUrl = 'http://localhost:8031/rest/ordenp/ordenmp_finalizar/${IdOrden}';
        POrdenProduccion.estado = "Generado";
        document.querySelector("#spanEstado").text = "Finalizado";

        HttpRequest.request(pUrl, method: "PUT" , responseType: "application/json").then((HttpRequest pReq){
          print(pReq.responseText);
        }).then((HttpRequest pRequest){
          ActualizaCostoSap();
        });
      }
      else{
        (document.querySelector("#btnEntrada") as ButtonElement).disabled = false;
      }

   });
}

void refrescarSurtido(){

  if (window.confirm("¿Refrescar surtido?")){

    var pUrl = "http://localhost:8031/rest/refresca_surtido_orden/${ObtenerIdOrden()}";
    print(pUrl);
    HttpRequest.request(pUrl, method: "POST", sendData: "${ObtenerIdOrden()}").then((HttpRequest request){

        window.location.reload();

    });

  }

}


void main() {
    HiddenInputElement pInpEditable = document.querySelector("#inpEditable") as HiddenInputElement;
    editable = pInpEditable.value == "true";

    ObtenerOrdenProduccion(ObtenerIdOrden());

    ButtonElement btnCerrarDetalleCosto = querySelector("#btn1");
    btnCerrarDetalleCosto.onClick.listen((_){

      ModalP.cierra_modal("mdlAgregarCosto");

    });

    AnchorElement anchorDetalleOrdenTarima = querySelector("#anchorDetalleOrdenTarima") as AnchorElement;
    anchorDetalleOrdenTarima.onClick.listen((_){
        detalleOrdenTarima();
    });

    ButtonElement btnCerrarDetalleTarima = querySelector("#btnCerrarDetalleTarima");
    btnCerrarDetalleTarima.onClick.listen((_){
        cerrarDetalleTarima();
    });

    ButtonElement cerrarDetalledoCajaTarima = querySelector("#cerrarDetalladoCajaTarima");
    cerrarDetalledoCajaTarima.onClick.listen((_){
        cerrarDetalladoTarima();
    });

    ButtonElement btnImprimir = querySelector("#btnImprimir");
    btnImprimir.onClick.listen((_){
        imprimir();
    });

    AnchorElement anchorSaldoSap = querySelector("#anchorSaldoSap") as AnchorElement;
    anchorSaldoSap.onClick.listen((_){
        ActualizaSaldosSap();
    });

    ButtonElement btnGeneraSalida = querySelector("#btnGeneraSalida");
    btnGeneraSalida.onClick.listen((_){
        PidePassword();
    });

    ButtonElement btnCerrarPassword = querySelector("#btnCerrarPassword");
    btnCerrarPassword.onClick.listen((_){
        ModalP.cierra_modal("mdlPassword");
    });

    ButtonElement btnCerrarPassword2 = querySelector("#btnCerrarPassword2");
    btnCerrarPassword2.onClick.listen((_){
        ModalP.cierra_modal("mdlPassword");
    });

    ButtonElement btnPasswordAceptar = querySelector("#btnPasswordAceptar");
    btnPasswordAceptar.onClick.listen((_){
        GeneraSalidaSap();
    });

    ButtonElement btnCerrarDetalleProducidoAceptar = querySelector("#btnProducidoAceptar");
    btnCerrarDetalleProducidoAceptar.onClick.listen((_){
        ModalP.cierra_modal("mdlDetalleProducido");
    });

    ButtonElement btnCerrarDetalleProducido = querySelector("#btnCerrarDetalleProducido");
    btnCerrarDetalleProducido.onClick.listen((_){
      ModalP.cierra_modal("mdlDetalleProducido");
    });

    ButtonElement btnCerrarDetalleProducido2 = querySelector("#btnCerrarDetalleProducido2");
    btnCerrarDetalleProducido2.onClick.listen((_){
        ModalP.cierra_modal("mdlDetalleProducido");
    });

    ButtonElement btnCerrarValorRescate = querySelector("#btnCerrarValorRescate");
    btnCerrarValorRescate.onClick.listen((_){
      ModalP.cierra_modal("mdlValorRescate");
    });

    ButtonElement btnCerrarValorRescate2 = querySelector("#btnCerrarValorRescate2");
    btnCerrarValorRescate2.onClick.listen((_){
      ModalP.cierra_modal("mdlValorRescate");
    });

    ButtonElement btnPasswordAceptar2 = querySelector("#btnPasswordAceptar2");
    btnPasswordAceptar2.onClick.listen((_){
        GeneraEntradaSap();
    });

    ButtonElement btnCerrarMdlPassword = querySelector("#btnCerrarMdlPassword");
    btnCerrarMdlPassword.onClick.listen((_){
      ModalP.cierra_modal("mdlPassword2");
    });

    ButtonElement btnCerrarMdlPassword2 = querySelector("#btnCerrarMdlPassword2");
    btnCerrarMdlPassword2.onClick.listen((_){
      ModalP.cierra_modal("mdlPassword2");
    });

    ButtonElement btnSalida = querySelector("#btnSalida")..onClick.listen((_){
        guardar();
    });

    ButtonElement btnCancelarTodo = querySelector("#btnCancelarTodo")..onClick.listen((_){
        cancelar();
    });

    ButtonElement btnCrearEntrada = querySelector("#btnEntrada")..onClick.listen((_){
        PidePassword2();
    });

    querySelector("#mdlCostoMaquila-cerrar1")..onClick.listen((_){
        ModalP.cierra_modal("mdlCostoMaquila");
    });

    querySelector("#mdlCostoMaquila-cerrar2")..onClick.listen((_){
      ModalP.cierra_modal("mdlCostoMaquila");
    });

    ButtonElement btnRefrescarSurtido = querySelector("#btnRefrescarSurtido")..onClick.listen((_){
            refrescarSurtido();
     });

    /*document.querySelector("#mdlAgregarProductos").classes.remove("hiden");
    document.querySelector("#mdlAgregarCosto").classes.remove("hiden");
    document.querySelector("#mdlCostoMaquila").classes.remove("hiden");
    document.querySelector("#mdlPassword").classes.remove("hiden");
    document.querySelector("#mdlPassword2").classes.remove("hiden");
    document.querySelector("#mdlDetalleProducido").classes.remove("hiden");
    document.querySelector("#mdlValorRescate").classes.remove("hiden");*/

    Timer.run(()=>document.querySelector("#id_orden").focus());
}