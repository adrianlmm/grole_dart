// ignore_for_file: non_constant_identifier_names, avoid_init_to_null, avoid_single_cascade_in_expression_statements, unnecessary_brace_in_string_interps, prefer_is_empty, unnecessary_string_interpolations

import 'package:web/web.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart' as intl;
import 'qdialogs.dart' as quickdialogs;
import 'package:http/http.dart' as http;

int idOrdenSalida = 0;
String lastErrorMessage = "";
var Detalle = <Map>[];
int indice = 9999;
StreamSubscription? EventoBotonEditar = null;
var pNumberFormat = intl.NumberFormat("#,##0.00");
HTMLInputElement inpClavePtoTarima = document.querySelector("#inpClavePtoTarima") as HTMLInputElement;
HTMLInputElement btnCosultarTarimas = document.querySelector("#btnCosultarTarimas") as HTMLInputElement;
HTMLInputElement btnCancelarCosultarTarimas = document.querySelector("#btnCancelarCosultarTarimas") as HTMLInputElement;
HTMLInputElement inpNombrePtoTarima = document.querySelector("#inpNombrePtoTarima") as HTMLInputElement;
HTMLSelectElement inpCamaras = document.querySelector("#inpCamaras") as HTMLSelectElement;
final HTMLSelectElement inpTipo = document.querySelector("#inpTipo") as HTMLSelectElement;
final HTMLInputElement inpPesoCamion = document.querySelector("#inpPesoCamion") as HTMLInputElement;
final HTMLInputElement inpTarima1 = document.querySelector("#inpTarima1") as HTMLInputElement;
final HTMLInputElement inpTarima2 = document.querySelector("#inpTarima2") as HTMLInputElement;
final HTMLSelectElement inpDiasProduccion = document.querySelector("#inpDiasProduccion") as HTMLSelectElement;
HTMLTableElement tablaConsultaTarimas = document.querySelector("#tablaConsultaTarimas") as HTMLTableElement;
final HTMLSelectElement inpClienteMaquila = document.querySelector("#inpClienteMaquila") as HTMLSelectElement;
final HTMLSelectElement inpDestino = document.querySelector("#inpDestino") as HTMLSelectElement;
final HTMLSelectElement inpClaseSalida = document.querySelector("#inpClaseSalida") as HTMLSelectElement;
final HTMLSelectElement inpValidaRangoProduccion = document.querySelector("#inpValidaRangoProduccion") as HTMLSelectElement;
final HTMLInputElement inpFechaRangoInicial = document.querySelector("#inpFechaRangoInicial") as HTMLInputElement;
final HTMLInputElement inpFechaRangoFinal = document.querySelector("#inpFechaRangoFinal") as HTMLInputElement;
final HTMLInputElement inpDiasProduccionLinea = document.querySelector("#inpDiasProduccionLinea") as HTMLInputElement;
final HTMLInputElement inpComentarios = document.querySelector("#inpComentarios") as HTMLInputElement;
final HTMLInputElement inpNumeroTIF = document.querySelector("#inpNumeroTIF") as HTMLInputElement;
final HTMLInputElement inpCorreoEnvio = document.querySelector("#inpCorreoEnvio") as HTMLInputElement;
final HTMLInputElement inpPuedeEditar = document.querySelector("#inpPuedeEditar") as HTMLInputElement;
final HTMLInputElement inpFolio = document.querySelector("#inpFolio") as HTMLInputElement;
final HTMLInputElement inpPuedeCerrar = document.querySelector("#inpPuedeCerrar") as HTMLInputElement;
List<dynamic> ListaTarimas = <dynamic>[];
intl.NumberFormat nf = intl.NumberFormat("###,###.00");
var pSpamCumplimiento = document.querySelector('#spanCumplimiento') as HTMLSpanElement;

final HTMLButtonElement btnCorreo = document.querySelector('#btnCorreo') as HTMLButtonElement;

StreamSubscription? EventoBotonAceptarCorreo = null;
StreamSubscription? EventoBotonCancelarCorreo = null;

String gMotivo = '';
//String pUrlServicios = 'http://192.168.10.240:9990';
//String pUrlServicios = 'http://localhost:8031';
String pUrlServicios = '';
HTMLButtonElement btnPrueba = document.querySelector("#btnPrueba") as HTMLButtonElement;

Future<dynamic> obtenerClientesMaquila() async {
  print('1aa');
  Completer<dynamic> pCompleter = Completer<dynamic>();
  var pUrl = "$pUrlServicios/obtener_clientes_maquila";
  print('1bb');

  var pResponse = await http.get(Uri.parse(pUrl));
  print(pResponse.body);
  print('1cc');

  pCompleter.complete(jsonDecode(pResponse.body));
  print('1dd');

  return pCompleter.future;
}

Future<dynamic> obtenerClasesSalidas() async {
  print('2aa');
  Completer<dynamic> pCompleter = Completer<dynamic>();

  var pUrl = "$pUrlServicios/api/clases_salidas";
  print('2bb');

  var pResponse = await http.get(Uri.parse(pUrl));

  print('2cc');

  var pResult = jsonDecode(pResponse.body);
  print(pResult);
  print('2dd');
  pResult.sort((s, d) => (s["nombre"].toString().toUpperCase().compareTo(d["nombre"].toString().toUpperCase())));
  print('2ee');

  pCompleter.complete(pResult);
  print('2ff');

  return pCompleter.future;
}

Future<dynamic> obtenerClientes(String AMercado) async {
  var pUrl = "$pUrlServicios/rest/salidas/get_clientes/$AMercado";
  var pResponse = await http.get(Uri.parse(pUrl));

  return jsonDecode(pResponse.body);
}

