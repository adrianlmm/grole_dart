// ignore_for_file: non_constant_identifier_names

library LibOrdenProduccion;

import 'dart:convert';

class OrdenProduccion {
  int id = 0;
  String fecha = "";
  int id_usuario = 0;
  int id_usuario_embarques = 0;
  int id_tipo = 0;
  String descripcion = "";
  double kilos_produccion = 0.0;
  double rendimiento = 0.0;
  String estado = "";
  int lote_produccion = 0;
  int clase = 0;
  String nombre_clase = "";
  String folio_sap = "";
  String usuario = "";
  String fecha_creacion = "";
  String nombre_cliente = "";
  String responsable = "";
  String procesado = "";
  String fecha_modificacion = "";
  int cajas_destiempo = 0;
  String MotivoModificacion = "";

  String ToJson() {
    Map p_map = {};

    p_map['id'] = id;
    p_map['fecha'] = fecha;
    p_map['id_usuario'] = id_usuario;
    p_map['id_usuario_embarques'] = id_usuario_embarques;
    p_map['id_tipo'] = id_tipo;
    p_map['descripcion'] = descripcion;
    p_map['kilos_produccion'] = kilos_produccion;
    p_map['rendimiento'] = rendimiento;
    p_map['estado'] = estado;
    p_map['lote_produccion'] = lote_produccion.toString();
    p_map['nombre_clase'] = nombre_clase;
    p_map['folio_sap'] = folio_sap;
    p_map['cajas_destiempo'] = cajas_destiempo;

    return jsonEncode(p_map);
  }

  OrdenProduccion();

  OrdenProduccion.FromJSON(String AJSON) {
    print(".....");
    print(AJSON);

    var p_lista = jsonDecode(AJSON);

    id = p_lista['id'];
    fecha = p_lista['fecha'];
    id_usuario = p_lista['id_usuario'];
    id_usuario_embarques = p_lista['id_usuario_embarques'];
    id_tipo = p_lista['id_tipo'];
    descripcion = p_lista['descripcion'];
    kilos_produccion = p_lista['kilos_producccion'];
    rendimiento = p_lista['rendimiento'];
    estado = p_lista['estado'];
    lote_produccion = p_lista['lote_produccion'];
    clase = p_lista['clase'];
    nombre_clase = p_lista['nombre_clase'];
    folio_sap = p_lista['folio_sap'];
    usuario = p_lista['usuario'];
    fecha_creacion = p_lista['fechahorasistema'];
    nombre_cliente = p_lista['nombre_cliente'];
    fecha_creacion = p_lista['fecha_ultima_modificacion'].toString();

    if (p_lista['cajas_destiempo'] == null) {
      cajas_destiempo = 0;
    } else {
      cajas_destiempo = p_lista['cajas_destiempo'];
    }

    if (p_lista['motivo_modificacion'] == null) {
      MotivoModificacion = "";
    } else {
      cajas_destiempo = p_lista["motivo_modificacion"];
    }
  }
}
