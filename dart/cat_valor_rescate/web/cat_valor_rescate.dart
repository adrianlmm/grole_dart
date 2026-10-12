import 'dart:html';
import 'dart:convert';
import 'package:intl/intl.dart' as intl;

void llenaGrid(){
	var pUrl = "http://localhost:8031/rest/rescate/ValorRescate_obtener_lista";
	
	HttpRequest.getString(pUrl).then((String Data){
	
		List<Map> pLista = JSON.decode(Data);
		
		TableElement tableLista = querySelector("#gridLista");
		
		intl.DateFormat dateFormater = new intl.DateFormat("dd/MM/yyyy");
		intl.NumberFormat numberFormater = new intl.NumberFormat("00000");
		
		for (Map AItem in pLista){
		
				TableRowElement tr  = new TableRowElement()..id = 'tr${AItem["id"].toString()}';
				TableCellElement td = new TableCellElement()..text = numberFormater.format(AItem["id"]);
				tr.children.add(td);
				
				String pFechaS = AItem["fecha"];
				
				int pYear = int.parse(pFechaS.substring(0, 4));
				int pMes  = int.parse(pFechaS.substring(5, 7));
				int pDia  = int.parse(pFechaS.substring(8, 10));
				
				DateTime pFecha = new DateTime(pYear, pMes, pDia);
		
				td = new TableCellElement()..text = dateFormater.format(pFecha);
				tr.children.add(td);
				
				pFechaS = AItem["fechafinal"];
				
				pYear = int.parse(pFechaS.substring(0, 4));
				pMes  = int.parse(pFechaS.substring(5, 7));
				pDia  = int.parse(pFechaS.substring(8, 10));
				
				pFecha = new DateTime(pYear, pMes, pDia);
				
				td = new TableCellElement()..text = dateFormater.format(pFecha);
				tr.children.add(td);
				
				td = new TableCellElement()..text = AItem["descripcion"];
				tr.children.add(td);
				td = new TableCellElement()..text = AItem["activo"];
				tr.children.add(td);
		
				String pHtmlBtn = "<button class='btn button_edit''><i class='icon-edit'></i></button>";
				ButtonElement btn = new Element.html(pHtmlBtn)..id = 'btnEditar${AItem["id"].toString()}'..onClick.listen((_){
		
					window.location.href = "http://localhost:8031/cat_valor_rescate/${AItem["id"].toString()}";
		
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
	window.location.href = "http://localhost:8031/cat_valor_rescate/0";
}

void main() {
  	llenaGrid();
		
	ButtonElement btnAgregar = querySelector("#btnAgregar");
	btnAgregar.onClick.listen((var e){
		agregaCostoMaquila();
	});
}