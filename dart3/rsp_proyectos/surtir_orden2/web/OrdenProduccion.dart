library LibOrdenProduccion;

import 'dart:convert';
import 'package:intl/intl.dart';

class OrdenProduccion {
  int id;
  String fecha;
  int id_usuario;
  int id_usuario_embarques;
  int id_tipo;
  int id_programacion;
  String id_salida;
  String descripcion;
  double kilos_produccion;
  double rendimiento;
  String estado;
  String lote_produccion;
  double costo_maquila;
  double valor_rescate;
  double costo_salida;
  String modo_calculo;

  String ToJson() {
    Map p_map = new Map();

    p_map['id'] = this.id;
    p_map['fecha'] = this.fecha;
    p_map['id_usuario'] = this.id_usuario;
    p_map['id_usuario_embarques'] = this.id_usuario_embarques;
    p_map['id_tipo'] = this.id_tipo;
    p_map['descripcion'] = this.descripcion;
    p_map['kilos_produccion'] = this.kilos_produccion;
    p_map['rendimiento'] = this.rendimiento;
    p_map['estado'] = this.estado;
    p_map['lote_produccion'] = this.lote_produccion;
    //p_map['porcentaje']           = this.porcentaje;
    //p_map['cajas']                = this.cajas;
    p_map['costo_maquila'] = this.costo_maquila.toDouble();
    p_map['costo_maquila'] = this.valor_rescate.toDouble();
    p_map['costo_salida'] = this.costo_salida.toDouble();
    p_map['modo_calculo_costo'] = this.modo_calculo;

    return jsonEncode(p_map);
  }

  OrdenProduccion();

  OrdenProduccion.FromJSON(String AJSON) {
    var p_lista = jsonDecode(AJSON);

    this.id = p_lista['id'];

    String pFecha = p_lista['fecha'];
    pFecha = pFecha.substring(0, 10);

    print(pFecha);
    //pFecha = DateTime.parse(pFecha) as String;

    this.fecha = pFecha;
    this.id_usuario = p_lista['id_usuario'];
    this.id_usuario_embarques = p_lista['id_usuario_embarques'];
    this.id_tipo = p_lista['id_tipo'];
    this.id_programacion = p_lista['id_programacion'];
    this.descripcion = p_lista['descripcion'];
    this.kilos_produccion = p_lista['kilos_producccion'];
    this.rendimiento = p_lista['rendimiento'];
    this.estado = p_lista['estado'];
    this.lote_produccion = p_lista['lote_produccion'].toString();
    this.id_salida = p_lista['id_salida_embarques'].toString();
    this.costo_maquila = p_lista['costo_maquila'].toDouble();

    try {
      this.valor_rescate = p_lista['valor_rescate'].toDouble();
    } catch (ex) {
      this.valor_rescate = 0.0;
    }

    this.costo_salida = p_lista['costo_salida'].toDouble();

    try {
      this.modo_calculo = p_lista['modo_calculo_costo'].toDouble();
    } catch (ex) {
      this.modo_calculo = "Normal";
    }

    if (this.modo_calculo == null) this.modo_calculo = "Normal";
  }
}

class Produccion {
  int id;
  int factura;
  String clave_producto;
  String codigosap;
  String nombre_producto;
  double programado;
  double producido;
  double porcentaje;
  int cajas;
  double costo_maquila;
  double valor_rescate;
  double importe_maquila;
  double importe_rescate;
  double costo_salida;
  double costo_pto_terminado;
  double importe;

  Produccion();

  Produccion.fromMap(Map AMapa) {
    try {
      this.factura = AMapa["id_factura"];
    } catch (ex) {
      this.factura = 0;
    }

    this.id = AMapa["id"];
    this.clave_producto = AMapa["producto"];
    this.codigosap = AMapa["codigosap"];
    this.nombre_producto = AMapa["descripcion"];
    this.programado = AMapa["programado"].toDouble();
    this.producido = AMapa["producido"].toDouble();
    this.porcentaje = 0.0; //p_lista['porcentaje'];
    this.cajas = AMapa['cajas'];
    this.costo_maquila = AMapa['costo_maquila'].toDouble();

    this.importe_maquila = AMapa['importe_maquila'].toDouble();

    try {
      this.valor_rescate = AMapa['valor_rescate'].toDouble();
    } catch (ex) {
      this.valor_rescate = 0.0;
    }

    this.importe_maquila = this.producido * this.costo_maquila;
    this.importe_rescate = this.producido * this.valor_rescate;
    this.costo_pto_terminado = 0.0;
    this.importe = 0.0;
    this.costo_salida = 0.0;
  }
}
