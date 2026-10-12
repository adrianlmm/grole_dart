// ignore_for_file: library_prefixes, non_constant_identifier_names, avoid_types_as_parameter_names, avoid_single_cascade_in_expression_statements

import 'dart:html';
import 'package:intl/intl.dart' as intl;
import 'OrdenProduccion.dart';
import 'OrdenPP.dart';
import 'detalle_mp.dart';
import 'salida_inventario.dart';
import 'dart:convert';
import 'dart:async';
import 'package:quickdialogs/quickdialogs.dart' as ModalP;

String IdOrden = "";
OrdenProduccion POrdenProduccion = OrdenProduccion();
List<OrdenMP> ListaOrdenPMP = <OrdenMP>[];
List<OrdenMP> ListaOrdenPP = <OrdenMP>[];
List<Produccion> ListaProduccion = <Produccion>[];
List<DetalleMP> ListaDetalle = <DetalleMP>[];
List<DetalleMPTarima> ListaDetalleTarima = <DetalleMPTarima>[];

final HiddenInputElement inpPassword = querySelector("#inpPassword") as HiddenInputElement;
final SpanElement spanTotalCostoEmpaque = querySelector("#TotalCostoEmpaque") as SpanElement;
final SpanElement spanTotalSuma = querySelector("#TotalSuma") as SpanElement;
final SpanElement spamTotalImporteFinal = querySelector("#TotalImporteFinal") as SpanElement;

double SurtidoTotal = 0.0;
StreamSubscription? EventoCostoSalida;
StreamSubscription? EventoCostoMaquila;
StreamSubscription? EventoValorRescate;
bool editable = true;
var pHost = '';
//var pHost = 'http://localhost:8031';
//var pHost = 'http://192.168.10.240:9990';

double pTotalKilos = 0.0;
double pTotalSurtido = 0.0;
double pTotalCosto = 0.0;
double pTotalImporte = 0.0;

double pTotalProgramado = 0.0;
double pTotalProducidoT = 0.0;
double pTotalCajas = 0.0;
double pTotalCostoMaquila = 0.0;
double pTotalImporteMaquila = 0.0;
double pTotalValorRescate = 0.0;
double pTotalImporteRescate = 0.0;
double pTotalCostoEmpaque = 0.0;
String FolioSalida = "-";

Future actualizaCostoEmpaque(int AOrden, double ACosto) async {
  
  var pUrl = '$pHost/rest/ordenp/actualiza_costo_empaque?orden=$AOrden&costo_empaque=$ACosto';
  var p_result = await HttpRequest.getString(pUrl);

}

Future<double> obtenerCostoEmpaque(int AOrden) async{
  var pUrl = '$pHost/rest/ordenp/obtener_costo_empaque/$AOrden';
  print(pUrl);
  var p_result = await HttpRequest.getString(pUrl);
  if (p_result.isEmpty) {
    return 0.0;
  } else {
    var p_costo = jsonDecode(p_result);
    return p_costo;
  }
}

String ObtenerIdOrden() {
  String p_querySelector_string = window.location.search!;
  String p_orden = p_querySelector_string.split("&")[0];
  p_orden = p_orden.split("=")[1];
  return p_orden;
}

void agregaFilaMPrima(OrdenMP item) {
  TableElement tableMP = querySelector("#tableMPrima") as TableElement;

  TableRowElement tr = TableRowElement()..id = item.id.toString();
  TableCellElement td = TableCellElement()..text = item.producto;
  tr.children.add(td);
  td = TableCellElement()..text = item.codigosap;
  tr.children.add(td);
  td = TableCellElement()..text = item.descripcion;
  tr.children.add(td);
  td =
      TableCellElement()
        ..text = intl.NumberFormat("#,##0.00").format(item.kilos)
        ..style.textAlign = "right";
  tr.children.add(td);
  td =
      TableCellElement()
        ..text = intl.NumberFormat("#,##0.00").format(item.surtido)
        ..style.textAlign = "right";
  tr.children.add(td);
  td =
      TableCellElement()
        ..text = item.cajas.toString()
        ..style.textAlign = "right";
  tr.children.add(td);
  td =
      TableCellElement()
        ..text = intl.NumberFormat("#,##0.00").format(item.saldo_sap)
        ..style.textAlign = "right"
        ..id = "mp_saldo_sap${item.id}";
  tr.children.add(td);
  td =
      TableCellElement()
        ..text = intl.NumberFormat("#,##0.00").format(item.costo_salida)
        ..style.textAlign = "right"
        ..id = "mp_costo${item.id}";
  tr.children.add(td);
  td =
      TableCellElement()
        ..text = intl.NumberFormat("#,##0.00").format(item.importe_salida)
        ..style.textAlign = "right"
        ..id = "mp_importe_costo${item.id}";
  tr.children.add(td);

  String pHtmlBtn = "<button class='btn edit_btn'><i class='icon-list'></i></button>";
  ButtonElement btn =
      Element.html(pHtmlBtn) as ButtonElement
        ..id = 'btnDetalleOrden${item.id.toString()}'
        ..onClick.listen((_) {
          if (item != null) {
            detalleOrden(item);
          }
        });

  td = TableCellElement()..children.add(btn);
  tr.children.add(td);

  tableMP.tBodies[0].children.add(tr);
}

Future<int> obtenerCajasPendientes(String AOrden) async {
  String pUrl = "$pHost/rest/cajas_pendientes_orden/$AOrden";

  String pResponse = await HttpRequest.getString(pUrl);

  return int.parse(pResponse);
}

void actualizaFilaMPrima(OrdenMP item) {
  (querySelector("#mp_costo${item.id}") as TableCellElement).text = intl.NumberFormat(
    "#,##0.00",
  ).format(item.costo_salida);
  (querySelector("#mp_importe_costo${item.id}") as TableCellElement).text = intl.NumberFormat(
    "#,##0.00",
  ).format(item.importe_salida);
  (querySelector("#mp_saldo_sap${item.id}") as TableCellElement).text = intl.NumberFormat(
    "#,##0.00",
  ).format(item.saldo_sap);
}

