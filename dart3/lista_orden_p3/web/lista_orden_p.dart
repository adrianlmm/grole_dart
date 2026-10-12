// ignore_for_file: non_constant_identifier_names, unused_element

import 'dart:html';
import 'dart:convert';
import 'package:intl/intl.dart' as intl;
import 'dart:async';
import 'OrdenProduccion.dart';
import 'package:quickdialogs/quickdialogs.dart' as ModalP;

SelectElement inpClase = querySelector("#inpClase") as SelectElement;
SelectElement inpFiltro = querySelector("#filtro") as SelectElement;
final ButtonElement btnConsultar = querySelector("#btnConsultar") as ButtonElement;
TableElement tablaConsulta = querySelector("#tablaConsulta") as TableElement;
ButtonElement btnCancelarCambioEstado = querySelector("#btnCancelarCambioEstado") as ButtonElement;
ButtonElement btnCerrarModalCambiarEstado = querySelector("#btnCerrarModalCambiarEstado") as ButtonElement;
ButtonElement btnCambiarEstado = querySelector("#btnCambiarEstado") as ButtonElement;
ButtonElement btnBusca = querySelector("#btnBusca") as ButtonElement;
ButtonElement btnCerrarModalBuscar1 = querySelector("#btnCerrarModalBuscar1") as ButtonElement;
ButtonElement btnCerrarModalBuscar2 = querySelector("#btnCerrarModalBuscar2") as ButtonElement;

ButtonElement btnAgregar = querySelector("#btnAgregar") as ButtonElement;
ButtonElement btnBuscar = querySelector("#btnBuscar") as ButtonElement;

ButtonElement inpAutorizar = querySelector("#inpAutorizar") as ButtonElement;

ButtonElement btnCerrarModalAutorizar1 = querySelector("#btnCerrarModalAutorizar1") as ButtonElement;
ButtonElement btnCerrarModalAutorizar2 = querySelector("#btnCerrarModalAutorizar2") as ButtonElement;
ButtonElement btnAutorizar = querySelector("#btnAutorizar") as ButtonElement;
PasswordInputElement inpPassword = querySelector("#inpPassword") as PasswordInputElement;
final SelectElement inpClienteMaquila = querySelector("#inpClienteMaquila") as SelectElement;
final SelectElement inpProcesado = querySelector("#inpProcesado") as SelectElement;
final HiddenInputElement inpUsuario = querySelector("#idUsuario") as HiddenInputElement;
final HiddenInputElement inpResponsableDe = querySelector("#inpResponsableDe") as HiddenInputElement;
final HiddenInputElement inpPuedeCambiarEstado = querySelector('#inpPuedeCambiarEstado') as HiddenInputElement;
var pHost = "";
//var pHost = "http://localhost:8031";

class Clase {
  int Id = 0;
  String Nombre = "";
  String Activo = "";
  bool Selected = false;

  Clase(this.Id, this.Nombre, this.Activo, this.Selected);

  Clase.fromMap(Map AMap) {
    Id = AMap['id'];
    Nombre = AMap['clase'];
    Activo = AMap['activo'];
    Selected = false;
  }
}

List<OrdenProduccion> ListaOrdenP = <OrdenProduccion>[];
List<Clase> ListaClases = <Clase>[];
OrdenProduccion pOrdenProduccion = OrdenProduccion();

String _EstadoTmp = "";
int _IdTmp = 0;

bool editable = false;

Future<List<dynamic>> obtenerClientesMaquila() async {
  Completer<List<dynamic>> pCompleter = Completer<List<dynamic>>();
  var pUrl = "$pHost/obtener_clientes_maquila";

  String pJson = await HttpRequest.getString(pUrl);

  pCompleter.complete(jsonDecode(pJson));

  return pCompleter.future;
}

llenaSelectClientesMaquila() async {
  var pListaClientesMaquila = await obtenerClientesMaquila();

  inpClienteMaquila.children.add(Element.html("<option value='0'>Todos</option>"));

  for (Map item in pListaClientesMaquila) {
    inpClienteMaquila.children.add(Element.html("<option value=${item["id"]}>${item["nombre"]}</option>"));
  }
}

Future<Map> ligarOrdenes(int AFolio) async {
  Completer<Map> pCompleter = Completer<Map>();

  var pUrl = "$pHost/folios_sap_salidas/$AFolio";

  String pResult = await HttpRequest.getString(pUrl);

  Map pData = jsonDecode(pResult);

  pCompleter.complete(pData);

  return pCompleter.future;
}

