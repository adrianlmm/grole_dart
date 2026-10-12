import 'dart:html';
import 'dart:convert';

HiddenInputElement inpFolio          = querySelector("#inpFolio");
InputElement inpDescripcion         = querySelector("#inpDescripcion");
InputElement inpClaveProducto       = querySelector("#inpClaveProducto");
InputElement inpDescripcionProducto = querySelector("#inpDescripcionProducto");
InputElement inpCantidad            = querySelector("#inpCantidad");
ButtonElement btnAgregar            = querySelector("#btnAgregar");
ButtonElement btnGuardar            = querySelector("#btnGuardar");
ButtonElement btnCancelar           = querySelector("#btnCancelar");
TableElement tableData              = querySelector("#tableData");
List<Map<int, String>> ListaDetalle = new List<Map<int, String>>();
int i = 99999;

void eliminaRegistro(int AId){
    ListaDetalle.removeWhere((Map item) => item["id"] == AId);
    (querySelector("#tr${AId}") as TableRowElement).remove();
}

void clearEdits(){

    inpClaveProducto.value = "";
    inpDescripcionProducto.value =  "";
    inpCantidad.value = "1";
  
}

inpClaveBlur(_){
  
    var pProducto = inpClaveProducto.value.trim();
    
    if (pProducto.length > 0){
        var pUrl = "http://localhost:8031/rest/productos/obtener_descripcion/${pProducto}";
        
        HttpRequest.getString(pUrl).then((String Data){
          
          Map pProducto = JSON.decode(Data);
          
          inpDescripcionProducto.value = pProducto["descripcion"];
        });
    }
  
}

Map obtenerFilaEntidad(){
    Map pResult = new Map();
    pResult["id"] = i;
    i++;
    pResult["producto"]    = inpClaveProducto.value;
    pResult["descripcion"] = inpDescripcionProducto.value;
    pResult["cajas"]       = inpCantidad.value;
    
    return pResult;
}

bool agregarFila(Map AItem){
    
    int pCantidad = 0;

    try{
      pCantidad = int.parse(AItem["cajas"]);
    }
    catch(_)
    {
      try{
        pCantidad = AItem["cajas"];
      }
      catch(__){
        pCantidad = 0;
      }
    }
    
    if ( pCantidad <= 0){
        window.alert("Cantidad no es válida");
        inpCantidad.select();
        inpCantidad.focus();
        return false;
    }
  
    if (ListaDetalle.where((Map item) => item["producto"] == AItem["producto"]).length > 0){
        window.alert("Error, el producto ya esta en la lista");
        inpClaveProducto.select();
        inpClaveProducto.focus();
        return false;
    }
    
    ListaDetalle.add(AItem);
  
    TableRowElement tr = new TableRowElement()..id = "tr${AItem["id"]}";
    
    TableCellElement td = new TableCellElement()..text = AItem["producto"];
    tr.children.add(td);
    td = new TableCellElement()..text = AItem["descripcion"];
    tr.children.add(td);
    td = new TableCellElement()..text = AItem["cajas"].toString();
    tr.children.add(td);
    
    ButtonElement btnEliminar = new Element.html("<button><i class='icon-trash'><i></button>");
    btnEliminar.onClick.listen((_){
      
        if (window.confirm("¿Eliminar Registro?")){
            eliminaRegistro(AItem["id"]);
        }
      
    });
    
    td = new TableCellElement()..children.add(btnEliminar);
    tr.children.add(td);
    tableData.tBodies[0].children.add(tr);
  
    return true;
}

String ObtenerEntidad(){
    Map pResult = new Map();
    pResult["id"] = int.parse(inpFolio.value);
    pResult["descripcion"] = inpDescripcion.value;
    pResult["detalle"] = ListaDetalle;
    
    return JSON.encode(pResult);
}

void guardar(){
  
    String pUrl = "http://localhost:8031/insertar_estimacion_empaque";
    String pData = ObtenerEntidad();
    
    HttpRequest.request(pUrl, method: "POST", sendData: pData).then((HttpRequest ARequest){
      
        window.location.href = "http://localhost:8031/estimacion_empaque";
      
    });
  
}

void cancelar(){
  if (window.confirm("¿Cancelar captura?")){
    window.location.href = "http://localhost:8031/estimacion_empaque";
  }
}

void despliegaEntidad(Map AEstimacion){
    
    inpDescripcion.value = AEstimacion["descripcion"];
    
    for (Map item in AEstimacion["detalle"]){
        agregarFila(item);
    }
  
}

void obtenerEstimacion(){
  
    var pUrl = "http://localhost:8031/rest/estimacion_empaque/${inpFolio.value}'";
    HttpRequest.getString(pUrl).then((String AData){
      
        Map pEstimacion = JSON.decode(AData);
        despliegaEntidad(pEstimacion);
      
    });
  
}

void main() {
    btnAgregar.onClick.listen((_){
        if (agregarFila(obtenerFilaEntidad())){
          clearEdits();
          inpClaveProducto.focus();
        }
    });
    
    inpClaveProducto.onBlur.listen((_){
        inpClaveBlur(_);
    });
    
    btnGuardar.onClick.listen((_){
        guardar();
    });
    
    btnCancelar.onClick.listen((_){
        cancelar();
    });
    
    obtenerEstimacion();
    
}
