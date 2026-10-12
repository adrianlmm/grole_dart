library OrdenPP;

import 'dart:convert';

class OrdenMP{
  int id;
  int id_orden;
  int factura;
  String producto;
  String codigosap;
  String descripcion;
  double kilos;
  int cajas;
  double surtido;
  double producido;
  double rendimiento;
  double costo_salida;
  double importe_salida;
  double saldo_sap;
  
  String toJSON(){
    Map p_map = new Map();
    p_map['factura' ]       = this.factura;
    p_map['id']             = this.id;
    p_map['id_orden']       = this.id_orden;
    p_map['producto']       = this.producto;
    p_map['descripcion']    = this.descripcion;
    p_map['kilos']          = this.kilos;
    p_map['cajas']          = this.cajas;
    p_map['surtido']        = this.surtido;
    p_map['producido']      = this.producido;
    p_map['rendimiento']    = this.rendimiento;
    p_map['codigosap']      = this.codigosap;
    p_map['costo_salida']   = this.costo_salida.toDouble();
    p_map['importe_salida'] = this.importe_salida.toDouble();
    p_map['saldo_sap']      = this.saldo_sap.toDouble();
    
    return JSON.encode(p_map);
  }
  
  OrdenMP();
  
  OrdenMP.FromMap(Map AMap){
    
    try{
      this.factura = AMap['id'];
    }
    catch(ex){
      this.factura = 0;
    }
    
    this.id              = AMap['id'];
    this.id_orden        = AMap['id_orden'];
    this.producto        = AMap['producto'];
    this.codigosap       = AMap['codigosap'];
    this.descripcion     = AMap['descripcion'];
    this.kilos           = AMap['kilos'];
    this.cajas           = AMap['cajas_surtidas'];
    this.surtido         = AMap['surtido'];
    
    try{
      this.producido   = AMap['producido'];
      this.rendimiento = AMap['rendimiento'];
    }
    catch(error){
      this.producido   = 0.0;
      this.rendimiento = 0.0;
    }
    
    try{
      this.costo_salida   = AMap['costo_salida'].toDouble();  
    }
    catch(error){
      this.costo_salida   = 0.0;
    }
    
    try{
      this.importe_salida = AMap['importe_salida'].toDouble();
    }
    catch(error){
      this.importe_salida = 0.0;
    }
    
    try{
      this.saldo_sap      = AMap['saldo_sap'].toDouble();
    }
    catch(error){
      this.saldo_sap      = 0.0;
    }
   
  }
}