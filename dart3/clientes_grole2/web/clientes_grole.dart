import 'dart:html';
import "dart:convert";
import "modal_p.dart" as ModalP;

TableElement pTable = querySelector("#tablaClientes");
InputElement inpCliente = querySelector("#inpCliente");
InputElement inpClienteEditar = querySelector("#inpClienteEditar");
InputElement inpClaveClienteEditar = querySelector("#inpClaveClienteEditar");
InputElement inpBuscar = querySelector("#inpBuscar");

void eliminarCliente(int AId){
    if (window.confirm("¿Eliminar Cliente?")){
        
        var pUrl = "http://localhost:8031/rest/salidas/cliente_eliminar/${AId}";
        
        HttpRequest.request(pUrl, method: "POST", sendData: "${AId}").then((HttpRequest ARequest){
            
            Map pResult = jsonDecode(ARequest.responseText);
            if (pResult["error"]){
                window.alert(pResult["mensaje"]);
                return;
            }
            else{
                (querySelector("#tr${AId}") as TableRowElement).remove();
            }
        });
    };
}

void agregaFila(Map AItem){
    
    print(AItem);
    TableRowElement tr = new TableRowElement()..id = "tr${AItem["id"]}";
    TableCellElement td = new TableCellElement()..text = AItem["nombre"];
    tr.children.add(td);
    
    ButtonElement btnEliminar = new Element.html("<button class='btn'><i class='icon-trash'></i></button>")..style.marginLeft = "5px"..onClick.listen((_){
        eliminarCliente(AItem["id"]);
    });
    
    td = new TableCellElement()..children.add(btnEliminar);
    
    ButtonElement btnEditar = new Element.html("<button class='btn'><i class='icon-edit'></i></button>")..style.marginLeft = "5px"..onClick.listen((_){
        editarCliente(AItem);
    });
    
    td.children.add(btnEditar);
    
    tr.children.add(td);
    
    pTable.tBodies[0].children.add(tr);
    
}

void modificaFila(Map AItem){
    
    TableRowElement tr = querySelector("#tr${AItem["id"]}");
    tr.children[0].text = AItem["nombre"];
    
}

void llenaGrid(){
    
    var pUrl  = "http://localhost:8031/rest/salidas/get_clientes";
    
    HttpRequest.getString(pUrl).then((String Data){
        
        var pLista = jsonDecode(Data);
        
        for (Map item in pLista){
            agregaFila(item);
        }
        
    });
    
}

void capturaNuevoCliente(){
    ModalP.modal("mdlNuevo");
    (querySelector("#inpCliente") as InputElement).value = "";
    (querySelector("#inpCliente") as InputElement).focus();
}

void agregarCliente(){
    
    var pUrl = "http://localhost:8031/rest/salidas/cliente_insertar";
    Map pCliente = new Map();
    pCliente["id"]     = 0;
    pCliente["nombre"] = inpCliente.value;
    
    HttpRequest.request(pUrl, method: "POST", sendData: jsonEncode(pCliente)).then((HttpRequest ARequest){
        Map pClienteResult = jsonDecode(ARequest.responseText);
        agregaFila(pClienteResult);
        inpCliente.value = "";
        inpCliente.focus();
    });
}

void editarCliente(Map AItem){
    inpClaveClienteEditar.value = AItem["id"].toString();
    inpClienteEditar.value = AItem["nombre"];
    ModalP.modal("mdlEditar");
    inpClienteEditar.focus();
    inpClienteEditar.select();
    
}

void modificaCliente(){
    var pUrl = "http://localhost:8031/rest/salidas/cliente_insertar";
    Map pCliente = new Map();
    pCliente["id"]     = inpClaveClienteEditar.value;
    pCliente["nombre"] = inpClienteEditar.value;
    
    HttpRequest.request(pUrl, method: "POST", sendData: jsonEncode(pCliente)).then((HttpRequest ARequest){
        Map pClienteResult = jsonDecode(ARequest.responseText);
        modificaFila(pClienteResult);
        ModalP.cierra_modal("mdlEditar");
    });
}

void buscar(){
    ModalP.modal("mdlBuscar");
    inpBuscar.focus();
    inpBuscar.select();
}

void buscaCliente(){
    var pUrl = "http://localhost:8031/rest/salidas/get_cliente_por_nombre/*";
    
    if (inpBuscar.value.trim().length > 0){
        pUrl = "http://localhost:8031/rest/salidas/get_cliente_por_nombre/${inpBuscar.value}";
    }
    
    HttpRequest.getString(pUrl).then((String Data){
       
        var pLista = jsonDecode(Data);
        
        pTable.tBodies[0].children.clear();
        for (Map item in pLista){
            agregaFila(item);
        }       
        
        ModalP.cierra_modal("mdlBuscar");
    });
}

void init(){
    
    (querySelector("#btnNuevo") as ButtonElement).onClick.listen((_){
        capturaNuevoCliente();
    });
    
    (querySelector("#btnAceptarCliente") as InputElement).onClick.listen((_){
        agregarCliente();
    });
    
    (querySelector("#btnAceptarClienteEditar") as InputElement).onClick.listen((_){
        modificaCliente();
    });
    
    (querySelector("#btnCancelarCliente") as InputElement).onClick.listen((_){
        ModalP.cierra_modal("mdlNuevo");
    });
    
    (querySelector("#btnCancelarClienteEditar") as InputElement).onClick.listen((_){
        ModalP.cierra_modal("mdlEditar");
    });
    
    (querySelector("#btnBuscar") as ButtonElement).onClick.listen((_){
        buscar();
    });
    
    (querySelector("#btnAceptarBusqueda") as InputElement).onClick.listen((_){
        buscaCliente();
    });
    
    (querySelector("#btnCancelarBusqueda") as InputElement).onClick.listen((_){
        ModalP.cierra_modal("mdlBuscar");
    });
    
}

void main() {
    init();
    llenaGrid();
}