import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart' as intl;
import 'package:quickdialogs/quickdialogs.dart' as ModalP;
import 'autorizacion.dart';
import 'pedido_ventas.dart';
import 'detalle_saldo.dart';

Map MapaParametros = new Map();
String Fecha = new intl.DateFormat("dd/MM/yyyy").format(new DateTime.now());
double pPrecio = 0.0;
Map<String, double> ListaKilosPorCaja   = new Map<String, double>();
List<Map> ListaLineaPedido = new List<Map>();
Map<String, int> ProductosPrecioModificado = new Map<String, int>();
double TotalKilos           = 0.0;
double TotalImporte         = 0.0;
double pLineaCredito        = 0.0;
double pComprometidoCliente = 0.0;
double pSaldoCliente        = 0.0;
double pVencido             = 0.0;
int pDiasVencidos           = 0;
int pDiasCredito            = 0;
String pRiesgo              = "";
int pTipo                   = -1;
String pNombreTipo          = "";
Map pLineaPedidoGlobal = new Map();
List<DetalleSaldo> ListaDetalleSaldo = new List<DetalleSaldo>();
final InputElement inpObservacionesAutorizaciones = querySelector("#inpObservacionesAutorizaciones");
final ButtonElement btnAceptarObservaciones       = querySelector("#btnAceptarObservaciones");
final HiddenInputElement inpListaPrecios          = querySelector("#inpListaPrecios");
final SelectElement inpEntregas                   = querySelector("#inpEntregas");
StreamSubscription btnAceptarObservacionesStream  = null;
String pEstado = 'Nuevo';
String pEntregaTmp = '';
String pRutaTmp = '';
String RutaVentas = '';

int id = 9999;

void onClaveClienteBlur(){

  String ClaveCliente = (querySelector("#inpCliente") as InputElement).value;

  if (ClaveCliente.trim().length > 2){
    var pUrl = "http://localhost/webfrontend/MenuPedidos/ObtenerCliente?Clave=${ClaveCliente}&Empresa=SolesProd";

    HttpRequest.getString(pUrl).then((String Data){
      Map pCliente = JSON.decode(Data);

      if (pCliente["Clave"] == null){
          window.alert("El cliente no existe");
          ClaveCliente = "";
          querySelector("#inpCliente").focus();
          return null;
      }
      else if (pCliente["Grupo"].toString() != MapaParametros["Grupo"]){
          window.alert("El cliente ${pCliente["Nombre"]} no es de esta sucursal, no existe o está inactivo");
          ClaveCliente = "";
          querySelector("#inpCliente").focus();
          return null;
      }
      else if (pCliente["RutaVentas"] == 0){
          window.alert("El cliente ${pCliente["Nombre"]} no tiene asignada la ruta de ventas");
          ClaveCliente = "";
          querySelector("#inpCliente").focus();
          return null;
      }

      pVencido = pCliente["Vencido"].toDouble();

      (querySelector("#inpNombreCliente") as InputElement).value = pCliente["Nombre"];
      (querySelector("#inpRuta") as SelectElement).value         = pCliente["RutaVentas"].toString();
      
      RutaVentas = pCliente["RutaVentas"].toString();
      

      pLineaCredito          = pCliente["CreditLine"];
      pComprometidoCliente   = pCliente["Comprometido"].toDouble();

      int pFolioTmp = 0;

      try
      {
        pFolioTmp = int.parse((querySelector("#inpFolio") as InputElement).value);
      }
      catch(_)
      {
        pFolioTmp = 0;
      }

      if ( pFolioTmp > 0)
      {
          pComprometidoCliente = 0.0;
      }

      pDiasVencidos          = pCliente["DiasVencidos"];
      pDiasCredito           = pCliente["DiasCredito"];
      pRiesgo                = pCliente["Clase"];
      pTipo                  = pCliente["Tipo"];
      pNombreTipo            = pCliente["NombreTipo"];

      querySelector("#spanRiesgo").text   = pRiesgo;
      querySelector("#spanDiasCred").text = pDiasVencidos.toString();
      querySelector("#spanTipo").text     = pNombreTipo;

      (querySelector("#inpComprometido") as InputElement).value = new intl.NumberFormat("#,##0.00").format(pComprometidoCliente);
      (querySelector("#inpCredito") as InputElement).value = new intl.NumberFormat("#,##0.00").format(pLineaCredito);

      inpEntregas.children.clear();

      for (String item in pCliente["Entregas"]){

          inpEntregas.children.add(new Element.html('<option value="${item}">${item}</option>'));

      }
      
      if (pCliente["AlmacenDefault"] != "0"){
        (querySelector("#inpAlmacen") as SelectElement).value = pCliente["AlmacenDefault"];
      }
      
      return pCliente["Nombre"];
    }).then((String Data){

      if (Data == null){
          return null;
      }

      if (Data.length > 0){
          var pUrlSaldo = "http://localhost/WebFrontEnd/AntSaldos/ObtenerSaldoCliente?Fecha=${Fecha}&Cliente=${ClaveCliente}&Empresa=Solesprod";
          return HttpRequest.getString(pUrlSaldo);
      }
      else{
        return null;
      }
    }).then((Data){
      if (Data != null){
        (querySelector("#npSaldo") as InputElement).value = new intl.NumberFormat("#,##0.00").format(double.parse(Data));
        pSaldoCliente = double.parse(Data).toDouble();
      }
      else{
        (querySelector("#inpSaldo") as InputElement).value = "0";
      }
    });
  }
}

void detalleSaldoCliente(){

  String pClaveCliente = (querySelector("#inpCliente") as InputElement).value;

  if (pClaveCliente.trim().length <= 0){
      window.alert("No se capturo clave de cliente");
      (querySelector("#inpCliente") as InputElement).focus();
      return;
  }

  var pUrl = "http://localhost/WebFrontEnd/AuxSaldosClientes/AuxiliarSaldoCliente?idCliente=${pClaveCliente}&Empresa=SolesProd";

  ButtonElement pBtnDetalleSaldo = querySelector("#btnDetalleSaldo");
  pBtnDetalleSaldo.disabled = true;
  pBtnDetalleSaldo.value = ".:.";

  HttpRequest.getString(pUrl).then((String Data){

    pBtnDetalleSaldo.disabled = false;
    pBtnDetalleSaldo.value = "...";

    List pLista = JSON.decode(Data);

    TableElement pTableDetalle = querySelector("#gridDetalle");
    pTableDetalle.tBodies[0].children.clear();

    for (Map item in pLista){

        if (item["Cargos"].toDouble() > 0.0){
            TableRowElement tr = new TableRowElement();
            TableCellElement td = new TableCellElement();

            AnchorElement pAnchorElement = new AnchorElement(href: "#");

            pAnchorElement.onClick.listen((_){

                window.open("http://192.168.0.3:8030/get_pdf_factura_soles_por_docnum/${item["Documento"]}", "Factura " + item["Documento"]);

            });

            pAnchorElement.text = item["Documento"];

            td.children.add(pAnchorElement);
            tr.children.add(td);

            td = new TableCellElement();
            td.text = item["FechaStr"];
            td.style.textAlign = "center";
            tr.children.add(td);
            td = new TableCellElement();
            td.text = item["FechaVenceStr"];
            td.style.textAlign = "center";
            tr.children.add(td);
            td = new TableCellElement();
            td.text = item["Concepto"];
            tr.children.add(td);
            td = new TableCellElement();
            td.text = new intl.NumberFormat("#,##0.00").format(item["Cargos"]);
            td.style.textAlign = "right";
            tr.children.add(td);
            td = new TableCellElement();
            td.text = item["DiasVencidos"].toString();
            td.style.textAlign = "right";
            tr.children.add(td);

            pTableDetalle.tBodies[0].children.add(tr);
        }
    }

    ModalP.showModal("mc");

    //(querySelector("#mdlDetalleSaldoCliente") as InputElement).xtag.show();
    //(querySelector("#mClave") as InputElement).focus();

  }, onError:(_){
      pBtnDetalleSaldo.disabled = false;
      pBtnDetalleSaldo.value = "...";
      window.alert("Error al obtener el detalle del saldo");
   });


}

