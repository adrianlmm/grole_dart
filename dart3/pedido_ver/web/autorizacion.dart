library Autorizacion;

import "dart:convert";
import "dart:html";
import "dart:async";
import "package:intl/intl.dart" as intl;

class AutorizacionPedido{

  int Id;
  String CardCode;
  String CardName;
  String ItemCode;
  String ItemName;
  int Vendedor;
  String NombreVendedor;
  int Sucursal;
  String NombreSucursal;
  double Precio;
  String Estado;
  int IdUsuario;
  int IdUsuarioAutorizador;
  DateTime FechaHoraSistema;
  bool Dirty;
  String Tipo;
  String Descripcion;
  String Observaciones;
  int Nivel;

  AutorizacionPedido();
  AutorizacionPedido.withData(this.Id, this.CardCode, this.CardName, this.ItemCode, this.ItemName, this.Vendedor, this.NombreVendedor, this.Sucursal, this.NombreSucursal, this.Precio, this.Estado, this.IdUsuario, this.IdUsuarioAutorizador, this.FechaHoraSistema, this.Dirty);
  AutorizacionPedido.fromMap(Map AMap){


    this.Id                   = AMap['Id'];
    this.CardCode             = AMap['CardCode'];
    this.CardName             = AMap['CardName'];
    this.ItemCode             = AMap['ItemCode'];
    this.ItemName             = AMap['ItemName'];
    this.Vendedor             = AMap['Vendedor'];
    this.NombreVendedor       = AMap['NombreVendedor'];
    this.Sucursal             = AMap['Sucursal'];
    this.NombreSucursal       = AMap['NombreSucursal'];
    this.Precio               = AMap['Precio'].toDouble();
    this.Estado               = AMap['Estado'];
    this.IdUsuario            = AMap['IdUsuario'];
    this.IdUsuarioAutorizador = AMap['IdusuarioAutorizador'];
    this.FechaHoraSistema     = new DateTime.now();
    this.Descripcion          = AMap["Descripcion"];
    this.Observaciones        = AMap["Observaciones"];
    this.Nivel                = AMap["Nivel"];

  }

  String toJSON(){
      Map pMapa = new Map();
      pMapa['Id']                   = this.Id;
      pMapa['CardCode']             = this.CardCode;
      pMapa['CardName']             = this.CardName;
      pMapa['ItemCode']             = this.ItemCode;
      pMapa['ItemName']             = this.ItemName;
      pMapa['Vendedor']             = this.Vendedor;
      pMapa['NombreVendedor']       = this.NombreVendedor;
      pMapa['Sucursal']             = this.Sucursal;
      pMapa['NombreSucursal']       = this.NombreSucursal;
      pMapa['Precio']               = new intl.NumberFormat("######.00").format(this.Precio);
      pMapa['Estado']               = this.Estado;
      pMapa['IdUsuario']            = this.IdUsuario;
      pMapa['IdUsuarioAutorizador'] = this.IdUsuarioAutorizador;
      pMapa['FechahoraSistema']     = new DateTime.now().toString();
      pMapa['Tipo']                 = this.Tipo;
      pMapa['Descripcion']          = this.Descripcion;
      pMapa['Observaciones']        = this.Observaciones;
      pMapa['Nivel']                = this.Nivel;

      return JSON.encode(pMapa);
  }

  AutorizacionPedido autorizacionPedidoInsertar(){
      var pUrl = "http://localhost/webfrontend/MenuPedidos/AutorizacionPedidoInsertar";
      String pData = this.toJSON();

      AutorizacionPedido pAutorizacion = null;

      Map<String, String> pHeaders = new Map<String, String>();
      pHeaders["content-type"] = "application/json";

      Future pFuture = HttpRequest.request(pUrl, method: "POST", requestHeaders: pHeaders, sendData: pData).then((HttpRequest ARequest){

          print(ARequest.responseText);
          pAutorizacion = new AutorizacionPedido.fromMap(JSON.decode(ARequest.responseText));

      }, onError: (_) => (window.alert("Error al insertar Autorización")));

      Future.wait([pFuture]);

      return pAutorizacion;
  }

}