library OrdenPP;

import 'package:web_ui/web_ui.dart';
import 'dart:json' as json;

@observable
class OrdenPP{
  int id;
  int id_orden;
  String producto;
  String descripcion;
  double kilos;
  double producido;
  double rendimiento;
  int receta;
  int cajas;
  
  String toJSON(){
    Map p_map = new Map();
    p_map['id']          = this.id;
    p_map['id_orden']    = this.id_orden;
    p_map['producto']    = this.producto;
    p_map['descripcion'] = this.descripcion;
    p_map['kilos']       = this.kilos;
    p_map['producido']   = this.producido;
    p_map['rendimiento'] = this.rendimiento;
    p_map['cajas']       = this.cajas;
    
    return json.stringify(p_map);
  }
  
  OrdenPP();
  
  OrdenPP.FromMap(Map AMap){
    
    this.id          = AMap['id'];
    this.id_orden    = AMap['id_orden'];
    this.producto    = AMap['producto'];
    this.descripcion = AMap['descripcion'];
    this.kilos       = AMap['kilos'];
    
    try{
      this.producido   = AMap['producido'];
      this.rendimiento = AMap['rendimiento'];
    }
    catch(error){
      this.producido   = 0.0;
      this.rendimiento = 0.0;
    }
    
    try{
      this.cajas       = AMap['cajas'];
    }
    catch(error){
      this.cajas       = 0;
    }
   
  }
}

