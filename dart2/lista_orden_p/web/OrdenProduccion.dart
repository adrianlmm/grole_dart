library LibOrdenProduccion;
import 'dart:convert';

class OrdenProduccion{
  int id;
  String fecha;
  int id_usuario;
  int id_usuario_embarques;
  int id_tipo;
  String descripcion;
  double kilos_produccion;
  double rendimiento;
  String estado;
  int lote_produccion;
  int clase;
  String nombre_clase;
  String folio_sap;
  String usuario;

  String ToJson(){
    Map p_map = new Map();

    p_map['id']                   = this.id;
    p_map['fecha']                = this.fecha;
    p_map['id_usuario']           = this.id_usuario;
    p_map['id_usuario_embarques'] = this.id_usuario_embarques;
    p_map['id_tipo']              = this.id_tipo;
    p_map['descripcion']          = this.descripcion;
    p_map['kilos_produccion']     = this.kilos_produccion;
    p_map['rendimiento']          = this.rendimiento;
    p_map['estado']               = this.estado;
    p_map['lote_produccion']      = this.lote_produccion.toString();
    p_map['nombre_clase']         = this.nombre_clase;
    p_map['folio_sap']            = this.folio_sap;

    return JSON.encode(p_map);
  }

  OrdenProduccion();

  OrdenProduccion.FromJSON(String AJSON){

    print(".....");
    print(AJSON);

    var p_lista = JSON.decode(AJSON);

    this.id                   = p_lista['id'];
    this.fecha                = p_lista['fecha'];
    this.id_usuario           = p_lista['id_usuario'];
    this.id_usuario_embarques = p_lista['id_usuario_embarques'];
    this.id_tipo              = p_lista['id_tipo'];
    this.descripcion          = p_lista['descripcion'];
    this.kilos_produccion     = p_lista['kilos_producccion'];
    this.rendimiento          = p_lista['rendimiento'];
    this.estado               = p_lista['estado'];
    this.lote_produccion      = p_lista['lote_produccion'];
    this.clase                = p_lista['clase'];
    this.nombre_clase         = p_lista['nombre_clase'];
    this.folio_sap            = p_lista['folio_sap'];
    this.usuario              = p_lista['usuario'];

  }
}

