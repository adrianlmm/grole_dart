library DetalleMP;
import 'package:web_ui/web_ui.dart';
import 'package:web_ui/observe/observable.dart' as __observe;


@observable
class DetalleMP extends Observable {
    int __$tarimaOrigen;
    int get tarimaOrigen {
      if (__observe.observeReads) {
        __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'tarimaOrigen');
      }
      return __$tarimaOrigen;
    }
    set tarimaOrigen(int value) {
      if (__observe.hasObservers(this)) {
        __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'tarimaOrigen',
            __$tarimaOrigen, value);
      }
      __$tarimaOrigen = value;
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
    String __$codigoBarras;
    String get codigoBarras {
      if (__observe.observeReads) {
        __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'codigoBarras');
      }
      return __$codigoBarras;
    }
    set codigoBarras(String value) {
      if (__observe.hasObservers(this)) {
        __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'codigoBarras',
            __$codigoBarras, value);
      }
      __$codigoBarras = value;
    }
    double __$peso;
    double get peso {
      if (__observe.observeReads) {
        __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'peso');
      }
      return __$peso;
    }
    set peso(double value) {
      if (__observe.hasObservers(this)) {
        __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'peso',
            __$peso, value);
      }
      __$peso = value;
    }
 
    DetalleMP.fromMAP(Map AMap){
        this.tarimaOrigen = AMap["tarima_origen"];
        this.producto     = AMap["producto"];
        this.codigoBarras = AMap["codigobarras"];
        this.peso         = AMap["peso"].toDouble();
    }
}

@observable
class DetalleMPTarima extends Observable {
  int __$tarimaOrigen;
  int get tarimaOrigen {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'tarimaOrigen');
    }
    return __$tarimaOrigen;
  }
  set tarimaOrigen(int value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'tarimaOrigen',
          __$tarimaOrigen, value);
    }
    __$tarimaOrigen = value;
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
  
  DetalleMPTarima.fromMAP(Map AMap){
    this.tarimaOrigen = AMap["tarima_origen"];
    this.cajas        = AMap["cajas"];
    this.kilos        = AMap["kilos"].toDouble();
  }
}
//# sourceMappingURL=detalle_mp.dart.map