Future<String> ProcesarOrden(int AIdOrden) async {
  var pUrl = "$pHost/procesar_orden/$AIdOrden";
  var pData = "id=$AIdOrden";

  var pResponse = await HttpRequest.request(pUrl, method: "PUT", sendData: pData);

  return pResponse.responseText!;
}

void autorizar(OrdenProduccion AOrdenProduccion) {
  window.localStorage["IdAuth"] = AOrdenProduccion.id.toString();
  ModalP.showModal("#mdlAutorizar");
  inpPassword.focus();
}

autoriza() async {
  if (inpPassword.value!.trim() != "soles32") {
    await ModalP.showDialog("Contraseña incorrecta", "Error", ModalP.TDialogType.ERROR, ModalP.TDialogButtons.OK);
    inpPassword.focus();
    return;
  }

  int pId = int.parse(window.localStorage["IdAuth"]!);

  var pUrl = "$pHost/rest/cambiar_estado_orden_produccion/$pId/Autorizado";

  HttpRequest pResult = await HttpRequest.request(pUrl, method: "PUT", sendData: "");

  Map pMap = jsonDecode(pResult.responseText!);

  if (pMap["result"] == 0) {
    (querySelector("#tdEstado$pId") as TableCellElement).text = "Autorizado";

    try {
      ListaOrdenP.where((x) => x.id == pId).first.estado = "Autorizado";
    } catch (_) {}

    ModalP.cierraModal("#mdlAutorizar");
  }
}

