library OrdenMP;

import 'package:web_ui/web_ui.dart';
import 'dart:json' as json;

@observable
class OrdenMP{
  int id;
  int id_orden;
  String producto;
  String descripcion;
  double kilos = 0.0;
  double surtido = 0.0;
  double producido;
  double rendimiento;
  double saldo_sap;
  
  
  String toJSON(){
    Map p_map = new Map();
    p_map['id']          = this.id;
    p_map['id_orden']    = this.id_orden;
    p_map['producto']    = this.producto;
    p_map['descripcion'] = this.descripcion;
    p_map['kilos']       = this.kilos.toDouble();
    p_map['surtido']     = this.surtido.toDouble();
    p_map['producido']   = this.producido;
    p_map['rendimiento'] = this.rendimiento;
    p_map['saldo_sap']   = this.saldo_sap;
    
    return json.stringify(p_map);
  }
  
  OrdenMP();
  
  OrdenMP.FromMap(Map AMap){
    
    this.id          = AMap['id'];
    this.id_orden    = AMap['id_orden'];
    this.producto    = AMap['producto'];
    this.descripcion = AMap['descripcion'];
    this.kilos       = AMap['kilos'].toDouble();
    this.saldo_sap   = 0.0;
    
    try{
      this.surtido     = AMap['surtido'].toDouble();
      this.producido   = AMap['producido'];
      this.rendimiento = AMap['rendimiento'];
    }
    catch(error){
      this.surtido     = 0.0;
      this.producido   = 0.0;
      this.rendimiento = 0.0;
    }
   
  }
}