llenaSelectClientesMaquila() async {
  print('1a');
  var pListaClientesMaquila = await obtenerClientesMaquila();
  print(pListaClientesMaquila);
  print('1b');

  for (Map item in pListaClientesMaquila) {
    print('1c');
    var pOptionElement = HTMLOptionElement();
    pOptionElement.value = item["id"].toString();
    print('1e');
    pOptionElement.text = item['nombre'];
    print('1f');
    inpClienteMaquila.appendChild(pOptionElement);
  }
  print('1e');
}

llenaClaseSalidas() async {
  print('2a');
  var pClaseSalidas = await obtenerClasesSalidas();
  print('2b');

  for (Map item in pClaseSalidas) {
    print('2c');
    var pOptionElement = HTMLOptionElement();
    pOptionElement.value = item["id"].toString();
    pOptionElement.text = item['nombre'];
    inpClaseSalida.appendChild(pOptionElement);
  }
  print('2e');
}

llenaClientes() async {
  var pMercado = (document.querySelector("#inpTipo") as HTMLSelectElement).value;
  HTMLSelectElement pDestinoTmp = (document.querySelector("#inpDestino") as HTMLSelectElement);
  var pClientes = await obtenerClientes(pMercado);

  pDestinoTmp.children.clear();

  pClientes.forEach((item) {
    var pOptionElement = HTMLOptionElement();
    pOptionElement.value = item["id"].toString();
    pOptionElement.text = item['nombre'];
    pDestinoTmp.appendChild(pOptionElement);
  });
}

Future<Map> capturaCorreo() async {
  var pResult = {};

  Completer<Map> pCompleter = Completer<Map>();

  quickdialogs.showModal('#mdlEnviaCorreo');

  var btnAceptarCorreo = document.querySelector('#btnAceptarCorreo') as HTMLButtonElement;
  var btnCancelarCorreo = document.querySelector('#btnCancelarCorreo') as HTMLButtonElement;
  var inpCorreo = document.querySelector("#inpCorreo") as HTMLInputElement;
  var inpCuerpo = document.querySelector('#inpCuerpo') as HTMLInputElement;

  inpCorreo.focus();
  inpCuerpo.value = 'Salida de embarques orden $idOrdenSalida';

  EventoBotonAceptarCorreo = btnAceptarCorreo.onClick.listen((event) async {
    if (inpCorreo.value.isEmpty) {
      await quickdialogs.showDialogWeb('El correo no puede estar vacío', 'Error', quickdialogs.TDialogType.ERROR, quickdialogs.TDialogButtons.OK);
      inpCorreo.focus();
      return;
    }

    pResult['correo'] = inpCorreo.value;
    pResult['cuerpo'] = inpCuerpo.value;
    EventoBotonAceptarCorreo!.cancel();
    EventoBotonCancelarCorreo!.cancel();
    quickdialogs.cierraModal("#mdlEnviaCorreo");
    pCompleter.complete(pResult);
  });

  EventoBotonCancelarCorreo = btnCancelarCorreo.onClick.listen((event) {
    pResult['correo'] = '';
    pResult['cuerpo'] = '';
    EventoBotonAceptarCorreo!.cancel();
    EventoBotonCancelarCorreo!.cancel();
    quickdialogs.cierraModal("#mdlEnviaCorreo");
    pCompleter.complete(pResult);
  });

  return pCompleter.future;
}

Future enviaCorreo(int AId, Map ADatosCorreo) async {
  var pUrl = 'https://consultasap.soles.com.mx/webfrontend/ConsultaOrdenesSalidaAutorizadas/ObtenerPDFSalidaGrole?Id=$AId&Destinatario=${ADatosCorreo['correo']}&Cuerpo=${ADatosCorreo['cuerpo']}';
  print(pUrl);
  await http.get(Uri.parse(pUrl));
}