void llena_lista_consulta(String data) {
  print(data);

  ListaOrdenP.clear();

  List p_lista = jsonDecode(data);

  String pClase = inpClase.value ?? "";

  if (pClase != "0") {
    p_lista = p_lista.where((x) => x['clase'].toString() == pClase).toList();
  }

  if (inpProcesado.value != "Todos") {
    p_lista = p_lista.where((x) => x['procesado'].toString() == inpProcesado.value).toList();
  }

  window.localStorage["Clase"] = pClase;

  tablaConsulta.tBodies[0].children.clear();

  for (int i = 0; i <= p_lista.length - 1; i++) {
    OrdenProduccion item = OrdenProduccion();
    item.id = p_lista[i]['id'];
    item.descripcion = p_lista[i]['descripcion'];
    item.fecha = p_lista[i]['fecha'];
    item.fecha = item.fecha.substring(0, 10);
    item.lote_produccion = p_lista[i]['lote_produccion'];
    item.nombre_clase = p_lista[i]['nombre_clase'];
    item.estado = p_lista[i]['estado'];
    item.clase = p_lista[i]['clase'];
    item.folio_sap = p_lista[i]['folio_sap'] ?? "";
    item.usuario = p_lista[i]['usuario'];
    item.fecha_creacion = p_lista[i]['fechahorasistema'].substring(0, 10);
    item.nombre_cliente = p_lista[i]['nombre_cliente'];
    item.procesado = p_lista[i]['procesado'];
    item.cajas_destiempo = p_lista[i]['cajas_destiempo'] ?? 0;

    try {
      item.fecha_modificacion = p_lista[i]['fecha_ultima_modificacion'].substring(0, 16);
    } catch (_) {
      item.fecha_modificacion = '';
    }

    try {
      item.MotivoModificacion = p_lista[i]['motivo_modificacion'];
    } catch (_) {
      item.MotivoModificacion = '';
    }

    TableRowElement tr = new TableRowElement();

    if (item.cajas_destiempo > 0) {
      tr.style.backgroundColor = 'rgb(255, 204, 204)';
    }

    TableCellElement td = new TableCellElement()
      ..id = "td" + item.id.toString()
      ..text = item.id.toString();
    tr.children.add(td);

    td = new TableCellElement();
    td.id = "tdFolioSAP${item.id}";

    if (item.folio_sap == null) {
      td.text = "";
    } else {
      td.text = item.folio_sap.toString();
    }

    tr.children.add(td);

    td = new TableCellElement();

    if (item.nombre_cliente.length > 15) {
      td.text = item.nombre_cliente.substring(0, 14) + '...';
    } else {
      td.text = item.nombre_cliente;
    }

    tr.children.add(td);

    td = new TableCellElement()..text = item.descripcion;
    tr.children.add(td);

    td = new TableCellElement()
      ..text = item.fecha_creacion
      ..style.textAlign = "center";
    tr.children.add(td);

    td = new TableCellElement()
      ..text = item.fecha
      ..style.textAlign = "center";
    tr.children.add(td);

    td = new TableCellElement()
      ..text = item.usuario
      ..style.textAlign = "center";
    tr.children.add(td);

    td = new TableCellElement()
      ..text = item.nombre_clase
      ..style.textAlign = "center";
    tr.children.add(td);

    td = new TableCellElement()..style.textAlign = "center";

    print("Cliente soles:");
    print(item.nombre_cliente.toUpperCase());

    if (item.nombre_cliente.toUpperCase().contains("SOLE")) {
      if (item.nombre_clase == 'Traspasos') {
        item.responsable = "Sergio D";
        td.text = "SergioD";
      } else {
        item.responsable = "Dannia";
        td.text = "Dannia";
      }
    } else {
      item.responsable = "N/A";
      td.text = "N/A";
    }

    tr.children.add(td);

    td = new TableCellElement()
      ..id = "tdEstado" + item.id.toString()
      ..text = item.estado
      ..style.textAlign = "center";
    tr.children.add(td);

    td = new TableCellElement()
      ..id = "tdFechaModificado" + item.id.toString()
      ..text = item.fecha_modificacion
      ..style.textAlign = "center";
    tr.children.add(td);

    td = new TableCellElement()
      ..id = "tdProcesado" + item.id.toString()
      ..text = item.procesado
      ..style.textAlign = "center";

    if (item.procesado == null) {
      td.text = "No";
    }

    tr.children.add(td);

    td = new TableCellElement()
      ..id = "tdMotivoModificado" + item.id.toString()
      ..text = item.MotivoModificacion
      ..style.textAlign = "left";
    tr.children.add(td);

    AnchorElement ancSurtir = AnchorElement()
      ..classes.add("label")
      ..text = "Surtir"
      ..onClick.listen((_) {
        surtir(item);
      });

    td = TableCellElement()
      ..style.textAlign = "center"
      ..children.add(ancSurtir);
    td.children.add(Element.html("<span>&nbsp;</span>"));

    AnchorElement ancModificar = AnchorElement()
      ..classes.add("label")
      ..text = "m"
      ..onClick.listen((_) {
        modificar(item);
      });

    td.children.add(ancModificar);
    td.children.add(new Element.html("<span>&nbsp;</span>"));

    AnchorElement ancEliminar = new AnchorElement()
      ..classes.add("label")
      ..text = "e"
      ..onClick.listen((_) {
        eliminar(item);
      });

    td.children.add(ancEliminar);

    td.children.add(Element.html("<span>&nbsp;</span>"));

    if (inpPuedeCambiarEstado.value! == "Si") {
      var ancCambiarEstado = AnchorElement()
        ..classes.add("label")
        ..text = "c"
        ..onClick.listen((_) {
          print("Aqui");
          cambiarEstado(item);
        });
      td.children.add(ancCambiarEstado);
    } else {
      td.children.add(SpanElement()..text = "");
    }

    tr.children.add(td);

    td.children.add(Element.html("<span>&nbsp;</span>"));

    AnchorElement ancAutorizar = new AnchorElement()
      ..classes.add("label")
      ..text = "a"
      ..onClick.listen((_) async {
        if (item.estado == "Cerrado") {
          autorizar(item);
        } else {
          await ModalP.showDialog("La orden debe estar cerrada", "Error", ModalP.TDialogType.ERROR, ModalP.TDialogButtons.OK);
        }
      });

    td.children.add(ancAutorizar);

    td.children.add(new Element.html("<span>&nbsp;</span>"));

    AnchorElement ancLigar = new AnchorElement()
      ..classes.add("label")
      ..text = "l"
      ..onClick.listen((_) async {
        Map pLiga = await ligarOrdenes(item.id);

        print("Liga: $pLiga");

        if (pLiga.length > 0) {
          (querySelector("#tdFolioSAP${item.id}") as TableCellElement).text = pLiga.values.elementAt(0);
        }
      });

    td.children.add(ancLigar);

    td.children.add(Element.html("<span>&nbsp;</span>"));

    AnchorElement ancProcesar = AnchorElement()
      ..classes.add("label")
      ..text = "p"
      ..onClick.listen((_) async {
        print(item.folio_sap);
        if (item.folio_sap != null) {
          if (inpResponsableDe.value == item.responsable) {
            if (window.confirm("¿Procesar Orden?")) {
              await ProcesarOrden(item.id);
              await ModalP.showDialog("Orden Procesada con éxito", "Procesar", ModalP.TDialogType.INFO, ModalP.TDialogButtons.OK);

              var pTdProcesado = querySelector("#tdProcesado${item.id}") as TableCellElement;
              pTdProcesado.text = "Si";
            }
          } else {
            await ModalP.showDialog("Usuario no puede procesar esta orden", "Error", ModalP.TDialogType.ERROR, ModalP.TDialogButtons.OK);
          }
        } else {
          await ModalP.showDialog("Orden necesita folio SAP antes de procesarse", "Error", ModalP.TDialogType.ERROR, ModalP.TDialogButtons.OK);
        }
      });

    td.children.add(ancProcesar);

    tr.children.add(td);

    tablaConsulta.tBodies[0].children.add(tr);

    ListaOrdenP.add(item);
  }

  print("***************");
  print(ListaOrdenP);
}

