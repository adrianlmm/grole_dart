import 'dart:html';
import 'dart:convert';

void llenaGrid(){
    var pUrl = "http://localhost:8031/rest/sobrantes";
    
    HttpRequest.getString(pUrl).then((String Data){
      
        List<Map> pLista = JSON.decode(Data);
        
        TableElement tableLista = querySelector("#gridLista");
        
        for (Map item in pLista){
          
          TableRowElement tr  = new TableRowElement()..id = 'tr${item["id"].toString()}';
          TableCellElement td = new TableCellElement()..text = item["producto"];
          tr.children.add(td);
          td = new TableCellElement()..text = item["descripcion"];
          tr.children.add(td);
          td = new TableCellElement()..text = item["activo"];
          tr.children.add(td);

          String pHtmlBtn = "<button class='btn'><i class='icon-edit'></i></button>";
          ButtonElement btn = new Element.html(pHtmlBtn)..id = 'btnEditar${item["id"].toString()}'..onClick.listen((_){
            
              window.location.href = "/sobrantes/${item["id"]}";
            
          });
          
          td = new TableCellElement()..children.add(btn);
          tr.children.add(td);
          
          pHtmlBtn = "<button class='btn'><i class='icon-trash'></i></button>";
          ButtonElement btnEliminar = new Element.html(pHtmlBtn)..id = 'btnEliminar${item["id"].toString()}'..onClick.listen((_){
            
             if (window.confirm("¿Eliminar Formula de Producción?")){
            
                var pUrl = 'http://localhost:8031/rest/sobrantes/eliminar/${item["id"]}';
              
                HttpRequest.request(pUrl, method: "DELETE", sendData: "").then((HttpRequest ARequest){
                  
                  TableRowElement tr_elim = (querySelector("#tr${item["id"].toString()}"));
                  tr_elim.remove();
                  
                });
             }
            
          });
          
          td.children.add(btnEliminar);
          
          tr.children.add(td);
          
          tableLista.tBodies[0].children.add(tr);
          
        }
      
    });
}

void main() {
  
    llenaGrid();
    
    ButtonElement btnAgregar = querySelector("#btnAgregar");
    btnAgregar.onClick.listen((_){
        window.location.href = "/sobrantes/0";
    });
  
}