void agregaFila(Map AItem, {bool AEditable = true}) {
  Detalle.add(AItem);

  HTMLTableElement pTabla = document.querySelector("#tablaDetalle") as HTMLTableElement;
  HTMLTableRowElement tr = HTMLTableRowElement()..id = "tr${AItem['id']}";

  var td = document.createTableCell()..text = AItem['producto'];
  tr.appendChild(td);
  td = document.createTableCell()..text = AItem['descripcion'];
  tr.appendChild(td);
  td = document.createTableCell()
    ..text = AItem['cajas'].toString()
    ..style.textAlign = "right";
  tr.appendChild(td);
  td = document.createTableCell()
    ..text = pNumberFormat.format(AItem['kilos'])
    ..style.textAlign = "right";
  tr.appendChild(td);
  td = document.createTableCell()
    ..text = AItem['cajas_surtidas'].toString()
    ..style.textAlign = "right";
  tr.appendChild(td);
  td = document.createTableCell()
    ..text = pNumberFormat.format(AItem['kilos_surtidos'])
    ..style.textAlign = "right";
  tr.appendChild(td);
  print(AItem['dias_produccion']);
  td = document.createTableCell()
    ..text = AItem['dias_produccion'].toString()
    ..style.textAlign = "right";
  tr.appendChild(td);

  double pCumplimiento = (AItem['cajas_surtidas'] / AItem['cajas']) * 100;
  String pCumplimientoS = "${pNumberFormat.format(pCumplimiento)}%";

  td = document.createTableCell()
    ..text = pCumplimientoS
    ..style.textAlign = "right";
  tr.appendChild(td);

  td = document.createTableCell()
    ..text = pNumberFormat.format(AItem['peso_bruto'] - AItem["kilos_surtidos"])
    ..style.textAlign = "right";
  tr.appendChild(td);

  if (AEditable) {
    var btnEliminar = HTMLButtonElement();
    btnEliminar.classList.add('btn');
    btnEliminar.classList.add('icon-trash');
    btnEliminar.onClick.listen((_) {
      if (AItem["cajas_surtidas"] == 0) {
        if (window.confirm("¿Eliminar registro?")) {
          Detalle.removeWhere((Map x) => x["id"] == AItem["id"]);
          tr.remove();
        }
      } else {
        print("No se puede eliminar el registro porque tiene cajas surtidas");
        window.alert("No se puede eliminar el registro porque tiene cajas surtidas");
      }
    });
    btnEliminar.style.marginLeft = "5px";

    td = document.createTableCell()..appendChild(btnEliminar);

    var btnEditar = HTMLButtonElement();
    btnEditar.classList.add('btn');
    btnEditar.classList.add('icon-edit');
    btnEditar.onClick.listen((_) async {
      var pMapaTmp = Detalle.where((Map x) => x["id"] == AItem["id"]).toList().first;

      print(pMapaTmp);

      despliegaProducto(pMapaTmp);
      quickdialogs.showModal("#mdlEditar");
      (document.querySelector("#inpCajasEdicion") as HTMLInputElement).focus();
      (document.querySelector("#inpCajasEdicion") as HTMLInputElement).select();

      if (EventoBotonEditar != null) {
        await EventoBotonEditar!.cancel();
      }

      HTMLInputElement btnEditarProducto = document.querySelector("#btnEditarProducto") as HTMLInputElement;

      EventoBotonEditar = btnEditarProducto.onClick.listen((_) {
        int pCajas = 0;
        double pKilos = 0.0;

        try {
          pCajas = int.parse((document.querySelector("#inpCajasEdicion") as HTMLInputElement).value);
        } catch (_) {
          pCajas = -1;
        }

        try {
          pKilos = double.parse((document.querySelector("#inpKilosEdicion") as HTMLInputElement).value);
        } catch (_) {
          pKilos = -1.0;
        }

        if (pCajas < 0) {
          window.alert("Error, el número de cajas no es válido");
          (document.querySelector("#inpCajasEdicion") as HTMLInputElement).focus();
          return;
        }

        if (pKilos < 0) {
          window.alert("Error, el número de kilos no es válido");
          (document.querySelector("#inpKilosEdicion") as HTMLInputElement).focus();
          return;
        }

        if (pCajas > 0 && pKilos > 0) {
          window.alert("Error, solo uno cajas o kilos puede ser mayor a cero, ambos no");
          (document.querySelector("#inpCajasEdicion") as HTMLInputElement).focus();
          return;
        }

        if (pCajas == 0 && pKilos == 0) {
          window.alert("Error, debe poner cajas o kilos con un valor mayor a cero");
          (document.querySelector("#inpCajasEdicion") as HTMLInputElement).focus();
          return;
        }

        int pDiasProduccion = 0;

        try {
          pDiasProduccion = int.parse((document.querySelector("#inpDiasProduccionEdicion") as HTMLInputElement).value);
        } catch (_) {
          pDiasProduccion = 0;
        }

        Map pMapa = Detalle.where((Map x) => x["id"] == AItem["id"]).toList().first;
        pMapa["cajas"] = pCajas;
        pMapa["kilos"] = pKilos;
        pMapa["dias_produccion"] = pDiasProduccion;
        pMapa["valida_rango_produccion"] = (document.querySelector("#inpValidaRangoProduccionEdicion") as HTMLSelectElement).value;
        pMapa["fecha_produccion_inicial"] = (document.querySelector("#inpFechaRangoInicialEdicion") as HTMLInputElement).value;
        pMapa["fecha_produccion_final"] = (document.querySelector("#inpFechaRangoFinalEdicion") as HTMLInputElement).value;

        print(pMapa);
        despliegaProductoFila(pMapa);

        quickdialogs.cierraModal("#mdlEditar");
      });
    });

    btnEditar.style.marginLeft = "5px";

    td.appendChild(btnEditar);
    tr.appendChild(td);
  }

  pTabla.tBodies[0]!.appendChild(tr);
}

void muestraBotonCerrar() {
  (document.querySelector("#btnCerrar") as HTMLButtonElement).style.display = "inline";
}

void ocultaBotonGuardar() {
  (document.querySelector("#btnGuardar") as HTMLButtonElement).style.display = "none";
}

