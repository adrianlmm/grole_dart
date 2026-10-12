import 'dart:html';
import 'dart:convert';
import 'package:intl/intl.dart' as intl;

String pFolio = '';
var pLista = <dynamic>[];
intl.NumberFormat pNumberFormat = intl.NumberFormat('###,#0.00');
int pIndice = 9999999;

InputElement inpDescripcionM = querySelector('#inpDescripcionM');
SelectElement inpActivo = querySelector('#inpActivo');
InputElement inpFecha = querySelector('#inpFecha');
InputElement inpFechaFinal = querySelector('#inpFechaFinal');

dynamic CostoMaquilaObtener(int AId) async{

  var pUrl = 'http://localhost:8031/rest/maquila/CostoMaquila_obtener/$AId';

  var pData = await HttpRequest.getString(pUrl);

  return jsonDecode(pData);

}

void _togleButtons(int AId){

	TableElement _tableLista = document.querySelector('#gridDetalleCostosMaquila');
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
	TableElement tableLista = document.querySelector('#gridDetalleCostosMaquila');
	
	TableRowElement tr = tableLista.tBodies[0].querySelector('#tr${ACostoMaquilaD['id'].toString()}');
	_togleButtons(ACostoMaquilaD['id']);
	
	tr.cells[0].text = '';
	var pInputProducto = InputElement()..id = 'inpProducto${ACostoMaquilaD['id'].toString()}' ..value = ACostoMaquilaD['producto'].toString();
	
	pInputProducto.onBlur.listen((var e){
	
		obtenerDescripcionProducto(ACostoMaquilaD['id']);
	
	});
	
	tr.cells[0].children.add(pInputProducto);
	tr.cells[1].text = '';
	var pInputDescripcion = InputElement()..value..id='inpDescripcion${ACostoMaquilaD['id']}'..value = ACostoMaquilaD['descripcion']..readOnly = true;
	tr.cells[1].children.add(pInputDescripcion);
	tr.cells[2].text = '';
	var pInputCosto = InputElement()..id='inpCosto${ACostoMaquilaD['id'].toString()}'..value = ACostoMaquilaD['costo'].toString();
	tr.cells[2].children.add(pInputCosto);

  var pInputCC = SelectElement();
  pInputCC.id = "inpCC${ACostoMaquilaD['id']}";
  pInputCC.children.add(Element.html("<option value='DE1'>DE1 Sacrificio</option>"));
  pInputCC.children.add(Element.html("<option value='DE2'>DE2 Corte</option>"));
  pInputCC.children.add(Element.html("<option value='DE3'>DE3 Porcionados</option>"));
  pInputCC.children.add(Element.html("<option value='DE25'>DE25 Mejorado de Cerdos</option>"));
  pInputCC.children.add(Element.html("<option value='DE26'>DE26 Mejorado de Ave</option>"));
  pInputCC.children.add(Element.html("<option value='DE27'>DE27 Ahumados</option>"));
  pInputCC.children.add(Element.html("<option value='DE30'>DE30 Procesados Crudo</option>"));
  pInputCC.value = ACostoMaquilaD['cc'];
  tr.cells[3].text = '';
  tr.cells[3].children.add(pInputCC);

	pInputCC.focus();
	
}

Map obtenerCosto(AId){
	return pLista.where((var item) => item['id'] == AId).first;
}

