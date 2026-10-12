import 'dart:html';
import 'dart:convert';

List<Map> pLista = new List<Map>();
Map _Entidad;
int pId = 99999;

void _togleButtons(int AId){
    TableElement _tableLista = document.querySelector("#gridLista");
    ButtonElement btnAceptar = _tableLista.tBodies[0].querySelector('#btnAceptar${AId.toString()}');
    ButtonElement btnEditar = _tableLista.tBodies[0].querySelector('#btnEditar${AId.toString()}');
    ButtonElement btnCancelar = _tableLista.tBodies[0].querySelector('#btnCancelar${AId.toString()}');
    ButtonElement btnEliminar = _tableLista.tBodies[0].querySelector('#btnEliminar${AId.toString()}');
    btnEditar.classes.toggle('oculto');
    btnAceptar.classes.toggle('oculto');
    btnCancelar.classes.toggle('oculto');
    btnEliminar.classes.toggle('oculto');
}

void editEntidad(Map AEntidad){
    TableElement tableLista = document.querySelector("#gridLista");
    
    TableRowElement tr = tableLista.tBodies[0].querySelector("#tr${AEntidad['id'].toString()}");
    _togleButtons(AEntidad["id"]);
    
    tr.cells[0].text = '';
    InputElement pInputProducto = new InputElement()..id = "inpProducto${AEntidad['id'].toString()}" ..value = AEntidad['producto'].toString();
    
    pInputProducto.onBlur.listen((_){
      
        onEditProductoBlur(AEntidad["id"]);
      
    });
    
    tr.cells[0].children.add(pInputProducto);
    tr.cells[1].text = '';
    
    InputElement pInputDescripcion = new InputElement()..id = "inpDescripcion${AEntidad['id'].toString()}" ..value = AEntidad['descripcion'].toString();
    tr.cells[0].children.add(pInputDescripcion);
    tr.cells[1].text = '';
    
    tr.cells[1].children.add(pInputDescripcion);
    pInputProducto.focus();
    pInputProducto.select();
}

void eliminarEntidad(int AId){

  if (window.confirm("¿Eliminar Línea?")){
    
      Map pLinea = pLista.where((Map item) => item['id'] == AId).first;
      pLinea['deleted'] = true;
      pLinea['dirty']   = true;
      TableRowElement tr = document.querySelector("#tr${AId.toString()}");
      tr.remove();        
    
  }
  
}

String puedeAgregarEntidad([int AId = 0]){

    String pProducto = "";
    
    if (AId > 0){
      pProducto = AId.toString();
    }
    
    String pNombre = (document.querySelector("#inpDescripcion${pProducto}") as InputElement).value;
    
    if (pNombre.trim().length == 0){
        (document.querySelector("#inpProducto${pNombre}") as InputElement).focus();
        return "El producto no puede estar vacío";
    }
    
    /*if (lineaEstaEnLaLista(pNombre)){
      (document.querySelector("#inpNombre${pClaveLinea}") as InputElement).focus();
      return "La línea ya existe";
    }*/
    
    return "";    
  
}

Map obtenerEntidad(AId){
  return pLista.where((Map item) => item['id'] == AId).first;
}

void editarEntidad(AId){

  String puedeAgregar = puedeAgregarEntidad(AId);

  if (puedeAgregar.length == 0){
  
    String pProducto = (document.querySelector("#inpProducto${AId.toString()}") as InputElement).value;
    String pDescripcion = (document.querySelector("#inpDescripcion${AId.toString()}") as InputElement).value;
    
    Map pEntidad = obtenerEntidad(AId);
    pEntidad["producto"]    = pProducto;
    pEntidad["descripcion"] = pDescripcion;
    pEntidad["dirty"]       = true;
    pEntidad["deleted"]     = false;
  
    TableRowElement tr = document.querySelector("#tr${AId.toString()}");
    tr.cells[0].children.clear();
    tr.cells[0].text = pProducto;
    tr.cells[1].children.clear();
    tr.cells[1].text = pDescripcion;
  
    _togleButtons(AId);
    
  }
  else{
    window.alert(puedeAgregar);
  }
}