void despliegaEntidad(Map AItem) {
  try{
    print(AItem);

    print('d1');
    (document.querySelector("#inpDestino") as HTMLSelectElement).value = AItem["destino"].toString();
    print('d11');
    (document.querySelector("#inpDescripcion") as HTMLInputElement).value = AItem["descripcion"].toString();
    print('d12');
    (document.querySelector("#inpFechaEmbarque") as HTMLInputElement).value =
        "${(AItem["fecha_embarque"] as String).substring(8, 10)}/${(AItem["fecha_embarque"] as String).substring(5, 7)}/${(AItem["fecha_embarque"] as String).substring(0, 4)}";
    print('d13');
    (document.querySelector("#inpFechaTmp") as HTMLInputElement).value = (document.querySelector("#inpFechaEmbarque") as HTMLInputElement).value;
    print('d4');
    (document.querySelector("#inpValidaProductos") as HTMLSelectElement).value = AItem["valida_productos"];
    print('d5');
    (document.querySelector("#inpClaveCliente") as HTMLInputElement).value = AItem["destino"].toString();
    print('d6');
    (document.querySelector("#spanFolio") as HTMLSpanElement).text = AItem["id"].toString();
    print('d7');
    (document.querySelector("#spanEstado") as HTMLSpanElement).text = AItem["estado"];
    print('d8');
    (document.querySelector("#inpIdUsuario") as HTMLInputElement).text = AItem["id_usuario"].toString();
    print('d9');
    inpTipo.value = AItem["tipo"];
    print('d10');
    inpPesoCamion.value = AItem["peso_camion"].toString();
    print('d11');
    inpTarima1.value = AItem["tarima_1"].toString();
    print('d12');
    inpTarima2.value = AItem["tarima_2"].toString();
    print('d13');
    inpDiasProduccion.value = AItem["dias_produccion"].toString();
    print('d14');
    inpComentarios.value = AItem["comentarios"] ?? "";
    print('d15');
    inpNumeroTIF.value = AItem["numero_tif"] ?? "";
    print('d16');

    if (AItem.containsKey('correo')) {
      inpCorreoEnvio.value = AItem['correo'] ?? "";    
    }
    print('d2');
    try {
      inpClienteMaquila.value = AItem["id_cliente_maquila"].toString();
    } catch (_) {
      inpClienteMaquila.value = "1002";
    }

    if (AItem['estado'] == 'Cerrado') {
      ocultaBotonGuardar();
    }

    if (AItem["tipo"] == "Nacional") {
      var pFolioTmp = int.tryParse(inpFolio.value) ?? 0;
      if (pFolioTmp > 0) {
        if (inpPuedeEditar.value == "No") {
          ocultaBotonGuardar();
        }
      }
    }

    int p_total_cajas = 0;
    int p_total_cajas_surtidas = 0;
    double p_total_kilos = 0.0;
    double p_total_kilos_surtidos = 0.0;
    double p_total_tara = 0.0;

    print('d3');

    for (Map item in AItem['detalle']) {
      if ((item['cajas_surtidas'] > 0 || item['kilos_surtidos'] > 0) && AItem['estado'] != 'Cerrado') {
        muestraBotonCerrar();
      }

      agregaFila(item, AEditable: item["origen"] != "tarima");
      p_total_cajas += int.parse(item['cajas'].toString());
      p_total_cajas_surtidas += int.parse(item['cajas_surtidas'].toString());
      p_total_kilos += item["kilos"];
      p_total_kilos_surtidos += item["kilos_surtidos"];
      p_total_tara += item['peso_bruto'] - item["kilos_surtidos"];
    }

    double p_cumplimiento = (p_total_cajas_surtidas / p_total_cajas) * 100;

    if (p_cumplimiento.isNaN) {
      p_cumplimiento = 0.0;
    }

    print('d4');

    var pCumplimientoS = "${pNumberFormat.format(p_cumplimiento)}%";
    (document.querySelector("#spanCumplimiento") as HTMLSpanElement).text = pCumplimientoS;
    (document.querySelector("#spanTotalCajas") as HTMLSpanElement).text = p_total_cajas.toString();
    (document.querySelector("#spanTotalCajasSurtidas") as HTMLSpanElement).text = p_total_cajas_surtidas.toString();
    (document.querySelector("#spanTotalKilos") as HTMLSpanElement).text = nf.format(p_total_kilos);
    (document.querySelector("#spanTotalKilosSurtidos") as HTMLSpanElement).text = nf.format(p_total_kilos_surtidos);
    (document.querySelector("#spanTotalTara") as HTMLSpanElement).text = nf.format(p_total_tara);

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
    print('d5');
    print(AItem["id_clase_salida"].toString());
    Future.delayed(const Duration(milliseconds: 100), () => inpClaseSalida.value = AItem["id_clase_salida"].toString());
  }catch(e){
    print("Error al desplegar entidad: $e");
  }
}

Future llenaListaTarimasOrden() async {
  try{
  var pUrl = "$pUrlServicios/rest/salidas/obtener_lista_tarimas_orden_salida/$idOrdenSalida";

  var pResponse = await http.get(Uri.parse(pUrl));
  ListaTarimas = jsonDecode(pResponse.body);
  }catch(e){
    print("Error al obtener lista de tarimas: $e");
  }
}

Future obtenerOrdenSalida() async {
  idOrdenSalida = int.parse((document.querySelector("#inpFolio") as HTMLInputElement).value);

  var pUrl = "$pUrlServicios/rest/salidas/orden_salida_obtener/${idOrdenSalida}";

  var pResponse = await http.get(Uri.parse(pUrl));
  Map pOrdenSalida = jsonDecode(pResponse.body);
  print('----');
  print(pOrdenSalida);
  print('----');
  print('xx1');
  despliegaEntidad(pOrdenSalida);
  print('xx2');
  await llenaListaTarimasOrden();
  print('xx3');
}

Map? obtenerEntidad() {
  Map? pResult = {};
  pResult["id"] = idOrdenSalida.toString();
  pResult["descripcion"] = (document.querySelector("#inpDescripcion") as HTMLInputElement).value;
  pResult["fecha_embarque"] = (document.querySelector("#inpFechaEmbarque") as HTMLInputElement).value;
  pResult["valida_productos"] = (document.querySelector("#inpValidaProductos") as HTMLSelectElement).value;
  pResult["destino"] = int.parse((document.querySelector("#inpClaveCliente") as HTMLInputElement).value);
  pResult["id_usuario"] = (document.querySelector("#inpIdUsuario") as HTMLInputElement).value;
  pResult["estado"] = "Nuevo";
  pResult["detalle"] = Detalle;
  pResult["tarimas"] = ListaTarimas;
  pResult["tipo"] = inpTipo.value;

  pResult["peso_camion"] = double.tryParse(inpPesoCamion.value) ?? 0.0;

  pResult["tarima_1"] = int.tryParse(inpTarima1.value) ?? 0;
  pResult["tarima_2"] = int.tryParse(inpTarima2.value) ?? 0;
  pResult["dias_produccion"] = inpDiasProduccion.value;
  pResult["id_cliente_maquila"] = int.parse(inpClienteMaquila.value);
  pResult["id_clase_salida"] = int.parse(inpClaseSalida.value);
  pResult["comentarios"] = inpComentarios.value;
  pResult["numero_tif"] = inpNumeroTIF.value;
  pResult["correo"] = inpCorreoEnvio.value;

  if (pResult["descripcion"].trim().length == 0) {
    pResult = null;
    lastErrorMessage = "Necesita capturar la descripción";
  }

  if (Detalle.isEmpty) {
    pResult = null;
    lastErrorMessage = "No se han capturado producto";
  }

  return pResult;
}