void onBlurClaveProductoEdicion(int AId){
  String pClaveProducto = (querySelector("#claveProducto${AId}") as InputElement).value;

  if (pClaveProducto.trim().length > 0){
    String pUrl = "http://localhost/WebFrontEnd/ConsultaAnaliticoSaldos/DameNombreProductoporId?idProducto=${pClaveProducto}&Empresa=SolesProd";
    HttpRequest.getString(pUrl).then((String Data){
      String pDescripcionProducto = JSON.decode(Data);

      if (pDescripcionProducto == "???"){
        window.alert("Error, Producto no existe");
        (querySelector("#nombreProducto${AId}") as InputElement).value = "";
        (querySelector("#claveProducto${AId}") as InputElement).focus();
        return null;
      }
      else{
        (querySelector("#nombreProducto${AId}") as InputElement).value = pDescripcionProducto;
        String pClaveCliente = (querySelector("#inpCliente") as InputElement).value;
        String pUrlPrecio = "http://localhost/WebFrontEnd/Productos/ObtenerPrecioProducto?Producto=${pClaveProducto}&ListaPrecios=${inpListaPrecios.value}&Cliente=${pClaveCliente}&Empresa=SolesProd&Sucursal=${MapaParametros["Sucursal"]}";
        return HttpRequest.getString(pUrlPrecio);
      }
    }).then((Data){

      if (Data == null){
        (querySelector("#precio${AId}") as InputElement).value = "0.0";
        return null;
      }
      else{

        print("Precio: ${Data}");
        var pDataz = JSON.decode(Data);
        pPrecio = double.parse(pDataz.toString());
        (querySelector("#precio${AId}") as InputElement).value  = new intl.NumberFormat("#,##0.00").format(pPrecio);

        String pUrlKilosPorCajas = "http://localhost/WebFrontEnd/Productos/ObtenerKilosPorCaja?Producto=${pClaveProducto}&Empresa=SolesProd";
        return HttpRequest.getString(pUrlKilosPorCajas);

      }
    }).then((Data){

      (querySelector("#cajas${AId}") as InputElement).value = "1";

      if (Data == null){

      }
      else{
        if (ListaKilosPorCaja[pClaveProducto] != null){
          (querySelector("#kilos${AId}") as InputElement).value = new intl.NumberFormat("#,##0.00").format(ListaKilosPorCaja[pClaveProducto]);
        }
        else{
          double pKilos = JSON.decode(Data).toDouble();
          (querySelector("#kilos${AId}") as InputElement).value = new intl.NumberFormat("#,##0.00").format(pKilos);
          ListaKilosPorCaja[pClaveProducto] = pKilos;
        }
      }
    }).then((Data){

      double pPrecio = double.parse((querySelector("#precio${AId}") as InputElement).value);
      double pKilos  = double.parse((querySelector("#kilos${AId}") as InputElement).value);
      (querySelector("#importe${AId}") as InputElement).value = new intl.NumberFormat("#,##0.00").format(pKilos * pPrecio);

      String pAlmancen = (querySelector("#inpAlmacen") as SelectElement).value;
      String pUrlSaldoProducto = "http://localhost/WebFrontEnd/Productos/ObtenerSaldoProducto?Producto=${pClaveProducto}&Empresa=SolesProd&Almacen=${pAlmancen}";
      return HttpRequest.getString(pUrlSaldoProducto);

    }).then((Data){

      print("...");
      print(Data);
      double pStock = JSON.decode(Data).toDouble();
      (querySelector("#stock${AId}") as InputElement).value = new intl.NumberFormat("#,##0.00").format(pStock);

      var pFolio   = (querySelector("#inpFolio") as InputElement).value;
      var pAlmacen = (querySelector("#inpAlmacen") as SelectElement).value;

      var pUrl = "http://localhost/webfrontend/MenuPedidos/ObtenerComprometidoProducto?IdPedido=${pFolio}&Producto=${pClaveProducto}&Almacen=${pAlmacen}";

      return HttpRequest.getString(pUrl);

    }).then((String Data){
        double pComprometido =  double.parse(Data).toDouble();
        (querySelector("#comprometido${AId}") as InputElement).value = new intl.NumberFormat("###0.00").format(pComprometido);
    });
  }
}