void cancelarEdicion(int AId){
    Map pLinea = pLista.where((Map item) => item["id"] == AId).first;
    
    TableRowElement tr = document.querySelector("#tr${AId.toString()}");
    tr.cells[0].children.clear();
    tr.cells[0].text = pLinea["producto"];
    tr.cells[1].children.clear();
    tr.cells[1].text = pLinea["descripcion"];
    
    _togleButtons(AId);
}

void agregaFila(Map AEntidad, [bool AAppend = true]){
    AEntidad["dirty"] = true;
    
    TableElement tableLista = document.querySelector("#gridLista");
    
    TableRowElement tr  = new TableRowElement()..id = 'tr${AEntidad["id"].toString()}';
    TableCellElement td = new TableCellElement()..text = AEntidad["producto"];
    tr.children.add(td);
    td = new TableCellElement()..text = AEntidad["descripcion"];
    tr.children.add(td);
    
    String pHtmlBtn = "<button class='btn'><i class='icon-edit'></i></button>";
    ButtonElement btn = new Element.html(pHtmlBtn)..id = 'btnEditar${AEntidad["id"].toString()}'..onClick.listen((_){
    
        editEntidad(AEntidad);
    
    });
    
    td = new TableCellElement()..children.add(btn);
    
    pHtmlBtn = "<button class='btn edit_btn'><i class='icon-trash'></i></button>";
    btn = new Element.html(pHtmlBtn)..id = 'btnEliminar${AEntidad["id"].toString()}'..onClick.listen((_){
    
        eliminarEntidad(AEntidad['id']);
    
    });
    
    td.children.add(btn);
  
    pHtmlBtn = "<button class='btn oculto'><i class='icon-ok'></i></button>";
    btn = new Element.html(pHtmlBtn)..id = 'btnAceptar${AEntidad["id"].toString()}'..onClick.listen((_){
    
        editarEntidad(AEntidad["id"]);
    
    });
    
    td.children.add(btn);
  
    pHtmlBtn = "<button class='btn oculto edit_btn'><i class='icon-remove'></i></button>";
    btn = new Element.html(pHtmlBtn)..id = 'btnCancelar${AEntidad["id"].toString()}'..onClick.listen((_){
    
        cancelarEdicion(AEntidad["id"]);
    
    });
    
    td.children.add(btn);
    
    tr.children.add(td);
    
    if (AAppend){
      tableLista.tBodies[0].children.add(tr);
    }
    else{
      tableLista.tBodies[0].children.insert(0,tr);
    }
}

void onClaveBlur(){
    
    String pClave = (querySelector("#inpClave") as InputElement).value;
    
    if (pClave.trim().length > 0){
      
        var pUrl = "http://localhost:8031/rest/productos/obtener_descripcion/${pClave}";
      
        HttpRequest.getString(pUrl).then((String Data){
          
            Map pData = JSON.decode(Data);
            (querySelector("#inpDescripcionM") as InputElement).value = pData["descripcion"];
            
        });
      
    }
}

void onProductoBlur(){
  
  String pClave = (querySelector("#inpProducto") as InputElement).value;
  
  if (pClave.trim().length > 0){
    
    var pUrl = "http://localhost:8031/rest/productos/obtener_descripcion/${pClave}";
    
    HttpRequest.getString(pUrl).then((String Data){
      
      Map pData = JSON.decode(Data);
      (querySelector("#inpDescripcion") as InputElement).value = pData["descripcion"];
      
    });
    
  }
}

void onEditProductoBlur(int AId){
  
  String pClave = (querySelector("#inpProducto${AId}") as InputElement).value;
  
  if (pClave.trim().length > 0){
    
    var pUrl = "http://localhost:8031/rest/productos/obtener_descripcion/${pClave}";
    
    HttpRequest.getString(pUrl).then((String Data){
      
      Map pData = JSON.decode(Data);
      (querySelector("#inpDescripcion${AId}") as InputElement).value = pData["descripcion"];
      
    });
    
  }
}

