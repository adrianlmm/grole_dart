import 'dart:html';
import 'dart:convert';
import 'package:intl/intl.dart' as intl;

List<Map> pConsulta = <Map>[];
int pId = 1;

double pTotalKilos   = 0.0;
double pTotalImporte = 0.0;
bool   pFacturacionRestringida = false;
bool   pEsMartes = DateTime.now().weekday == 2;

void facturar(){

    if (window.confirm('¿Facturar Ordenes?')){

        (querySelector('#btnFacturar') as ButtonElement).disabled = true;

        var pUrl = 'http://localhost:8031/facturar';

        var pMapData = {};

        pMapData['kilos']   = pTotalKilos.toDouble();
        pMapData['importe'] = pTotalImporte.toDouble();
        pMapData['clase']   = int.parse((querySelector('#inpDepto') as SelectElement).value);
        pMapData['lista']   = pConsulta;

        var pData = jsonEncode(pMapData);

        HttpRequest.request(pUrl, method: 'POST' , sendData: pData, onProgress:((var x){})).then((HttpRequest ARequest){

            Map pResult =jsonDecode(ARequest.responseText);
            window.alert('Se creo factura folio ${pResult['id']}');
            window.location.href = '/facturas';

        });
    }
}

void llenaGrid(){

    var pFolio = int.parse(((querySelector('#folio') as HiddenInputElement).value));
    var pFechaIni = (querySelector('#inpFechaIni') as InputElement).value;
    var pFechaFin = (querySelector('#inpFechaFin') as InputElement).value;
    var pClase    = (querySelector('#inpDepto') as SelectElement).value;

    if (pFacturacionRestringida){

        var pFechaFinal   = DateTime.now();
        var pFechaInicial = pFechaFinal.subtract(Duration(days: 8));

        pFechaIni = intl.DateFormat('dd/MM/yyyy').format(pFechaInicial);
        pFechaFin = intl.DateFormat('dd/MM/yyyy').format(pFechaFinal);

        window.alert('La facturación esta restringida, solo se mostrarán ordenes de los últimos 8 días');

    }

    var pUrl = '';
    if (pFolio == 0){
        pUrl = 'http://localhost:8031/consulta_costos_maquila?fecha_ini=${pFechaIni}&fecha_fin=${pFechaFin}&clase=${pClase}';
    }
    else{
        pUrl = 'http://localhost:8031/rest/facturas/${pFolio}';
    }

    print(pUrl);

    HttpRequest.getString(pUrl).then((String Data){

        pConsulta =jsonDecode(Data);

        TableElement tableLista = document.querySelector('#gridLista');
        tableLista.tBodies[0].children.clear();
        tableLista.tFoot.children.clear();
        var nf = intl.NumberFormat('###,##0.00');
        var df   = intl.DateFormat('dd/MM/yyyy');

        pTotalKilos   = 0.0;
        pTotalImporte = 0.0;

        for (var item in pConsulta){

            var tr  = TableRowElement()..id    = 'tr${pId.toString()}';
            var d = DateTime.parse((item['fecha'] as String).substring(0, 10));

            var td = TableCellElement()..text = df.format(d);
            tr.children.add(td);
            td = TableCellElement()..text = item['id_orden'].toString();
            tr.children.add(td);
            td = TableCellElement()..text = item['producto'];
            tr.children.add(td);
            td = TableCellElement()..text = item['codigosap'];
            tr.children.add(td);
            td = TableCellElement()..text = item['descripcion'];
            tr.children.add(td);
            td = TableCellElement()..text = nf.format(item['costo_maquila'].toDouble())..classes.add('lr');
            tr.children.add(td);
            td = TableCellElement()..text = nf.format(item['producido'].toDouble())..classes.add('lr');
            tr.children.add(td);
            td = TableCellElement()..text = nf.format(item['importe_maquila'].toDouble())..classes.add('lr');
            tr.children.add(td);

            tableLista.tBodies[0].children.add(tr);

            pTotalKilos   += item['producido'].toDouble();
            pTotalImporte += item['importe_maquila'].toDouble();

            pId++;

        }

        if (pConsulta.isNotEmpty){

            var tr  = TableRowElement()..id    = 'tr${pId.toString()}';

            var td = TableCellElement()..text = '';

            if (pFolio == 0){
              var btnPreFacturar = ButtonElement()..classes.add('btn')..text = 'Facturar'..id='btnFacturar';

              btnPreFacturar.onClick.listen((var ev){
                  facturar();
              });

              td.children.add(btnPreFacturar);
            }

            tr.children.add(td);

            td = TableCellElement()..text = '';
            tr.children.add(td);
            td = TableCellElement()..text = '';
            tr.children.add(td);
            td = TableCellElement()..text = '';
            tr.children.add(td);
            td = TableCellElement()..text = '';
            tr.children.add(td);
            td = TableCellElement()..text = '';
            tr.children.add(td);
            td = TableCellElement()..text = nf.format(pTotalKilos)..classes.add('lr')..classes.add('b');
            tr.children.add(td);
            td = TableCellElement()..text = nf.format(pTotalImporte)..classes.add('lr')..classes.add('b');
            tr.children.add(td);

            tableLista.tFoot.children.add(tr);
        }

    });

}

void consultar(){
    llenaGrid();
}

void inicializa(){

  var pFolio = int.parse(((querySelector('#folio') as HiddenInputElement).value));
  print(pFolio);
	var nf = intl.DateFormat('dd/MM/yyyy');
  var pFechaIni = nf.format(DateTime.now());
  print(pFechaIni);
	(document.querySelector('#inpFechaIni') as InputElement).value = pFechaIni;
	(document.querySelector('#inpFechaFin') as InputElement).value = pFechaIni;

	if (pFolio > 0)
    {
	   (querySelector('#inpFechaIni') as InputElement).disabled = true;
	   (querySelector('#inpFechaFin') as InputElement).disabled = true;
	   (querySelector('#inpDepto') as SelectElement).disabled = true;

	   (querySelector('#inpFechaIni') as InputElement).value = '';
	   (querySelector('#inpFechaFin') as InputElement).value = '';
    }

	var pUrl = 'http://localhost:8031/rest/clase_ordenp_obtener_lista';

  HttpRequest.getString(pUrl).then((String Data){

		var pDeptos = (querySelector('#inpDepto') as SelectElement);

	    var pLista =jsonDecode(Data);

	    for (Map item in pLista){
	        pDeptos.appendHtml("<option value='${item['id']}'>${item['clase']}</option>");
	    }

  }).then((_){

      var pUrlConfiguraciones = 'http://localhost:8031/rest/obtener_configuraciones';

      HttpRequest.getString(pUrlConfiguraciones).then((String Data){

          var pData =jsonDecode(Data);
          pFacturacionRestringida = false;//pData['restringir_facturacion'] == 'Si';

      });

  });

	var btnConsultar = querySelector('#btnConsultar') as ButtonElement;
	btnConsultar.onClick.listen((var ev){
	   consultar();
	});

	var btnCancelar = querySelector('#btnCancelar') as ButtonElement;
    btnCancelar.onClick.listen((var ev){
       window.location.href = '/facturas';
    });

	if (pFolio > 0){
	   btnConsultar.disabled = true;
	   llenaGrid();
	}

}

void main() {
	inicializa();
}

