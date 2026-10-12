import 'dart:html';
import 'dart:json' as json;
import 'package:intl/intl.dart' as intl;

void llenaGrid(){
	var pUrl = "http://localhost:8031/rest/maquila/CostoMaquila_obtener_lista";
	
	HttpRequest.getString(pUrl).then((String Data){
	
		List<Map> pListaCostos = json.parse(Data);
		
		TableElement tableLista = document.query("#gridCostosMaquila");
		
		intl.DateFormat dateFormater = new intl.DateFormat("dd/MM/yyyy");
		intl.NumberFormat numberFormater = new intl.NumberFormat("00000");
		
		for (Map ACostoMaquila in pListaCostos){
		
				TableRowElement tr  = new TableRowElement()..id = 'tr${ACostoMaquila["id"].toString()}';
				TableCellElement td = new TableCellElement()..text = numberFormater.format(ACostoMaquila["id"]);
				tr.children.add(td);
				
				String pFechaS = ACostoMaquila["fecha"];
				
				int pYear = int.parse(pFechaS.substring(0, 4));
				int pMes  = int.parse(pFechaS.substring(5, 7));
				int pDia  = int.parse(pFechaS.substring(8, 10));
				
				DateTime pFecha = new DateTime(pYear, pMes, pDia);
		
				td = new TableCellElement()..text = dateFormater.format(pFecha);
				tr.children.add(td);
				
				pFechaS = ACostoMaquila["fechafinal"];
				
				pYear = int.parse(pFechaS.substring(0, 4));
				pMes  = int.parse(pFechaS.substring(5, 7));
				pDia  = int.parse(pFechaS.substring(8, 10));
				
				pFecha = new DateTime(pYear, pMes, pDia);
				
				td = new TableCellElement()..text = dateFormater.format(pFecha);
				tr.children.add(td);
				
				td = new TableCellElement()..text = ACostoMaquila["descripcion"];
				tr.children.add(td);
				td = new TableCellElement()..text = ACostoMaquila["activo"];
				tr.children.add(td);
		
				String pHtmlBtn = "<button class='btn button_edit''><i class='icon-edit'></i></button>";
				ButtonElement btn = new Element.html(pHtmlBtn)..id = 'btnEditar${ACostoMaquila["id"].toString()}'..onClick.listen((_){
		
					window.location.href = "http://localhost:8031/cat_costo_maquila/${ACostoMaquila["id"].toString()}";
		
				});
		
				td = new TableCellElement()..children.add(btn);
				
				tr.children.add(td);
				
				tableLista.tBodies[0].children.add(tr);
		}
	
	
	}, onError:(var Err){
		window.alert(Err.message);
	});
}

void agregaCostoMaquila(){
	window.location.href = "http://localhost:8031/cat_costo_maquila/0";
}

void main() {
  	llenaGrid();
		
	ButtonElement btnAgregar = document.query("#btnAgregar");
	btnAgregar.onClick.listen((var e){
		agregaCostoMaquila();
	});
}

