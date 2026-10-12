import 'dart:html';
import 'dart:json' as json;
import 'package:web_ui/web_ui.dart';
import 'package:web_ui/watcher.dart' as watcher;

bool permite_edicion = false;
bool modo_insercion  = true;

modificar(){
  permite_edicion = !permite_edicion;
  modo_insercion  = true;
  
  if (permite_edicion){
    query('#btnPermiteEdicion').value = 'Restringir';
    query('#tdatos').classes.clear();
    query('#tdatos').classes.add("tabla_datos_edicion");
  }
  else{
    query('#btnPermiteEdicion').value = 'Modificar';
    query('#tdatos').classes.clear();
    query('#tdatos').classes.add("tabla_datos");
  }
}

class destino{
  int clave;
  String nombredestino;
}

List<destino> lista_destino = new List<destino>();

llena_lista(data){
  lista_destino= new List<destino>();
  List p_lista = json.parse(data);

  for (int i = 0; i <= p_lista.length - 1; i++){
    destino item = new destino();
    item.clave = p_lista[i]['clave'];
    item.nombredestino = p_lista[i]['destino'];

    lista_destino.add(item);
  }

  watcher.dispatch();
}

obtener_lista(){
  HttpRequest.getString('http://localhost:8031/rest/destinos/destino_obtener_lista').then(llena_lista);
}

destino obtener_entidad(){
  destino p_destino = new destino();
  p_destino.clave = int.parse(query('#clave').value);
  p_destino.nombredestino = query('#nombredestino').value;

  return p_destino;
}

Map obtener_entidad_mapa(){
  Map p_map = new Map();

  p_map['clave'] = query('#clave').value;
  p_map['destino'] = query('#nombredestino').value;

  return p_map;
}

limpia_edits(){
  query('#clave').value = '1';
  query('#nombredestino').value = '';

  query('#nombredestino').focus();
}

agregar(){

  destino p_destino = obtener_entidad();

  if (p_destino.nombredestino.length == 0){
    window.alert('Se necesita capturar el campo nombredestino');
    query('#nombredestino').focus();
  }

  var req = new HttpRequest();
  if (query('#btnAgregar').value == 'Agregar'){
    req.open('POST', 'http://localhost:8031/rest/destinos/destino_insertar');
    req.setRequestHeader('Content-type', 'application/json');
    req.send(json.stringify(obtener_entidad_mapa()));
    req.onReadyStateChange.listen((data){
      if (req.readyState == HttpRequest.DONE && (req.status == 200 || req.status == 0)) {
        p_destino.clave = (json.parse(req.responseText))['clave'];
        lista_destino.add(p_destino);
        watcher.dispatch();
        limpia_edits();
      }
    });
  }
  else{
    req.open('PUT', 'http://localhost:8031/rest/destinos/destino_actualizar');
    req.setRequestHeader('Content-type', 'application/json');
    req.send(json.stringify(obtener_entidad_mapa()));

    destino p_destino_tmp = lista_destino.where((x) => x.clave == p_destino.clave).toList()[0];
    actualiza_destino(p_destino_tmp, p_destino);

    query('#btnAgregar').value = 'Agregar';
    limpia_edits();
  }

  modo_insercion = true;
}

void actualiza_destino(destino p_destino_tmp, destino p_destino){
  p_destino_tmp.clave = p_destino.clave;
  p_destino_tmp.nombredestino = p_destino.nombredestino;
}

eliminar(destino a_destino){
  if (window.confirm('¿Eliminar registro?'))   {

    var req = new HttpRequest();
    req.open('DELETE', 'http://localhost:8031/rest/destinos/destino_eliminar');
    req.setRequestHeader('Content-type', 'application/json');

    Map p_map = new Map();
    p_map['clave'] = a_destino.clave;

    req.send(json.stringify(p_map));
    lista_destino.remove(a_destino);
  }
}

cancelar(){
  limpia_edits();
  modo_insercion = true;
  query('#btnAgregar').value = 'Agregar';
}

despliega_clase(destino a_destino){
  query('#clave').value = a_destino.clave.toString();
  query('#nombredestino').value = a_destino.nombredestino.toString();
  query('#nombredestino').focus();
  query('#btnAgregar').value = 'Editar';
}

editar(destino a_destino){
  despliega_clase(a_destino);
  modo_insercion = false;
 // window.scroll(0, 0);
}

main(){
  obtener_lista();
}