Future guardarOrdenSalida() async {
  var pEntidad = obtenerEntidad();

  print(pEntidad);

  if (pEntidad == null) {
    window.alert(lastErrorMessage);
    return;
  }

  var pUrl = "$pUrlServicios/rest/salidas/orden_salida_insertar";
  var pData = jsonEncode(pEntidad);

  var ARequest = await http.post(Uri.parse(pUrl), body: pData);
  print("Regresando de servidor...");
  print(ARequest.body);
  Map pResult = jsonDecode(ARequest.body);
  window.alert(pResult["mensaje"]);

  if (pResult["error"]) {
    return;
  } else {
    window.location.href = "/salidas";
  }
}

void limpiaEditores() {
  (document.querySelector("#inpProducto") as HTMLInputElement).value = "";
  (document.querySelector("#inpDescripcionProducto") as HTMLInputElement).value = "";
  (document.querySelector("#inpCajas") as HTMLInputElement).value = "1";
  (document.querySelector("#inpKilos") as HTMLInputElement).value = "0";
  (document.querySelector("#inpDiasProduccionLinea") as HTMLInputElement).value = "0";

  DateTime pToday = DateTime.now();
  var pMes = pToday.month.toString().padLeft(2, "0");
  var pDia = pToday.day.toString().padLeft(2, "0");
  inpFechaRangoInicial.value = "$pDia/$pMes/${pToday.year}";
  inpFechaRangoFinal.value = "$pDia/$pMes/${pToday.year}";
}

void despliegaProducto(Map AItem) {
  (document.querySelector("#inpProductoEdicion") as HTMLInputElement).value = AItem["producto"];
  (document.querySelector("#inpDescripcionProductoEdicion") as HTMLInputElement).value = AItem["descripcion"];
  (document.querySelector("#inpCajasEdicion") as HTMLInputElement).value = AItem["cajas"].toString();
  (document.querySelector("#inpKilosEdicion") as HTMLInputElement).value = AItem["kilos"].toString();
  (document.querySelector("#inpDiasProduccionEdicion") as HTMLInputElement).value = AItem["dias_produccion"].toString();
  (document.querySelector("#inpValidaRangoProduccionEdicion") as HTMLSelectElement).value = AItem["valida_rango_produccion"];
  (document.querySelector("#inpFechaRangoInicialEdicion") as HTMLInputElement).value = AItem["fecha_produccion_inicial"];
  (document.querySelector("#inpFechaRangoFinalEdicion") as HTMLInputElement).value = AItem["fecha_produccion_final"];
}

void despliegaProductoFila(Map AItem) {
  print(AItem);
  HTMLTableRowElement tr = (document.querySelector("#tr${AItem["id"]}")) as HTMLTableRowElement;
  (tr.cells[0] as HTMLTableCellElement).text = AItem["producto"];
  (tr.cells[0] as HTMLTableCellElement).text = AItem["descripcion"];
  (tr.cells[0] as HTMLTableCellElement).text = AItem["cajas"].toString();
  (tr.cells[0] as HTMLTableCellElement).text = pNumberFormat.format(AItem["kilos"]);
  (tr.cells[0] as HTMLTableCellElement).text = AItem["dias_produccion"].toString();
  (tr.cells[0] as HTMLTableCellElement).text = pNumberFormat.format(AItem["peso_bruto"] - AItem["kilos"]).toString();
}

void agregar() {
  if (ListaTarimas.isNotEmpty) {
    window.alert("No se pueden agregar productos s ya se agregaron tarimas");
    return;
  }

  limpiaEditores();
  quickdialogs.showModal("#mdlAgregar");
  (document.querySelector("#inpProducto") as HTMLInputElement).focus();
}

Future onBlurProducto() async {
  var pProducto = (document.querySelector("#inpProducto") as HTMLInputElement).value;

  if (pProducto.trim().isNotEmpty) {
    var pUrl = "$pUrlServicios/rest/productos/obtener_descripcion/${pProducto}";

    var pRequest = await http.get(Uri.parse(pUrl));
    var data = pRequest.body;
    var pMap = jsonDecode(data);

    if (pMap["clave"] != "0") {
      (document.querySelector("#inpDescripcionProducto") as HTMLInputElement).value = pMap["descripcion"];
      (document.querySelector("#inpCajas") as HTMLInputElement).focus();
    } else {
      window.alert("No existe el producto");
      (document.querySelector("#inpProducto") as HTMLInputElement).focus();
    }
  }
}

Future onBlurProductoConsultaTarimas() async {
  String pProducto = inpClavePtoTarima.value;

  if (pProducto.trim().length > 0) {
    String pUrl = "$pUrlServicios/rest/productos/obtener_descripcion/${pProducto}";

    var data = await http.get(Uri.parse(pUrl));
    var pMap = jsonDecode(data.body);

    if (pMap["clave"] != "0") {
      inpNombrePtoTarima.value = pMap["descripcion"];
      inpCamaras.focus();
    } else {
      window.alert("No existe el producto");
      inpClavePtoTarima.focus();
      inpNombrePtoTarima.value = "";
    }
  }
}

