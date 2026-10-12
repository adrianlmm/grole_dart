library LibOrdenProduccion;
import 'package:web_ui/web_ui.dart';
import 'dart:json' as json;
import 'package:intl/intl.dart';
import 'package:web_ui/observe/observable.dart' as __observe;


class OrdenProduccion{
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
    p_map['lote_produccion']      = this.lote_produccion;
    p_map['porcentaje']           = this.porcentaje;
    p_map['cajas']                = this.cajas;
    p_map['costo_maquila']        = this.costo_maquila.toDouble();
    p_map['costo_maquila']        = this.valor_rescate.toDouble();
    p_map['costo_salida']         = this.costo_salida.toDouble();
    
    return json.stringify(p_map);
  }

  OrdenProduccion();
  
  OrdenProduccion.FromJSON(String AJSON){
    
    var p_lista = json.parse(AJSON);
    
    this.id = p_lista['id'];
    
    String pFecha = p_lista['fecha'];
    pFecha = pFecha.substring(0, 10);
    
    DateFormat pDateFormat = new DateFormat("dd/MM/yyyy");
    
    pFecha = pDateFormat.format(DateTime.parse(pFecha));
    
    this.fecha                = pFecha;
    this.id_usuario           = p_lista['id_usuario'];
    this.id_usuario_embarques = p_lista['id_usuario_embarques'];
    this.id_tipo              = p_lista['id_tipo'];
    this.id_programacion      = p_lista['id_programacion'];
    this.descripcion          = p_lista['descripcion'];
    this.kilos_produccion     = p_lista['kilos_producccion'];
    this.rendimiento          = p_lista['rendimiento'];
    this.estado               = p_lista['estado'];
    this.lote_produccion      = p_lista['lote_produccion'].toString();
    this.id_salida            = p_lista['id_salida_embarques'].toString();
    this.costo_maquila        = p_lista['costo_maquila'].toDouble();
    
    try{
      this.valor_rescate        = p_lista['valor_rescate'].toDouble();  
    }
    catch(ex){
      this.valor_rescate = 0.0;
    }
    
    this.costo_salida         = p_lista['costo_salida'].toDouble();
    
   
  }
}

@observable
class Produccion extends Observable {
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
    String __$clave_producto;
    String get clave_producto {
      if (__observe.observeReads) {
        __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'clave_producto');
      }
      return __$clave_producto;
    }
    set clave_producto(String value) {
      if (__observe.hasObservers(this)) {
        __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'clave_producto',
            __$clave_producto, value);
      }
      __$clave_producto = value;
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
    String __$nombre_producto;
    String get nombre_producto {
      if (__observe.observeReads) {
        __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'nombre_producto');
      }
      return __$nombre_producto;
    }
    set nombre_producto(String value) {
      if (__observe.hasObservers(this)) {
        __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'nombre_producto',
            __$nombre_producto, value);
      }
      __$nombre_producto = value;
    }
    double __$programado;
    double get programado {
      if (__observe.observeReads) {
        __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'programado');
      }
      return __$programado;
    }
    set programado(double value) {
      if (__observe.hasObservers(this)) {
        __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'programado',
            __$programado, value);
      }
      __$programado = value;
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
    double __$porcentaje;
    double get porcentaje {
      if (__observe.observeReads) {
        __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'porcentaje');
      }
      return __$porcentaje;
    }
    set porcentaje(double value) {
      if (__observe.hasObservers(this)) {
        __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'porcentaje',
            __$porcentaje, value);
      }
      __$porcentaje = value;
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
    double __$costo_maquila;
    double get costo_maquila {
      if (__observe.observeReads) {
        __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'costo_maquila');
      }
      return __$costo_maquila;
    }
    set costo_maquila(double value) {
      if (__observe.hasObservers(this)) {
        __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'costo_maquila',
            __$costo_maquila, value);
      }
      __$costo_maquila = value;
    }
    double __$valor_rescate;
    double get valor_rescate {
      if (__observe.observeReads) {
        __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'valor_rescate');
      }
      return __$valor_rescate;
    }
    set valor_rescate(double value) {
      if (__observe.hasObservers(this)) {
        __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'valor_rescate',
            __$valor_rescate, value);
      }
      __$valor_rescate = value;
    }
    double __$importe_maquila;
    double get importe_maquila {
      if (__observe.observeReads) {
        __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'importe_maquila');
      }
      return __$importe_maquila;
    }
    set importe_maquila(double value) {
      if (__observe.hasObservers(this)) {
        __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'importe_maquila',
            __$importe_maquila, value);
      }
      __$importe_maquila = value;
    }
    double __$importe_rescate;
    double get importe_rescate {
      if (__observe.observeReads) {
        __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'importe_rescate');
      }
      return __$importe_rescate;
    }
    set importe_rescate(double value) {
      if (__observe.hasObservers(this)) {
        __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'importe_rescate',
            __$importe_rescate, value);
      }
      __$importe_rescate = value;
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
    
    Produccion();
    
    Produccion.fromMap(Map AMapa){
      
        try{
            this.factura = AMapa["id_factura"];
        }
        catch(ex){
            this.factura = 0;
        }
        
        this.id              = AMapa["id"];
        this.clave_producto  = AMapa["producto"];
        this.codigosap       = AMapa["codigosap"];
        this.nombre_producto = AMapa["descripcion"];
        this.programado      = AMapa["programado"].toDouble();
        this.producido       = AMapa["producido"].toDouble();
        this.porcentaje      = 0.0;//p_lista['porcentaje'];
        this.cajas           = AMapa['cajas'];
        this.costo_maquila   = AMapa['costo_maquila'].toDouble();
        
        this.importe_maquila = AMapa['importe_maquila'].toDouble();
        
        try{
          this.valor_rescate   = AMapa['valor_rescate'].toDouble();
        }
        catch(ex){
          this.valor_rescate = 0.0;
        }
        
        this.importe_maquila = this.producido * this.costo_maquila;
        this.importe_rescate = this.producido * this.valor_rescate;
        this.costo_salida    = 0.0;
    }
}
//# sourceMappingURL=OrdenProduccion.dart.map