library OrdenPP;

import 'package:web_ui/web_ui.dart';
import 'dart:json' as json;
import 'package:web_ui/observe/observable.dart' as __observe;


@observable
class OrdenMP extends Observable {
  int __$id;
  int get id {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'id');
    }
    return __$id;
  }
  set id(int value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'id',
          __$id, value);
    }
    __$id = value;
  }
  int __$id_orden;
  int get id_orden {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'id_orden');
    }
    return __$id_orden;
  }
  set id_orden(int value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'id_orden',
          __$id_orden, value);
    }
    __$id_orden = value;
  }
  int __$factura;
  int get factura {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'factura');
    }
    return __$factura;
  }
  set factura(int value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'factura',
          __$factura, value);
    }
    __$factura = value;
  }
  String __$producto;
  String get producto {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'producto');
    }
    return __$producto;
  }
  set producto(String value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'producto',
          __$producto, value);
    }
    __$producto = value;
  }
  String __$codigosap;
  String get codigosap {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'codigosap');
    }
    return __$codigosap;
  }
  set codigosap(String value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'codigosap',
          __$codigosap, value);
    }
    __$codigosap = value;
  }
  String __$descripcion;
  String get descripcion {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'descripcion');
    }
    return __$descripcion;
  }
  set descripcion(String value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'descripcion',
          __$descripcion, value);
    }
    __$descripcion = value;
  }
  double __$kilos;
  double get kilos {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'kilos');
    }
    return __$kilos;
  }
  set kilos(double value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'kilos',
          __$kilos, value);
    }
    __$kilos = value;
  }
  int __$cajas;
  int get cajas {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'cajas');
    }
    return __$cajas;
  }
  set cajas(int value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'cajas',
          __$cajas, value);
    }
    __$cajas = value;
  }
  double __$surtido;
  double get surtido {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'surtido');
    }
    return __$surtido;
  }
  set surtido(double value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'surtido',
          __$surtido, value);
    }
    __$surtido = value;
  }
  double __$producido;
  double get producido {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'producido');
    }
    return __$producido;
  }
  set producido(double value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'producido',
          __$producido, value);
    }
    __$producido = value;
  }
  double __$rendimiento;
  double get rendimiento {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'rendimiento');
    }
    return __$rendimiento;
  }
  set rendimiento(double value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'rendimiento',
          __$rendimiento, value);
    }
    __$rendimiento = value;
  }
  double __$costo_salida;
  double get costo_salida {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'costo_salida');
    }
    return __$costo_salida;
  }
  set costo_salida(double value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'costo_salida',
          __$costo_salida, value);
    }
    __$costo_salida = value;
  }
  double __$importe_salida;
  double get importe_salida {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'importe_salida');
    }
    return __$importe_salida;
  }
  set importe_salida(double value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'importe_salida',
          __$importe_salida, value);
    }
    __$importe_salida = value;
  }
  double __$saldo_sap;
  double get saldo_sap {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'saldo_sap');
    }
    return __$saldo_sap;
  }
  set saldo_sap(double value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'saldo_sap',
          __$saldo_sap, value);
    }
    __$saldo_sap = value;
  }
  
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
    
    return json.stringify(p_map);
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
//# sourceMappingURL=OrdenPP.dart.map