void editarCosto(AId){

	var puedeAgregar = puedeAgregarProducto(AId);

	if (puedeAgregar.isEmpty){
	
		var pProducto    = (document.querySelector('#inpProducto${AId.toString()}') as InputElement).value;
		var pDescripcion = (document.querySelector('#inpDescripcion${AId.toString()}') as InputElement).value;
		var pCostoS     = (document.querySelector('#inpCosto${AId.toString()}') as InputElement).value;

    var pSelectCC  = (document.querySelector('#inpCC${AId.toString()}') as SelectElement);
    var pCC        = pSelectCC.value;
    var pNombreCC  = pSelectCC.options[pSelectCC.selectedIndex].text;
		
		var pCosto = obtenerCosto(AId);
		pCosto['producto']    = pProducto;
		pCosto['descripcion'] = pDescripcion;
		pCosto['costo']       = double.parse(pCostoS);
		pCosto['cc']          = pCC;
    pCosto['dirty']       = true;
		pCosto['deleted']     = false;
	
		TableRowElement tr = document.querySelector('#tr${AId.toString()}');
		tr.cells[0].children.clear();
		tr.cells[0].text = pProducto;
		tr.cells[1].children.clear();
		tr.cells[1].text = pDescripcion;
		tr.cells[2].children.clear();
		tr.cells[2].text = pCostoS;
    tr.cells[3].children.clear();
    tr.cells[3].dataset['CC'] = pCC;
		tr.cells[3].text = pNombreCC;
	
		_togleButtons(AId);
		
	}
	else{
		window.alert(puedeAgregar);
	}
}

void eliminarDetalleCosto(int AId){

	if (window.confirm('¿Eliminar Costo?')){
		var pCosto = pLista.where((var item) => item['id'] == AId).first;
		pCosto['deleted'] = true;
		pCosto['dirty']   = true;
		TableRowElement tr = document.querySelector('#tr${AId.toString()}');
		tr.remove();
	}
}

void cancelarEdicion(int AId){
	var pCosto = pLista.where((var item) => item['id'] == AId).first;

  print(pCosto);
	
	TableRowElement tr = document.querySelector('#tr${AId.toString()}');
	tr.cells[0].children.clear();
	tr.cells[0].text = pCosto['producto'];
	tr.cells[1].children.clear();
	tr.cells[1].text = pCosto['descripcion'];
	tr.cells[2].children.clear();
	tr.cells[2].text = pNumberFormat.format(pCosto['costo']);
  tr.cells[3].children.clear();
	tr.cells[3].dataset['CC'] = pCosto['cc'];
  tr.cells[3].text = obtenerNombreCC(pCosto['cc']);
	
	_togleButtons(AId);
}

String obtenerNombreCC(String ACC){
  switch (ACC){
      case 'DE1': return 'DE1 Sacrificio';
      case 'DE2': return 'DE2 Corte';
      case 'DE3': return 'DE3 Porcionados';
      case 'DE25': return 'DE25 Mejorado de Cerdos';
      case 'DE26': return 'DE26 Mejorado de Ave';
      case 'DE27': return 'DE27 Ahumados';
      case 'DE30': return 'DE30 Procesados Crudo';
      default: return '???';
  }
}

