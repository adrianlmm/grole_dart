import 'dart:convert';

class MovInventarioM{

    int Id;
    DateTime Fecha;
    String CardCode;
    String Cardname;
    String Observaciones;
    String Estado;
    int Pedimento;
    int Aduana;
    String Lugar_origen;
    String Nombre_origen;
    String Ciudad_destino;
    int Id_usuario;
    String Nombre_usuario;
    int Id_usuario_elimino;
    String Nombre_usuario_elimino;
    int Docentry;
    int Id_orden_produccion;
    DateTime Fechahorasistema;
    String Tipo_moviento;
    bool Dirty;

    MovInventarioM(this.Id, this.Fecha, this.CardCode, this.Cardname, this.Observaciones, this.Estado, this.Pedimento, this.Aduana, this.Lugar_origen, this.Nombre_origen, this.Ciudad_destino, this.Id_usuario, this.Nombre_usuario, this.Id_usuario_elimino, this.Nombre_usuario_elimino, this.Docentry, this.Id_orden_produccion, this.Fechahorasistema, this.Tipo_moviento, this.Dirty);

    MovInventarioM.fromMap(Map AMap){

        this.Id = AMap['id'];
        this.Fecha = AMap['fecha'];
        this.CardCode = AMap['cardcode'];
        this.Cardname = AMap['cardname'];
        this.Observaciones = AMap['observaciones'];
        this.Estado = AMap['estado'];
        this.Pedimento = AMap['pedimento'];
        this.Aduana = AMap['aduana'];
        this.Lugar_origen = AMap['lugar_origen'];
        this.Nombre_origen = AMap['nombre_origen'];
        this.Ciudad_destino = AMap['ciudad_destino'];
        this.Id_usuario = AMap['id_usuario'];
        this.Nombre_usuario = AMap['nombre_usuario'];
        this.Id_usuario_elimino = AMap['id_usuario_elimino'];
        this.Nombre_usuario_elimino = AMap['nombre_usuario_elimino'];
        this.Docentry = AMap['docentry'];
        this.Id_orden_produccion = AMap['id_orden_produccion'];
        this.Fechahorasistema = AMap['fechahorasistema'];
        this.Tipo_moviento = AMap['tipo_moviento'];

    }

    String toJSON(){
        Map pMapa = new Map();
        pMapa['id'] = this.Id;
        pMapa['fecha'] = this.Fecha;
        pMapa['cardcode'] = this.CardCode;
        pMapa['cardname'] = this.Cardname;
        pMapa['observaciones'] = this.Observaciones;
        pMapa['estado'] = this.Estado;
        pMapa['pedimento'] = this.Pedimento;
        pMapa['aduana'] = this.Aduana;
        pMapa['lugar_origen'] = this.Lugar_origen;
        pMapa['nombre_origen'] = this.Nombre_origen;
        pMapa['ciudad_destino'] = this.Ciudad_destino;
        pMapa['id_usuario'] = this.Id_usuario;
        pMapa['nombre_usuario'] = this.Nombre_usuario;
        pMapa['id_usuario_elimino'] = this.Id_usuario_elimino;
        pMapa['nombre_usuario_elimino'] = this.Nombre_usuario_elimino;
        pMapa['docentry'] = this.Docentry;
        pMapa['id_orden_produccion'] = this.Id_orden_produccion;
        pMapa['fechahorasistema'] = this.Fechahorasistema;
        pMapa['tipo_moviento'] = this.Tipo_moviento;

        return JSON.encode(pMapa);
    }
}