void agregaFilaProducido(Produccion item) {
  TableElement tableMP = querySelector("#tablaProducido") as TableElement;

  TableRowElement tr = TableRowElement()..id = item.id.toString();

  TableCellElement td = TableCellElement()..text = item.factura.toString();
  tr.children.add(td);
  td = TableCellElement()..text = item.clave_producto;
  tr.children.add(td);
  td = TableCellElement()..text = item.codigosap;
  tr.children.add(td);
  td = TableCellElement()..text = item.nombre_producto;
  tr.children.add(td);
  td =
      TableCellElement()
        ..text = intl.NumberFormat("#,##0.00").format(item.programado)
        ..style.textAlign = "right";
  tr.children.add(td);
  td =
      TableCellElement()
        ..text = intl.NumberFormat("#,##0.00").format(item.producido)
        ..style.textAlign = "right";
  tr.children.add(td);
  td =
      TableCellElement()
        ..text = intl.NumberFormat("#,##0.00").format(item.porcentaje)
        ..style.textAlign = "right";
  tr.children.add(td);

  AnchorElement pCajas = Element.html("<a href=\"#\">${item.cajas}</a>") as AnchorElement;

  pCajas.onClick.listen((_) async {
    await detalleProducido(item);
  });

  td =
      TableCellElement()
        ..style.textAlign = "right"
        ..id = "pp_cajas${item.id}"
        ..children.add(pCajas);
  tr.children.add(td);
  td =
      TableCellElement()
        ..text = intl.NumberFormat("#,##0.00").format(item.costo_maquila)
        ..style.textAlign = "right"
        ..id = "pp_costo_maquila${item.id}";
  tr.children.add(td);
  td =
      TableCellElement()
        ..text = intl.NumberFormat("#,##0.00").format(item.importe_maquila)
        ..style.textAlign = "right"
        ..id = "pp_importe_maquila${item.id}";
  tr.children.add(td);
  AnchorElement pValorRescate =
      Element.html("<a href=\"#\">${intl.NumberFormat("#,##0.00").format(item.valor_rescate)}</a>") as AnchorElement;

  pValorRescate.onClick.listen((_) {
    capturaValorRescate(item);
  });

  td =
      TableCellElement()
        ..style.textAlign = "right"
        ..id = "pp_valor_rescate${item.id}"
        ..children.add(pValorRescate);
  tr.children.add(td);

  td =
      TableCellElement()
        ..text = intl.NumberFormat("#,##0.00").format(item.importe_rescate)
        ..style.textAlign = "right"
        ..id = "pp_importe_rescate${item.id}";
  tr.children.add(td);

  td =
      TableCellElement()
        ..style.textAlign = "right"
        ..text = intl.NumberFormat("#,##0.00").format(item.costo_pto_terminado);
  tr.children.add(td);

  td =
      TableCellElement()
        ..style.textAlign = "right"
        ..text = intl.NumberFormat("#,##0.00").format(item.importe);
  tr.children.add(td);

  td = TableCellElement()
        ..style.textAlign = "right"
        ..text = intl.NumberFormat("#,##0.00").format(item.importe_final);
  tr.children.add(td);

  var pHtmlBtn = "<button class='btn edit_btn'><i class='icon-list'></i></button>";
  ButtonElement btn =
      Element.html(pHtmlBtn) as ButtonElement
        ..id = 'btnCostoMaquila${item.id.toString()}'
        ..onClick.listen((_) {
          costoMaquila(item);
        });

  td = TableCellElement()..children.add(btn);
  tr.children.add(td);

  tableMP.tBodies[0].children.add(tr);
}

void actualizaFilaProduccion(Produccion item) {
  (querySelector("#pp_costo_maquila${item.id}") as TableCellElement).text = intl.NumberFormat(
    "#,##0.00",
  ).format(item.costo_maquila);
  (querySelector("#pp_importe_maquila${item.id}") as TableCellElement).text = intl.NumberFormat(
    "#,##0.00",
  ).format(item.importe_maquila);
  TableCellElement pCellValorRescate = (querySelector("#pp_valor_rescate${item.id}") as TableCellElement);
  (pCellValorRescate.children[0] as AnchorElement).text = intl.NumberFormat("#,##0.00").format(item.valor_rescate);
  (querySelector("#pp_importe_rescate${item.id}") as TableCellElement).text = intl.NumberFormat(
    "#,##0.00",
  ).format(item.importe_rescate);
}

Future ObtenerOrdenProduccion(String AId) async {
  IdOrden = AId;
  String pUrl = '$pHost/rest/ordenp/OrdenProduccion_obtener/$AId';

  var data = await HttpRequest.getString(pUrl, onProgress: null);
  POrdenProduccion = OrdenProduccion.FromJSON(data);

  DespliegaEntidad(POrdenProduccion);
  //print(POrdenProduccion.estado);
  pUrl = '$pHost/rest/ordenp/ordenmp_obtener_lista/${POrdenProduccion.id.toString()}';
  print(pUrl);
  var Data = await HttpRequest.getString(pUrl, onProgress: null);
  var pLista = jsonDecode(Data);

  pTotalImporte = 0.0;

  for (var item in pLista) {
    var pOdenMP = OrdenMP.FromMap(item);
    ListaOrdenPMP.add(pOdenMP);

    agregaFilaMPrima(pOdenMP);

    pTotalKilos += pOdenMP.kilos;
    pTotalSurtido += pOdenMP.surtido;
    pTotalCosto += pOdenMP.costo_salida;
    pTotalImporte += pOdenMP.importe_salida;

    print("{}----");
    print(pTotalImporte);
  }

  SurtidoTotal = pTotalSurtido;

  (document.querySelector("#TotalKilosP") as SpanElement).innerHtml = intl.NumberFormat("#,##0.00").format(pTotalKilos);
  (document.querySelector("#TotalSurtidoP") as SpanElement).innerHtml = intl.NumberFormat(
    "#,##0.00",
  ).format(pTotalSurtido);
  (document.querySelector("#TotalCostoP") as SpanElement).innerHtml = intl.NumberFormat("#,##0.00").format(pTotalCosto);
  (document.querySelector("#TotalImporteP") as SpanElement).innerHtml = intl.NumberFormat(
    "#,##0.00",
  ).format(pTotalImporte);

  print(POrdenProduccion.costo_salida);

  //POrdenProduccion.costo_salida = 0.0;

  if (POrdenProduccion.costo_salida > 100) {
    print("El costo es mayor a cero");
    pTotalImporte = POrdenProduccion.costo_salida;
    (document.querySelector("#TotalImporteP") as SpanElement).innerHtml = POrdenProduccion.costo_salida.toStringAsFixed(
      2,
    );
  } else {
    print("El costo es cero");
    var pUrlCosto =
        "http://172.17.1.22:8045/WebFrontEnd/inventarios/ObtenerCostoSalida?Orden=${IdOrden.toString()}&Cuenta=11100030001&Empresa=SolesProd";
    print(pUrlCosto);

    HttpRequest.getString(pUrlCosto).then((String Data) {
      print('Costo obtenido $Data');
      double pCosto = jsonDecode(Data).toDouble();
      pTotalImporte = pCosto;
      POrdenProduccion.costo_salida = pCosto;
      (document.querySelector("#TotalImporteP") as SpanElement).innerHtml = pCosto.toStringAsFixed(2);

      String pUrl = "$pHost/rest/ordenp/actualizar_costo_salida_orden/${IdOrden.toString()}";
      String pData = '{"costo": "${pCosto.toString()}" }';
      Map<String, String> headers = <String, String>{};
      headers["content-type"] = "application/json";

      HttpRequest.request(
        pUrl,
        method: "POST",
        responseType: "application/json",
        sendData: pData,
        requestHeaders: headers,
      );
    });
  }

  pUrl = '$pHost/rest/ordenp/ordenpp_obtener_lista/${POrdenProduccion.id.toString()}';
  //print("..w..${pUrl}");
  Data = await HttpRequest.getString(pUrl);
  pLista = jsonDecode(Data);

  for (var item in pLista) {
    OrdenMP pItem = OrdenMP.FromMap(item);
    ListaOrdenPP.add(pItem);
  }

  Data = await HttpRequest.getString(pUrl, onProgress: null);
  DespliegaEntidad(POrdenProduccion);
  pUrl = '$pHost/rest/ordenp/obtener_producido_orden/$AId';

  Data = await HttpRequest.getString(pUrl);
  //print("Producido");
  //print(Data);
  pLista = jsonDecode(Data);
  double pTotalProducido = 0.0;

  for (Map item in pLista) {
    print(item);
    var pProduccion = Produccion.fromMap(item);

    print("Modo calculo:");
    print(POrdenProduccion.modo_calculo);

    if (POrdenProduccion.modo_calculo == "Diferencia") {
      print("Diferencia");
      pProduccion.importe_maquila = pProduccion.costo_maquila * (pProduccion.producido - SurtidoTotal);
    }

    pTotalProgramado += pProduccion.programado;
    pTotalCajas += pProduccion.cajas;
    pTotalCostoMaquila += pProduccion.costo_maquila;
    pTotalImporteMaquila += pProduccion.importe_maquila;
    pTotalValorRescate += pProduccion.valor_rescate;
    pTotalProducidoT += pProduccion.producido;

    print("----aqui-----");
    print(item);
    if (pProduccion.importe_maquila == 0) {
      pTotalImporteRescate += pProduccion.importe_rescate;
      print("pTotalImporteRescate $pTotalImporteRescate");
    } else {
      pTotalProducido += pProduccion.producido;
      print("pTotalProducido $pTotalProducido");
    }

    if (pProduccion.costo_maquila > 0) {
      String pUrl = "$pHost/rest/ordenp/actualizar_costo_maquila/${pProduccion.id}";
      String pData = '{"costo":${pProduccion.costo_maquila},"importe":${pProduccion.importe_maquila}}';
      Map<String, String> headers = <String, String>{};
      headers["content-type"] = "application/json";

      print('costo maquila');
      print(pData);
      HttpRequest.request(
        pUrl,
        method: "POST",
        responseType: "application/json",
        sendData: pData,
        requestHeaders: headers,
      ).then((HttpRequest ARequest) {
        //print(ARequest.responseText);
      });
    }
  }

  Future.delayed(Duration(seconds: 2)).then((_) async{    
    var pTotalImporteM = 0.0;
    var pTotalProduccionConCostoDeMaquila = 0.0;

    for (Map item in pLista) {
      var pProduccion = Produccion.fromMap(item);

      print("pTotalImporteMaquila $pTotalImporteMaquila");
      print("pTotalImporte $pTotalImporte");
      print("pTotalImporteRescate $pTotalImporteRescate");
      print("pTotalProducido $pTotalProducido");

      pTotalCostoEmpaque = await obtenerCostoEmpaque(int.parse(ObtenerIdOrden()));
      print("pTotalCostoEmpaque $pTotalCostoEmpaque");
      //spanTotalCostoEmpaque.text = pTotalCostoEmpaque.toString();
      spanTotalCostoEmpaque.text = intl.NumberFormat("#,##0.00",).format(pTotalCostoEmpaque);
      //spanTotalSuma.text = (pTotalCostoEmpaque + pTotalImporteMaquila).toString();
      spanTotalSuma.text = intl.NumberFormat("#,##0.00",).format(pTotalCostoEmpaque + pTotalImporteMaquila);

      if (pProduccion.costo_maquila == 0) {
        pProduccion.costo_pto_terminado = pProduccion.valor_rescate;
      } else {
        pProduccion.costo_pto_terminado = ((pTotalImporteMaquila + pTotalImporte) - pTotalImporteRescate) / (pTotalProducido);
        pTotalProduccionConCostoDeMaquila += pProduccion.producido;
      }

      pProduccion.importe = pProduccion.producido * pProduccion.costo_pto_terminado;
      pTotalImporteM += pProduccion.importe;
      ListaProduccion.add(pProduccion);
    }

    print("-- Producción con Maquila ----");
    print(pTotalProduccionConCostoDeMaquila);
    print("------");

    var pProductosConCostoMaquila = ListaProduccion.where((item) => item.costo_maquila > 0).toList();

    print("-- Productos con costo de Maquila ----");
    pProductosConCostoMaquila.forEach((item) {
      print("${item.clave_producto} - ${item.producido}");
    });
    print("------");

    print('--- Total Importe---');
    print(pTotalImporte);
    print('----');

    print('--- Total Costo Empaque---');
    print(pTotalCostoEmpaque);
    print('----');
    
    var pImporteProductosSinCostoMaquila = 0.0;
    ListaProduccion.where((item) => item.costo_maquila == 0).forEach((item) {
      pImporteProductosSinCostoMaquila += item.importe;
    });
    
    print('--- Total Producido sin Maquila---');
    print(pImporteProductosSinCostoMaquila);
    print('----');

    var pCostoProrrateo = (pTotalImporte + pTotalCostoEmpaque) - pImporteProductosSinCostoMaquila;

    print('--- Total Costo prorrateo---');
    print(pCostoProrrateo);
    print('----');

    print("-- Prorrateo ----");
    pProductosConCostoMaquila.forEach((item) {
      var pPorProrrateo = item.producido / pTotalProduccionConCostoDeMaquila;
      print("${item.clave_producto} - ${pPorProrrateo}");
      var pCostoFinal = pPorProrrateo * pCostoProrrateo;
      print("${item.clave_producto} - ${pCostoFinal}");

      var pSumaCostoFinal = pCostoFinal + item.importe_maquila;
      item.importe_final = pSumaCostoFinal;
      print("pSumaCostoFinal: ${item.clave_producto} - ${pSumaCostoFinal}");
    });
    print("------");

    ListaProduccion.where((item) => item.costo_maquila == 0).forEach((item) {
      item.importe_final += item.importe;
    });

    var pTotalImporteFinal = 0.0;
    for (var item in ListaProduccion) {
      pTotalImporteFinal += item.importe_final;
      agregaFilaProducido(item);
    }

    spamTotalImporteFinal.text = intl.NumberFormat("#,##0.00",).format(pTotalImporteFinal);

    (document.querySelector("#TotalProgramado") as SpanElement).innerHtml = intl.NumberFormat(
      "#,##0.00",
    ).format(pTotalProgramado);
    (document.querySelector("#TotalProducido") as SpanElement).innerHtml = intl.NumberFormat(
      "#,##0.00",
    ).format(pTotalProducidoT);
    (document.querySelector("#TotalCajas") as SpanElement).innerHtml = pTotalCajas.toString();
    (document.querySelector("#TotalCostoMaquila") as SpanElement).innerHtml = intl.NumberFormat(
      "#,##0.00",
    ).format(pTotalCostoMaquila);
    (document.querySelector("#TotalImporteMaquila") as SpanElement).innerHtml = intl.NumberFormat(
      "#,##0.00",
    ).format(pTotalImporteMaquila);
    (document.querySelector("#TotalValorRescate") as SpanElement).innerHtml = intl.NumberFormat(
      "#,##0.00",
    ).format(pTotalValorRescate);
    (document.querySelector("#TotalImporteRescate") as SpanElement).innerHtml = intl.NumberFormat(
      "#,##0.00",
    ).format(pTotalImporteRescate);
    (document.querySelector("#TotalImporte") as SpanElement).innerHtml = intl.NumberFormat(
      "#,##0.00",
    ).format(pTotalImporteM);

    /*for (Produccion item in ListaProduccion) {
      try {
        item.porcentaje = (item.producido / SurtidoTotal) * 100;
      } catch (ex) {
        item.porcentaje = 0.0;
      }
    }*/
  });
}

Future refrescaTablaProducido() async{    
  var pTotalImporteM = 0.0;
  var pTotalProduccionConCostoDeMaquila = 0.0;
  var pTotalProducido = 0.0;

  for (var pProduccion in ListaProduccion) {
    print("pTotalImporteMaquila $pTotalImporteMaquila");
    print("pTotalImporte $pTotalImporte");
    print("pTotalImporteRescate $pTotalImporteRescate");
    print("pTotalProducido $pTotalProducido");

    //pTotalCostoEmpaque = await obtenerCostoEmpaque(int.parse(ObtenerIdOrden()));
    print("pTotalCostoEmpaque $pTotalCostoEmpaque");
    //spanTotalCostoEmpaque.text = pTotalCostoEmpaque.toString();
    spanTotalCostoEmpaque.text = intl.NumberFormat("#,##0.00",).format(pTotalCostoEmpaque);
    //spanTotalSuma.text = (pTotalCostoEmpaque + pTotalImporteMaquila).toString();
    spanTotalSuma.text = intl.NumberFormat("#,##0.00",).format(pTotalCostoEmpaque + pTotalImporteMaquila);

    if (pProduccion.costo_maquila == 0) {
    //  pProduccion.costo_pto_terminado = pProduccion.valor_rescate;
    } else {
      //pProduccion.costo_pto_terminado = ((pTotalImporteMaquila + pTotalImporte) - pTotalImporteRescate) / (pTotalProducido);
      pTotalProduccionConCostoDeMaquila += pProduccion.producido;
    }

    /*pProduccion.importe = pProduccion.producido * pProduccion.costo_pto_terminado;*/
    pTotalImporteM += pProduccion.importe;
  }

  print("-- Producción con Maquila ----");
  print(pTotalProduccionConCostoDeMaquila);
  print("------");

  var pProductosConCostoMaquila = ListaProduccion.where((item) => item.costo_maquila > 0).toList();

  print("-- Productos con costo de Maquila ----");
  pProductosConCostoMaquila.forEach((item) {
    print("${item.clave_producto} - ${item.producido}");
  });
  print("------");

  print('--- Total Importe---');
  print(pTotalImporte);
  print('----');

  print('--- Total Costo Empaque---');
  print(pTotalCostoEmpaque);
  print('----');
  
  var pImporteProductosSinCostoMaquila = 0.0;
  ListaProduccion.where((item) => item.costo_maquila == 0).forEach((item) {
    pImporteProductosSinCostoMaquila += item.importe;
  });
  
  print('--- Total Producido sin Maquila---');
  print(pImporteProductosSinCostoMaquila);
  print('----');

  var pCostoProrrateo = (pTotalImporte + pTotalCostoEmpaque) - pImporteProductosSinCostoMaquila;

  print('--- Total Costo prorrateo---');
  print(pCostoProrrateo);
  print('----');

  print("-- Prorrateo ----");
  pProductosConCostoMaquila.forEach((item) {
    var pPorProrrateo = item.producido / pTotalProduccionConCostoDeMaquila;
    print("${item.clave_producto} - ${pPorProrrateo}");
    var pCostoFinal = pPorProrrateo * pCostoProrrateo;
    print("${item.clave_producto} - ${pCostoFinal}");

    var pSumaCostoFinal = pCostoFinal + item.importe_maquila;
    item.importe_final = pSumaCostoFinal;
    print("pSumaCostoFinal: ${item.clave_producto} - ${pSumaCostoFinal}");
  });
  print("------");

  TableElement tableMP = querySelector("#tablaProducido") as TableElement;
  tableMP.tBodies[0].children.clear();

  var pTotalImporteFinal = 0.0;
  for (var item in ListaProduccion) {
    pTotalImporteFinal += item.importe_final;
    agregaFilaProducido(item);
  }

  spamTotalImporteFinal.text = intl.NumberFormat("#,##0.00",).format(pTotalImporteFinal);

  (document.querySelector("#TotalProducido") as SpanElement).innerHtml = intl.NumberFormat(
    "#,##0.00",
  ).format(pTotalProducidoT);
  (document.querySelector("#TotalCajas") as SpanElement).innerHtml = pTotalCajas.toString();
  (document.querySelector("#TotalCostoMaquila") as SpanElement).innerHtml = intl.NumberFormat(
    "#,##0.00",
  ).format(pTotalCostoMaquila);
  (document.querySelector("#TotalImporteMaquila") as SpanElement).innerHtml = intl.NumberFormat(
    "#,##0.00",
  ).format(pTotalImporteMaquila);
  (document.querySelector("#TotalValorRescate") as SpanElement).innerHtml = intl.NumberFormat(
    "#,##0.00",
  ).format(pTotalValorRescate);
  (document.querySelector("#TotalImporteRescate") as SpanElement).innerHtml = intl.NumberFormat(
    "#,##0.00",
  ).format(pTotalImporteRescate);
  (document.querySelector("#TotalImporte") as SpanElement).innerHtml = intl.NumberFormat(
    "#,##0.00",
  ).format(pTotalImporteM);
}

void ocultaBotones() {
  (document.querySelector("#btnSalida") as ButtonElement).style.display = "none";
  (document.querySelector("#btnGeneraSalida") as ButtonElement).style.display = "none";
}

void DespliegaEntidad(OrdenProduccion AOrdenProduccion) {
  (document.querySelector("#spanId") as SpanElement).text = AOrdenProduccion.id.toString();
  (document.querySelector("#id_orden") as InputElement).value = AOrdenProduccion.descripcion;
  (document.querySelector("#fecha") as InputElement).value = AOrdenProduccion.fecha;
  (document.querySelector("#lote_produccion") as InputElement).value = AOrdenProduccion.lote_produccion.toString();
  (document.querySelector("#spanEstado") as SpanElement).text = AOrdenProduccion.estado;
  (document.querySelector("#spanFolioSalida") as SpanElement).text = ",Salida: ${AOrdenProduccion.id_salida}";

  if (AOrdenProduccion.estado == "Surtido") {
    (document.querySelector("#btnSalida") as ButtonElement).text = "Cerrar";
  }

  if (AOrdenProduccion.estado == "Autorizado") {
    (document.querySelector("#btnSalida") as ButtonElement).text = "Abrir";

    (document.querySelector("#btnGeneraSalida") as ButtonElement).classes.remove("hiden");
    //(document.querySelector("#btnGeneraPoliza") as ButtonElement).classes.remove("hiden");
  }

  if (AOrdenProduccion.estado == "Generado" || AOrdenProduccion.estado == "Finalizado") {
    (document.querySelector("#btnSalida") as ButtonElement).classes.add("hiden");
  }

  if (AOrdenProduccion.estado == "Generado" || AOrdenProduccion.estado == "Finalizado") {
    (document.querySelector("#btnSalida") as ButtonElement).classes.add("hiden");
  }

  if (AOrdenProduccion.estado == "Generado") {
    (document.querySelector("#btnEntrada") as ButtonElement).classes.remove("hiden");
  }

  if (!editable) {
    ocultaBotones();
  }
}

OrdenProduccion ObtenerEntidad() {
  OrdenProduccion pOrdenProduccion = OrdenProduccion();
  pOrdenProduccion.id = int.parse((querySelector("#id") as HiddenInputElement).value!);
  pOrdenProduccion.id_usuario = int.parse((querySelector("#id_usuario") as HiddenInputElement).value!);
  print("id_usuario: ${pOrdenProduccion.id_usuario}");
  pOrdenProduccion.id_tipo = int.parse((querySelector("#id_tipo") as HiddenInputElement).value!);
  pOrdenProduccion.descripcion = (querySelector("#id_orden") as InputElement).value!;
  pOrdenProduccion.fecha = (querySelector("#fecha") as InputElement).value!;
  pOrdenProduccion.lote_produccion = (querySelector("#lote_produccion") as InputElement).value!;
  pOrdenProduccion.estado = (document.querySelector("#spanEstado") as SpanElement).text!;

  return pOrdenProduccion;
}

Future programaOrdenProduccion() async {
  if (window.confirm("¿Programar la orden de producción?") == false) {
    return;
  }

  Map pParametros = {};

  String pProductos = "";
  for (OrdenMP item in ListaOrdenPP) {
    pProductos += "${item.producto},";
  }

  pProductos = pProductos.substring(0, pProductos.length - 1);

  var pUrl = '$pHost/rest/ordenp/programar_orden';
  String pData =
      "lote=${POrdenProduccion.lote_produccion.toString()}&productos=$pProductos&fecha=${POrdenProduccion.fecha}&id_orden=${POrdenProduccion.id.toString()}&id_usuario=${(querySelector("#id_usuario") as HiddenInputElement).value}";
  print(pData);

  Map<String, String> headers = <String, String>{};
  headers["content-type"] = "application/json";

  var ARequest = await HttpRequest.request(
    pUrl,
    method: "POST",
    responseType: "application/json",
    sendData: pData,
    requestHeaders: headers,
  );
  print(ARequest.responseText);
  Map pResult = jsonDecode(ARequest.responseText!);

  if (pResult["id"] == 0) {
    window.alert(pResult["mensaje"]);
  } else {
    POrdenProduccion.estado = "Programado";
    POrdenProduccion.id_programacion = pResult["id"];
    (document.querySelector("#spanEstado") as SpanElement).text = "Programado";
    (document.querySelector("#btnSalida") as ButtonElement).text = "DesProgramar";
    window.alert("Se programo la orden con éxito");
  }
}

Future desprogramaOrdenProduccion() async {
  if (window.confirm("¿Desprogramar la orden de producción?") == false) {
    return;
  }

  Map pParametros = {};

  String pProductos = "";
  for (OrdenMP item in ListaOrdenPP) {
    pProductos += "${item.producto},";
  }

  pProductos = pProductos.substring(0, pProductos.length - 1);

  var pUrl = '$pHost/rest/ordenp/desprogramar_orden';
  String pData =
      "id_orden=${POrdenProduccion.id.toString()}&id_programacion=${POrdenProduccion.id_programacion.toString()}";
  print(pData);

  Map<String, String> headers = <String, String>{};
  headers["content-type"] = "application/json";

  var ARequest = await HttpRequest.request(
    pUrl,
    method: "POST",
    responseType: "application/json",
    sendData: pData,
    requestHeaders: headers,
  );
  print(ARequest.responseText);
  Map pResult = jsonDecode(ARequest.responseText!);

  if (pResult["id"] == 0) {
    window.alert(pResult["mensaje"]);
  } else {
    POrdenProduccion.estado = "Surtido";
    (document.querySelector("#spanEstado") as SpanElement).text = "Surtido";
    (document.querySelector("#btnSalida") as ButtonElement).text = "Programar";
    window.alert("Se desprogramo la orden con éxito");
  }
}

Future cerrarOrdenProduccion() async {
  if (window.confirm("¿Cerrar la orden de producción?")) {
    Map pParametros = {};

    String pData = jsonEncode(pParametros);
    String pUrl = '$pHost/rest/ordenp/ordenmp_cerrar/$IdOrden';
    print(pUrl);
    Map<String, String> headers = <String, String>{};
    headers["content-type"] = "application/json";

    var request = await HttpRequest.request(pUrl, method: "PUT", requestHeaders: headers, sendData: pData);
    print(request.responseText);
    Map pResult = jsonDecode(request.responseText!);
    print(pResult['result'].toString());
    if (pResult['result'] == 0) {
      window.alert("Se cerro con éxito");

      String pFecha = "";
      var pLista = window.location.search!.split("&");
      pLista = pLista[1].split("=");
      pFecha = pLista[1];

      window.location.href = "/ordenes_produccion?fecha=$pFecha";
    } else {
      print(pResult['mensaje'].toString());
      window.alert(pResult['mensaje'].toString());
    }
  }
}

Future abrirOrdenProduccion() async {
  if (window.confirm("¿Abrir la orden de producción?")) {
    Map pParametros = {};

    String pData = jsonEncode(pParametros);
    String pUrl = '$pHost/rest/ordenp/ordenmp_abrir/$IdOrden';
    print(pUrl);
    Map<String, String> headers = <String, String>{};
    headers["content-type"] = "application/json";

    var request = await HttpRequest.request(pUrl, method: "PUT", requestHeaders: headers, sendData: pData);
    print(request.responseText);
    Map pResult = jsonDecode(request.responseText!);
    print(pResult['result'].toString());
    if (pResult['result'] == 0) {
      window.alert("Se abrió con éxito");
      String pFecha = "";
      var pLista = window.location.search!.split("&");
      pLista = pLista[1].split("=");
      pFecha = pLista[1];
      window.location.href = "/ordenes_produccion?fecha=$pFecha";
    } else {
      print(pResult['mensaje'].toString());
      window.alert(pResult['mensaje'].toString());
    }
  }
}

Future guardar() async {
  String pFecha = "";
  var pLista = window.location.search!.split("&");
  pLista = pLista[1].split("=");
  pFecha = pLista[1];

  if (POrdenProduccion.estado == "Surtido") {
    await cerrarOrdenProduccion();
  } else if (POrdenProduccion.estado == "Cerrado") {
    await abrirOrdenProduccion();
  } else {
    if (window.confirm("¿Crear salida para orden de producción?")) {
      int pCajasPendientes = await obtenerCajasPendientes(IdOrden);

      if (pCajasPendientes > 0) {
        await ModalP.showDialog(
          "No se puede crear una salida porque hay $pCajasPendientes cajas pendientes en esta orden",
          "Error",
          ModalP.TDialogType.ERROR,
          ModalP.TDialogButtons.OK,
        );
        return;
      }

      Map pParametros = {};
      pParametros["id_usuario_embarques"] = (querySelector("#id_usuario_embarques") as HiddenInputElement).value;
      pParametros["id_salida_embarques"] = FolioSalida;

      String pData = jsonEncode(pParametros);
      String pUrl = '$pHost/rest/ordenp/ordenmp_surtir/$IdOrden';
      print(pUrl);
      Map<String, String> headers = <String, String>{};
      headers["content-type"] = "application/json";

      var request = await HttpRequest.request(pUrl, method: "PUT", requestHeaders: headers, sendData: pData);
      print(request.responseText);
      Map pResult = jsonDecode(request.responseText!);
      print(pResult['result'].toString());
      if (pResult['result'] == 0) {
        window.alert("Se genero la salida ${pResult['salida'].toString()}");
        window.location.href = "/ordenes_produccion?fecha=$pFecha";
      } else {
        print(pResult['mensaje'].toString());
        window.alert(pResult['mensaje'].toString());
      }
    }
  }
}

void cancelar() {
  if (window.confirm("¿Cancelar captura?")) {
    String pFecha = "";
    var pLista = window.location.search!.split("&");
    pLista = pLista[1].split("=");
    pFecha = pLista[1];

    window.location.href = "/ordenes_produccion?fecha=$pFecha";
  }
}

void capturaValorRescate(Produccion item) {
  if (!editable) {
    window.alert("No tiene derecho a modificar");
    return;
  }

  ModalP.showModal("#mdlValorRescate");
  (document.querySelector("#inpValorRescate") as InputElement).focus();

  ButtonElement btnElement = (document.querySelector("#btnValorRescateAceptar") as ButtonElement);

  if (EventoValorRescate != null) {
    EventoValorRescate!.cancel();
  }

  btnElement.onClick.listen((_) async {
    var pUrl = "$pHost/rest/ordenp/actualiza_valor_rescate";
    Map pMap = {};

    double pValorRescate = 0.0;

    try {
      pValorRescate = double.parse((querySelector("#inpValorRescate") as InputElement).value!);
    } catch (Exception) {
      pValorRescate = -1.0;
    }

    if (pValorRescate < 0) {
      window.alert("Valor de rescato no es válido");
      (querySelector("#inpValorRescate") as InputElement).focus();
      return;
    }

    pMap["valor_rescate"] = pValorRescate.toDouble();
    pMap["id_orden"] = item.id;

    String pData = jsonEncode(pMap);

    await HttpRequest.request(pUrl, method: "POST", sendData: pData);
    item.valor_rescate = pValorRescate;
    item.importe_rescate = pValorRescate * item.producido;
    ModalP.cierraModal("#mdlValorRescate");
    actualizaFilaProduccion(item);
  });
}

void GuardaValorRescate() {}

Future seleccionar_salida() async {
  OrdenMP pOrdenPP = OrdenMP();

  pOrdenPP.producto = (querySelector("#pClave") as InputElement).value!;
  pOrdenPP.descripcion = (querySelector("#pDescripcion") as InputElement).value!;
  pOrdenPP.kilos = double.parse((querySelector("#pKilos") as InputElement).value!);

  if (pOrdenPP.descripcion.trim().isEmpty) {
    window.alert("El producto no es válido");
    //(querySelector("#inpClave")).focus();
    return;
  }

  if (pOrdenPP.kilos <= 0) {
    window.alert("Los kilos no son válidos");
    //querySelector("#pKilos").focus();
    return;
  }

  FolioSalida = (querySelector("#pClave") as InputElement).value!;

  (querySelector("#pClave") as InputElement).value = "";
  (querySelector("#pDescripcion") as InputElement).value = "";
  (querySelector("#pKilos") as InputElement).value = "0.0";

  //document.querySelector("#mdlAgregarProductos").tagName.hide();

  String pUrl = "/embarques/obtener_detalle_productos_salida/$FolioSalida";

  var Data = await HttpRequest.getString(pUrl);
  var pLista = jsonDecode(Data);

  for (var item in pLista) {
    OrdenMP pOrdenMp = ListaOrdenPMP.where((OrdenMP x) => x.producto == item["producto"]).toList()[0];

    if (pOrdenMp != null) {
      pOrdenMp.surtido = item["kilos"];
    }
  }
}

void eliminar_produccion(item) {
  if (window.confirm("¿Eliminar Producción?")) {
    ListaOrdenPMP.remove(item);
  }
}

Future despliega_salida() async {
  String pSalida = (querySelector("#pClave") as InputElement).value!;
  String pUrl = "/embarques/obtener_salida/$pSalida";

  var data = await HttpRequest.getString(pUrl);
  var pMap = jsonDecode(data);

  if (pMap["codigo"] != "0") {
    (querySelector("#pDescripcion") as InputElement).value = pMap["concepto"];
    (querySelector("#pKilos") as InputElement).value = intl.NumberFormat("###0.00").format(pMap["kilos"]);
  } else {
    window.alert("No existe la salida");
    //document.querySelector("#pClave").focus();
  }
}

Future despliega_producto_mp() async {
  String pProducto = (querySelector("#mClave") as InputElement).value!;
  String pUrl = "$pHost/rest/productos/obtener_descripcion/$pProducto";

  var data = await HttpRequest.getString(pUrl);
  var pMap = jsonDecode(data);

  String pCodigo = pMap["clave"];

  if (pMap["clave"] != "0") {
    (querySelector("#mDescripcion") as InputElement).value = pMap["descripcion"];
  } else {
    window.alert("No existe el producto");
    //document.querySelector("#mClave").focus();
  }
}

void detalleOrden(OrdenMP AOrdenMP) {
  if (!editable) {
    window.alert("No tiene derecho a modificar");
    return;
  }

  ModalP.showModal("#mdlAgregarCosto");

  (querySelector("#mCosto") as InputElement).value = intl.NumberFormat("###,0.00").format(AOrdenMP.costo_salida);
  (document.querySelector("#mCosto") as InputElement).select();
  (document.querySelector("#mCosto") as InputElement).focus();

  bool pError = false;

  ButtonElement btnElement = (document.querySelector("#btnCostoAceptar") as ButtonElement);

  if (EventoCostoSalida != null) {
    EventoCostoSalida!.cancel();
  }

  EventoCostoSalida = btnElement.onClick.listen((_) async {
    AOrdenMP.costo_salida = double.parse((querySelector("#mCosto") as InputElement).value!) ?? 0.0;
    if (!pError) {
      AOrdenMP.importe_salida = AOrdenMP.surtido * AOrdenMP.costo_salida;

      String pUrl = "$pHost/rest/ordenp/actualizar_costo_salida/${AOrdenMP.id}";
      String pData = '{"costo":${AOrdenMP.costo_salida},"importe":${AOrdenMP.importe_salida}}';
      Map<String, String> headers = <String, String>{};
      headers["content-type"] = "application/json";

      await HttpRequest.request(
        pUrl,
        method: "POST",
        responseType: "application/json",
        sendData: pData,
        requestHeaders: headers,
      );
      actualizaFilaMPrima(AOrdenMP);

      double pTotalCosto = 0.0;
      double pTotalImporte = 0.0;

      for (OrdenMP item in ListaOrdenPMP) {
        pTotalCosto += item.costo_salida;
        pTotalImporte += item.importe_salida;
      }

      (document.querySelector("#TotalCostoP") as SpanElement).innerHtml = intl.NumberFormat(
        "###,0.00",
      ).format(pTotalCosto);
      (document.querySelector("#TotalImporteP") as SpanElement).innerHtml = intl.NumberFormat(
        "###,0.00",
      ).format(pTotalImporte);

      ModalP.cierraModal("#mdlAgregarCosto");
    }
  });
}

Future detalleProducido(Produccion AProduccion) async {
  print('aqui...');
  var pUrl = "$pHost/tabla_detalle_producto_orden/$IdOrden/${AProduccion.clave_producto}";

  var Data = await HttpRequest.getString(pUrl);
  (document.querySelector("#divDetalleProducido") as DivElement).innerHtml = Data;
  ModalP.showModal("#mdlDetalleProducido");
}

void costoMaquila(Produccion AProduccion) {
  if (!editable) {
    window.alert("No tiene derecho a modificar");
    return;
  }

  ModalP.showModal("#mdlCostoMaquila");
  (querySelector("#mCostoMaquila") as InputElement).value = intl.NumberFormat(
    "###,0.00",
  ).format(AProduccion.costo_maquila);
  (querySelector("#mCostoMaquila") as InputElement).select();
  (querySelector("#mCostoMaquila") as InputElement).focus();

  bool pError = false;

  ButtonElement btnElement = (document.querySelector("#btnCostoMaquilaAceptar") as ButtonElement);

  if (EventoCostoMaquila != null) {
    EventoCostoMaquila!.cancel();
  }

  EventoCostoMaquila = btnElement.onClick.listen((_) async {
    AProduccion.costo_maquila = double.parse((querySelector("#mCostoMaquila") as InputElement).value!);

    if (!pError) {
      AProduccion.importe_maquila = AProduccion.producido * AProduccion.costo_maquila;

      String pUrl = "$pHost/rest/ordenp/actualizar_costo_maquila/${AProduccion.id}";
      String pData = '{"costo":${AProduccion.costo_maquila},"importe":${AProduccion.importe_maquila}}';
      Map<String, String> headers = <String, String>{};
      headers["content-type"] = "application/json";

      await HttpRequest.request(
        pUrl,
        method: "POST",
        responseType: "application/json",
        sendData: pData,
        requestHeaders: headers,
      );
      double pTotalCosto = 0.0;
      double pTotalImporte = 0.0;

      for (Produccion item in ListaProduccion) {
        pTotalCosto += item.costo_maquila;
        pTotalImporte += item.importe_maquila;
      }

      (document.querySelector("#TotalCostoMaquila") as SpanElement).innerHtml = intl.NumberFormat(
        "###,0.00",
      ).format(pTotalCosto);
      (document.querySelector("#TotalImporteMaquila") as SpanElement).innerHtml = intl.NumberFormat(
        "###,0.00",
      ).format(pTotalImporte);

      ModalP.cierraModal("#mdlCostoMaquila");

      actualizaFilaProduccion(AProduccion);
    }
  });
}

void agregarFilaDetalladoTarima(DetalleMP item) {
  TableElement tablaDetalladoTarima = (querySelector("#tablaDetalladoTarima") as TableElement);
  TableRowElement tr = TableRowElement();

  TableCellElement td =
      TableCellElement()
        ..text = item.tarimaOrigen.toString()
        ..style.textAlign = "center";
  tr.children.add(td);
  td =
      TableCellElement()
        ..text = item.producto
        ..style.textAlign = "center";
  tr.children.add(td);
  td =
      TableCellElement()
        ..text = item.codigoBarras
        ..style.textAlign = "center";
  tr.children.add(td);
  td =
      TableCellElement()
        ..text = intl.NumberFormat("#,##0.00").format(item.peso)
        ..style.textAlign = "right";
  tr.children.add(td);

  tablaDetalladoTarima.tBodies[0].children.add(tr);
}

Future detalladoTarima(int ATarima) async {
  var pUrl = "$pHost/rest/ordenp/obtener_detalle_mp_ordenp_tarima/$IdOrden/${ATarima.toString()}";
  print(pUrl);

  var Data = await HttpRequest.getString(pUrl);
  print(Data);

  List pLista = jsonDecode(Data);

  ListaDetalle.clear();

  TableElement tablaDetalladoTarima = (querySelector("#tablaDetalladoTarima") as TableElement);
  tablaDetalladoTarima.tBodies[0].children.clear();

  for (Map item in pLista) {
    DetalleMP pItem = DetalleMP.fromMAP(item);
    ListaDetalle.add(pItem);
    agregarFilaDetalladoTarima(pItem);
  }

  ModalP.showModal("#divDetalladoTarima");
}

void agregarFilaDetalleTarima(DetalleMPTarima item) {
  TableElement tableDetalleTarima = (querySelector("#tableDetalleTarima") as TableElement);
  TableRowElement tr = TableRowElement();

  TableCellElement td =
      TableCellElement()
        ..text = item.tarimaOrigen.toString()
        ..style.textAlign = "center";
  tr.children.add(td);

  AnchorElement anchorCajas = (Element.html("<a href=\"#\">${item.cajas.toString()}</a>") as AnchorElement);

  anchorCajas.onClick.listen((_) async {
    print('detallado...');
    await detalladoTarima(item.tarimaOrigen);
  });

  td =
      TableCellElement()
        ..children.add(anchorCajas)
        ..style.textAlign = "right";
  tr.children.add(td);
  td =
      TableCellElement()
        ..text = intl.NumberFormat("#,##0.00").format(item.kilos)
        ..style.textAlign = "right";
  tr.children.add(td);

  tableDetalleTarima.tBodies[0].children.add(tr);
}

Future detalleOrdenTarima() async {
  var pUrl = "$pHost/rest/ordenp/obtener_detalle_mp_ordenp_agrupado/$IdOrden";
  print(pUrl);

  ListaDetalleTarima.clear();

  var Data = await HttpRequest.getString(pUrl);
  print(Data);

  List pLista = jsonDecode(Data);

  print("limpiando lista");

  TableElement tableDetalleTarima = (querySelector("#tableDetalleTarima") as TableElement);
  tableDetalleTarima.tBodies[0].children.clear();

  for (Map item in pLista) {
    var pDetalleTarima = DetalleMPTarima.fromMAP(item);
    ListaDetalleTarima.add(pDetalleTarima);
    agregarFilaDetalleTarima(pDetalleTarima);
  }

  print(ListaDetalleTarima.length);

  ModalP.showModal("#divDetalleTarima");
}

void cerrarDetalle() {
  (document.querySelector("#divDetalle") as DivElement).classes.toggle("oculto", true);
}

void cerrarDetalleTarima() {
  ModalP.cierraModal("#divDetalleTarima");
}

void cerrarDetalladoTarima() {
  (document.querySelector("#divDetalladoTarima") as DivElement).classes.toggle("oculto", true);
}

void imprimir() {
  window.open("$pHost/get_surtido_orden/$IdOrden", "surtido", "width: 400; heigth: 400px;");
}

Future ActualizaSaldosSap() async {
  if (window.confirm("¿Actualizar saldos?")) {
    String pUrl = "";

    for (OrdenMP item in ListaOrdenPMP) {
      pUrl =
          "http://172.17.1.22:8045/WebFrontEnd/inventarios/ObtenerSaldoProducto?AProducto=${item.codigosap}&AAlmacen=01&AConexion=SolesProd";
      print(pUrl);

      var Data = await HttpRequest.getString(pUrl);
      print(Data);
      Map pMap = jsonDecode(Data);
      item.saldo_sap = pMap['saldo'].toDouble();

      Map<String, String> headers = <String, String>{};
      headers["content-type"] = "application/json";

      String pUrlPost = "$pHost/rest/ordenp/actualiza_saldo_sap/${item.id}";
      print(pUrlPost);
      await HttpRequest.request(
        pUrlPost,
        method: "POST",
        responseType: "application/json",
        sendData: Data,
        requestHeaders: headers,
      );

      actualizaFilaMPrima(item);
      print('Fin');
    }
  }
}

Future ActualizaCostoSap() async {
  print('Actualizando costo sap...');
  String pUrl = "";

  for (OrdenMP item in ListaOrdenPMP) {
    if (item.surtido > 0) {
      pUrl =
          "http://172.17.1.22:8045/WebFrontEnd/inventarios/ObtenerCostoLineaSalida?Orden=${IdOrden.toString()}&Producto=${item.codigosap}&Empresa=SolesProd";

      print(pUrl);

      var Data = await HttpRequest.getString(pUrl);
      double pCosto = jsonDecode(Data).toDouble();
      item.costo_salida = pCosto;
      item.importe_salida = pCosto * item.surtido;

      actualizaFilaMPrima(item);

      Map<String, String> headers = <String, String>{};
      headers["content-type"] = "application/json";

      String pData = '{"costo":"${pCosto.toDouble()}", "importe":"${item.importe_salida.toDouble()}"';

      String pUrlPost = "$pHost/rest/ordenp/actualiza_costo_linea_sap/${item.id}";
      await HttpRequest.request(
        pUrlPost,
        method: "POST",
        responseType: "application/json",
        sendData: pData,
        requestHeaders: headers,
      );
    }
  }

  var pUrlCosto =
      "http://172.17.1.22:8045/WebFrontEnd/inventarios/ObtenerCostoSalida?Orden=${IdOrden.toString()}&Cuenta=11100030001&Empresa=SolesProd";
  print(pUrlCosto);

  var Data = await HttpRequest.getString(pUrlCosto);
  double pCosto = jsonDecode(Data);
  POrdenProduccion.costo_salida = pCosto;
  (document.querySelector("#TotalImporteP") as SpanElement).innerHtml = intl.NumberFormat("###,0.00").format(pCosto);

  pUrl = "$pHost/rest/ordenp/actualizar_costo_salida_orden/${IdOrden.toString()}";
  String pData = '{"costo": "${pCosto.toString()}" }';
  Map<String, String> headers = <String, String>{};
  headers["content-type"] = "application/json";

  await HttpRequest.request(
    pUrl,
    method: "POST",
    responseType: "application/json",
    sendData: pData,
    requestHeaders: headers,
  );
}

Future GeneraSalidaSap() async {
  print("Generando salida");

  String pPassword = (querySelector("#mPassword") as InputElement).value!;

  if (pPassword != inpPassword.value) {
    window.alert("Contraseña incorrecta");
    (document.querySelector("#mPassword") as PasswordInputElement).focus();
    return;
  }

  ModalP.cierraModal("#mdlPassword");
  (document.querySelector("#btnGeneraSalida") as ButtonElement).disabled = true;

  SalidaInventario pSalidaInventario = SalidaInventario();

  pSalidaInventario.Comments = POrdenProduccion.descripcion;
  pSalidaInventario.DocDate = (document.querySelector("#fecha") as InputElement).value!;
  pSalidaInventario.TaxDate = pSalidaInventario.DocDate;
  pSalidaInventario.OrdenProduccion = IdOrden;
  pSalidaInventario.Reference2 = IdOrden.toString();
  pSalidaInventario.Series = "102";
  pSalidaInventario.FolioSalida = POrdenProduccion.id_salida;

  for (OrdenMP item in ListaOrdenPMP) {
    print(item.producto);
    print(item.surtido);

    if (item.surtido > 0 && item.codigosap.trim().isNotEmpty) {
      LineaSalidaInventario pLinea = LineaSalidaInventario();
      pLinea.ItemCode = item.codigosap;
      pLinea.AccountCode = "11100010060";
      pLinea.Quantity = item.surtido;
      pLinea.WarehouseCode = "01";
      pLinea.CostingCode = "PL1";
      pLinea.LineTotal = item.surtido;

      pSalidaInventario.Lineas.add(pLinea);
    }
  }

  print("Lineas: ${pSalidaInventario.Lineas}");

  var pUrl = "http://172.17.1.22:8045/webfrontend/inventarios/CrearSalida";
  Map<String, String> headers = <String, String>{};

  String Data = pSalidaInventario.toJSON();

  print("Data");
  print(Data);

  var pRequest = await HttpRequest.request(
    pUrl,
    method: "POST",
    responseType: "application/json",
    sendData: Data,
    requestHeaders: headers,
  );
  print("-================================================-");
  print(pRequest.responseText);

  Map pMapResult = jsonDecode(pRequest.responseText!);

  await ModalP.showDialog(pMapResult["Mensaje"], "Crear Salida", ModalP.TDialogType.INFO, ModalP.TDialogButtons.OK);

  
  if (pMapResult["Folio"] == "1") {
    (document.querySelector("#btnGeneraSalida") as ButtonElement).classes.add("hiden");
    (document.querySelector("#btnSalida") as ButtonElement).classes.add("hiden");

    String pUrl = '$pHost/rest/ordenp/ordenmp_generar/$IdOrden';
    POrdenProduccion.estado = "Generado";
    (document.querySelector("#spanEstado") as SpanElement).text = "Generado";

    var pReq = await HttpRequest.request(pUrl, method: "PUT", responseType: "application/json");
    print(pReq.responseText);
    await ActualizaCostoSap();
    if (window.confirm("¿Generar Poliza?")) {
      var pCounter = 1;
      bool pResultGenera = false;
      while (pCounter <= 5) {
        if (pTotalCostoEmpaque > 0) {
          pResultGenera = await GeneraPolizaSapEmpaque();
        } else {
          pResultGenera = await GeneraPolizaSap();
        }
        if (pResultGenera) {
          pCounter = 100;
        } else {
          pCounter++;
          await Future.delayed(Duration(seconds: 3));
        }
      }
    }
  } else {
    (document.querySelector("#btnGeneraSalida") as ButtonElement).disabled = false;
  }
}

Future<bool> GeneraPolizaSap() async {
  try {
    var pMemo = "Orden de prod: $IdOrden, Fecha: ${POrdenProduccion.fecha}";
    var pUrl =
        "http://172.17.5.21:8042/api/FacturasSAP/NuevaPolizaContable?Orden=$IdOrden&CuentaCredito=21030010025&ImporteCredito=${pTotalImporteMaquila.toStringAsFixed(2)}&CuentaDebito=11100010060&ImporteDebito=${pTotalImporteMaquila.toStringAsFixed(2)}&Memo=$pMemo&Fecha=${POrdenProduccion.fecha}&Usuario=${(querySelector("#id_usuario") as HiddenInputElement).value}&NombreConexion=SolesProd";
    var Data = await HttpRequest.getString(pUrl);
    window.alert(Data);
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> GeneraPolizaSapEmpaque() async {
  try {
    var pImporte = pTotalImporteMaquila + pTotalCostoEmpaque;
    var pMemo = "Orden de prod: $IdOrden, Fecha: ${POrdenProduccion.fecha}";
    var pUrl =
        "http://172.17.5.21:8042/api/FacturasSAP/NuevaPolizaContableEmpaque?Orden=$IdOrden&CuentaCredito=21030010025&ImporteCredito=${pTotalImporteMaquila.toStringAsFixed(2)}&CuentaCredito2=21030010029&ImporteCredito2=${pTotalCostoEmpaque.toStringAsFixed(2)}&CuentaDebito=11100010060&ImporteDebito=${pImporte.toStringAsFixed(2)}&Memo=$pMemo&Fecha=${POrdenProduccion.fecha}&Usuario=${(querySelector("#id_usuario") as HiddenInputElement).value}&NombreConexion=Soles_PRODD";

    var Data = await HttpRequest.getString(pUrl);
    window.alert(Data);
    return true;
  } catch (_) {
    return false;
  }
}

void PidePassword() {
  if (POrdenProduccion.estado != "Autorizado") {
    window.alert("La orden debe estar autorizada");
    return;
  }

  if (!window.confirm("¿Generar Salida en SAP?")) {
    return;
  }

  ModalP.showModal("#mdlPassword");
  (document.querySelector("#mPassword") as PasswordInputElement).focus();
}

void PidePassword2() {
  if (POrdenProduccion.estado != "Generado") {
    window.alert("La orden debe estar generada");
    return;
  }

  if (!window.confirm("¿Generar Entrada en SAP?")) {
    return;
  }

  ModalP.showModal("#mdlPassword2");
  (document.querySelector("#mPassword2") as PasswordInputElement).focus();
}

Future GeneraEntradaSap() async {
  String pPassword = (querySelector("#mPassword2") as PasswordInputElement).value!;

  if (pPassword != inpPassword.value) {
    window.alert("Contraseña incorrecta");
    (document.querySelector("#mPassword2") as PasswordInputElement).focus();
    return;
  }

  ModalP.cierraModal("#mdlPassword2");
  (document.querySelector("#btnEntrada") as ButtonElement).disabled = true;

  SalidaInventario pSalidaInventario = SalidaInventario();

  pSalidaInventario.Comments = POrdenProduccion.descripcion;
  pSalidaInventario.DocDate = (document.querySelector("#fecha") as InputElement).value!;
  pSalidaInventario.TaxDate = pSalidaInventario.DocDate;
  pSalidaInventario.OrdenProduccion = IdOrden;
  pSalidaInventario.Reference2 = IdOrden.toString();
  pSalidaInventario.Series = "103";
  pSalidaInventario.FolioSalida = POrdenProduccion.id_salida;

  for (Produccion item in ListaProduccion) {
    if (item.producido > 0) {
      LineaSalidaInventario pLinea = LineaSalidaInventario();
      pLinea.ItemCode = item.codigosap;
      pLinea.AccountCode = "11100010060";
      pLinea.Quantity = item.producido;
      pLinea.WarehouseCode = "01";
      pLinea.CostingCode = "PL1";

      if (item.costo_maquila > 0) {
        pLinea.LineTotal = item.importe_final;
      } else {
        pLinea.LineTotal = item.importe_rescate;
      }

      pSalidaInventario.Lineas.add(pLinea);
    }
  }

  var pUrl = "http://172.17.1.22:8045/webfrontend/inventarios/CrearEntrada";
  Map<String, String> headers = <String, String>{};
  headers["content-type"] = "application/json";

  var Data = pSalidaInventario.toJSON();

  print("---------");
  print(pUrl);
  print(Data);
  print("---------");

  var pRequest = await HttpRequest.request(
    pUrl,
    method: "POST",
    responseType: "application/json",
    sendData: Data,
    requestHeaders: headers,
  );
  print("-================================================-");
  print(pRequest.responseText);

  Map pMapResult = jsonDecode(pRequest.responseText!);

  window.alert(pMapResult["Mensaje"]);

  if (pMapResult["Folio"] == "1") {
    (document.querySelector("#btnEntrada") as ButtonElement).classes.add("hiden");
    (document.querySelector("#btnSalida") as ButtonElement).classes.add("hiden");

    String pUrl = '$pHost/rest/ordenp/ordenmp_finalizar/$IdOrden';
    POrdenProduccion.estado = "Generado";
    (document.querySelector("#spanEstado") as SpanElement).text = "Finalizado";

    HttpRequest.request(pUrl, method: "PUT", responseType: "application/json")
        .then((HttpRequest pReq) {
          print(pReq.responseText);
        })
        .then(
          (HttpRequest pRequest) {
                //ActualizaCostoSap();
              }
              as FutureOr Function(Null value),
        );
  } else {
    (document.querySelector("#btnEntrada") as ButtonElement).disabled = false;
  }
}

Future refrescarSurtido() async {
  if (window.confirm("¿Refrescar surtido?")) {
    var pUrl = "$pHost/rest/refresca_surtido_orden/${ObtenerIdOrden()}";
    print(pUrl);
    await HttpRequest.request(pUrl, method: "POST", sendData: ObtenerIdOrden());
    window.location.reload();
  }
}

Future main() async {
  print("Iniciando:");

  HiddenInputElement pInpEditable = document.querySelector("#inpEditable") as HiddenInputElement;
  editable = pInpEditable.value == "true";

  await ObtenerOrdenProduccion(ObtenerIdOrden());

  ButtonElement btnCerrarDetalleCosto = (querySelector("#btn1") as ButtonElement);
  btnCerrarDetalleCosto.onClick.listen((_) {
    ModalP.cierraModal("#mdlAgregarCosto");
  });

  AnchorElement anchorDetalleOrdenTarima = querySelector("#anchorDetalleOrdenTarima") as AnchorElement;
  anchorDetalleOrdenTarima.onClick.listen((_) {
    detalleOrdenTarima();
  });

  ButtonElement btnCerrarDetalleTarima = (querySelector("#btnCerrarDetalleTarima") as ButtonElement);
  btnCerrarDetalleTarima.onClick.listen((_) {
    cerrarDetalleTarima();
  });

  ButtonElement cerrarDetalledoCajaTarima = (querySelector("#cerrarDetalladoCajaTarima") as ButtonElement);
  cerrarDetalledoCajaTarima.onClick.listen((_) {
    ModalP.cierraModal("#divDetalladoTarima");
  });

  ButtonElement btnImprimir = (querySelector("#btnImprimir") as ButtonElement);
  btnImprimir.onClick.listen((_) {
    imprimir();
  });

  AnchorElement anchorSaldoSap = querySelector("#anchorSaldoSap") as AnchorElement;
  anchorSaldoSap.onClick.listen((_) async {
    await ActualizaSaldosSap();
  });

  ButtonElement btnGeneraSalida = (querySelector("#btnGeneraSalida") as ButtonElement);
  btnGeneraSalida.onClick.listen((_) {
    PidePassword();
  });

  ButtonElement btnCerrarPassword = (querySelector("#btnCerrarPassword") as ButtonElement);
  btnCerrarPassword.onClick.listen((_) {
    ModalP.cierraModal("#mdlPassword");
  });

  ButtonElement btnCerrarPassword2 = (querySelector("#btnCerrarPassword2") as ButtonElement);
  btnCerrarPassword2.onClick.listen((_) {
    ModalP.cierraModal("#mdlPassword");
  });

  ButtonElement btnPasswordAceptar = (querySelector("#btnPasswordAceptar") as ButtonElement);
  btnPasswordAceptar.onClick.listen((_) {
    btnPasswordAceptar.disabled = true;
    GeneraSalidaSap();
    btnPasswordAceptar.disabled = false;
  });

  ButtonElement btnCerrarDetalleProducidoAceptar = (querySelector("#btnProducidoAceptar") as ButtonElement);
  btnCerrarDetalleProducidoAceptar.onClick.listen((_) {
    ModalP.cierraModal("#mdlDetalleProducido");
  });

  ButtonElement btnCerrarDetalleProducido = (querySelector("#btnCerrarDetalleProducido") as ButtonElement);
  btnCerrarDetalleProducido.onClick.listen((_) {
    ModalP.cierraModal("#mdlDetalleProducido");
  });

  ButtonElement btnCerrarDetalleProducido2 = (querySelector("#btnCerrarDetalleProducido2") as ButtonElement);
  btnCerrarDetalleProducido2.onClick.listen((_) {
    ModalP.cierraModal("#mdlDetalleProducido");
  });

  ButtonElement btnCerrarValorRescate = (querySelector("#btnCerrarValorRescate") as ButtonElement);
  btnCerrarValorRescate.onClick.listen((_) {
    ModalP.cierraModal("#mdlValorRescate");
  });

  ButtonElement btnCerrarValorRescate2 = (querySelector("#btnCerrarValorRescate2") as ButtonElement);
  btnCerrarValorRescate2.onClick.listen((_) {
    ModalP.cierraModal("#mdlValorRescate");
  });

  ButtonElement btnPasswordAceptar2 = (querySelector("#btnPasswordAceptar2") as ButtonElement);
  btnPasswordAceptar2.onClick.listen((_) async {
    await GeneraEntradaSap();
  });

  ButtonElement btnCerrarMdlPassword = (querySelector("#btnCerrarMdlPassword") as ButtonElement);
  btnCerrarMdlPassword.onClick.listen((_) {
    ModalP.cierraModal("#mdlPassword2");
  });

  ButtonElement btnCerrarMdlPassword2 = (querySelector("#btnCerrarMdlPassword2") as ButtonElement);
  btnCerrarMdlPassword2.onClick.listen((_) {
    ModalP.cierraModal("#mdlPassword2");
  });

  ButtonElement btnSalida =
      (querySelector("#btnSalida") as ButtonElement)
        ..onClick.listen((_) async {
          await guardar();
        });

  ButtonElement btnCancelarTodo =
      querySelector("#btnCancelarTodo") as ButtonElement
        ..onClick.listen((_) {
          cancelar();
        });

  ButtonElement btnCrearEntrada =
      querySelector("#btnEntrada") as ButtonElement
        ..onClick.listen((_) {
          PidePassword2();
        });

  querySelector("#mdlCostoMaquila-cerrar1") as ButtonElement
    ..onClick.listen((_) {
      ModalP.cierraModal("#mdlCostoMaquila");
    });

  querySelector("#mdlCostoMaquila-cerrar2") as ButtonElement
    ..onClick.listen((_) {
      ModalP.cierraModal("#mdlCostoMaquila");
    });

  ButtonElement btnRefrescarSurtido =
      querySelector("#btnRefrescarSurtido") as ButtonElement
        ..onClick.listen((_) async {
          await refrescarSurtido();
        });

  /*document.querySelector("#mdlAgregarProductos").classes.remove("hiden");
    document.querySelector("#mdlAgregarCosto").classes.remove("hiden");
    document.querySelector("#mdlCostoMaquila").classes.remove("hiden");
    document.querySelector("#mdlPassword").classes.remove("hiden");
    document.querySelector("#mdlPassword2").classes.remove("hiden");
    document.querySelector("#mdlDetalleProducido").classes.remove("hiden");
    document.querySelector("#mdlValorRescate").classes.remove("hiden");*/

  spanTotalCostoEmpaque.onClick.listen((_) async{
      var pTexto = await ModalP.inputText(spanTotalCostoEmpaque.text ?? "0.00", "Costo de Empaque") ?? spanTotalCostoEmpaque.text;

      if (pTexto != "-1" && pTexto!.isNotEmpty) {
        pTotalCostoEmpaque = double.parse(pTexto.replaceAll(",", ""));
        spanTotalCostoEmpaque.text = intl.NumberFormat("#,##0.00",).format(pTotalCostoEmpaque);
        await actualizaCostoEmpaque(int.parse(ObtenerIdOrden()), pTotalCostoEmpaque);
        var pTotalCosto = pTotalImporteMaquila + pTotalCostoEmpaque;
        spanTotalSuma.text = intl.NumberFormat("###0.00").format(pTotalCosto);
        refrescaTablaProducido();
      }

  });
  Timer.run(() => (document.querySelector("#id_orden") as InputElement).focus());
 
}