void onBlurCajas(int AId){
  String pClaveProducto = (querySelector("#claveProducto${AId}") as InputElement).value;
  int pCajas = int.parse((querySelector("#cajas${AId}") as InputElement).value, onError:(Data){
      (querySelector("#cajas${AId}") as InputElement).value = "1";
      return 1;
  });

  double pKilos  = ListaKilosPorCaja[pClaveProducto] * pCajas;
  double pPrecio = double.parse((querySelector("#precio${AId}") as InputElement).value);

  if (ListaKilosPorCaja[pClaveProducto] != null){
     (querySelector("#kilos${AId}") as InputElement).value   = new intl.NumberFormat("###0.00").format(pKilos);
     (querySelector("#importe${AId}") as InputElement).value = new intl.NumberFormat("###0.00").format(pPrecio * pKilos);
     print("Importe: ${(querySelector("#importe${AId}") as InputElement).value}");
  }
  else{
      (querySelector("#kilos${AId}") as InputElement).value = "1.0";
      (querySelector("#importe${AId}") as InputElement).value = new intl.NumberFormat("#,##0.00").format(pPrecio);
      print("Importe: ${(querySelector("#importe${AId}") as InputElement).value}");
  }
}

void onBlurKilos(int AId){
  double pKilos   = double.parse((querySelector("#kilos${AId}") as InputElement).value);
  double pPrecio  = double.parse((querySelector("#precio${AId}") as InputElement).value);
  String pImporte = new intl.NumberFormat("###0.00").format(pPrecio * pKilos);
  (querySelector("#importe${AId}") as InputElement).value = pImporte;
}

void onBlurPrecio(int AId){
      double pKilos   = double.parse((querySelector("#kilos${AId}") as InputElement).value);
      double pPrecio  = double.parse((querySelector("#precio${AId}") as InputElement).value);
      String pImporte = new intl.NumberFormat("###0.00").format(pPrecio * pKilos);
      (querySelector("#importe${AId}") as InputElement).value = pImporte;
}

PedidoVentas obtenerEntidadPedidoVentas(){

  PedidoVentas pPedidoVentasTmp = new PedidoVentas();

  pPedidoVentasTmp.id             = int.parse((querySelector("#inpFolio") as InputElement).value);
  pPedidoVentasTmp.Vendedor       = int.parse((querySelector("#inpVendedor") as SelectElement).value);
  pPedidoVentasTmp.Ruta           = int.parse((querySelector("#inpRuta") as SelectElement).value);

  SelectElement pSelectVendedor   = querySelector("#inpVendedor");
  SelectElement pSelectRuta       = querySelector("#inpRuta");

  pPedidoVentasTmp.NombreVendedor = pSelectVendedor.options[pSelectVendedor.selectedIndex].text;
  pPedidoVentasTmp.NombreRuta     = pSelectRuta.options[pSelectRuta.selectedIndex].text;
  pPedidoVentasTmp.Almacen        = int.parse((querySelector("#inpAlmacen") as SelectElement).value);
  SelectElement pSelectAlmacen    = querySelector("#inpAlmacen");
  pPedidoVentasTmp.NombreAlmacen  = pSelectAlmacen.options[pSelectAlmacen.selectedIndex].text;
  pPedidoVentasTmp.fecha          = "\/Date(212121212)\/";
  pPedidoVentasTmp.turno          = int.parse(MapaParametros["Turno"]);
  pPedidoVentasTmp.ocrcode        = (querySelector("#inpCliente") as InputElement).value;
  pPedidoVentasTmp.ocrname        = (querySelector("#inpNombreCliente") as InputElement).value;
  pPedidoVentasTmp.idUsuario      = MapaParametros["IdUsuario"];
  pPedidoVentasTmp.idSucursal     = MapaParametros["Sucursal"];
  pPedidoVentasTmp.nombreSucursal = MapaParametros["NombreSucursal"];
  pPedidoVentasTmp.fechaEntrega   = (querySelector("#inpFechaEntrega") as InputElement).value;
  pPedidoVentasTmp.Observaciones  = (querySelector("#inpObservaciones") as InputElement).value;
  pPedidoVentasTmp.Entrega        = inpEntregas.value;

  String pSaldoS = (querySelector("#inpSaldo") as InputElement).value;

  try{
    pPedidoVentasTmp.saldo   = double.parse(pSaldoS.replaceAll(',', ''));
  }
  catch(Ex){
    pPedidoVentasTmp.saldo = 0.0;
    (querySelector("#inpSaldo") as InputElement).value =  "0.0";
  }
  return pPedidoVentasTmp;
}

Future<String> pideObservaciones(){
    Completer<String> pCompleter = new Completer<String>();
    ModalP.showModal("mo");
    inpObservacionesAutorizaciones.value = "";
    inpObservacionesAutorizaciones.focus();

    btnAceptarObservacionesStream = null;
    btnAceptarObservacionesStream = btnAceptarObservaciones.onClick.listen((_) {

        pCompleter.complete(inpObservacionesAutorizaciones.value);

    });

    return pCompleter.future;
}

Future<List> puedeAgregarLineaPedido(Map ALineaPedido){

  Completer<List> pCompleter = new Completer<List>();

  if (ALineaPedido["claveProducto"].trim().length == 0){
    pCompleter.complete([false, "Error, La clave del producto no es válida"]);
    return pCompleter.future;
  }

  if (ALineaPedido["nombreProducto"].trim().length == 0 || ALineaPedido["nombreProducto"].trim() == "???"){
    pCompleter.complete([false, "Error, El nombre del producto no es válido"]);
    return pCompleter.future;
  }

  if (ALineaPedido["kilos"] == 0){
    pCompleter.complete([false, "Error, los kilos no pueden ser cero"]);
    return pCompleter.future;
  }

  if (ListaLineaPedido.where((Map x) => x["claveProducto"].trim().toUpperCase() == ALineaPedido["claveProducto"].trim().toUpperCase()).toList().length > 0){
    pCompleter.complete([false, "Error, producto ya está en la lista"]);
    return pCompleter.future;
  }

  if (ALineaPedido["precio"] <= 0){
      pCompleter.complete([false, "Error, el precio no puede ser cero"]);
      return pCompleter.future;
  }

  if (ALineaPedido["precio"] < pPrecio){

    if (window.confirm("El precio capturado es menor que el de la lista de precios, ¿Pedir Autorización?")){

        pideObservaciones().then((String Observaciones){

              ModalP.closeModal("mo");

              var pPedido = obtenerEntidadPedidoVentas();

              AutorizacionPedido pAutorizacion   = new AutorizacionPedido();
              pAutorizacion.Id                   = 0;
              pAutorizacion.IdUsuarioAutorizador = 0;
              pAutorizacion.NombreVendedor       = "";
              pAutorizacion.NombreSucursal       = "";
              pAutorizacion.CardCode             = pPedido.ocrcode;
              pAutorizacion.CardName             = pPedido.ocrname;
              pAutorizacion.Estado               = "Nuevo";
              pAutorizacion.FechaHoraSistema     = new DateTime.now();
              pAutorizacion.IdUsuario            = int.parse(pPedido.idUsuario);
              pAutorizacion.ItemCode             = ALineaPedido["claveProducto"];
              pAutorizacion.ItemName             = ALineaPedido["nombreProducto"];
              pAutorizacion.Precio               = ALineaPedido["precio"];
              pAutorizacion.Sucursal             = int.parse(pPedido.idSucursal);
              pAutorizacion.Vendedor             = int.parse(MapaParametros["Vendedor"]);
              pAutorizacion.Tipo                 = "Precio";
              pAutorizacion.Observaciones        = Observaciones;
              pAutorizacion.Descripcion          = "Cambio de Precio, ${ALineaPedido["nombreProducto"]}, Precio anterior: ${pPrecio.toStringAsFixed(2)}, Precio Nuevo: ${pAutorizacion.Precio.toStringAsFixed(2)}";
              pAutorizacion.Nivel                = 0;

              var pUrl = "http://localhost/webfrontend/MenuPedidos/AutorizacionPedidoInsertar";
              String pData = pAutorizacion.toJSON();

              Map<String, String> pHeaders = new Map<String, String>();
              pHeaders["content-type"] = "application/json";

              HttpRequest.request(pUrl, method: "POST", sendData: pData, mimeType: "application/json").then((HttpRequest ARequest){

                  print(ARequest.responseText);
                  pAutorizacion = new AutorizacionPedido.fromMap(JSON.decode(ARequest.responseText));
                  ProductosPrecioModificado[ALineaPedido["claveProducto"]] = pAutorizacion.Id;
                  window.alert("Autorización generada, folio: ${pAutorizacion.Id.toString()}");

              }, onError: (_) => (window.alert("Error al insertar Autorización")));

            }); //FIN PIDE OBSERACIONES
          }
          else{
            (querySelector("#precio") as InputElement).focus();
            pCompleter.complete([false, "Error, se necesita autorización para bajar el precio"]);
            return pCompleter.future;
          }

  }

  pCompleter.complete([true, ""]);
  return pCompleter.future;
}

Future<Map> obtenerEntidadLineaPedido(int AId){

  Completer<Map> pCompleter = new Completer<Map>();

  Map pLineaPedidoTmp = new Map();
  pLineaPedidoTmp["idPedido"]       = 0;
  pLineaPedidoTmp["id"]             = id;
  pLineaPedidoTmp["claveProducto"]  = (querySelector("#claveProducto${AId}") as InputElement).value;
  pLineaPedidoTmp["nombreProducto"] = (querySelector("#nombreProducto${AId}") as InputElement).value;
  pLineaPedidoTmp["stock"]          = double.parse((querySelector("#stock${AId}") as InputElement).value.replaceAll(",", ""));
  pLineaPedidoTmp["comprometido"]   = double.parse((querySelector("#comprometido${AId}") as InputElement).value.replaceAll(",", ""));
  pLineaPedidoTmp["cajas"]          = double.parse((querySelector("#cajas${AId}") as InputElement).value.replaceAll(",", ""));
  pLineaPedidoTmp["kilos"]          = double.parse((querySelector("#kilos${AId}") as InputElement).value.replaceAll(",", ""));
  pLineaPedidoTmp["precio"]         = double.parse((querySelector("#precio${AId}") as InputElement).value.replaceAll(",", ""));
  pLineaPedidoTmp["importe"]        = double.parse((querySelector("#importe${AId}") as InputElement).value.replaceAll(",", ""));

  id++;

  pCompleter.complete(pLineaPedidoTmp);

  return pCompleter.future;
}

void LimpiaEdits(){
  (querySelector("#claveProducto0") as InputElement).value  = "";
  (querySelector("#nombreProducto0") as InputElement).value = "";
  (querySelector("#stock0") as InputElement).value          = "0.0";
  (querySelector("#comprometido0") as InputElement).value   = "0.0";
  (querySelector("#cajas0") as InputElement).value          = "0";
  (querySelector("#kilos0") as InputElement).value          = "0.0";
  (querySelector("#precio0") as InputElement).value         = "0.0";
  (querySelector("#importe0") as InputElement).value        = "0.0";

  (querySelector("#claveProducto0") as InputElement).focus();
}

void ocultaButtons(int AId){
    (querySelector("#btnEliminar${AId}") as ButtonElement).classes.remove("oculto");
    (querySelector("#btnEditar${AId}") as ButtonElement).classes.remove("oculto");
    (querySelector("#btnAceptar${AId}") as ButtonElement).classes.add("oculto");
    (querySelector("#btnCancelar${AId}") as ButtonElement).classes.add("oculto");
}

void muestraButtons(int AId){
    (querySelector("#btnEliminar${AId}") as ButtonElement).classes.add("oculto");
    (querySelector("#btnEditar${AId}") as ButtonElement).classes.add("oculto");
    (querySelector("#btnAceptar${AId}") as ButtonElement).classes.remove("oculto");
    (querySelector("#btnCancelar${AId}") as ButtonElement).classes.remove("oculto");
}

void agregaLineaPedidoTabla(Map ALineaPedido){
    TableElement pTable = querySelector("#gridData");

    TableRowElement tr = new TableRowElement()..id = "tr${ALineaPedido["id"]}";
    TableCellElement td = new TableCellElement();
    td.text = ALineaPedido["claveProducto"];
    tr.children.add(td);

    td = new TableCellElement();
    td.text = ALineaPedido["nombreProducto"];
    tr.children.add(td);

    td = new TableCellElement();
    td.text = ALineaPedido["stock"].toString();
    td.style.textAlign = "right";
    tr.children.add(td);

    td = new TableCellElement();
    td.text = ALineaPedido["comprometido"].toString();
    td.style.textAlign = "right";
    tr.children.add(td);

    td = new TableCellElement();
    td.text = ALineaPedido["cajas"].toString();
    td.style.textAlign = "right";
    tr.children.add(td);

    td = new TableCellElement();
    td.text = ALineaPedido["kilos"].toString();
    td.style.textAlign = "right";
    tr.children.add(td);

    td = new TableCellElement();
    td.text = ALineaPedido["precio"].toString();
    td.style.textAlign = "right";
    tr.children.add(td);

    td = new TableCellElement();
    td.text = ALineaPedido["importe"].toString();
    td.style.textAlign = "right";
    tr.children.add(td);

    ButtonElement btnEliminarLinea = new ButtonElement()..text = "E"..id = "btnEliminar${ALineaPedido["id"]}"..onClick.listen((_){

        if (window.confirm("¿Eliminar registro?")){
            TableRowElement tr = querySelector("#tr${ALineaPedido["id"].toString()}");
            tr.remove();

            ListaLineaPedido.removeWhere((Map x) => x["id"] == ALineaPedido["id"]);

            if (ProductosPrecioModificado[ALineaPedido["claveProducto"]] != null ){

              var pUrl = "http://localhost/webfrontend/menupedidos/AutorizacionPedidoEliminar/${ProductosPrecioModificado[ALineaPedido["claveProducto"]]}";
              HttpRequest.getString(pUrl).then((_){
                  ProductosPrecioModificado.remove(ALineaPedido["claveProducto"]);
              });

            }

            LimpiaEdits();
        }

    });

    td = new TableCellElement();
    td.children.add(btnEliminarLinea);
    tr.children.add(td);

    ButtonElement btnEditarLinea = new ButtonElement()..text = "M"..id = "btnEditar${ALineaPedido["id"]}"..onClick.listen((_){

      TableRowElement tr = querySelector("#tr${ALineaPedido["id"].toString()}");
      InputElement inpClaveProducto = new InputElement()..value = tr.children[0].text;

      tr.children[0].children.clear();
      tr.children[0].children.add(inpClaveProducto);
      inpClaveProducto.style.width = "50px";
      inpClaveProducto.value = ALineaPedido["claveProducto"];
      inpClaveProducto.id = "claveProducto${ALineaPedido["id"]}";
      inpClaveProducto.focus();

      inpClaveProducto.onBlur.listen((_) => onBlurClaveProductoEdicion(ALineaPedido["id"]));

      InputElement inpNombreProducto = new InputElement()..value = tr.children[0].text;
      tr.children[1].children.clear();
      tr.children[1].children.add(inpNombreProducto);
      inpNombreProducto.style.width = "200px";
      inpNombreProducto.id = "nombreProducto${ALineaPedido["id"]}";
      inpNombreProducto.value = ALineaPedido["nombreProducto"];

      InputElement inpStock = new InputElement()..value = tr.children[0].text;
      tr.children[2].children.clear();
      tr.children[2].children.add(inpStock);
      inpStock.style.width = "100px";
      inpStock.style.textAlign = "right";
      inpStock.id = "stock${ALineaPedido["id"]}";
      inpStock.value = ALineaPedido["stock"].toString();

      InputElement inpComprometido = new InputElement()..value = tr.children[0].text;
      tr.children[3].children.clear();
      tr.children[3].children.add(inpComprometido);
      inpComprometido.style.width = "100px";
      inpComprometido.style.textAlign = "right";
      inpComprometido.id = "comprometido${ALineaPedido["id"]}";
      inpComprometido.value = ALineaPedido["comprometido"].toString();

      InputElement inpCajas = new InputElement()..value = tr.children[0].text;
      tr.children[4].children.clear();
      tr.children[4].children.add(inpCajas);
      inpCajas.style.width = "100px";
      inpCajas.style.textAlign = "right";
      inpCajas.id = "cajas${ALineaPedido["id"]}";
      inpCajas.value = ALineaPedido["cajas"].toString();
      inpCajas.onBlur.listen((_) => onBlurCajas(ALineaPedido["id"]));

      InputElement inpKilos = new InputElement()..value = tr.children[0].text;
      tr.children[5].children.clear();
      tr.children[5].children.add(inpKilos);
      inpKilos.style.width = "100px";
      inpKilos.style.textAlign = "right";
      inpKilos.id = "kilos${ALineaPedido["id"]}";
      inpKilos.value = ALineaPedido["kilos"].toString();
      inpKilos.onBlur.listen((_) => onBlurKilos(ALineaPedido["id"]));

      InputElement inpPrecio = new InputElement()..value = tr.children[0].text;
      tr.children[6].children.clear();
      tr.children[6].children.add(inpPrecio);
      inpPrecio.style.width = "100px";
      inpPrecio.style.textAlign = "right";
      inpPrecio.id = "precio${ALineaPedido["id"]}";
      inpPrecio.value = ALineaPedido["precio"].toString();
      inpPrecio.onBlur.listen((_) => onBlurPrecio(ALineaPedido["id"]));

      InputElement inpImporte = new InputElement()..value = tr.children[0].text;
      tr.children[7].children.clear();
      tr.children[7].children.add(inpImporte);
      inpImporte.style.width = "100px";
      inpImporte.style.textAlign = "right";
      inpImporte.id = "importe${ALineaPedido["id"]}";
      inpImporte.value = ALineaPedido["importe"].toString();

      muestraButtons(ALineaPedido["id"]);

    });

    ButtonElement btnCancelarCambios = new ButtonElement()..text = "X"..id = "btnCancelar${ALineaPedido["id"]}"..onClick.listen((_){

      if (window.confirm("¿Cancelar cambios?")){

          tr.children[0].children.clear();
          tr.children[0].text = ALineaPedido["claveProducto"];
          tr.children[1].children.clear();
          tr.children[1].text = ALineaPedido["nombreProducto"];
          tr.children[2].children.clear();
          tr.children[2].text = ALineaPedido["stock"].toString();
          tr.children[3].children.clear();
          tr.children[3].text = ALineaPedido["comprometido"].toString();
          tr.children[4].children.clear();
          tr.children[4].text = ALineaPedido["cajas"].toString();
          tr.children[5].children.clear();
          tr.children[5].text = ALineaPedido["kilos"].toString();
          tr.children[6].children.clear();
          tr.children[6].text = ALineaPedido["precio"].toString();
          tr.children[7].children.clear();
          tr.children[7].text = ALineaPedido["importe"].toString();

          ocultaButtons(ALineaPedido["id"]);
      }

    });

    td.children.add(btnCancelarCambios);
    btnCancelarCambios.classes.add("oculto");

    ButtonElement btnAceptarCambios = new ButtonElement()..text = "A"..id = "btnAceptar${ALineaPedido["id"]}"..onClick.listen((_) async {

        obtenerEntidadLineaPedido(ALineaPedido["id"]).then((Map pEntidadTmp){

            Map pEntidad = ListaLineaPedido.where((Map x) => x["id"] == ALineaPedido["id"]).toList().first;

            double pPrecioOriginal = double.parse(pEntidad["precio"].toString());
            double pPrecioNuevo    = double.parse(pEntidadTmp["precio"].toString());

            if (pPrecioNuevo < pPrecioOriginal){

                window.alert("El precio nuevo es menor al original, se generará autorizacion");

                var pPedido = obtenerEntidadPedidoVentas();

                AutorizacionPedido pAutorizacion   = new AutorizacionPedido();
                pAutorizacion.Id                   = 0;
                pAutorizacion.IdUsuarioAutorizador = 0;
                pAutorizacion.NombreVendedor       = "";
                pAutorizacion.NombreSucursal       = "";
                pAutorizacion.CardCode             = pPedido.ocrcode;
                pAutorizacion.CardName             = pPedido.ocrname;
                pAutorizacion.Estado               = "Nuevo";
                pAutorizacion.FechaHoraSistema     = new DateTime.now();
                pAutorizacion.IdUsuario            = int.parse(pPedido.idUsuario);
                pAutorizacion.ItemCode             = ALineaPedido["claveProducto"];
                pAutorizacion.ItemName             = ALineaPedido["nombreProducto"];
                pAutorizacion.Precio               = double.parse(ALineaPedido["precio"].toString());
                pAutorizacion.Sucursal             = int.parse(MapaParametros["Sucursal"]);
                pAutorizacion.Vendedor             = int.parse(MapaParametros["Vendedor"]);
                pAutorizacion.Tipo                 = "Precio";
                pAutorizacion.Observaciones        = "";
                pAutorizacion.Descripcion          = "Cambio de Precio, ${pEntidadTmp["nombreProducto"]}, Precio anterior: ${pPrecioOriginal.toStringAsFixed(2)}, Precio Nuevo: ${pAutorizacion.Precio.toStringAsFixed(2)}";
                pAutorizacion.Nivel                = 0;

                var pUrl = "http://localhost/webfrontend/MenuPedidos/AutorizacionPedidoInsertar";
                String pData = pAutorizacion.toJSON();

                Map<String, String> pHeaders = new Map<String, String>();
                pHeaders["content-type"] = "application/json";

                HttpRequest.request(pUrl, method: "POST", sendData: pData, mimeType: "application/json").then((HttpRequest ARequest){

                    print(ARequest.responseText);
                    pAutorizacion = new AutorizacionPedido.fromMap(JSON.decode(ARequest.responseText));
                    ProductosPrecioModificado[ALineaPedido["claveProducto"]] = pAutorizacion.Id;
                    window.alert("Autorización generada, folio: ${pAutorizacion.Id.toString()}");

                    pEntidad["claveProducto"]  = pEntidadTmp["claveProducto"];
                        pEntidad["nombreProducto"] = pEntidadTmp["nombreProducto"];
                        pEntidad["stock"]          = pEntidadTmp["stock"];
                        pEntidad["comprometido"]   = pEntidadTmp["comprometido"];
                        pEntidad["cajas"]          = pEntidadTmp["cajas"];
                        pEntidad["kilos"]          = pEntidadTmp["kilos"];
                        pEntidad["precio"]         = pEntidadTmp["precio"];
                        pEntidad["importe"]        = pEntidadTmp["importe"];

                        tr.children[0].children.clear();
                        tr.children[0].text = pEntidadTmp["claveProducto"];
                        tr.children[1].children.clear();
                        tr.children[1].text = pEntidadTmp["nombreProducto"];
                        tr.children[2].children.clear();
                        tr.children[2].text = pEntidadTmp["stock"].toString();
                        tr.children[3].children.clear();
                        tr.children[3].text = pEntidadTmp["comprometido"].toString();
                        tr.children[4].children.clear();
                        tr.children[4].text = pEntidadTmp["cajas"].toString();
                        tr.children[5].children.clear();
                        tr.children[5].text = pEntidadTmp["kilos"].toString();
                        tr.children[6].children.clear();
                        tr.children[6].text = pEntidadTmp["precio"].toString();
                        tr.children[7].children.clear();
                        tr.children[7].text = pEntidadTmp["importe"].toString();

                        ocultaButtons(ALineaPedido["id"]);

                });

            }
            else{
                pEntidad["claveProducto"]  = pEntidadTmp["claveProducto"];
                pEntidad["nombreProducto"] = pEntidadTmp["nombreProducto"];
                pEntidad["stock"]          = pEntidadTmp["stock"];
                pEntidad["comprometido"]   = pEntidadTmp["comprometido"];
                pEntidad["cajas"]          = pEntidadTmp["cajas"];
                pEntidad["kilos"]          = pEntidadTmp["kilos"];
                pEntidad["precio"]         = pEntidadTmp["precio"];
                pEntidad["importe"]        = pEntidadTmp["importe"];

                tr.children[0].children.clear();
                tr.children[0].text = pEntidadTmp["claveProducto"];
                tr.children[1].children.clear();
                tr.children[1].text = pEntidadTmp["nombreProducto"];
                tr.children[2].children.clear();
                tr.children[2].text = pEntidadTmp["stock"].toString();
                tr.children[3].children.clear();
                tr.children[3].text = pEntidadTmp["comprometido"].toString();
                tr.children[4].children.clear();
                tr.children[4].text = pEntidadTmp["cajas"].toString();
                tr.children[5].children.clear();
                tr.children[5].text = pEntidadTmp["kilos"].toString();
                tr.children[6].children.clear();
                tr.children[6].text = pEntidadTmp["precio"].toString();
                tr.children[7].children.clear();
                tr.children[7].text = pEntidadTmp["importe"].toString();

                ocultaButtons(ALineaPedido["id"]);
            }

        });

    });

    td.children.add(btnAceptarCambios);
    btnAceptarCambios.classes.add("oculto");

    td.children.add(btnEditarLinea);
    tr.children.add(td);

    pTable.tBodies[0].children.add(tr);

}

void agregarLineaPedido(){

  obtenerEntidadLineaPedido(0).then((Map pLineapedidoTmp){

    puedeAgregarLineaPedido(pLineapedidoTmp).then((List pValida) {

      if (pValida[0]){
             ListaLineaPedido.add(pLineapedidoTmp);
             agregaLineaPedidoTabla(pLineapedidoTmp);

              TotalKilos   += pLineapedidoTmp["kilos"];
              TotalImporte += pLineapedidoTmp["importe"];

              LimpiaEdits();
          }
          else{
              window.alert(pValida[1]);
          }

    });

  });
}

void InicializaVariables(){
  String pParametros = window.location.search.replaceAll("?", "");
  List pPar1 = pParametros.split("&");

  for (String item in pPar1){
    List pItemList = item.split("=");
    MapaParametros[pItemList[0]] = pItemList[1];
  }

  print(MapaParametros);

  String pUrlVendedores = "http://localhost/WebFrontEnd/Locaciones/ObtenerVendedores?Locacion=${MapaParametros["NombreSucursal"]}";

  DateTime pFechaEntrega = new DateTime.now().add( new Duration(days: 1));

  if (pFechaEntrega.weekday == DateTime.SUNDAY){
      pFechaEntrega = pFechaEntrega.add( new Duration(days: 1));
  }

  (querySelector("#inpFechaEntrega") as InputElement).value = new intl.DateFormat("dd/MM/yyyy").format(pFechaEntrega);

  HttpRequest.getString(pUrlVendedores).then((String Data){

    List<Map> pLista = JSON.decode(Data);

    SelectElement pInputVendedor = querySelector("#inpVendedor") as SelectElement;


    for (Map item in pLista){
        pInputVendedor.children.add(new Element.html('<option value="${item["Id"]}">${item["Nombre"]}</option>'));
    }

    (querySelector("#inpVendedor") as SelectElement).value = MapaParametros["Vendedor"].toString();
    (querySelector("#inpRuta") as SelectElement).value     = MapaParametros["Vendedor"].toString();

  }).then((String Data){

      var pPlaza = (querySelector("#inpPlaza") as InputElement).value;
      var pUrlRutaVentas = "http://localhost/WebFrontEnd/RutaVentas/ObtenerListaPlaza?Plaza=${pPlaza}";

      HttpRequest.getString(pUrlRutaVentas).then((String Data){

          List<Map> pLista = JSON.decode(Data);
          SelectElement pInputRuta = querySelector("#inpRuta") as SelectElement;

          for (Map item in pLista){
              pInputRuta.children.add(new Element.html('<option value="${item["Id"]}">${item["Nombre"]}</option>'));
          }

      });

  }).then((_){
    String pUrlAlmacenes  = "http://localhost/webfrontend/MenuPedidos/ObtenerAlmacenesLocacion?Locacion=${MapaParametros["NombreSucursal"]}&Empresa=SolesProd";
    HttpRequest.getString(pUrlAlmacenes).then((String Data){
      SelectElement pInputAlmacen = querySelector("#inpAlmacen") as SelectElement;
      List<Map> pLista = JSON.decode(Data);

      for (Map item in pLista){
          pInputAlmacen.children.add(new Element.html('<option value="${item["Clave"]}">${item["Nombre"]}</option>'));
      }

      String pAlmacen = MapaParametros["Almacen"].toString();
      (querySelector("#inpAlmacen") as SelectElement).value = MapaParametros["Almacen"].toString();
    });
  }).then((_){

      if (MapaParametros["IdPedido"] != "0" && MapaParametros["IdPedido"] != null){

          var pUrl = "http://localhost/webfrontend/MenuPedidos/PedidoObtener/${MapaParametros["IdPedido"]}";
          (querySelector("#inpFolio") as InputElement).value =  MapaParametros["IdPedido"].toString();

          HttpRequest.getString(pUrl).then((String Data){

              Map pPedido = JSON.decode(Data);
              (querySelector("#inpCliente") as InputElement).value       = pPedido["OcrCode"];
              (querySelector("#inpNombreCliente") as InputElement).value = pPedido["OcrName"];
              (querySelector("#inpFolio") as InputElement).value         = pPedido["Id"].toString();
              (querySelector("#inpSaldo") as InputElement).value         = pPedido["Saldo"].toString();
              (querySelector("#inpVendedor") as SelectElement).value     = pPedido["Vendedor"].toString();
              (querySelector("#inpAlmacen") as SelectElement).value      = pPedido["Almacen"].toString();
              (querySelector("#inpRuta") as SelectElement).value         = pPedido["Ruta"].toString();
              pRutaTmp = pPedido["Ruta"].toString();
              (querySelector("#inpFechaEntrega") as InputElement).value  = pPedido["FechaEntrega"].toString();
              (querySelector("#inpObservaciones") as InputElement).value = pPedido["Observaciones"].toString();
              pEntregaTmp = pPedido["Entrega"].toString();

              var pUrl = "http://localhost/webfrontend/MenuPedidos/DetallePedidoObtener/${MapaParametros["IdPedido"]}";

              return HttpRequest.getString(pUrl);
          }).then((String Data){

              List<Map> pListaDetalle = JSON.decode(Data);

              TableElement pTable = querySelector("#gridData");
              pTable.tBodies[0].children.clear();

              for (Map item in pListaDetalle){
                  ListaLineaPedido.add(item);
                  agregaLineaPedidoTabla(item);

                  TotalKilos   += item["kilos"];
                  TotalImporte += item["importe"];
              }

          }).then((_){
              onClaveClienteBlur();
              inpEntregas.value = pEntregaTmp;
              (querySelector("#inpRuta") as SelectElement).value = pRutaTmp;
          });
      }
  });
}

dynamic AutorizacioPendiente(){

    print("Pendientes: ${ProductosPrecioModificado.length.toString()}");

    if (ProductosPrecioModificado.length > 0){

        print("checando");

        List<int> pFoliosAutorizacion = ProductosPrecioModificado.values.toList();

        var pUrl = "http://localhost/webfrontend/MenuPedidos/AutorizacionPedidoObtenerEstado";

        String pData = JSON.encode(pFoliosAutorizacion);
        print("Autorizados ${pData}");

        Map<String, String> pHeaders = new Map<String, String>();
        pHeaders["content-type"] = "application/json";

        return HttpRequest.request(pUrl, method: "POST", sendData: pData, mimeType: "aplication/json");
    }
    else{
        return true;
    }

}

String obtenerDetallePedidoSerializado(int AIdPedido){

    for (Map item in ListaLineaPedido){
      item["idPedido"] = AIdPedido;
    }

    return JSON.encode(ListaLineaPedido);

}

double obtenerTotalPedido(){

    double pResult = 0.0;

    for (Map item in ListaLineaPedido){
        pResult += item["importe"];
    }

    return pResult;
}


Future sleep(dynamic result) {
  Completer completer = new Completer();
  Duration duration = new Duration(milliseconds: 2000);
  Timer timer = new Timer(duration, () => completer.complete(result) );
  return completer.future;
}


int obtenerNivel(){
  int pResult = 0;

   double pCreditoDisponible = pLineaCredito - (pSaldoCliente + pComprometidoCliente);
   double pLineaCredito80    = (pLineaCredito * 0.80);
   double pLineaCredito70    = (pLineaCredito * 0.70);
   double pLineaCredito10    = (pLineaCredito * 0.10);
   double pLineaCreditoExtra10 = (pLineaCredito * 0.10) + pLineaCredito;


   double pTotalImporte = 0.0;

   for (Map item in ListaLineaPedido){
      pTotalImporte += item["importe"];
   }

  //Clientes de Contado Sin Facturas Vencidas
   if (pNombreTipo == "CONTADO" && pVencido <= 0.0){
     return 0;
   }

  //Clientes de contado con facturas vencidas
  if (pNombreTipo == "CONTADO" && pVencido > 0.0){
     return 1;
  }
  //Clientes riesgo A con facturas vencidas con crédito disponible, de 0 a 5 días
  else if (pRiesgo == "A" && pNombreTipo == "CREDITO" && pVencido > 0 && pCreditoDisponible > 0 && (pDiasVencidos > 0 && pDiasVencidos <=5)){
     return 2;
  }
  //Clientes riesgo A con facturas vencidas de más de diez días y menor a quince se les da hasta un 70%
  else if (pRiesgo == "A" && pNombreTipo == "CREDITO" && (pDiasVencidos >= 11 && pDiasVencidos <= 15) && (pTotalImporte + pSaldoCliente) <= pLineaCredito80){
     return 8;
  }
  //Clientes riesgo A con facturas vencidas de más de cinco días  y menor a once días se les da hasta un 80%
  else if (pRiesgo == "A" && pNombreTipo == "CREDITO" && (pDiasVencidos >= 6 && pDiasVencidos <= 10) && (pTotalImporte + pSaldoCliente) <= pLineaCredito80){
     return 3;
  }
  //Clientes riesgo B con facturas vencidas de menos de 5 días se les da hasta un 80% del crédito
  else if (pRiesgo == "B" && pNombreTipo == "CREDITO" && pVencido > 0 && (pTotalImporte +  pSaldoCliente) <= pLineaCredito80 && pDiasVencidos <= 5){
     return 4;
  }
  //Clientes riesgo B con facturas vencidas de más de 5 días y menos de once se les da hasta un 70% del crédito
  else if (pRiesgo == "B" && pNombreTipo == "CREDITO" && pVencido > 0 && (pTotalImporte +  pSaldoCliente) <= pLineaCredito70 && (pDiasVencidos > 5 && pDiasVencidos < 11)){
     return 9;
  }
  //Clientes riesgo B sin facturas vencidas con días de crédito disponible se le da hasta un 10% extra
  else if (pRiesgo == "B" && pNombreTipo == "CREDITO" && pDiasVencidos == 0 && (pTotalImporte + pSaldoCliente) <= pLineaCreditoExtra10){
     return 5;
  }
  //Clientes riesgo A si no tiene factura vencida se le puede dar un 10% extra de crédito
  else if (pRiesgo == "A" && pNombreTipo == "CREDITO" && pDiasVencidos == 0 && (pTotalImporte + pSaldoCliente) <= pLineaCreditoExtra10){
     return 6;
  }
  //Clientes tipo C
  else if (pRiesgo == "C"){
     return 7;
  }
  else{
     return 7;
  }
}

void guardaPedido(){

   if (ListaLineaPedido.length == 0){
        window.alert("No se han capturado detalles del pedido");
        return;
   }

   var pFechaEntregaStr   = (querySelector("#inpFechaEntrega") as InputElement).value;

   String pAnoStr = pFechaEntregaStr.substring(6, 10);
   String pMesStr = pFechaEntregaStr.substring(3, 5);
   String pDiaStr = pFechaEntregaStr.substring(0, 2);

   int pAno = int.parse(pAnoStr);
   int pMes = int.parse(pMesStr);
   int pDia = int.parse(pDiaStr);

   DateTime pFechaEntrega = new DateTime(pAno, pMes, pDia);

   if (pFechaEntrega.weekday == DateTime.SUNDAY){
        window.alert("La fecha de entrega no puede ser domingo");
        return;
   }
   
   if (RutaVentas != "-1"){
       if (RutaVentas != (querySelector("#inpRuta") as SelectElement).value){
            window.alert("La ruta de ventas del cliente no es la que tiene asignada");
            return;
       }
   }

   double pTotalImporte = 0.0;

   for (Map item in ListaLineaPedido){
     pTotalImporte += item["importe"];
   }

   print("AQUI ESTA 1");
   if (pVencido > 0.0){

     if (window.confirm("El cliente tiene vencido ${new intl.NumberFormat("###,##0.00").format(pVencido)}, ¿Proseguir?")){

        pideObservaciones().then((String Observaciones){

            ModalP.closeModal("mo");

            pEstado = "Preliminar";

            AutorizacionPedido pAutorizacion   = new AutorizacionPedido();
            pAutorizacion.Id                   = 0;
            pAutorizacion.IdUsuarioAutorizador = 0;
            pAutorizacion.NombreVendedor       = "";
            pAutorizacion.NombreSucursal       = "";
            pAutorizacion.CardCode             = (querySelector("#inpCliente") as InputElement).value;
            pAutorizacion.CardName             = (querySelector("#inpNombreCliente") as InputElement).value;
            pAutorizacion.Estado               = "Nuevo";
            pAutorizacion.FechaHoraSistema     = new DateTime.now();
            pAutorizacion.IdUsuario            = int.parse(MapaParametros["IdUsuario"]);
            pAutorizacion.ItemCode             = "-1";
            pAutorizacion.ItemName             = "Saldo vencido";
            pAutorizacion.Precio               = pVencido;
            pAutorizacion.Sucursal             = int.parse(MapaParametros["Sucursal"]);
            pAutorizacion.Vendedor             = int.parse(MapaParametros["Vendedor"]);
            pAutorizacion.Tipo                 = "Saldo";
            pAutorizacion.Observaciones        = Observaciones;
            pAutorizacion.Descripcion          = "Cliente tiene vencido ${pVencido.toStringAsFixed(2)}, Saldo al momento de el pedido ${pSaldoCliente.toStringAsFixed(2)}";
            pAutorizacion.Nivel                = obtenerNivel();

            var pUrl = "http://localhost/webfrontend/MenuPedidos/AutorizacionPedidoInsertar";
            String pData = pAutorizacion.toJSON();

            Map<String, String> pHeaders = new Map<String, String>();
            pHeaders["content-type"] = "application/json";

            return HttpRequest.request(pUrl, method: "POST", sendData: pData, mimeType: "application/json").then((HttpRequest ARequest){

                print(ARequest.responseText);
                pAutorizacion = new AutorizacionPedido.fromMap(JSON.decode(ARequest.responseText));
                ProductosPrecioModificado["-1"] = pAutorizacion.Id;
                print("Autorización generada, folio: ${pAutorizacion.Id.toString()}");

            }, onError: (_) => (window.alert("Error al insertar Autorización saldo")));

        }).then((_){

               print("aqui");

               PedidoVentas pPedidoVentas = obtenerEntidadPedidoVentas();
               pPedidoVentas.estado = pEstado;
               Map<String, String> pHeaders = new Map<String, String>();
               pHeaders["Content-Type"] = "application/json";

               var pUrlInsertar  = "http://localhost/webfrontend/MenuPedidos/InsertarPedido";
               var pUrlInsertarD = "http://localhost/webfrontend/MenuPedidos/InsertarPedidoDetallePedidoVentas";
               var pMetodo       = "POST";

               sleep(pMetodo).then((_){

                 var pData  = pPedidoVentas.toJson(ProductosPrecioModificado);

                 HttpRequest.request(pUrlInsertar, method: pMetodo, sendData: pData, mimeType: "application/json").then((HttpRequest ARequest){

                   Map pPedido = JSON.decode(ARequest.responseText);

                   var pDataD = obtenerDetallePedidoSerializado(pPedido["Id"]);

                   return HttpRequest.request(pUrlInsertarD , method: pMetodo, sendData: pDataD, mimeType: "application/json");
                 }).then((HttpRequest ARequest){
                     window.alert("Se guardo pedido ${ARequest.responseText}");
                     window.location.href = "/webfrontend/MenuPedidos/PedidosTurno?IdUsuario=${MapaParametros["IdUsuario"]}&Turno=${MapaParametros["Turno"]}&FechaTurno=${MapaParametros["FechaTurno"]}&Vendedor=${MapaParametros["Vendedor"]}&NombreSucursal=${MapaParametros["NombreSucursal"]}&Sucursal=${MapaParametros["Sucursal"]}&Grupo=${MapaParametros["Grupo"]}&Almacen=${MapaParametros["Almacen"]}";
                 });
               });

               return;


        }) ; //FIN PIDE OBSERVACIONES
     }
     else{
        return;
     }
   }
   else{
     if ((pTotalImporte + pComprometidoCliente + pSaldoCliente) > pLineaCredito){
          print("AQUI ESTA 2");
       
          if (window.confirm("El total sobrepasa la línea de crédito del cliente, ¿Proseguir?")){

            ModalP.closeModal("mo");

              pEstado = "Preliminar";

              pideObservaciones().then((String Observaciones){

                    pEstado = "Preliminar";

                    AutorizacionPedido pAutorizacion   = new AutorizacionPedido();
                    pAutorizacion.Id                   = 0;
                    pAutorizacion.IdUsuarioAutorizador = 0;
                    pAutorizacion.NombreVendedor       = "";
                    pAutorizacion.NombreSucursal       = "";
                    pAutorizacion.CardCode             = (querySelector("#inpCliente") as InputElement).value;
                    pAutorizacion.CardName             = (querySelector("#inpNombreCliente") as InputElement).value;
                    pAutorizacion.Estado               = "Nuevo";
                    pAutorizacion.FechaHoraSistema     = new DateTime.now();
                    pAutorizacion.IdUsuario            = int.parse(MapaParametros["IdUsuario"]);
                    pAutorizacion.ItemCode             = "-1";
                    pAutorizacion.ItemName             = "Saldo vencido";
                    pAutorizacion.Precio               = pVencido;
                    pAutorizacion.Sucursal             = int.parse(MapaParametros["Sucursal"]);
                    pAutorizacion.Vendedor             = int.parse(MapaParametros["Vendedor"]);
                    pAutorizacion.Tipo                 = "Saldo";
                    pAutorizacion.Observaciones        = Observaciones;
                    pAutorizacion.Descripcion          = "Pedido sobrepasa la línea de crédito de ${pLineaCredito.toStringAsFixed(2)}, importe del pedido ${(pTotalImporte + pComprometidoCliente + pSaldoCliente).toStringAsFixed(2)}";
                    pAutorizacion.Nivel                = obtenerNivel();

                    var pUrl = "http://localhost/webfrontend/MenuPedidos/AutorizacionPedidoInsertar";
                    String pData = pAutorizacion.toJSON();

                    Map<String, String> pHeaders = new Map<String, String>();
                    pHeaders["content-type"] = "application/json";

                    HttpRequest.request(pUrl, method: "POST", sendData: pData, mimeType: "application/json").then((HttpRequest ARequest){

                        print(ARequest.responseText);
                        pAutorizacion = new AutorizacionPedido.fromMap(JSON.decode(ARequest.responseText));
                        ProductosPrecioModificado["-1"] = pAutorizacion.Id;
                        print("Autorización generada, folio: ${pAutorizacion.Id.toString()}");

                    }, onError: (_) => (window.alert("Error al insertar Autorización saldo"))).then((String Data){

                          PedidoVentas pPedidoVentas = obtenerEntidadPedidoVentas();
                          pPedidoVentas.estado = pEstado;
                          Map<String, String> pHeaders = new Map<String, String>();
                          pHeaders["Content-Type"] = "application/json";

                          var pUrlInsertar  = "http://localhost/webfrontend/MenuPedidos/InsertarPedido";
                          var pUrlInsertarD = "http://localhost/webfrontend/MenuPedidos/InsertarPedidoDetallePedidoVentas";
                          var pMetodo       = "POST";

                          sleep(pMetodo).then((_){

                            var pData  = pPedidoVentas.toJson(ProductosPrecioModificado);

                            HttpRequest.request(pUrlInsertar, method: pMetodo, sendData: pData, mimeType: "application/json").then((HttpRequest ARequest){

                              Map pPedido = JSON.decode(ARequest.responseText);

                              var pDataD = obtenerDetallePedidoSerializado(pPedido["Id"]);

                              return HttpRequest.request(pUrlInsertarD , method: pMetodo, sendData: pDataD, mimeType: "application/json");
                            }).then((HttpRequest ARequest){
                                window.alert("Se guardo pedido ${ARequest.responseText}");
                                window.location.href = "/webfrontend/MenuPedidos/PedidosTurno?IdUsuario=${MapaParametros["IdUsuario"]}&Turno=${MapaParametros["Turno"]}&FechaTurno=${MapaParametros["FechaTurno"]}&Vendedor=${MapaParametros["Vendedor"]}&NombreSucursal=${MapaParametros["NombreSucursal"]}&Sucursal=${MapaParametros["Sucursal"]}&Grupo=${MapaParametros["Grupo"]}&Almacen=${MapaParametros["Almacen"]}";
                            });
                          });

                    });

                }); //FIN PIDE OBSERVACIONES
          }
          else{
              return;
          }
     }
     else{

            print("AQUI ESTA 3");
            PedidoVentas pPedidoVentas = obtenerEntidadPedidoVentas();
            var pUrl =  "http://localhost/webfrontend/MenuPedidos/AutorizacionPedidoEliminarPorSaldo/" + MapaParametros["IdPedido"].toString();

            HttpRequest.getString(pUrl).then((String Data) {

                   pPedidoVentas.estado = pEstado;
                   Map<String, String> pHeaders = new Map<String, String>();
                   pHeaders["Content-Type"] = "application/json";

                   var pUrlInsertar  = "http://localhost/webfrontend/MenuPedidos/InsertarPedido";
                   var pUrlInsertarD = "http://localhost/webfrontend/MenuPedidos/InsertarPedidoDetallePedidoVentas";
                   var pMetodo       = "POST";

                   sleep(pMetodo).then((_){

                     var pData  = pPedidoVentas.toJson(ProductosPrecioModificado);

                     HttpRequest.request(pUrlInsertar, method: pMetodo, sendData: pData, mimeType: "application/json").then((HttpRequest ARequest){

                       Map pPedido = JSON.decode(ARequest.responseText);

                       var pDataD = obtenerDetallePedidoSerializado(pPedido["Id"]);

                       return HttpRequest.request(pUrlInsertarD , method: pMetodo, sendData: pDataD, mimeType: "application/json");
                     }).then((HttpRequest ARequest){
                         window.alert("Se guardo pedido ${ARequest.responseText}");
                         window.location.href = "/webfrontend/MenuPedidos/PedidosTurno?IdUsuario=${MapaParametros["IdUsuario"]}&Turno=${MapaParametros["Turno"]}&FechaTurno=${MapaParametros["FechaTurno"]}&Vendedor=${MapaParametros["Vendedor"]}&NombreSucursal=${MapaParametros["NombreSucursal"]}&Sucursal=${MapaParametros["Sucursal"]}&Grupo=${MapaParametros["Grupo"]}&Almacen=${MapaParametros["Almacen"]}";
                     });
                   });

                   return;
            });
        }
  }

  (querySelector("#btnGuardar") as ButtonElement).disabled  = true;
  (querySelector("#btnCancelar") as ButtonElement).disabled = true;

}

void cancelar(){
  if (window.confirm("¿Cancelar captura de pedido?")){
      window.location.href = "/webfrontend/MenuPedidos/PedidosTurno?IdUsuario=${MapaParametros["IdUsuario"]}&Turno=${MapaParametros["Turno"]}&FechaTurno=${MapaParametros["FechaTurno"]}&Vendedor=${MapaParametros["Vendedor"]}&NombreSucursal=${MapaParametros["NombreSucursal"]}&Sucursal=${MapaParametros["Sucursal"]}&Grupo=${MapaParametros["Grupo"]}&Almacen=${MapaParametros["Almacen"]}";
  }
}


void main() {
   InputElement pInpCliente = querySelector("#inpCliente");
   pInpCliente.onBlur.listen((_) => onClaveClienteBlur());

  InputElement pInpClaveProducto = querySelector("#claveProducto0");
  pInpClaveProducto.onBlur.listen((_) => onBlurClaveProductoEdicion(0));

  InputElement pInpCajas = querySelector("#cajas0");
  pInpCajas.onBlur.listen((_) => onBlurCajas(0));

  InputElement pInpKilos = querySelector("#kilos0");
  pInpKilos.onBlur.listen((_) => onBlurKilos(0));

  InputElement pInpPrecio = querySelector("#precio0");
  pInpPrecio.onBlur.listen((_) => onBlurPrecio(0));

  ButtonElement pBtnAgregarPedido = querySelector("#btnAgregarLineaPedido");
  pBtnAgregarPedido.onClick.listen((_) => agregarLineaPedido());

  ButtonElement pBtnGuardar = querySelector("#btnGuardar");
  pBtnGuardar.onClick.listen((_) => guardaPedido());

  ButtonElement pBtnCancelar = querySelector("#btnCancelar");
  pBtnCancelar.onClick.listen((_) => cancelar());

  ButtonElement pBtnDetalleSaldo = querySelector("#btnDetalleSaldo");
  pBtnDetalleSaldo.onClick.listen((_) => detalleSaldoCliente());

  ButtonElement pBtnCerrarDetalleSaldo = querySelector("#btnCerrar");
  pBtnCerrarDetalleSaldo.onClick.listen((_) => ModalP.closeModal("mc"));

  InicializaVariables();
}