void LlenaOrdenProduccion() {
  var pFechaIni = (querySelector("#fecha") as InputElement).value;
  var pFechaFin = (querySelector("#fechafin") as InputElement).value;
  var pFiltro = (querySelector("#filtro") as SelectElement).value;

  window.localStorage["FechaInicial"] = pFechaIni!;
  window.localStorage["FechaFinal"] = pFechaFin!;
  window.localStorage["Filtro"] = pFiltro!;
  window.localStorage["Clase"] = inpClase.value!;

  pFechaIni = pFechaIni.replaceAll("/", "%2F");
  pFechaFin = pFechaFin.replaceAll("/", "%2F");

  String pUrl = '$pHost/rest/ordenp/OrdenProduccion_obtener_lista/$pFechaIni/$pFechaFin/$pFiltro/${inpClienteMaquila.value}';

  print(pUrl);

  HttpRequest.getString(pUrl).then(llena_lista_consulta);
}

Future<int?> agregar() async {
  print("agregando");

  if (!editable) {
    await ModalP.showDialog("No tiene derecho a esta opción", "Error", ModalP.TDialogType.ERROR, ModalP.TDialogButtons.OK);
    return 0;
  }

  var pIdUsuario = (document.querySelector("#idUsuario") as HiddenInputElement).value;
  var pUrl = "$pHost/rest/dias_ultima_orden/$pIdUsuario";

  HttpRequest.getString(pUrl).then((String Data) async {
    Map pMap = jsonDecode(Data);

    if (pMap["dias"] > 3) {
      await ModalP.showDialog("No puede crear nuevas ordenes porque hay ordenes abiertas de ${pMap["dias"].toString()} de antigüedad", "Error", ModalP.TDialogType.ERROR, ModalP.TDialogButtons.OK);
      return;
    } else {
      window.location.href = "$pHost/orden_produccion?id=0";
    }
  });
  return null;
}

Future tiene_derecho_modificar() {
  String pUsuario = "5";
  String pDerecho = "40";
  var pUrl = "$pHost/rest/usuarios/usuario_tiene_derecho/$pUsuario/$pDerecho";

  return HttpRequest.getString(pUrl);
}

Future tiene_derecho_eliminar() async {
  var pUsuario = "4";
  var pDerecho = "40";
  var pUrl = "$pHost/rest/usuarios/usuario_tiene_derecho_eliminar_orden/$pUsuario/$pDerecho";

  return await HttpRequest.getString(pUrl);
}

Future modificar(OrdenProduccion item) async {
  if (!editable) {
    await ModalP.showDialog("No tiene derecho a esta opción", "Error", ModalP.TDialogType.ERROR, ModalP.TDialogButtons.OK);
    return;
  }

  if (item.estado == "Eliminado") {
    await ModalP.showDialog("No se puede modificar una orde eliminada", "Error", ModalP.TDialogType.ERROR, ModalP.TDialogButtons.OK);
    return;
  }

  var Data = await tiene_derecho_modificar();
  bool pResult = jsonDecode(Data);

  if (pResult) {
    if (item.estado != "Cerrado") {
      window.location.href = "$pHost/orden_produccion?id=${item.id.toString()}";
    } else {
      await ModalP.showDialog("No se puede modificar una orden cerrada", "Error", ModalP.TDialogType.ERROR, ModalP.TDialogButtons.OK);
    }
  } else {
    await ModalP.showDialog("El usuario no tiene derecho a modificar ordenes de producción", "Error", ModalP.TDialogType.ERROR, ModalP.TDialogButtons.OK);
  }
}