Map ObtenerEntidad(){
    String pFolio = (querySelector("#inpFolio") as HiddenInputElement).value;
    
    Map pEntidad = new Map();
    pEntidad["id"]       = pFolio;
    pEntidad["producto"] = (querySelector("#inpClave") as InputElement).value;
    pEntidad["activo"] = (querySelector("#inpActivo") as SelectElement).value;
    pEntidad["detalle"]  = pLista.where((Map item) => item['dirty'] == true).toList();
    
    return pEntidad;
}

void aceptar(){

    (document.querySelector("#btnAceptar") as ButtonElement).disabled = true;
  
    Map pEntidad = ObtenerEntidad();
  
    var pUrlExiste = "http://localhost:8031/rest/existe_sobrantes_producto/${pEntidad["producto"]}";
    print(pUrlExiste);
    
    HttpRequest.getString(pUrlExiste).then((String Data){
      
        bool pExiste = JSON.decode(Data);
        
        if (int.parse(pEntidad["id"]) > 0){
            pExiste = false;
        }
        
        if (pExiste){
            window.alert("Ya existe sobrantes de este producto");
            (document.querySelector("#btnAceptar") as ButtonElement).disabled = false;
            (document.querySelector("#inpClave") as InputElement).focus();
            return;
        }
        else{
          
            String pData = JSON.encode(pEntidad);
            print(pData);
            
            var pUrl = "http://localhost:8031/rest/sobrantes/insertar";
            
            HttpRequest.request(pUrl, method: "POST", mimeType:"application/json" , sendData: pData , onProgress: (var e){}).then((HttpRequest ARequest){
              
                Map pSobrante = JSON.decode(ARequest.responseText);
                window.alert("Se guardo con éxito, folio ${pSobrante["id"]}");
                window.location.href = "/sobrantes";
              
            });
        }
    });
  
}

void despliegaEntidad(Map AEntidad){
    
    (querySelector("#inpClave") as InputElement).value        = AEntidad["producto"];
    (querySelector("#inpDescripcionM") as InputElement).value = AEntidad["descripcion"];
    (querySelector("#inpActivo") as SelectElement).value      = AEntidad["activo"];
    
    for (Map item in AEntidad["detalle"]){
        item["dirty"]   = false;
        item["deleted"] = false;
        agregaFila(item, true);
    }
  
}

void inicializa(){
    
    String pFolio = (querySelector("#inpFolio") as HiddenInputElement).value;
    
    if (int.parse(pFolio) > 0){
        (querySelector("#inpClave") as InputElement).readOnly = true;
    }
  
    var pUrl = "http://localhost:8031/rest/sobrantes/${pFolio}";
    
    HttpRequest.getString(pUrl).then((String Data){
      
        _Entidad = JSON.decode(Data);
        pLista   = _Entidad["detalle"];
        
        despliegaEntidad(_Entidad);
        
    });
    
  
    InputElement pInpClave = querySelector("#inpClave") as InputElement;
    pInpClave.onBlur.listen((_){
      
        onClaveBlur();
      
    });
    
    InputElement pInpProducto = querySelector("#inpProducto") as InputElement;
    pInpProducto.onBlur.listen((_){
      
        onProductoBlur();
      
    });
    
    ButtonElement btnAgregar = querySelector("#btnAgregar") as ButtonElement;
    btnAgregar.onClick.listen((_){
      
        Map pData = new Map();
        pData["id"]          = pId;
        pId++;
        pData["producto"]    = (querySelector("#inpProducto") as InputElement).value;
        pData["descripcion"] = (querySelector("#inpDescripcion") as InputElement).value;
        
        agregaFila(pData);
        
        (querySelector("#inpProducto") as InputElement).value    = "";
        (querySelector("#inpDescripcion") as InputElement).value = "";
        (querySelector("#inpProducto") as InputElement).focus();
        
        pLista.add(pData);
      
    });
    
    ButtonElement btnAceptar = document.querySelector("#btnAceptar");
    
    btnAceptar.onClick.listen((var e){
      
        aceptar();  
      
    });
    
    ButtonElement btnCancelar = document.querySelector("#btnCancelar");
    
    btnCancelar.onClick.listen((var e){
      
        if (window.confirm("¿Cancelar captura?")){
            window.location.href = "/sobrantes";
        }
      
    });
}


void main() {
    
    inicializa();
  
}