void agregarProducto() {
  Map pMapa = {};
  pMapa["id"] = indice;
  indice++;
  pMapa["producto"] = (document.querySelector("#inpProducto") as HTMLInputElement).value.trim();
  pMapa["descripcion"] = (document.querySelector("#inpDescripcionProducto") as HTMLInputElement).value;

  try {
    pMapa["cajas"] = int.parse((document.querySelector("#inpCajas") as HTMLInputElement).value);
  } catch (_) {
    pMapa["cajas"] = -1;
  }

  try {
    pMapa["kilos"] = double.parse((document.querySelector("#inpKilos") as HTMLInputElement).value);
  } catch (_) {
    pMapa["kilos"] = -1;
  }

  try {
    pMapa["dias_produccion"] = int.parse((document.querySelector("#inpDiasProduccionLinea") as HTMLInputElement).value);
  } catch (_) {
    pMapa["dias_produccio"] = 0;
  }

  pMapa["cajas_surtidas"] = 0;
  pMapa["kilos_surtidos"] = 0;
  pMapa["peso_bruto"] = 0;

  if (pMapa["producto"].length == 0 || pMapa["producto"] == "") {
    window.alert("Error, el producto no es válido");
    (document.querySelector("#inpCajas") as HTMLInputElement).focus();
    return;
  }

  if (pMapa["cajas"] < 0) {
    window.alert("Error, el número de cajas no es válido");
    (document.querySelector("#inpCajas") as HTMLInputElement).focus();
    return;
  }

  if (pMapa["kilos"] < 0) {
    window.alert("Error, el número de kilos no es válido");
    (document.querySelector("#inpKilos") as HTMLInputElement).focus();
    return;
  }

  if (pMapa["cajas"] > 0 && pMapa["kilos"] > 0) {
    window.alert("Error, solo uno cajas o kilos puede ser mayor a cero, ambos no");
    (document.querySelector("#inpCajas") as HTMLInputElement).focus();
    return;
  }

  if (pMapa["cajas"] == 0 && pMapa["kilos"] == 0) {
    window.alert("Error, debe poner cajas o kilos con un valor mayor a cero");
    (document.querySelector("#inpCajas") as HTMLInputElement).focus();
    return;
  }

  if (Detalle.where((Map x) => x["producto"] == pMapa["producto"]).toList().length > 0) {
    window.alert("Error, el producto ya se encuentra en la lista");
    limpiaEditores();
    (document.querySelector("#inpProducto") as HTMLInputElement).focus();
    return;
  }

  pMapa["valida_rango_produccion"] = inpValidaRangoProduccion.value;
  pMapa["fecha_produccion_inicial"] = inpFechaRangoInicial.value;
  pMapa["fecha_produccion_final"] = inpFechaRangoFinal.value;

  agregaFila(pMapa);
  limpiaEditores();
  (document.querySelector("#inpProducto") as HTMLInputElement).focus();
}

Future<bool> productoSinSurtir() async {
  var pUrl = "$pUrlServicios/rest/productos_sin_surtir/$idOrdenSalida";

  var pRequest = await http.get(Uri.parse(pUrl));
  var pJson = pRequest.body;
  print(pJson);

  Map pData = jsonDecode(pJson);

  if (pData["result"] == 1) {
    print('x1');
    var pInput = await quickdialogs.showDialogWeb(pData["mensaje"] + " ¿Cerrar Orden?", "Cerrar", quickdialogs.TDialogType.ERROR, quickdialogs.TDialogButtons.YES_NO);
    print('x2');

    if (pInput == quickdialogs.TDialogResult.YES) {
      print('x3');
      var pPassword = await quickdialogs.inputText("", "Cerrar", Password: true);
      print('x4');

      if (pPassword == "soles89") {
        print("Correcto");
        return true;
      } else {
        print('x5');
        await quickdialogs.showDialogWeb("Contraseña incorrecta", "Error", quickdialogs.TDialogType.ERROR, quickdialogs.TDialogButtons.OK);
        print('x6');
        return false;
      }
    } else {
      return false;
    }
  } else {
    return false;
  }
}

DateTime strToFecha(String AFecha) {
  var pYear = AFecha.substring(6, 10);
  var pMes = AFecha.substring(3, 5);
  var pDia = AFecha.substring(0, 2);

  print("pYear: ${pYear}, pMes: ${pMes}, pDia: ${pDia}");

  return DateTime(int.parse(pYear), int.parse(pMes), int.parse(pDia));
}

DateTime getFechaActual() {
  DateTime pFechaActual = DateTime.now();
  return DateTime(pFechaActual.year, pFechaActual.month, pFechaActual.day);
}

