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
  }
  else{
    query('#btnPermiteEdicion').value = 'Modificar';
  }
}

class borrado_etiquetas_detalle{
  int id;
  int id_borrado;
  String fecha;
  int folio;
  String codigo_barras;
  String motivo;
  String aplicada;
}

List<borrado_etiquetas_detalle> lista_borrado_etiquetas_detalle = toObservable(new List<borrado_etiquetas_detalle>());

llena_lista(data){
  lista_borrado_etiquetas_detalle= new List<borrado_etiquetas_detalle>();
  List p_lista = json.parse(data);

  for (int i = 0; i <= p_lista.length - 1; i++){
    borrado_etiquetas_detalle item = new borrado_etiquetas_detalle();
    item.id = p_lista[i]['id'];
    item.id_borrado = p_lista[i]['id_borrado'];
    item.fecha = p_lista[i]['fecha'];
    item.folio = p_lista[i]['folio'];
    item.codigo_barras = p_lista[i]['codigo_barras'];
    item.motivo = p_lista[i]['motivo'];
    item.aplicada = p_lista[i]['aplicada'];

    lista_borrado_etiquetas_detalle.add(item);
  }

  watcher.dispatch();
}

obtener_lista(){
  HttpRequest.getString('http://localhost:8031/rest/granjas/borrado_etiquetas_detalle_obtener_lista').then(llena_lista);
}

borrado_etiquetas_detalle obtener_entidad(){
  borrado_etiquetas_detalle p_borrado_etiquetas_detalle = new borrado_etiquetas_detalle();
  p_borrado_etiquetas_detalle.id = int.parse(query('#id').value);
  p_borrado_etiquetas_detalle.id_borrado = int.parse(query('#id_borrado').value);
  p_borrado_etiquetas_detalle.fecha = query('#fecha').value;
  p_borrado_etiquetas_detalle.folio = int.parse(query('#folio').value);
  p_borrado_etiquetas_detalle.codigo_barras = query('#codigo_barras').value;
  p_borrado_etiquetas_detalle.motivo = query('#motivo').value;
  p_borrado_etiquetas_detalle.aplicada = query('#aplicada').value;

  return p_borrado_etiquetas_detalle;
}

Map obtener_entidad_mapa(){
  Map p_map = new Map();

  p_map['id'] = query('#id').value;
  p_map['id_borrado'] = query('#id_borrado').value;
  p_map['fecha'] = query('#fecha').value;
  p_map['folio'] = query('#folio').value;
  p_map['codigobarras'] = query('#codigo_barras').value;
  p_map['motivo'] = query('#motivo').value;
  p_map['aplicada'] = query('#aplicada').value;

  return p_map;
}

limpia_edits(){
  query('#id').value = '1';
  query('#id_borrado').value = '1';
  query('#fecha').value = '';
  query('#folio').value = '1';
  query('#codigo_barras').value = '';
  query('#motivo').value = '';
  query('#aplicada').value = 'Si';

  query('#id_borrado').focus();
}

agregar(){

  borrado_etiquetas_detalle p_borrado_etiquetas_detalle = obtener_entidad();

  var req = new HttpRequest();
  if (query('#btnAgregar').value == 'Agregar'){
    
//    HttpRequest.request('http://localhost:8031/rest/granjas/borrado_etiquetas_detalle_insertar', 'POST', false, "Application/json", json.stringify(obtener_entidad_mapa()));
    
    /*req.open('POST', 'http://localhost:8031/rest/granjas/borrado_etiquetas_detalle_insertar');
    req.setRequestHeader('Content-type', 'application/json');
    req.send(json.stringify(obtener_entidad_mapa()));
    req.onReadyStateChange.listen((data){
      print(data);
      if (req.readyState == HttpRequest.DONE && (req.status == 200 || req.status == 0)) {
        p_borrado_etiquetas_detalle.id = (json.parse(req.responseText))['id'];
        lista_borrado_etiquetas_detalle.add(p_borrado_etiquetas_detalle);
        watcher.dispatch();
        limpia_edits();
      }
    });*/
  }
  else{
    req.open('PUT', 'http://localhost:8031/rest/granjas/borrado_etiquetas_detalle_actualizar');
    req.setRequestHeader('Content-type', 'application/json');
    req.send(json.stringify(obtener_entidad_mapa()));

    borrado_etiquetas_detalle p_borrado_etiquetas_detalle_tmp = lista_borrado_etiquetas_detalle.where((x) => x.id == p_borrado_etiquetas_detalle.id).toList()[0];
    actualiza_borrado_etiquetas_detalle(p_borrado_etiquetas_detalle_tmp, p_borrado_etiquetas_detalle);

    query('#btnAgregar').value = 'Agregar';
    limpia_edits();
  }

  modo_insercion = true;
}

void actualiza_borrado_etiquetas_detalle(borrado_etiquetas_detalle p_borrado_etiquetas_detalle_tmp, borrado_etiquetas_detalle p_borrado_etiquetas_detalle){
  p_borrado_etiquetas_detalle_tmp.id = p_borrado_etiquetas_detalle.id;
  p_borrado_etiquetas_detalle_tmp.id_borrado = p_borrado_etiquetas_detalle.id_borrado;
  p_borrado_etiquetas_detalle_tmp.fecha = p_borrado_etiquetas_detalle.fecha;
  p_borrado_etiquetas_detalle_tmp.folio = p_borrado_etiquetas_detalle.folio;
  p_borrado_etiquetas_detalle_tmp.codigo_barras = p_borrado_etiquetas_detalle.codigo_barras;
  p_borrado_etiquetas_detalle_tmp.motivo = p_borrado_etiquetas_detalle.motivo;
  p_borrado_etiquetas_detalle_tmp.aplicada = p_borrado_etiquetas_detalle.aplicada;
}

eliminar(borrado_etiquetas_detalle a_borrado_etiquetas_detalle){
  if (window.confirm('¿Eliminar registro?'))   {

    var req = new HttpRequest();
    req.open('DELETE', 'http://localhost:8031/rest/granjas/borrado_etiquetas_detalle_eliminar');
    req.setRequestHeader('Content-type', 'application/json');

    Map p_map = new Map();
    p_map['id'] = a_borrado_etiquetas_detalle.id;

    req.send(json.stringify(p_map));
    lista_borrado_etiquetas_detalle.remove(a_borrado_etiquetas_detalle);

  }
}

cancelar(){
  limpia_edits();
  modo_insercion = true;
  query('#btnAgregar').value = 'Agregar';
}

despliega_clase(borrado_etiquetas_detalle a_borrado_etiquetas_detalle){
  query('#id').value = a_borrado_etiquetas_detalle.id.toString();
  query('#id_borrado').value = a_borrado_etiquetas_detalle.id_borrado.toString();
  query('#fecha').value = a_borrado_etiquetas_detalle.fecha.toString();
  query('#folio').value = a_borrado_etiquetas_detalle.folio.toString();
  query('#codigo_barras').value = a_borrado_etiquetas_detalle.codigo_barras.toString();
  query('#motivo').value = a_borrado_etiquetas_detalle.motivo.toString();
  query('#aplicada').value = a_borrado_etiquetas_detalle.aplicada.toString();
  query('#id_borrado').focus();
  query('#btnAgregar').value = 'Editar';
}

editar(borrado_etiquetas_detalle a_borrado_etiquetas_detalle){
  despliega_clase(a_borrado_etiquetas_detalle);
  modo_insercion = false;
  window.scroll(0, 0);
}

main(){
  obtener_lista();
}