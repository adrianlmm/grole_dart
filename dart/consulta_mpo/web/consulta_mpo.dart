import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:json' as json;
import 'consulta.dart';

ObservableList<ConsultaMP> ListaConsulta = new ObservableList<ConsultaMP>();
ObservableList<ConsultaMP> ListaConsultaFitrada = new ObservableList<ConsultaMP>();
ObservableList<FiltroFecha> ListaFiltroFechas = new ObservableList<FiltroFecha>();
ObservableList<FiltroFolio> ListaFiltroFolio = new ObservableList<FiltroFolio>();
ObservableList<FiltroProducto> ListaFiltroProducto = new ObservableList<FiltroProducto>();
@observable double pTotalKilos = 0.0;
@observable double pTotalSurtido = 0.0;

bool marcadoFecha = true;
bool marcadoFolio = true;
bool marcadoProducto = true;

@observable
class FiltroFecha{
    DateTime fecha;
    bool checked;
    
    FiltroFecha(this.fecha, this.checked);
}

@observable
class FiltroFolio{
    int folio;
    bool checked;
    
    FiltroFolio(this.folio, this.checked);
}

@observable
class FiltroProducto{
    String producto;
    bool checked;
    
    FiltroProducto(this.producto, this.checked);
}

void filtraFecha(){
    ListaConsultaFitrada.clear();
    
    pTotalKilos   = 0.0;
    pTotalSurtido = 0.0;
    
    List<FiltroFecha> pFiltroFechaTmp = ListaFiltroFechas.where((FiltroFecha x) => (x.checked == true)).toList();
    
    for (ConsultaMP pConsulta in ListaConsulta){
        if (pFiltroFechaTmp.where((FiltroFecha x) => (x.fecha == pConsulta.fecha)).length > 0){
            ListaConsultaFitrada.add(pConsulta);
            
            pTotalKilos   += pConsulta.kilos;
            pTotalSurtido += pConsulta.surtido;
        }
    }
    
    muestraFiltroFecha();
}

void filtraFolio(){
  ListaConsultaFitrada.clear();
  
  pTotalKilos   = 0.0;
  pTotalSurtido = 0.0;
  
  List<FiltroFolio> pFiltroFolioTmp = ListaFiltroFolio.where((FiltroFolio x) => (x.checked == true)).toList();
  
  for (ConsultaMP pConsulta in ListaConsulta){
    if (pFiltroFolioTmp.where((FiltroFolio x) => (x.folio == pConsulta.idOrden)).length > 0){
      ListaConsultaFitrada.add(pConsulta);
      
      pTotalKilos   += pConsulta.kilos;
      pTotalSurtido += pConsulta.surtido;
    }
  }
  
  muestraFiltroFolio();
}

void filtraProducto(){
  ListaConsultaFitrada.clear();
  
  pTotalKilos   = 0.0;
  pTotalSurtido = 0.0;
  
  List<FiltroProducto> pFiltroProductoTmp = ListaFiltroProducto.where((FiltroProducto x) => (x.checked == true)).toList();
  
  for (ConsultaMP pConsulta in ListaConsulta){
    if (pFiltroProductoTmp.where((FiltroProducto x) => (x.producto == pConsulta.producto)).length > 0){
      ListaConsultaFitrada.add(pConsulta);
      
      pTotalKilos   += pConsulta.kilos;
      pTotalSurtido += pConsulta.surtido;
    }
  }
  
  muestraFiltroProducto();
}

muestraFiltroFecha(){
    document.query("#divFiltroFecha").classes.toggle("oculto");
}

muestraFiltroFolio(){
    document.query("#divFiltroOrden").classes.toggle("oculto");
}

muestraFiltroProducto(){
    document.query("#divFiltroProducto").classes.toggle("oculto");
}

void togleMarcadoFecha(){
    marcadoFecha = !marcadoFecha;
  
    for (FiltroFecha item in ListaFiltroFechas){
        item.checked = marcadoFecha;
    }
}

void togleMarcadoFolio(){
    marcadoFolio = !marcadoFolio;
  
    for (FiltroFolio item in ListaFiltroFolio){
        item.checked = marcadoFolio;
    }
}

void togleMarcadoProducto(){
    marcadoProducto = !marcadoProducto;
  
    for (FiltroProducto item in ListaFiltroProducto){
        item.checked = marcadoProducto;
    }
}

void exporta_consulta(){
  
  if (ListaConsultaFitrada.length > 0){
    AnchorElement pAnchorConsulta = document.query("#aConsulta");
    
    String pConsulta = "data:text/csv;charset=UTF-8,";
    
    pConsulta += Uri.encodeFull('Fecha,Folio,Producto,Descripcion,Kilos Req.,Surtido,Salida\n');
      
    intl.DateFormat pDateFormater = new intl.DateFormat("dd/MM/yyyy");
    
    for (ConsultaMP item in ListaConsultaFitrada){
        pConsulta +=  Uri.encodeFull(' ${pDateFormater.format(item.fecha)},${item.idOrden.toString()}, ${item.producto}, ${item.descripcion}, ${item.kilos.toString()},${item.surtido.toString()}, ${item.idSalida.toString()}\n');
    }
  
    pAnchorConsulta.href = pConsulta;
    pAnchorConsulta.click();
  }
  else{
    window.alert("La consulta esta vacía");
  }
}

void consultar(){
    String pFechaInicial = (document.query("#inpFechaInicial") as InputElement).value;
    String pFechaFinal   = (document.query("#inpFechaFinal") as InputElement).value;
  
    String pUrl = "http://localhost:8031/rest/ordenp/consulta_materia_prima?FechaInicial=${pFechaInicial}&FechaFinal=${pFechaFinal}";
    
    HttpRequest.getString(pUrl).then((String Data){
        ListaConsulta.clear();
        ListaConsultaFitrada.clear();
        ListaFiltroFechas.clear();
      
        List<Map> pLista = json.parse(Data);
        
        for (Map item in pLista){
          
            ConsultaMP pConsulta = new ConsultaMP.fromMap(item);
           
            if (ListaFiltroFechas.where((FiltroFecha x) => (x.fecha == pConsulta.fecha)).length == 0){
                ListaFiltroFechas.add(new FiltroFecha(pConsulta.fecha, true));
            }
            
            if (ListaFiltroFolio.where((FiltroFolio x) => (x.folio == pConsulta.idOrden)).length == 0){
                ListaFiltroFolio.add(new FiltroFolio(pConsulta.idOrden, true));
            }
            
            if (ListaFiltroProducto.where((FiltroProducto x) => (x.producto == pConsulta.producto)).length == 0){
                ListaFiltroProducto.add(new FiltroProducto(pConsulta.producto, true));
            }
            
            pTotalKilos   += pConsulta.kilos;
            pTotalSurtido += pConsulta.surtido;
          
            ListaConsulta.add(pConsulta);
            ListaConsultaFitrada.add(pConsulta);
        }
        
    });
  
}

void main() {
  
    (document.query("#inpFechaInicial") as InputElement).value = new intl.DateFormat("dd/MM/yyyy").format(new DateTime.now());
    (document.query("#inpFechaFinal") as InputElement).value = new intl.DateFormat("dd/MM/yyyy").format(new DateTime.now());
  
}
