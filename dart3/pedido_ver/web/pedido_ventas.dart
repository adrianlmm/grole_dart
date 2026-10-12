library pedido_ventas;

import "dart:convert";

class PedidoVentas{
  int id;
  int Vendedor;
  String NombreVendedor;
  int Ruta;
  String NombreRuta;
  int Almacen;
  String NombreAlmacen;
  String fecha;
  int turno;
  String ocrcode;
  String ocrname;
  double saldo;
  double cantidad;
  double importe;
  String estado;
  String idUsuario;
  String idSucursal;
  String nombreSucursal;
  DateTime fechahorasistema;
  String fechaEntrega;
  String Observaciones;
  String Entrega;
  
  PedidoVentas(){
    this.cantidad       = 0.0;
    this.importe        = 0.0;
    this.estado         = "Nuevo";
    this.idUsuario      = "0";
    this.idSucursal     = "0";
    this.nombreSucursal = "???";
    this.fechahorasistema = new DateTime.now();
    this.fechaEntrega     = "";
    this.Observaciones    = "";
    this.Entrega          = "";
  }
  
  String toJson(Map<String, int> AProductosPrecioModificado){
     
      Map pMapa = new Map();
      pMapa["Id"]             = this.id;
      pMapa["Vendedor"]       = this.Vendedor;
      pMapa["NombreVendedor"] = this.NombreVendedor;
      pMapa["Ruta"]           = this.Ruta;
      pMapa["NombreRuta"]     = this.NombreRuta;
      pMapa["Almacen" ]       = this.Almacen;
      pMapa["NombreAlmacen" ] = this.NombreAlmacen;
      pMapa["Fecha"]          = this.fecha;
      pMapa["Turno"]          = this.turno;
      pMapa["OcrCode"]        = this.ocrcode;
      pMapa["OcrName"]        = this.ocrname;
      pMapa["Saldo"]          = this.saldo;
      pMapa["Cantidad"]       = this.cantidad;
      pMapa["Importe"]        = this.importe;
      pMapa["Estado"]         = this.estado;
      pMapa["IdUsuario"]      = int.parse(this.idUsuario);
      pMapa["IdSucursal"]     = int.parse(this.idSucursal);
      pMapa["NombreSucursal"] = this.nombreSucursal;
      pMapa["FechaEntrega"]   = this.fechaEntrega;
      pMapa["Observaciones"]  = this.Observaciones;
      pMapa["Entrega"]        = this.Entrega;
      
      List<int> pAutorizaciones = new List<int>();
      
      for(var item in AProductosPrecioModificado.values){
          pAutorizaciones.add(item);
      }
      
      pMapa["Autorizaciones"] = pAutorizaciones;
      
      
      return JSON.encode(pMapa);
  }
}
