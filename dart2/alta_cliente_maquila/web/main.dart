import "dart:html";
import "dart:async";
import "dart:convert";
import 'package:quickdialogs/quickdialogs.dart' as QuickDialogs;

HeadingElement hTitulo = querySelector("#hTitulo");

final HiddenInputElement inpId = querySelector("#inpId");

final InputElement inpNombre = querySelector("#inpNombre");

final ButtonElement btnGuardar = querySelector("#btnGuardar");
final ButtonElement btnCancelar = querySelector("#btnCancelar");


Future<Map> getEntidad() async{
  Completer<Map> pCompleter = new Completer<Map>();
  Map pResult = null;
  var pUrl = "http://localhost:8031/obtener_cliente_maquila/${inpId.value}";

  String pJsonStr = await HttpRequest.getString(pUrl);

  pResult = JSON.decode(pJsonStr);
  pCompleter.complete(pResult);

  return pCompleter.future;

}

Map obtenerEntidad(){
  Map pResult = new Map();

  pResult["id"] = int.parse(inpId.value);
  pResult["nombre"] = inpNombre.value;

  return pResult;
}

void despliegaEntidad(Map AEntidad){
  inpNombre.value = AEntidad["nombre"];
}

Map entidadValida(){
  Map pResult = new Map();
  pResult["Resultado"] = true;
  pResult["Mensaje"] = "";
  pResult["Componente"] = null;

  if (inpNombre.value.trim().length == 0){
    pResult["Resultado"] = false;
    pResult["Mensaje"] = "El campo nombre no puede estar vacio";
    pResult["Componente"] = inpNombre;
    return pResult;
  }


  return pResult;
}


Future<Map> guardar() async{
  Completer<Map> pCompleter = new Completer<Map>();
  var pUrl = "http://localhost:8031/insertar_cliente_maquila";
  var pData = JSON.encode(obtenerEntidad());
  HttpRequest pRequest = await HttpRequest.request(pUrl, method: "POST", sendData: pData);
  window.alert("Registro guardado correctamente");
  pCompleter.complete(JSON.decode(pRequest.responseText));

  return pCompleter.future;
}

void reinicializaCampos(){
  (inpNombre as InputElement).value = "";
}

void cancelar(){
  if (window.confirm("Cancelar Captura?")){
    reinicializaCampos();
  }
}


init() async{
  hTitulo.text = inpId.value;
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