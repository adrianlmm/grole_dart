import 'dart:html';
import 'dart:convert' as json;
import 'package:intl/intl.dart' as intl;

String pFolio = "";
List<Map> pLista = null;
intl.NumberFormat pNumberFormat = new intl.NumberFormat("###,#0.00");
int pIndice = 9999999;

void _togleButtons(int AId){

	TableElement _tableLista = document.querySelector("#gridDetalleCostosMaquila");
	ButtonElement btnAceptar = _tableLista.tBodies[0].querySelector('#btnAceptar${AId.toString()}');
	ButtonElement btnEditar = _tableLista.tBodies[0].querySelector('#btnEditar${AId.toString()}');
	ButtonElement btnCancelar = _tableLista.tBodies[0].querySelector('#btnCancelar${AId.toString()}');
	ButtonElement btnEliminar = _tableLista.tBodies[0].querySelector('#btnEliminar${AId.toString()}');
	btnEditar.classes.toggle('oculto');
	btnAceptar.classes.toggle('oculto');
	btnCancelar.classes.toggle('oculto');
	btnEliminar.classes.toggle('oculto');
}

void editCostoMaquilaD(Map ACostoMaquilaD){
	TableElement tableLista = document.querySelector("#gridDetalleCostosMaquila");
	
	TableRowElement tr = tableLista.tBodies[0].querySelector("#tr${ACostoMaquilaD['id'].toString()}");
	_togleButtons(ACostoMaquilaD["id"]);
	
	tr.cells[0].text = '';
	InputElement pInputProducto = new InputElement()..id = "inpProducto${ACostoMaquilaD['id'].toString()}" ..value = ACostoMaquilaD['producto'].toString();
	
	pInputProducto.onBlur.listen((var e){
	
		obtenerDescripcionProducto(ACostoMaquilaD['id']);
	
	});
	
	tr.cells[0].children.add(pInputProducto);
	tr.cells[1].text = '';
	InputElement pInputDescripcion = new InputElement()..value..id="inpDescripcion${ACostoMaquilaD['id'].toString()}"..value = ACostoMaquilaD['descripcion']..readOnly = true;
	tr.cells[1].children.add(pInputDescripcion);
	tr.cells[2].text = '';
	InputElement pInputCosto = new InputElement()..id="inpCosto${ACostoMaquilaD['id'].toString()}"..value = ACostoMaquilaD['costo'].toString();
	tr.cells[2].children.add(pInputCosto);
	pInputProducto.focus();
	pInputProducto.select();
}

Map obtenerCosto(AId){
	return pLista.where((Map item) => item['id'] == AId).first;
}

void editarCosto(AId){

	String puedeAgregar = puedeAgregarProducto(AId);

	if (puedeAgregar.length == 0){
	
		String pProducto    = (document.querySelector("#inpProducto${AId.toString()}") as InputElement).value;
		String pDescripcion = (document.querySelector("#inpDescripcion${AId.toString()}") as InputElement).value;
		String pCostoS     = (document.querySelector("#inpCosto${AId.toString()}") as InputElement).value;
		
		Map pCosto = obtenerCosto(AId);
		pCosto["producto"]    = pProducto;
		pCosto["descripcion"] = pDescripcion;
		pCosto["costo"]       = double.parse(pCostoS);
		pCosto["dirty"]       = true;
		pCosto["deleted"]     = false;
	
		TableRowElement tr = document.querySelector("#tr${AId.toString()}");
		tr.cells[0].children.clear();
		tr.cells[0].text = pProducto;
		tr.cells[1].children.clear();
		tr.cells[1].text = pDescripcion;
		tr.cells[2].children.clear();
		tr.cells[2].text = pCostoS;
	
		_togleButtons(AId);
		
	}
	else{
		window.alert(puedeAgregar);
	}
}

void eliminarDetalleCosto(int AId){

	if (window.confirm("¿Eliminar Costo?")){
		Map pCosto = pLista.where((Map item) => item['id'] == AId).first;
		pCosto['deleted'] = true;
		pCosto['dirty']   = true;
		TableRowElement tr = document.querySelector("#tr${AId.toString()}");
		tr.remove();
	}
}