Future surtir(OrdenProduccion item) async {
  if (item.estado == "Eliminado") {
    await ModalP.showDialog("No se puede surtir una orden eliminada", "Error", ModalP.TDialogType.ERROR, ModalP.TDialogButtons.OK);
    return;
  }

  var pFecha = (document.querySelector("#fecha") as InputElement).value;
  window.location.href = "$pHost/surtir_orden?id=${item.id.toString()}&fecha=$pFecha";
}

Future eliminar(OrdenProduccion item) async {
  if (!editable) {
    await ModalP.showDialog("No tiene derecho a esta opción", "Error", ModalP.TDialogType.ERROR, ModalP.TDialogButtons.OK);
    return;
  }

  if (item.estado != "Nuevo") {
    await ModalP.showDialog("No se pueden eliminar Ordenes que no son nuevas", "Error", ModalP.TDialogType.ERROR, ModalP.TDialogButtons.OK);
    return;
  }

  var Data = await tiene_derecho_eliminar();
  bool pResult = jsonDecode(Data);

  if (pResult) {
    if (window.confirm("¿Eliminar Orden de Produccion?")) {
      String pUrl = '$pHost/rest/ordenp/OrdenProduccion_eliminar/${item.id.toString()}';
      Map<String, String> headers = <String, String>{};
      headers["content-type"] = "application/json";
      String pData = item.ToJson();

      HttpRequest.request(pUrl, method: "DELETE", requestHeaders: headers, sendData: pData).then((HttpRequest request) => item.estado = "Eliminado");
    }
  } else {
    await ModalP.showDialog("El usuario no tiene derecho a eliminar ordenes de producción", "Error", ModalP.TDialogType.ERROR, ModalP.TDialogButtons.OK);
  }
}

void buscar() {
  ModalP.showModal("#mdlBuscar");
  document.querySelector("#pFolio")!.focus();
}

void buscaFolio() {
  ModalP.cierraModal("#mdlBuscar");
  var pFolio = (document.querySelector("#pFolio") as InputElement).value;
  var pUrl = '$pHost/rest/ordenp/OrdenProduccion_obtener_lista_folio/$pFolio';

  HttpRequest.getString(pUrl).then(llena_lista_consulta);
}

Future cambiarEstado(OrdenProduccion AOrdenProduccion) async {
  print("1");

  if (!editable) {
    await ModalP.showDialog("No tiene derecho a esta opción", "Error", ModalP.TDialogType.ERROR, ModalP.TDialogButtons.OK);
    return;
  }

  print("2");
  var pIdUsuario = (document.querySelector("#idUsuario") as InputElement).value;
  var pUrl = "$pHost/rest/puede_cambiar_estado/$pIdUsuario";

  print("3");

  HttpRequest.getString(pUrl).then((String Data) async {
    print("4");
    String pResult = jsonDecode(Data);

    print(pResult);

    if (pResult != "Si") {
      await ModalP.showDialog("El usuario no tiene derecho a cambiar estados", "Error", ModalP.TDialogType.ERROR, ModalP.TDialogButtons.OK);
      return;
    } else {
      pOrdenProduccion = AOrdenProduccion;

      _EstadoTmp = AOrdenProduccion.estado;

      window.localStorage["Estado"] = AOrdenProduccion.estado;

      window.localStorage["Id"] = AOrdenProduccion.id.toString();

      _IdTmp = AOrdenProduccion.id;

      ModalP.showModal("#mdlCambiarEstado");
      (document.querySelector("#inpEstado") as InputElement).focus();
    }
  });
}

