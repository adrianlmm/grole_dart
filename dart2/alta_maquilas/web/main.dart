import "dart:html";
import "dart:async";
import "dart:convert";
import 'package:quickdialogs/quickdialogs.dart' as QuickDialogs;

HeadingElement hTitulo = querySelector("#hTitulo");

final HiddenInputElement inpId = querySelector("#inpId");

final SelectElement inpCliente = querySelector("#inpCliente");
final InputElement inpFecha = querySelector("#inpFecha");
final InputElement inpFolioFactura = querySelector("#inpFolioFactura");
final InputElement inpCantidadTotal = querySelector("#inpCantidadTotal");
final InputElement inpPesoFactura = querySelector("#inpPesoFactura");

final ButtonElement btnGuardar = querySelector("#btnGuardar");
final ButtonElement btnCancelar = querySelector("#btnCancelar");


Future<Map> getEntidad() async{
  Completer<Map> pCompleter = new Completer<Map>();
  Map pResult = null;
  var pUrl = "http://localhost:8031/obtener_maquila/${inpId.value}";

  String pJsonStr = await HttpRequest.getString(pUrl);

  pResult = JSON.decode(pJsonStr);
  pCompleter.complete(pResult);

  return pCompleter.future;

}

Map obtenerEntidad(){
  Map pResult = new Map();

  pResult["id"] = int.parse(inpId.value);
  pResult["cliente"] = int.parse(inpCliente.value);
  pResult["fecha"] = inpFecha.value;
  pResult["folio_factura"] = inpFolioFactura.value;
  pResult["cantidadtotal"] = int.parse(inpCantidadTotal.value);
  pResult["pesofactura"] = double.parse(inpPesoFactura.value);

  return pResult;
}

void despliegaEntidad(Map AEntidad){
  inpCliente.value = AEntidad["cliente"].toString();
  inpFecha.value = AEntidad["fecha"];
  inpFolioFactura.value = AEntidad["folio_factura"];
  inpCantidadTotal.value = AEntidad["cantidadtotal"].toString();
  inpPesoFactura.value = AEntidad["pesofactura"].toStringAsFixed(2);
}

Map entidadValida(){
  Map pResult = new Map();
  pResult["Resultado"] = true;
  pResult["Mensaje"] = "";
  pResult["Componente"] = null;

  int pcantidadtotal = int.parse(inpCantidadTotal.value, onError:(x) => -1);
  if (pcantidadtotal < 0){
    pResult["Resultado"] = false;
    pResult["Mensaje"] = "El valor del campo cantidadtotal es no valido";
    pResult["Componente"] = inpCantidadTotal;
    return pResult;
  }

  double ppesofactura = double.parse(inpPesoFactura.value, (x) => -1.0);
  if (ppesofactura < 0){
    pResult["Resultado"] = false;
    pResult["Mensaje"] = "El valor del campo pesofactura es no valido";
    pResult["Componente"] = inpPesoFactura;
    return pResult;
  }

  return pResult;
}

Future<List<Map>> obtenerClientes() async{
  Completer<List<Map>> pCompleter = new Completer<List<Map>>();
  List<Map> pResult = null;
  var pUrl = "http://localhost:8031/obtener_clientes_maquila";

  String pJsonStr = await HttpRequest.getString(pUrl);
  pResult = JSON.decode(pJsonStr);
  pCompleter.complete(pResult);

  return pCompleter.future;
}


Future<Map> guardar() async{
  Completer<Map> pCompleter = new Completer<Map>();
  var pUrl = "http://localhost:8031/insertar_maquila";
  var pData = JSON.encode(obtenerEntidad());
  HttpRequest pRequest = await HttpRequest.request(pUrl, method: "POST", sendData: pData);
  window.alert("Registro guardado correctamente");
  pCompleter.complete(JSON.decode(pRequest.responseText));

  return pCompleter.future;
}

void reinicializaCampos(){
  (inpFecha as InputElement).value = "";
  (inpFolioFactura as InputElement).value = "";
  (inpCantidadTotal as InputElement).value = "";
  (inpPesoFactura as InputElement).value = "";
}

void cancelar(){
  if (window.confirm("Cancelar Captura?")){
    reinicializaCampos();
  }
}


init() async{
  hTitulo.text = inpId.value;

  List<Map> pcliente = await obtenerClientes();
  inpCliente.children.clear();
  for (var item in pcliente){
    inpCliente.children.add(new Element.html('<option value="${item["id"]}">${item["nombre"]}</option>'));
  }

  btnGuardar.onClick.listen((e) async {
    Map pEntidadValida = entidadValida();

    if (pEntidadValida["Resultado"] == false){
      window.alert(pEntidadValida['Mensaje']);
      (pEntidadValida["Componente"] as HtmlElement).focus();
      return;
    }

    Map pResult = await guardar();
    var pUri = window.location.protocol + "//" + window.location.host + "/";
    if (window.opener != null){
      window.opener.postMessage(JSON.encode(pResult), pUri);
      print("mensaje enviado");
    }
    if (window.opener != null){
      window.close();
    }
  });

  btnCancelar.onClick.listen((e){
    cancelar();
    if (window.opener != null){
      window.close();
    }
  });

  Map pEntidad = await getEntidad();
  despliegaEntidad(pEntidad);
}

main(){
  init();
}