Future cerrarOrden() async {
  var pCumplimiento = pSpamCumplimiento.innerText.replaceAll('%', '');
  var pCumplimientoD = double.parse(pCumplimiento);

  print(pCumplimientoD);
  print(inpPuedeCerrar.value);
  /*if (pCumplimientoD < 98 && inpPuedeCerrar.value == "No") {
    await quickdialogs.showDialogWeb('El cumplimiento debe ser mínimo 98%', 'Error', quickdialogs.TDialogType.ERROR, quickdialogs.TDialogButtons.OK);
    return;
  }*/
  if (inpPuedeCerrar.value == "No") {
    await quickdialogs.showDialogWeb('El cumplimiento debe ser mínimo 98%', 'Error', quickdialogs.TDialogType.ERROR, quickdialogs.TDialogButtons.OK);
    return;
  }

  String pFecha = (document.getElementById("inpFechaTmp") as HTMLInputElement).value;

  DateTime pFechaTmp = strToFecha(pFecha);
  print(pFechaTmp);

  DateTime pFechaActual = getFechaActual();

  print("fechas");
  print(pFechaTmp);
  print(pFechaActual);

  pFechaTmp.compareTo(pFechaActual);

  if (pFechaTmp.compareTo(pFechaActual) < 0) {
    await quickdialogs.showDialogWeb("No se puede cerrar orden porque la fecha actual y la fecha de embarques no son iguales", "Error", quickdialogs.TDialogType.ERROR, quickdialogs.TDialogButtons.OK);
    return;
  }

  if (window.confirm("¿Cerrar la orden de salida?")) {
    print("Cerrando orden...");
    (document.querySelector("#btnCerrar") as HTMLButtonElement).disabled = true;

    gMotivo = '';
    bool pProductosSinSurtir = await productoSinSurtir();

    print("Cerrando orden 2...");

    print('-----');
    print(pProductosSinSurtir);
    print('-----');

    if (pProductosSinSurtir == true) {
      print('0x');
      var pMotivos = Map<String, String>();
      pMotivos["Key"] = 'Producto no ubicado';
      pMotivos["Key"] = 'Faltante produccion';
      pMotivos["Key"] = 'Retenido por calidad';
      pMotivos["Key"] = 'Sin stock';

      var pLista = <dynamic>[];
      pLista.add({1, 'Producto no ubicado'});
      pLista.add({2, 'Faltante produccion'});
      pLista.add({3, 'Retenido por calidad'});
      pLista.add({4, 'Sin stock'});

      print('1');
      var gMotivo = await quickdialogs.inputText("", "Motivo");
      print('2');

      if (gMotivo == null) {
        (document.querySelector("#btnCerrar") as HTMLButtonElement).disabled = false;
        return;
      }
    }

    var pUrl = "$pUrlServicios/rest/salidas/crear_salida_embarques/${idOrdenSalida}";

    print(pUrl);

    var ARequest = await http.post(Uri.parse(pUrl), body: "_");
    print(ARequest.body);
    (document.querySelector("#btnCerrar") as HTMLButtonElement).disabled = false;

    Map pResult = jsonDecode(ARequest.body);
    window.alert(pResult['mensaje']);

    print(pResult['mensaje']);
    print(pResult["folio_salida"]);
    if ((pResult['mensaje'] as String).contains('exito') && pResult["folio_salida"] == 0) {
      print('Ya tiene');
      (document.querySelector("#btnGuardar") as HTMLButtonElement).style.display = "none";
      (document.querySelector("#btnCerrar") as HTMLButtonElement).style.display = "none";
      (document.querySelector("#spanEstado") as HTMLSpanElement).text = "Cerrado";
    }

    if (pResult["folio_salida"] > 0) {
      var pUrl = "$pUrlServicios/rest/salidas/cambiar_estado?id=${idOrdenSalida}&estado=Cerrado&motivo=${gMotivo}";
      print(pUrl);

      Map pData = {};
      pData['estado'] = "Cerrado";

      ARequest = await http.get(Uri.parse(pUrl));
      (document.querySelector("#btnGuardar") as HTMLButtonElement).style.display = "none";
      (document.querySelector("#btnCerrar") as HTMLButtonElement).style.display = "none";
      (document.querySelector("#spanEstado") as HTMLSpanElement).text = "Cerrado";

      var pDatosCorreo = {'correo': inpCorreoEnvio.value, 'cuerpo': 'Salida de embarques orden $idOrdenSalida'};

      if (pDatosCorreo['correo'].toString() != '' && pDatosCorreo['correo'].toString().contains('@')) {
        await enviaCorreo(pResult["folio_salida"], pDatosCorreo);
      }

      /*if (await ModalP.showDialog('¿Enviar salida por correo?', 'Correo', ModalP.TDialogType.QUESTION, ModalP.TDialogButtons.YES_NO) == ModalP.TDialogResult.YES) {
          var pDatosCorreo = await capturaCorreo();
          if (pDatosCorreo['correo'] != '') {
            await enviaCorreo(pResult["folio_salida"], pDatosCorreo);
          }
        }*/
    }
  }
}

void agregarTarimas() {
  if (ListaTarimas.length == 0 && Detalle.length > 0) {
    window.alert("No se pueden agregar tarimas porque ya existen productos");
    return;
  }

  quickdialogs.showModal("#mdlConsultaTarimas");
  inpClavePtoTarima.focus();
}

Future llenaCamaras() async {
  try{
    var pUrl = "$pUrlServicios/camaras/obtener_lista";

    print(pUrl);
    var pResponse = await http.get(Uri.parse(pUrl));
    print('1x');
    print(pResponse.body);
    print('1xx');
    var pListaCamaras = jsonDecode(pResponse.body);
    print('a');

    for (var item in pListaCamaras) {
      var pOption = HTMLOptionElement();
      pOption.value = item['id'].toString();
      pOption.text = item['descripcion'];
      inpCamaras.appendChild(pOption);
    }
  }catch(e){
    print('Error al cargar cámaras: $e');
  }
}

void agregaTarimaDetalle(Map ATarima) {
  Map? item = null;
  try {
    item = Detalle.where((Map x) => x["producto"] == ATarima["producto"]).toList().first;
  } catch (_) {
    item = null;
  }

  if (item == null) {
    Map pItem = {};
    pItem['id'] = indice;
    indice++;
    pItem["producto"] = ATarima["producto"];
    pItem["descripcion"] = ATarima["descripcion"];
    pItem["cajas"] = ATarima["cajas"];
    pItem["kilos"] = ATarima["kilos"];
    pItem["cajas_surtidas"] = 0;
    pItem["kilos_surtidos"] = 0.0;
    pItem["origen"] = "tarima";
    agregaFila(pItem, AEditable: false);
  } else {
    item["producto"] = ATarima["producto"];
    item["descripcion"] = ATarima["descripcion"];
    item["cajas"] += ATarima["cajas"];
    item["kilos"] += ATarima["kilos"];
    item["origen"] = "tarima";
    despliegaProductoFila(item);
  }
}