setCambiarEstado() async {
  var pEstado = (document.querySelector("#inpEstado") as SelectElement).value;

  pOrdenProduccion = OrdenProduccion();
  pOrdenProduccion.id = int.parse(window.localStorage["Id"]!);
  pOrdenProduccion.estado = window.localStorage["Estado"]!;

  if (pEstado == pOrdenProduccion.estado) {
    await ModalP.showDialog("No se puede cambiar al estado actual", "Error", ModalP.TDialogType.ERROR, ModalP.TDialogButtons.OK);
    return;
  }

  if (pEstado == "Nuevo" && pOrdenProduccion.estado != "Surtido") {
    await ModalP.showDialog("No se puede cambiar el estado a Nuevo desde el estado actual", "Error", ModalP.TDialogType.ERROR, ModalP.TDialogButtons.OK);
    return;
  }

  var pUrl = "$pHost/rest/cambiar_estado_orden_produccion/${pOrdenProduccion.id}/$pEstado";

  HttpRequest.request(pUrl, method: "PUT", sendData: "").then((HttpRequest ARequest) {
    Map pMap = jsonDecode(ARequest.responseText!);

    if (pMap["result"] == 0) {
      ModalP.cierraModal("#mdlCambiarEstado");

      var pIdtdTmp = "#tdEstado${pOrdenProduccion.id}";

      print("---------------------");
      print(ListaOrdenP);

      (querySelector(pIdtdTmp) as TableCellElement).text = pEstado;
      OrdenProduccion pOP = ListaOrdenP.where((OrdenProduccion x) => x.id == pOrdenProduccion.id).first;
      pOP.estado = pEstado!;
    }
  });
}

main() async {
  if (window.localStorage["Filtro"] != null) {
    inpFiltro.value = window.localStorage["Filtro"];
  }

  await llenaSelectClientesMaquila();

  HiddenInputElement pInpEditable = document.querySelector("#inpEditable") as HiddenInputElement;
  editable = pInpEditable.value == "true";

  document.querySelector("#mdlBuscar")!.classes.remove("hiden");

  String pFecha = "";

  if (window.localStorage.containsKey("FechaInicial")) {
    (document.querySelector("#fecha") as InputElement).value = window.localStorage["FechaInicial"];
  } else {
    (document.querySelector("#fecha") as InputElement).value = intl.DateFormat("dd/MM/yyyy").format(DateTime.now());
  }

  if (window.localStorage.containsKey("FechaFinal")) {
    (document.querySelector("#fechafin") as InputElement).value = window.localStorage["FechaFinal"];
  } else {
    (document.querySelector("#fechafin") as InputElement).value = intl.DateFormat("dd/MM/yyyy").format(DateTime.now());
  }

  if (window.localStorage.containsKey("FechaFinal")) {
    (document.querySelector("#filtro") as SelectElement).value = window.localStorage["Filtro"];
  } else {
    (document.querySelector("#filtro") as SelectElement).value = "Todos";
  }

  var pUrl = "$pHost/rest/clase_ordenp_obtener_lista";

  HttpRequest.getString(pUrl).then((String Data) {
    var pLista = jsonDecode(Data);

    inpClase.children.add(Element.html("<option value='0'>Todos</option>"));

    for (Map item in pLista) {
      inpClase.children.add(Element.html("<option value='${item["id"]}'>${item["clase"]}</option>"));
    }

    if (window.localStorage["Clase"] != null) {
      inpClase.value = window.localStorage["Clase"];
    }

    LlenaOrdenProduccion();
  });

  btnConsultar.onClick.listen((_) => LlenaOrdenProduccion());

  btnCancelarCambioEstado.onClick.listen((_) => ModalP.cierraModal("#mdlCambiarEstado"));
  btnCerrarModalCambiarEstado.onClick.listen((_) => ModalP.cierraModal("#mdlCambiarEstado"));

  btnCambiarEstado.onClick.listen((_) => setCambiarEstado());
  btnAgregar.onClick.listen((_) => agregar());
  btnBusca.onClick.listen((_) => buscar());

  btnCerrarModalBuscar1.onClick.listen((_) => ModalP.cierraModal("#mdlBuscar"));
  btnCerrarModalBuscar2.onClick.listen((_) => ModalP.cierraModal("#mdlBuscar"));

  btnBuscar.onClick.listen((_) => buscaFolio());

  btnCerrarModalAutorizar1.onClick.listen((_) => ModalP.cierraModal("#mdlAutorizar"));
  btnCerrarModalAutorizar2.onClick.listen((_) => ModalP.cierraModal("#mdlAutorizar"));

  btnAutorizar.onClick.listen((_) async => autoriza());
}
