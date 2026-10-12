library ConsultaMP;

import 'package:web_ui/web_ui.dart';
import 'package:web_ui/observe/observable.dart' as __observe;


@observable
class ConsultaMP extends Observable {
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
    int __$idOrden;
    int get idOrden {
      if (__observe.observeReads) {
        __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'idOrden');
      }
      return __$idOrden;
    }
    set idOrden(int value) {
      if (__observe.hasObservers(this)) {
        __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'idOrden',
            __$idOrden, value);
      }
      __$idOrden = value;
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
    DateTime __$fecha;
    DateTime get fecha {
      if (__observe.observeReads) {
        __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'fecha');
      }
      return __$fecha;
    }
    set fecha(DateTime value) {
      if (__observe.hasObservers(this)) {
        __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'fecha',
            __$fecha, value);
      }
      __$fecha = value;
    }
    int __$idSalida;
    int get idSalida {
      if (__observe.observeReads) {
        __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'idSalida');
      }
      return __$idSalida;
    }
    set idSalida(int value) {
      if (__observe.hasObservers(this)) {
        __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'idSalida',
            __$idSalida, value);
      }
      __$idSalida = value;
    }
    
    ConsultaMP.fromMap(Map AMap){
        this.id          = AMap['id'];
        this.idOrden     = AMap['id_orden'];
        this.producto    = AMap['producto'];
        this.descripcion = AMap['descripcion'];
        this.kilos       = AMap['kilos'].toDouble();
        this.surtido     = AMap['surtido'].toDouble();
        //2013-06-29 00:00:00
        String pFechaStr = AMap['fecha'];
        pFechaStr        = pFechaStr.substring(0, 10); 
        this.fecha       = DateTime.parse(pFechaStr);
        this.idSalida    = AMap['id_salida_embarques'];
    }
}
//# sourceMappingURL=consulta.dart.map