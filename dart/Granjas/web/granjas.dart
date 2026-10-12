import 'dart:html';
import 'dart:json' as json;
import 'package:web_ui/web_ui.dart';
import 'package:web_ui/watcher.dart' as watcher;

bool permite_edicion = false;
bool modo_insercion  = true;
int pScrollY = 0;

modificar(){
  permite_edicion = !permite_edicion;
  modo_insercion  = true;
  
  watcher.dispatch();

  if (permite_edicion){
    query('#btnPermiteEdicion').value = 'Restringir';
    limpia_edits();
  }
  else{
    query('#btnPermiteEdicion').value = 'Modificar';
  }
}

class granja{
  int clave;
  String nombre;
}

List<granja> lista_granja = new List<granja>();

llena_lista(data){
  lista_granja= new List<granja>();
  List p_lista = json.parse(data);

  for (int i = 0; i <= p_lista.length - 1; i++){
    granja item = new granja();
    item.clave = p_lista[i]['clave'];
    item.nombre = p_lista[i]['nombre'];

    lista_granja.add(item);
  }

  watcher.dispatch();
}

obtener_lista(){
  HttpRequest.getString('http://localhost:8031/rest/granjas/granja_obtener_lista').then(llena_lista);
}

granja obtener_entidad(){
  granja p_granja = new granja();
  p_granja.clave = int.parse(query('#clave').value);
  p_granja.nombre = query('#nombre').value;

  return p_granja;
}

Map obtener_entidad_mapa(){
  Map p_map = new Map();

  p_map['clave'] = query('#clave').value;
  p_map['nombre'] = query('#nombre').value;

  return p_map;
}

limpia_edits(){
  query('#clave').value = '1';
  query('#nombre').value = '';

  query('#nombre').focus();
}

agregar(){

  granja p_granja = obtener_entidad();

  if (p_granja.nombre.length == 0){
    window.alert('Se necesita capturar el campo nombre');
    query('#nombre').focus();
  }

  var req = new HttpRequest();
  if (query('#btnAgregar').value == 'Agregar'){
    req.open('POST', 'http://localhost:8031/rest/granjas/granja_insertar');
    req.setRequestHeader('Content-type', 'application/json');
    req.send(json.stringify(obtener_entidad_mapa()));
    req.onReadyStateChange.listen((data){
      if (req.readyState == HttpRequest.DONE && (req.status == 200 || req.status == 0)) {
        p_granja.clave = (json.parse(req.responseText))['clave'];
        lista_granja.add(p_granja);
        watcher.dispatch();
        limpia_edits();
      }
    });
  }
  else{
    req.open('PUT', 'http://localhost:8031/rest/granjas/granja_actualizar');
    req.setRequestHeader('Content-type', 'application/json');
    req.send(json.stringify(obtener_entidad_mapa()));

    granja p_granja_tmp = lista_granja.where((x) => x.clave == p_granja.clave).toList()[0];
    actualiza_granja(p_granja_tmp, p_granja);

    query('#btnAgregar').value = 'Agregar';
    limpia_edits();
  }

  modo_insercion = true;
  
  watcher.dispatch();
  print(pScrollY);
  window.scrollTo(0, pScrollY);
}

void actualiza_granja(granja p_granja_tmp, granja p_granja){
  p_granja_tmp.clave = p_granja.clave;
  p_granja_tmp.nombre = p_granja.nombre;
}

eliminar(granja a_granja){
  if (window.confirm('¿Eliminar registro?'))   {

    var req = new HttpRequest();
    req.open('DELETE', 'http://localhost:8031/rest/granjas/granja_eliminar');
    req.setRequestHeader('Content-type', 'application/json');

    Map p_map = new Map();
    p_map['clave'] = a_granja.clave;

    req.send(json.stringify(p_map));
    lista_granja.remove(a_granja);

  }
}

cancelar(){
  limpia_edits();
  modo_insercion = true;
  query('#btnAgregar').value = 'Agregar';
}

despliega_clase(granja a_granja){
  query('#clave').value = a_granja.clave.toString();
  query('#nombre').value = a_granja.nombre.toString();
  query('#nombre').focus();
  query('#btnAgregar').value = 'Editar';
}

editar(granja a_granja){
  pScrollY = window.scrollY;
  despliega_clase(a_granja);
  modo_insercion = false;
  print(pScrollY);
}

main(){
  obtener_lista();
}