void cancelarEdicion(int AId){
	Map pCosto = pLista.where((Map item) => item["id"] == AId).first;
	
	TableRowElement tr = document.querySelector("#tr${AId.toString()}");
	tr.cells[0].children.clear();
	tr.cells[0].text = pCosto["producto"];
	tr.cells[1].children.clear();
	tr.cells[1].text = pCosto["descripcion"];
	tr.cells[2].children.clear();
	tr.cells[2].text = pNumberFormat.format(pCosto["costo"]);
	
	_togleButtons(AId);
}

void agregaFila(Map ACosto, [bool AAppend = true]){
	TableElement tableLista = document.querySelector("#gridDetalleCostosMaquila");
	
	TableRowElement tr  = new TableRowElement()..id = 'tr${ACosto["id"].toString()}';
	TableCellElement td = new TableCellElement()..text = ACosto["producto"];
	tr.children.add(td);
	td = new TableCellElement()..text = ACosto["descripcion"];
	tr.children.add(td);
	td = new TableCellElement()..text = pNumberFormat.format(ACosto["costo"].toDouble());
	tr.children.add(td);
	
	String pHtmlBtn = "<button class='btn'><i class='icon-edit'></i></button>";
	ButtonElement btn = new Element.html(pHtmlBtn)..id = 'btnEditar${ACosto["id"].toString()}'..onClick.listen((_){
	
		editCostoMaquilaD(ACosto);
	
	});
	
	td = new TableCellElement()..children.add(btn);
	
	pHtmlBtn = "<button class='btn edit_btn'><i class='icon-trash'></i></button>";
	btn = new Element.html(pHtmlBtn)..id = 'btnEliminar${ACosto["id"].toString()}'..onClick.listen((_){
	
		eliminarDetalleCosto(ACosto['id']);
	
	});
	
	td.children.add(btn);

	pHtmlBtn = "<button class='btn oculto'><i class='icon-ok'></i></button>";
	btn = new Element.html(pHtmlBtn)..id = 'btnAceptar${ACosto["id"].toString()}'..onClick.listen((_){
	
		editarCosto(ACosto["id"]);
	
	});
	
	td.children.add(btn);

	pHtmlBtn = "<button class='btn oculto edit_btn'><i class='icon-remove'></i></button>";
	btn = new Element.html(pHtmlBtn)..id = 'btnCancelar${ACosto["id"].toString()}'..onClick.listen((_){
	
		cancelarEdicion(ACosto["id"]);
	
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

void llenaGrid(){
	
	var pUrl = "http://localhost:8031/rest/maquila/CostoMaquilaD_obtener_lista/${pFolio}";
	
	HttpRequest.getString(pUrl).then((String Data){
	
		pLista = json.JSON.decode(Data);
		
		for (Map item in pLista){
			item["dirty"]  = false;
			item["deleted"] = true;
			agregaFila(item);
		}
	
	
	}
	,onError: (var ex) => (window.alert(ex.message) ));
	
	
}

bool productoEstaEnLaLista(String AProducto){
	
  int pCuenta = pLista.where((Map item) => item["producto"] == AProducto).toList().length;
	
  return pCuenta > 0;	

}

void limpiaEdits(){
	(document.querySelector("#inpProducto") as InputElement).value = "";
	(document.querySelector("#inpDescripcion") as InputElement).value = "";
	(document.querySelector("#inpCosto") as InputElement).value = "0.00";
	(document.querySelector("#inpProducto") as InputElement).focus();
}

String puedeAgregarProducto([int AId = 0]){
	String pClaveProducto = "";
	
	if (AId > 0){
		pClaveProducto = AId.toString();
	}
	
	String pProducto = (document.querySelector("#inpProducto${pClaveProducto}") as InputElement).value;
	
	if (pProducto.trim().length == 0){
		(document.querySelector("#inpProducto${pClaveProducto}") as InputElement).focus();
		return "El producto esta vacío";
	}
	
	String pCostoS = (document.querySelector("#inpCosto${pClaveProducto}") as InputElement).value;
	
	try
	{
		double pCosto = double.parse(pCostoS);
	}
	catch(ex){
		(document.querySelector("#inpCosto${pClaveProducto}") as InputElement).focus();
		return "El costo inválido";
	}
	
	/*if (productoEstaEnLaLista(pProducto)){
		(document.querySelector("#inpProducto${pClaveProducto}") as InputElement).focus();
		return "El producto ya esta en la lista";
	}*/
	
	return "";	
}

void agregarProducto(){
	
	String pPuedeAgregarProducto = puedeAgregarProducto();
	
	if (pPuedeAgregarProducto.length == 0){
	
		Map pCosto = new Map();
		pCosto["id"]          = pIndice;
		pIndice++;
		pCosto["id_costo"]    = int.parse(pFolio);
		pCosto["producto"]    = (document.querySelector("#inpProducto") as InputElement).value;
		pCosto["descripcion"] = (document.querySelector("#inpDescripcion") as InputElement).value;
		pCosto["costo"]       = double.parse((document.querySelector("#inpCosto") as InputElement).value);
		pCosto["dirty"]       = true;
		
		pLista.add(pCosto);
		
		agregaFila(pCosto, false);
		limpiaEdits();
	
	}
	else{
		window.alert(pPuedeAgregarProducto);
	}

}

void obtenerDescripcionProducto([int AId = 0]){
	
		String pClaveProducto = "";
		
		if (AId > 0){
			pClaveProducto = AId.toString();
		}

		String pProducto = (document.querySelector("#inpProducto${pClaveProducto}") as InputElement).value;
		if (pProducto.trim().length == 0){
		(document.querySelector("#inpProducto${pClaveProducto}") as InputElement).value = "";
			return;
		}
		else{
			var pUrl = "http://localhost:8031/rest/productos/obtener_descripcion/${pProducto}";
			
			HttpRequest.getString(pUrl).then((String Data){
			
				Map pProducto = json.JSON.decode(Data);
				(document.querySelector("#inpDescripcion${pClaveProducto}") as InputElement).value = pProducto["descripcion"];
				(document.querySelector("#inpCosto${pClaveProducto}") as InputElement).value = "0.00";
				(document.querySelector("#inpCosto${pClaveProducto}") as InputElement).select();
				(document.querySelector("#inpCosto${pClaveProducto}") as InputElement).focus();
			
			});
			
		}
}

void aceptar(){

	(document.querySelector("#btnAceptar") as ButtonElement).disabled = true;

	var pListaTmp = pLista.where((Map item) => item['dirty'] == true).toList();

	Map CostoMaquila = new Map();
	CostoMaquila['id']          = int.parse(pFolio);
	CostoMaquila['fecha']       = (document.querySelector("#inpFecha") as InputElement).value;
	CostoMaquila['fechafinal']  = (document.querySelector("#inpFechaFinal") as InputElement).value;
	CostoMaquila['descripcion'] = (document.querySelector("#inpDescripcionM") as InputElement).value;
	CostoMaquila['activo']      = (document.querySelector("#inpActivo") as SelectElement).value;
	CostoMaquila['detalle']     = pListaTmp;

	
	String data = json.JSON.encode(CostoMaquila);
	print(data);
	
	var pUrl = "http://localhost:8031/rest/maquila/CostoMaquilaD_insertar";
	
	HttpRequest.request(pUrl, method: "POST", mimeType:"application/json" , sendData: data , onProgress: (var e){}).then((HttpRequest ARequest){
	
		window.location.href = "http://localhost:8031/costos_maquila";
	
	});
	
}

void cancelar(){
	if (window.confirm("¿Cancelar Captura?")){
		window.location.href = "http://localhost:8031/costos_maquila";
	}
}

void main() {

	pFolio = (document.querySelector("#folio") as InputElement).value;
	
	SelectElement inpActivo = document.querySelector("#inpActivo");
	inpActivo.value = (document.querySelector("#activo") as InputElement).value;
		
	llenaGrid();

	InputElement inpProducto = document.querySelector("#inpProducto");
	
	inpProducto.onBlur.listen((var e){
		
		obtenerDescripcionProducto();	
	
	});
	
	ButtonElement btnAgregar = document.querySelector("#btnAgregar");
	
	btnAgregar.onClick.listen((var e){
		
		agregarProducto();	
	
	});
	
	ButtonElement btnAceptar = document.querySelector("#btnAceptar");
	
	btnAceptar.onClick.listen((var e){
		
		aceptar();	
	
	});
	
	ButtonElement btnCancelar = document.querySelector("#btnCancelar");
	
	btnCancelar.onClick.listen((var e){
		
		cancelar();	
	
	});
	
}

