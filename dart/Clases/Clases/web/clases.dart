import 'dart:html';
import 'dart:json' as json;
import 'package:web_ui/web_ui.dart';
import 'package:web_ui/watcher.dart' as watcher;

bool permite_edicion = false;
bool modo_insercion  = true;

modificar(){
  permite_edicion = !permite_edicion;

  if (permite_edicion){
    query('#btnPermiteEdicion').value = 'Restringir';
  }
  else{
    query('#btnPermiteEdicion').value = 'Modificar';
  }
}

class Clase{
  int clave;
  String descripcion;
  String manejaextra;
  String tipo;
  int activo;
}

List<Clase> lista_clase = new List<Clase>();

llena_lista(data){
  lista_clase= new List<Clase>();
  List p_lista = json.parse(data);

  for (int i = 0; i <= p_lista.length - 1; i++){
    Clase item = new Clase();
    item.clave = p_lista[i]['clave'];
    item.descripcion = p_lista[i]['descripcion'];
    item.manejaextra = p_lista[i]['manejaextra'];
    item.tipo = p_lista[i]['tipo'];
    item.activo = p_lista[i]['activo'];

  lista_clase.add(item);
  }

  watcher.dispatch();
}

obtener_lista(){
  HttpRequest.getString('http://localhost:8031/rest/usuarios/clase_obtener_lista').then(llena_lista);
}

Clase obtener_entidad(){
  Clase p_clase = new Clase();
  p_clase.clave = int.parse(query('#clave').value);
  p_clase.descripcion = query('#descripcion').value;
  p_clase.manejaextra = query('#manejaextra').value;
  p_clase.tipo = query('#tipo').value;
  p_clase.activo = int.parse(query('#activo').value);

  return p_clase;
}

Map obtener_entidad_mapa(){
  Map p_map = new Map();

  p_map['clave'] = query('#clave').value;
  p_map['descripcion'] = query('#descripcion').value;
  p_map['manejaextra'] = query('#manejaextra').value;
  p_map['tipo'] = query('#tipo').value;
  p_map['activo'] = query('#activo').value;

  return p_map;
}

limpia_edits(){
  query('#clave').value = '1';
  query('#descripcion').value = '';
  query('#manejaextra').value = 'Si';
  query('#tipo').value = '';
  query('#activo').value = '1';

  query('#descripcion').focus();
}

agregar(){

  Clase p_clase = obtener_entidad();

  if (p_clase.descripcion.length == 0){
    window.alert('Se necesita capturar el campo descripcion');
    query('#descripcion').focus();
  }

  var req = new HttpRequest();
  if (query('#btnAgregar').value == 'Agregar'){
    req.open('POST', 'http://localhost:8031/rest/usuarios/clase_insertar');
    req.setRequestHeader('Content-type', 'application/json');
    req.send(json.stringify(obtener_entidad_mapa()));
    req.onReadyStateChange.listen((data){
      if (req.readyState == HttpRequest.DONE && (req.status == 200 || req.status == 0)) {
        p_clase.clave = (json.parse(req.responseText))['clave'];
        lista_clase.add(p_clase);
        watcher.dispatch();
        limpia_edits();
      }
    });
  }
  else{
    req.open('PUT', 'http://localhost:8031/rest/usuarios/clase_actualizar');
    req.setRequestHeader('Content-type', 'application/json');
    req.send(json.stringify(obtener_entidad_mapa()));

    Clase p_clase_tmp = lista_clase.where((x) => x.clave == p_clase.clave).toList()[0];
    actualiza_clase(p_clase_tmp, p_clase);

    query('#btnAgregar').value = 'Agregar';
    limpia_edits();
  }

  modo_insercion = true;
}

void actualiza_clase(Clase p_clase_tmp, Clase p_clase){
  p_clase_tmp.clave = p_clase.clave;
  p_clase_tmp.descripcion = p_clase.descripcion;
  p_clase_tmp.manejaextra = p_clase.manejaextra;
  p_clase_tmp.tipo = p_clase.tipo;
  p_clase_tmp.activo = p_clase.activo;
}

eliminar(Clase a_clase){
  if (window.confirm('¿Eliminar registro?'))   {

    var req = new HttpRequest();
    req.open('DELETE', 'http://localhost:8031/rest/usuarios/clase_eliminar');
    req.setRequestHeader('Content-type', 'application/json');

    Map p_map = new Map();
    p_map['clave'] = a_clase.clave;

    req.send(json.stringify(p_map));
    lista_clase.remove(a_clase);

    query('#descripcion').focus();
  }
}

cancelar(){
  limpia_edits();
  modo_insercion = true;
  query('#btnAgregar').value = 'Agregar';
}

despliega_clase(Clase a_clase){
  query('#clave').value = a_clase.clave.toString();
  query('#descripcion').value = a_clase.descripcion.toString();
  query('#manejaextra').value = a_clase.manejaextra.toString();
  query('#tipo').value = a_clase.tipo.toString();
  query('#activo').value = a_clase.activo.toString();
  query('#descripcion').focus();
  query('#btnAgregar').value = 'Editar';
}

editar(Clase a_clase){
  despliega_clase(a_clase);
  modo_insercion = false;
  window.scroll(0, 0);
}

main(){
  obtener_lista();
}