import 'dart:html';
import 'dart:convert';
//import 'dart:math' as math;

InputElement inpOrden = querySelector("#inpOrden");
TableElement tablaUsoEmpaque = querySelector("#tablaUsoEmpaque");
ButtonElement btnConsultar = querySelector("#btnConsultar");

SpanElement spanTotalUsoEmpaque = querySelector("#spanTotalUsoEmpaque");
SpanElement spanTotalCantidadEntregada = querySelector("#spanTotalCantidadEntregada");
SpanElement spanTotalDiferencia = querySelector("#spanTotalDiferencia");
SpanElement spanTotalGeneral = querySelector("#spanTotalGeneral");

double pTotalCantidadUsada = 0.0;
double pTotalCantidadEntregada = 0.0;
double pTotalDiferencia = 0.0;
double pTotalGeneral = 0.0;

void agregarFila(Map AItem){
  
    TableRowElement tr = new TableRowElement()..id = "${AItem["id"]}";
    TableCellElement td = new TableCellElement()..text = AItem["id_orden"].toString();
    tr.children.add(td);
    td = new TableCellElement()..text = AItem["codigosap"];
    tr.children.add(td);
    td = new TableCellElement()..text = AItem["nombre"];
    tr.children.add(td);

    double pUsado = 0.0;

    try{
        pUsado = AItem["usado"].toDouble();
    }
    catch(_){
        pUsado = 0.0;
    }

    tr.children.add(td);
    td = new TableCellElement()..text = pUsado.toDouble().toStringAsFixed(2)..style.textAlign = "right";
    tr.children.add(td);
    double pCantidadEntregada = 0.0;
    
    try{
      pCantidadEntregada = AItem["cantidad_entregada"].toDouble();
    }
    catch(_){
      pCantidadEntregada = 0.0;
    }
    
    td = new TableCellElement()..text = pCantidadEntregada.toStringAsFixed(2)..style.textAlign = "right";
    tr.children.add(td);
    td = new TableCellElement()..text = (pCantidadEntregada - pUsado.toDouble()).toStringAsFixed(2)..style.textAlign = "right";
    tr.children.add(td);
    
    double pCosto = 0.0;
        
    try{
      pCosto = AItem["costo_empaque"].toDouble();
    }
    catch(_){
      pCosto = 0.0;
    }
    
    td = new TableCellElement()..text = pCosto.toDouble().toStringAsFixed(2)..style.textAlign = "right";
    tr.children.add(td);
    td = new TableCellElement()..text = (pCosto.toDouble() * pUsado).toStringAsFixed(2)..style.textAlign = "right";
    tr.children.add(td);
    
    tablaUsoEmpaque.tBodies[0].children.add(tr);
  
}

void consultar(){
      
  String pUrl = "http://localhost:8031/rest/obtener_uso_empaque_orden?orden=${inpOrden.value}";

  btnConsultar.disabled = true;
  HttpRequest.getString(pUrl).then((String Data){
    
      List<Map> pLista = JSON.decode(Data);
      
      pTotalCantidadUsada = 0.0;
      pTotalDiferencia = 0.0;
      pTotalGeneral = 0.0;
      pTotalCantidadEntregada = 0.0;
      
      tablaUsoEmpaque.tBodies[0].children.clear();

      String pCSV = "";

      print(pLista);
      for (Map item in pLista){
          agregarFila(item);

          try {

              pTotalCantidadUsada += item["usado"].toDouble();
          }
          catch(_){
              item["usado"] = 0.0;
              pTotalCantidadUsada += 0;
          }

          try{
            pTotalCantidadEntregada += item["cantidad_entregada"];
          }
          catch(_){
            pTotalCantidadEntregada += 0;
          }

          try{
            pTotalGeneral += ((item["usado"]) * item["costo_empaque"]);
          }
          catch(_){
            pTotalGeneral += 0;
          }

          double pCantidadEntregada = 0.0;
          try{
            pCantidadEntregada = item["cantidad_entregada"].toDouble();
          }
          catch(_){
            pCantidadEntregada = 0.0;
          }
          double pCosto = 0.0;
          try{
            pCosto = ((item["usado"]) * item["costo_empaque"]);
          }
          catch(_){
            pCosto = 0.0;
          }
          pCSV += inpOrden.value + "," + item["codigosap"] + "," + item["nombre"] + "," + item["usado"].toString() + ","  + pCantidadEntregada.toString() + "," + 
          (pCantidadEntregada - item["usado"]).toString() + "," + item["costo_empaque"].toString() + "," + pCosto.toString() + "\n";
      }

      print(pTotalCantidadUsada.runtimeType);
      spanTotalUsoEmpaque.innerHtml        = pTotalCantidadUsada.toStringAsFixed(2);
      spanTotalCantidadEntregada.innerHtml = pTotalCantidadEntregada.toStringAsFixed(2);
      spanTotalDiferencia.innerHtml        = (pTotalCantidadEntregada- pTotalCantidadUsada).toStringAsFixed(2);
      spanTotalGeneral.innerHtml           = pTotalGeneral.toStringAsFixed(2);

      AnchorElement pExcel = document.querySelector("#aExcel");
      String pData = new HtmlEscape().convert("ORDEN,CODIGO,DESCRIPCION,CANTIDAD_USADA,CANTIDAD PRODUCIDA,DIFERENCIA,COSTO,TOTAL\n");

      pExcel.href = "data:application/text," + pData + pCSV;

      btnConsultar.disabled = false;
  });
  
}

void init(){
   btnConsultar.onClick.listen((_){
       try {
           consultar();
       }
       finally{

       }
   });
}

void main() {
    init();
}