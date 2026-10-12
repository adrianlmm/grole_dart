library LibOrdenProduccion;
import 'package:web_ui/web_ui.dart';
import 'dart:json' as json;
import 'package:web_ui/observe/observable.dart' as __observe;


@observable
class OrdenProduccion extends Observable {
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
  String __$fecha;
  String get fecha {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'fecha');
    }
    return __$fecha;
  }
  set fecha(String value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'fecha',
          __$fecha, value);
    }
    __$fecha = value;
  }
  int __$id_usuario;
  int get id_usuario {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'id_usuario');
    }
    return __$id_usuario;
  }
  set id_usuario(int value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'id_usuario',
          __$id_usuario, value);
    }
    __$id_usuario = value;
  }
  int __$id_usuario_embarques;
  int get id_usuario_embarques {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'id_usuario_embarques');
    }
    return __$id_usuario_embarques;
  }
  set id_usuario_embarques(int value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'id_usuario_embarques',
          __$id_usuario_embarques, value);
    }
    __$id_usuario_embarques = value;
  }
  int __$id_tipo;
  int get id_tipo {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'id_tipo');
    }
    return __$id_tipo;
  }
  set id_tipo(int value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'id_tipo',
          __$id_tipo, value);
    }
    __$id_tipo = value;
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
  double __$kilos_produccion;
  double get kilos_produccion {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'kilos_produccion');
    }
    return __$kilos_produccion;
  }
  set kilos_produccion(double value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'kilos_produccion',
          __$kilos_produccion, value);
    }
    __$kilos_produccion = value;
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
  String __$estado;
  String get estado {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'estado');
    }
    return __$estado;
  }
  set estado(String value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'estado',
          __$estado, value);
    }
    __$estado = value;
  }
  int __$lote_produccion;
  int get lote_produccion {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'lote_produccion');
    }
    return __$lote_produccion;
  }
  set lote_produccion(int value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'lote_produccion',
          __$lote_produccion, value);
    }
    __$lote_produccion = value;
  }
  int __$clase;
  int get clase {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'clase');
    }
    return __$clase;
  }
  set clase(int value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'clase',
          __$clase, value);
    }
    __$clase = value;
  }
  String __$nombre_clase;
  String get nombre_clase {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'nombre_clase');
    }
    return __$nombre_clase;
  }
  set nombre_clase(String value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'nombre_clase',
          __$nombre_clase, value);
    }
    __$nombre_clase = value;
  }
  String __$folio_sap;
  String get folio_sap {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'folio_sap');
    }
    return __$folio_sap;
  }
  set folio_sap(String value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'folio_sap',
          __$folio_sap, value);
    }
    __$folio_sap = value;
  }
  String __$usuario;
  String get usuario {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'usuario');
    }
    return __$usuario;
  }
  set usuario(String value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'usuario',
          __$usuario, value);
    }
    __$usuario = value;
  }
  
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
    
    return json.stringify(p_map);
  }

  OrdenProduccion();
  
  OrdenProduccion.FromJSON(String AJSON){
    
    print(".....");
    print(AJSON);
    
    var p_lista = json.parse(AJSON);
    
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


//# sourceMappingURL=OrdenProduccion.dart.map