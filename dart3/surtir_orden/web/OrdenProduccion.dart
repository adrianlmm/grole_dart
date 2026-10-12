// ignore_for_file: non_constant_identifier_names

library LibOrdenProduccion;

import 'dart:convert';
import 'package:intl/intl.dart';

class OrdenProduccion {
  int id = 0;
  String fecha = "";
  int id_usuario = 0;
  int id_usuario_embarques = 0;
  int id_tipo = 0;
  int id_programacion = 0;
  String id_salida = "";
  String descripcion = "";
  double kilos_produccion = 0.0;
  double rendimiento = 0.0;
  String estado = "";
  String lote_produccion = "";
  double costo_maquila = 0.0;
  double valor_rescate = 0.0;
  double costo_salida = 0.0;
  String modo_calculo = "Normal";

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
    p_map['lote_produccion'] = lote_produccion;
    //p_map['porcentaje']           = this.porcentaje;
    //p_map['cajas']                = this.cajas;
    p_map['costo_maquila'] = costo_maquila.toDouble();
    p_map['costo_maquila'] = valor_rescate.toDouble();
    p_map['costo_salida'] = costo_salida.toDouble();
    p_map['modo_calculo_costo'] = modo_calculo;

    return jsonEncode(p_map);
  }

  OrdenProduccion();

  OrdenProduccion.FromJSON(String AJSON) {
    var p_lista = jsonDecode(AJSON);

    id = p_lista['id'];

    String pFecha = p_lista['fecha'];
    pFecha = pFecha.substring(0, 10);

    print(pFecha);
    //pFecha = DateTime.parse(pFecha) as String;

    fecha = pFecha;
    id_usuario = p_lista['id_usuario'];
    id_usuario_embarques = p_lista['id_usuario_embarques'] ?? 0;
    id_tipo = p_lista['id_tipo'];
    id_programacion = p_lista['id_programacion'] ?? 0;
    descripcion = p_lista['descripcion'];
    kilos_produccion = p_lista['kilos_producccion'] ?? 0.00;
    rendimiento = p_lista['rendimiento'] ?? 0.00;
    estado = p_lista['estado'];
    lote_produccion = p_lista['lote_produccion'].toString();
    id_salida = p_lista['id_salida_embarques'].toString();
    costo_maquila = p_lista['costo_maquila'].toDouble();

    try {
      valor_rescate = p_lista['valor_rescate'].toDouble();
    } catch (ex) {
      valor_rescate = 0.0;
    }

    costo_salida = p_lista['costo_salida'].toDouble();

    try {
      modo_calculo = p_lista['modo_calculo_costo'].toDouble();
    } catch (ex) {
      modo_calculo = "Normal";
    }

    if (modo_calculo == "") modo_calculo = "Normal";
  }
}

class Produccion {
  int id = 0;
  int factura = 0;
  String clave_producto = "";
  String codigosap = "";
  String nombre_producto = "";
  double programado = 0.0;
  double producido = 0.0;
  double porcentaje = 0.0;
  int cajas = 0;
  double costo_maquila = 0.0;
  double valor_rescate = 0.0;
  double importe_maquila = 0.0;
  double importe_rescate = 0.0;
  double costo_salida = 0.0;
  double costo_pto_terminado = 0.0;
  double importe = 0.0;
  double importe_final = 0.0;

  Produccion();

  Produccion.fromMap(Map AMapa) {
    try {
      factura = AMapa["id_factura"];
    } catch (ex) {
      factura = 0;
    }

    id = AMapa["id"];
    clave_producto = AMapa["producto"];
    codigosap = AMapa["codigosap"];
    nombre_producto = AMapa["descripcion"];
    programado = AMapa["programado"].toDouble();
    producido = AMapa["producido"].toDouble();
    porcentaje = 0.0; //p_lista['porcentaje'];
    cajas = AMapa['cajas'];
    costo_maquila = AMapa['costo_maquila'].toDouble();

    importe_maquila = AMapa['importe_maquila'].toDouble();

    try {
      valor_rescate = AMapa['valor_rescate'].toDouble();
    } catch (ex) {
      valor_rescate = 0.0;
    }

    importe_maquila = producido * costo_maquila;
    importe_rescate = producido * valor_rescate;
    costo_pto_terminado = 0.0;
    importe = 0.0;
    costo_salida = 0.0;
  }
}