void agregaFila(Map ACosto, [bool AAppend = true]){
	TableElement tableLista = document.querySelector('#gridDetalleCostosMaquila');
	
	var tr  = TableRowElement()..id = 'tr${ACosto['id'].toString()}';
	var td = TableCellElement()..text = ACosto['producto'];
	tr.children.add(td);
	td = TableCellElement()..text = ACosto['descripcion'];
	tr.children.add(td);
	td = TableCellElement()..text = pNumberFormat.format(ACosto['costo'].toDouble());
  tr.children.add(td);
  td = TableCellElement()..dataset['CC'] = ACosto['cc']..text = obtenerNombreCC(ACosto['cc']);
	tr.children.add(td);

	var pHtmlBtn = "<button class='btn'><i class='icon-edit'></i></button>";
	ButtonElement btn = Element.html(pHtmlBtn)..id = 'btnEditar${ACosto['id'].toString()}'..onClick.listen((_){
	
		editCostoMaquilaD(ACosto);
	
	});
	
	td = TableCellElement()..children.add(btn);
	
	pHtmlBtn = "<button class='btn edit_btn'><i class='icon-trash'></i></button>";
	btn = Element.html(pHtmlBtn)..id = 'btnEliminar${ACosto['id'].toString()}'..onClick.listen((_){
	
		eliminarDetalleCosto(ACosto['id']);
	
	});
	
	td.children.add(btn);

	pHtmlBtn = "<button class='btn oculto'><i class='icon-ok'></i></button>";
	btn = Element.html(pHtmlBtn)..id = 'btnAceptar${ACosto['id'].toString()}'..onClick.listen((_){
	
		editarCosto(ACosto['id']);
	
	});
	
	td.children.add(btn);

	pHtmlBtn = "<button class='btn oculto edit_btn'><i class='icon-remove'></i></button>";
	btn = Element.html(pHtmlBtn)..id = 'btnCancelar${ACosto['id'].toString()}'..onClick.listen((_){
	
		cancelarEdicion(ACosto['id']);
	
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
	
	var pUrl = 'http://localhost:8031/rest/maquila/CostoMaquilaD_obtener_lista/${pFolio}';
  print(pUrl);
	
	HttpRequest.getString(pUrl).then((String Data){
	
    var pTmp = jsonDecode(Data);
    print(pTmp);
    print(pTmp.runtimeType);
		pLista = jsonDecode(Data);

    
		for (var item in pLista){
			item['dirty']  = false;
			item['deleted'] = true;
			agregaFila(item);
		}
	
	
	}
	,onError: (var ex) => (window.alert(ex.message) ));
	
	
}

bool productoEstaEnLaLista(String AProducto){
	
  var pCuenta = pLista.where((var item) => item['producto'] == AProducto).toList().length;
	
  return pCuenta > 0;	

}

void limpiaEdits(){
	(document.querySelector('#inpProducto') as InputElement).value = '';
	(document.querySelector('#inpDescripcion') as InputElement).value = '';
	(document.querySelector('#inpCosto') as InputElement).value = '0.00';
	(document.querySelector('#inpProducto') as InputElement).focus();
}

String puedeAgregarProducto([int AId = 0]){
	var pClaveProducto = '';
	
	if (AId > 0){
		pClaveProducto = AId.toString();
	}
	
	var pProducto = (document.querySelector('#inpProducto${pClaveProducto}') as InputElement).value;
	
	if (pProducto.trim().isEmpty){
		(document.querySelector('#inpProducto${pClaveProducto}') as InputElement).focus();
		return 'El producto esta vacío';
	}
	
	var pCostoS = (document.querySelector('#inpCosto${pClaveProducto}') as InputElement).value;
	
	try
	{
		var pCosto = double.parse(pCostoS);
	}
	catch(ex){
		(document.querySelector('#inpCosto${pClaveProducto}') as InputElement).focus();
		return 'El costo inválido';
	}
	
	/*if (productoEstaEnLaLista(pProducto)){
		(document.querySelector('#inpProducto${pClaveProducto}') as InputElement).focus();
		return 'El producto ya esta en la lista';
	}*/
	
	return '';	
}

void agregarProducto(){
	
	var pPuedeAgregarProducto = puedeAgregarProducto();
	
	if (pPuedeAgregarProducto.isEmpty){
	
		var pCosto = {};
		pCosto['id']          = pIndice;
		pIndice++;
		pCosto['id_costo']    = int.parse(pFolio);
		pCosto['producto']    = (document.querySelector('#inpProducto') as InputElement).value;
		pCosto['descripcion'] = (document.querySelector('#inpDescripcion') as InputElement).value;
		pCosto['costo']       = double.parse((document.querySelector('#inpCosto') as InputElement).value);
    pCosto['cc']          = (document.querySelector('#inpCC') as SelectElement).value;
		pCosto['dirty']       = true;
		
		pLista.add(pCosto);
		
		agregaFila(pCosto, false);
		limpiaEdits();
	
	}
	else{
		window.alert(pPuedeAgregarProducto);
	}

}

void obtenerDescripcionProducto([int AId = 0]){
	
		var pClaveProducto = '';
		
		if (AId > 0){
			pClaveProducto = AId.toString();
		}

		var pProducto = (document.querySelector('#inpProducto${pClaveProducto}') as InputElement).value;
		if (pProducto.trim().isEmpty){
		(document.querySelector('#inpProducto${pClaveProducto}') as InputElement).value = '';
			return;
		}
		else{
			var pUrl = 'http://localhost:8031/rest/productos/obtener_descripcion/${pProducto}';
			
			HttpRequest.getString(pUrl).then((String Data){
			
				Map pProducto =  jsonDecode(Data);
        print(pProducto);
        print(pClaveProducto);
				(document.querySelector('#inpDescripcion${pClaveProducto}') as InputElement).value = pProducto['descripcion'];
				(document.querySelector('#inpCosto${pClaveProducto}') as InputElement).value = '0.00';
				(document.querySelector('#inpCosto${pClaveProducto}') as InputElement).select();
				(document.querySelector('#inpCosto${pClaveProducto}') as InputElement).focus();
			
			});
			
		}
}

void aceptar(){

	(document.querySelector('#btnAceptar') as ButtonElement).disabled = true;

	var pListaTmp = pLista.where((var item) => item['dirty'] == true).toList();

	var CostoMaquila = {};
	CostoMaquila['id']          = int.parse(pFolio);
	CostoMaquila['fecha']       = (document.querySelector('#inpFecha') as InputElement).value;
	CostoMaquila['fechafinal']  = (document.querySelector('#inpFechaFinal') as InputElement).value;
	CostoMaquila['descripcion'] = (document.querySelector('#inpDescripcionM') as InputElement).value;
	CostoMaquila['activo']      = (document.querySelector('#inpActivo') as SelectElement).value;
	CostoMaquila['detalle']     = pListaTmp;

	
	var data = jsonEncode(CostoMaquila);
	print(data);
	
	var pUrl = 'http://localhost:8031/rest/maquila/CostoMaquilaD_insertar';
  print(pUrl);
	
	HttpRequest.request(pUrl, method: 'POST', mimeType:'application/json' , sendData: data , onProgress: (var e){}).then((HttpRequest ARequest){
	
		window.location.href = 'http://localhost:8031/costos_maquila';
	
	});
	
}

void cancelar(){
	if (window.confirm('¿Cancelar Captura?')){
		window.location.href = 'http://localhost:8031/costos_maquila';
	}
}

String convierteFecha(String AFecha){

  //2013-10-23 00:00:00 -0600
  var pFecha = AFecha.substring(8, 10) + '/' + AFecha.substring(5, 7) + '/' + AFecha.substring(0, 4);
  return pFecha;
}

void main() async{

	pFolio = (document.querySelector('#folio') as InputElement).value;

	SelectElement inpActivo = document.querySelector('#inpActivo');
	inpActivo.value = (document.querySelector('#activo') as InputElement).value;

  if (int.parse(pFolio)> 0){
    var pMaquilaTmp = await CostoMaquilaObtener(int.parse(pFolio));
    print(pMaquilaTmp);
    inpFecha.value = convierteFecha(pMaquilaTmp['fecha']);
    inpFechaFinal.value = convierteFecha(pMaquilaTmp['fechafinal']);
    inpDescripcionM.value = pMaquilaTmp['descripcion'];
    inpActivo.value = pMaquilaTmp['activo'];
  }
		
	llenaGrid();

	InputElement inpProducto = document.querySelector('#inpProducto');
	
	inpProducto.onBlur.listen((var e){
		
		obtenerDescripcionProducto();	
	
	});
	
	ButtonElement btnAgregar = document.querySelector('#btnAgregar');
	
	btnAgregar.onClick.listen((var e){
		
		agregarProducto();	
	
	});
	
	ButtonElement btnAceptar = document.querySelector('#btnAceptar');
	
	btnAceptar.onClick.listen((var e){
		
		aceptar();	
	
	});
	
	ButtonElement btnCancelar = document.querySelector('#btnCancelar');
	
	btnCancelar.onClick.listen((var e){
		
		cancelar();	
	
	});
	
}

