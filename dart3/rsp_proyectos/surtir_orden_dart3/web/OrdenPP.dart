// ignore_for_file: non_constant_identifier_names

library OrdenPP;

import 'dart:convert';

class OrdenMP {
  int id = 0;
  int id_orden = 0;
  int factura = 0;
  String producto = "";
  String codigosap = "";
  String descripcion = "";
  double kilos = 0.0;
  int cajas = 0;
  double surtido = 0.0;
  double producido = 0.0;
  double rendimiento = 0.0;
  double costo_salida = 0.0;
  double importe_salida = 0.0;
  double saldo_sap = 0.0;

  String toJSON() {
    Map p_map = {};
    p_map['factura'] = factura;
    p_map['id'] = id;
    p_map['id_orden'] = id_orden;
    p_map['producto'] = producto;
    p_map['descripcion'] = descripcion;
    p_map['kilos'] = kilos;
    p_map['cajas'] = cajas;
    p_map['surtido'] = surtido;
    p_map['producido'] = producido;
    p_map['rendimiento'] = rendimiento;
    p_map['codigosap'] = codigosap;
    p_map['costo_salida'] = costo_salida.toDouble();
    p_map['importe_salida'] = importe_salida.toDouble();
    p_map['saldo_sap'] = saldo_sap.toDouble();

    return jsonEncode(p_map);
  }

  OrdenMP();

  OrdenMP.FromMap(Map AMap) {
    try {
      factura = AMap['id'];
    } catch (ex) {
      factura = 0;
    }

    id = AMap['id'];
    id_orden = AMap['id_orden'];
    producto = AMap['producto'];
    codigosap = AMap['codigosap'];
    descripcion = AMap['descripcion'];
    kilos = AMap['kilos'];
    cajas = AMap['cajas_surtidas'] ?? 0;
    surtido = AMap['surtido'] ?? 0.00;

    try {
      producido = AMap['producido'];
      rendimiento = AMap['rendimiento'];
    } catch (error) {
      producido = 0.0;
      rendimiento = 0.0;
    }

    try {
      costo_salida = AMap['costo_salida'].toDouble();
    } catch (error) {
      costo_salida = 0.0;
    }

    try {
      importe_salida = AMap['importe_salida'].toDouble();
    } catch (error) {
      importe_salida = 0.0;
    }

    try {
      saldo_sap = AMap['saldo_sap'].toDouble();
    } catch (error) {
      saldo_sap = 0.0;
    }
  }
}
