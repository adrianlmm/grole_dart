library LibOrdenProduccion;
import 'dart:convert';
import 'package:intl/intl.dart';

class OrdenProduccion{
  int id;
  String fecha;
  int id_usuario;
  int id_usuario_embarques;
  int id_tipo;
  String descripcion;
  double kilos_produccion;
  double rendimiento;
  String estado;
  String lote_produccion;
  int clase;
  String validar_productos;
  int pedimento;
  String valida_surtido_antes_producir;
  int FolioEmpaque;
  int lote_prod_marinador_1;
  int lote_prod_marinador_2;
  String proveedor_marinador_1;
  String proveedor_marinador_2;
  String producto_marinador_1;
  String producto_marinador_2;
  int lote_marinador_1;
  int lote_marinador_2;
  String folio_certificado_calidad_1;
  String folio_certificado_calidad_2;
  int lote_caliente;
  int granja_caliente;
  String fecha_caliente;
  String modo_calculo = "Normal";
  int id_cliente_maquila = 0;


  String ToJson(){
    Map p_map = new Map();

    p_map['id']                     = this.id;
    p_map['fecha']                  = this.fecha;
    p_map['id_usuario']             = this.id_usuario;
    p_map['id_usuario_embarques']   = this.id_usuario_embarques;
    p_map['id_tipo']                = this.id_tipo;
    p_map['descripcion']            = this.descripcion;
    p_map['kilos_produccion']       = this.kilos_produccion;
    p_map['rendimiento']            = this.rendimiento;
    p_map['estado']                 = this.estado;
    p_map['lote_produccion']        = this.lote_produccion;
    p_map['clase']                  = this.clase;
    p_map['validar_productos']      = this.validar_productos;
    p_map['pedimento']              = this.pedimento;
    p_map['valida_surtido_antes_producir'] = this.valida_surtido_antes_producir;
    p_map['salida_empaque']          = this.FolioEmpaque;
    p_map['lote_prod_marinador_1']   = this.lote_prod_marinador_1.toString();
    p_map['lote_prod_marinador_2']   = this.lote_prod_marinador_2.toString();
    p_map['proveedor_marinador_1']   = this.proveedor_marinador_1;
    p_map['proveedor_marinador_2']   = this.proveedor_marinador_2;
    p_map['lote_marinador_1']        = this.lote_marinador_1;
    p_map['lote_marinador_2']        = this.lote_marinador_2;
    p_map['producto_marinador_1']    = this.producto_marinador_1;
    p_map['producto_marinador_2']    = this.producto_marinador_2;
    p_map['lote_marinador_1']        = this.lote_marinador_1.toString();
    p_map['lote_marinador_2']        = this.lote_marinador_2.toString();
    p_map['folio_certificado_calidad_1'] = this.folio_certificado_calidad_1;
    p_map['folio_certificado_calidad_2'] = this.folio_certificado_calidad_2;
    p_map['lote_caliente']           = this.lote_caliente;
    p_map['granja_caliente']         = this.granja_caliente;
    p_map['fecha_caliente']          = this.fecha_caliente;
    p_map['modo_calculo_costo']      = this.modo_calculo;
    p_map['id_cliente_maquila']      = this.id_cliente_maquila;

    return JSON.encode(p_map);
  }

  OrdenProduccion();

  OrdenProduccion.FromJSON(String AJSON){

    var p_lista = JSON.decode(AJSON);

    this.id = p_lista['id'];

    String pFecha = p_lista['fecha'];
    pFecha = pFecha.substring(0, 10);

    DateFormat pDateFormat = new DateFormat("dd/MM/yyyy");

    pFecha = pDateFormat.format(DateTime.parse(pFecha));

    this.fecha                = pFecha;
    this.id_usuario           = p_lista['id_usuario'];
    this.id_usuario_embarques = p_lista['id_usuario_embarques'];
    this.id_tipo              = p_lista['id_tipo'];
    this.descripcion          = p_lista['descripcion'];
    this.kilos_produccion     = p_lista['kilos_producccion'];
    this.rendimiento          = p_lista['rendimiento'];
    this.estado               = p_lista['estado'];
    this.lote_produccion      = p_lista['lote_produccion'].toString();
    this.clase                = p_lista['clase'];
    this.validar_productos    = p_lista['validar_productos'];

    this.valida_surtido_antes_producir = p_lista['valida_surtido_antes_producir'];

    if (this.valida_surtido_antes_producir ==  null){
        this.valida_surtido_antes_producir = 'No';
    }

    try
    {
      this.pedimento            = p_lista['pedimento'];
    }
    catch(Ex){
      this.pedimento = 0;
    }

    try
    {
        this.FolioEmpaque = p_lista['salida_empaque'];
        if (this.FolioEmpaque.isNaN){
          this.FolioEmpaque = 0;
        }
    }
    catch(Ex){
        this.FolioEmpaque = 0;
    }

    this.lote_prod_marinador_1 = p_lista['lote_prod_marinador_1'];
    this.lote_prod_marinador_2 = p_lista['lote_prod_marinador_2'];
    this.proveedor_marinador_1 = p_lista['proveedor_marinador_1'];
    this.proveedor_marinador_2 = p_lista['proveedor_marinador_2'];
    this.lote_marinador_1      = p_lista['lote_marinador_1'];
    this.lote_marinador_2      = p_lista['lote_marinador_2'];
    this.producto_marinador_1  = p_lista['producto_marinador_1'];
    this.producto_marinador_2  = p_lista['producto_marinador_2'];
    this.lote_marinador_1      = p_lista['lote_marinador_1'];
    this.lote_marinador_2      = p_lista['lote_marinador_2'];
    this.folio_certificado_calidad_1 = p_lista['folio_certificado_calidad_1'];
    this.folio_certificado_calidad_2 = p_lista['folio_certificado_calidad_2'];

    try
    {
        this.lote_caliente = p_lista['lote_caliente'];
        if (this.lote_caliente.isNaN){
          this.lote_caliente = 0;
        }
    }
    catch(Ex){
        this.lote_caliente = 0;
    }

    try
    {
      this.granja_caliente = p_lista['lote_caliente'];
      if (this.granja_caliente.isNaN){
        this.granja_caliente = 0;
      }
    }
    catch(Ex){
      this.granja_caliente = 0;
    }

    try
    {
      this.fecha_caliente = p_lista['fecha_caliente'].toString();
    }
    catch(Ex){
      this.fecha_caliente = "";
    }

    try
    {
      this.modo_calculo = p_lista['modo_calculo_costo'];
    }
    catch(Ex){
      this.modo_calculo = "Normal";
    }

    try{
      this.id_cliente_maquila = p_lista["id_cliente_maquila"];
    }
    catch(_){
        this.id_cliente_maquila = 1001;
    }

   }
}