void remueveTarimaDetalle(Map ATarima) {
  Map? item = null;
  try {
    item = Detalle.where((Map x) => x["producto"] == ATarima["producto"]).toList().first;
  } catch (_) {
    item = null;
  }

  if (item != null) {
    item["producto"] = ATarima["producto"];
    item["descripcion"] = ATarima["descripcion"];
    item["cajas"] -= ATarima["cajas"];
    item["kilos"] -= ATarima["kilos"];
    despliegaProductoFila(item);

    if (item["cajas"] == 0 && item["kilos"] <= 1.0) {
      Detalle.removeWhere((Map x) => int.parse(x["id"]) == int.parse(item!["id"].toString()));
      HTMLTableRowElement tr = document.querySelector("#tr${item["id"]}") as HTMLTableRowElement;
      tr.remove();
    }
  }
}

Future llenaTablaConsultaTarimas() async {
  tablaConsultaTarimas.tBodies[0]!.children.clear();

  var pUrl = "$pUrlServicios/rest/salidas/obtener_consulta_tarimas/${inpCamaras.value}/${inpClavePtoTarima.value}/${idOrdenSalida}";

  var pRequest = await http.get(Uri.parse(pUrl));
  var Data = pRequest.body;

  var pLista = jsonDecode(Data);

  for (var item in pLista) {
    HTMLTableRowElement tr = HTMLTableRowElement()..id = "trt${item["folio"]}";

    HTMLInputElement chkFolio = HTMLInputElement();

    if (ListaTarimas.where((x) => x == item["folio"]).length > 0) {
      chkFolio.checked = true;
    }

    chkFolio.onClick.listen((_) {
      if (chkFolio.checked) {
        ListaTarimas.add(item["folio"]);
        agregaTarimaDetalle(item);
      } else {
        ListaTarimas.removeWhere((x) => x == item["folio"]);
        remueveTarimaDetalle(item);
      }
    });

    HTMLTableCellElement td = document.createTableCell();
    tr.appendChild(td);
    td = document.createTableCell()..text = "${item["folio"]}";
    tr.appendChild(td);
    td = document.createTableCell()..text = "${item["descripcion"]}";
    tr.appendChild(td);
    td = document.createTableCell()..text = "${item["cajas"]}";
    tr.appendChild(td);
    td = document.createTableCell()..text = "${pNumberFormat.format(item["kilos"])}";
    tr.appendChild(td);
    td = document.createTableCell()..text = "${item["dias_produccion"]}";
    tr.appendChild(td);

    tablaConsultaTarimas.tBodies[0]!.appendChild(tr);
  }
}

Future init() async {
  Completer pCompleter = Completer();

  print("Llenando cámaras...");
  await llenaCamaras();
  print('1');
  await llenaSelectClientesMaquila();
  print('2');
  await llenaClaseSalidas();
  print('3');
  await llenaClientes();
  print('4');

  (document.querySelector("#btnGuardar") as HTMLButtonElement).onClick.listen((_) {
    guardarOrdenSalida();
  });

  (document.querySelector("#btnCancelar") as HTMLButtonElement).onClick.listen((_) {
    if (window.confirm("¿Cancelar captura de salida?")) {
      window.location.href = "/salidas";
    }
  });

  (document.querySelector("#btnAgregar") as HTMLButtonElement).onClick.listen((_) {
    agregar();
  });

  (document.querySelector("#btnAgregarTarimas") as HTMLButtonElement).onClick.listen((_) {
    agregarTarimas();
  });

  btnCosultarTarimas.onClick.listen((_) {
    llenaTablaConsultaTarimas();
  });

  btnCancelarCosultarTarimas.onClick.listen((_) {
    quickdialogs.cierraModal("#mdlConsultaTarimas");
  });

  (document.querySelector("#inpProducto") as HTMLInputElement).onBlur.listen((_) {
    onBlurProducto();
  });

  inpClavePtoTarima.onBlur.listen((_) {
    onBlurProductoConsultaTarimas();
  });

  (document.querySelector("#btnAgregarProducto") as HTMLInputElement).onClick.listen((_) {
    agregarProducto();
  });

  (document.querySelector("#btnCancelarCaptura") as HTMLInputElement).onClick.listen((_) {
    quickdialogs.cierraModal("#mdlAgregar");
  });

  (document.querySelector("#btnCancelarEdicion") as HTMLInputElement).onClick.listen((_) {
    quickdialogs.cierraModal("#mdlEditar");
  });

  (document.querySelector("#btnCerrar") as HTMLButtonElement).onClick.listen((_) async {
    await cerrarOrden();
  });

  inpValidaRangoProduccion.onChange.listen((z) {
    if (inpValidaRangoProduccion.value == "Si") {
      inpDiasProduccionLinea.value = "0";
    }
  });

  
  inpDestino.onChange.listen((x) {
    (document.querySelector("#inpClaveCliente") as HTMLInputElement).value = inpDestino.value;
  });
  pCompleter.complete();
  return pCompleter.future;
}

main() async {
  /*btnPrueba.onClick.listen((event) async {
    var pResult = await inputOptions('Motivo', 'Motivo', <String>['uno', 'dos', 'tres']);
    print(pResult);
  });*/

  print("Inicializando...");
  await init();
  print('6');
  obtenerOrdenSalida();
  print('7');
  inpTipo.onChange.listen((_) async {
    await llenaClientes();
    if (inpTipo.value == "Nacional") {
      var pFolioTmp = int.tryParse(inpFolio.value) ?? 0;
      if (pFolioTmp > 0) {
        if (inpPuedeEditar.value == "No") {
          ocultaBotonGuardar();
        }
      }
    } else {
      (document.querySelector("#btnGuardar") as HTMLButtonElement).style.display = "inline";
    }
  });

  print('8');
  /*btnCorreo.onClick.listen((event) async {
    var pDatosCorreo = await capturaCorreo();
    print(pDatosCorreo);
    if (pDatosCorreo['cuerpo'] != '') {
      await enviaCorreo(111117, pDatosCorreo);
    }
  });*/
  print('9');
}
