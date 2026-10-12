import 'dart:html';
import 'dart:convert';
import 'package:intl/intl.dart' as intl;

List<Map> pConsulta = null;
int pId = 1;

double pTotalKilos   = 0.0;
double pTotalImporte = 0.0;
bool   pFacturacionRestringida = false;
bool   pEsMartes = new DateTime.now().weekday == 2;

void facturar(){

    if (window.confirm("¿Facturar Ordenes?")){

        (querySelector("#btnFacturar") as ButtonElement).disabled = true;

        var pUrl = "http://localhost:8031/facturar";

        Map pMapData = new Map();

        pMapData["kilos"]   = pTotalKilos.toDouble();
        pMapData["importe"] = pTotalImporte.toDouble();
        pMapData["clase"]   = int.parse((querySelector("#inpDepto") as SelectElement).value);
        pMapData["lista"]   = pConsulta;

        var pData = JSON.encode(pMapData);

        HttpRequest.request(pUrl, method: "POST" , sendData: pData, onProgress:((var x){})).then((HttpRequest ARequest){

            Map pResult = JSON.decode(ARequest.responseText);
            window.alert("Se creo factura folio ${pResult["id"]}");
            window.location.href = "/facturas";

        });
    }
}

void llenaGrid(){

    int pFolio = int.parse(((querySelector("#folio") as HiddenInputElement).value));
    String pFechaIni = (querySelector("#inpFechaIni") as InputElement).value;
    String pFechaFin = (querySelector("#inpFechaFin") as InputElement).value;
    String pClase    = (querySelector("#inpDepto") as SelectElement).value;

    if (pFacturacionRestringida){

        var pFechaFinal   = new DateTime.now();
        var pFechaInicial = pFechaFinal.subtract(new Duration(days: 8));

        pFechaIni = new intl.DateFormat("dd/MM/yyyy").format(pFechaInicial);
        pFechaFin = new intl.DateFormat("dd/MM/yyyy").format(pFechaFinal);

        window.alert("La facturación esta restringida, solo se mostrarán ordenes de los últimos 8 días");

    }

    var pUrl = "";
    if (pFolio == 0){
        pUrl = "http://localhost:8031/consulta_costos_maquila?fecha_ini=${pFechaIni}&fecha_fin=${pFechaFin}&clase=${pClase}";
    }
    else{
        pUrl = "http://localhost:8031/rest/facturas/${pFolio}";
    }

    print(pUrl);

    HttpRequest.getString(pUrl).then((String Data){

        pConsulta = JSON.decode(Data);

        TableElement tableLista = document.querySelector("#gridLista");
        tableLista.tBodies[0].children.clear();
        tableLista.tFoot.children.clear();
        intl.NumberFormat nf = new intl.NumberFormat("###,##0.00");
        intl.DateFormat df   = new intl.DateFormat("dd/MM/yyyy");

        pTotalKilos   = 0.0;
        pTotalImporte = 0.0;

        for (Map item in pConsulta){

            TableRowElement tr  = new TableRowElement()..id    = 'tr${pId.toString()}';
            DateTime d = DateTime.parse((item["fecha"] as String).substring(0, 10));

            TableCellElement td = new TableCellElement()..text = df.format(d);
            tr.children.add(td);
            td = new TableCellElement()..text = item["id_orden"].toString();
            tr.children.add(td);
            td = new TableCellElement()..text = item["producto"];
            tr.children.add(td);
            td = new TableCellElement()..text = item["codigosap"];
            tr.children.add(td);
            td = new TableCellElement()..text = item["descripcion"];
            tr.children.add(td);
            td = new TableCellElement()..text = nf.format(item["costo_maquila"].toDouble())..classes.add("lr");
            tr.children.add(td);
            td = new TableCellElement()..text = nf.format(item["producido"].toDouble())..classes.add("lr");
            tr.children.add(td);
            td = new TableCellElement()..text = nf.format(item["importe_maquila"].toDouble())..classes.add("lr");
            tr.children.add(td);

            tableLista.tBodies[0].children.add(tr);

            pTotalKilos   += item["producido"].toDouble();
            pTotalImporte += item["importe_maquila"].toDouble();

            pId++;

        }

        if (pConsulta.length > 0){

            TableRowElement tr  = new TableRowElement()..id    = 'tr${pId.toString()}';

            TableCellElement td = new TableCellElement()..text = "";

            if (pFolio == 0){
              ButtonElement btnPreFacturar = new ButtonElement()..classes.add("btn")..text = "Facturar"..id="btnFacturar";

              btnPreFacturar.onClick.listen((var ev){
                  facturar();
              });

              td.children.add(btnPreFacturar);
            }

            tr.children.add(td);

            td = new TableCellElement()..text = "";
            tr.children.add(td);
            td = new TableCellElement()..text = "";
            tr.children.add(td);
            td = new TableCellElement()..text = "";
            tr.children.add(td);
            td = new TableCellElement()..text = "";
            tr.children.add(td);
            td = new TableCellElement()..text = "";
            tr.children.add(td);
            td = new TableCellElement()..text = nf.format(pTotalKilos)..classes.add("lr")..classes.add("b");
            tr.children.add(td);
            td = new TableCellElement()..text = nf.format(pTotalImporte)..classes.add("lr")..classes.add("b");
            tr.children.add(td);

            tableLista.tFoot.children.add(tr);
        }

    });

}

void consultar(){
    llenaGrid();
}

void inicializa(){

  int pFolio = int.parse(((querySelector("#folio") as HiddenInputElement).value));

	intl.DateFormat nf = new intl.DateFormat("dd/MM/yyyy");
	(document.querySelector("#inpFechaIni") as InputElement).value = nf.format(new DateTime.now());
	(document.querySelector("#inpFechaFin") as InputElement).value = nf.format(new DateTime.now());

	if (pFolio > 0)
    {
	   (querySelector("#inpFechaIni") as InputElement).disabled = true;
	   (querySelector("#inpFechaFin") as InputElement).disabled = true;
	   (querySelector("#inpDepto") as SelectElement).disabled = true;

	   (querySelector("#inpFechaIni") as InputElement).value = "";
	   (querySelector("#inpFechaFin") as InputElement).value = "";
    }

	var pUrl = "http://localhost:8031/rest/clase_ordenp_obtener_lista";

  HttpRequest.getString(pUrl).then((String Data){

		SelectElement pDeptos = (querySelector("#inpDepto") as SelectElement);

	    var pLista = JSON.decode(Data);

	    for (Map item in pLista){
	        pDeptos.appendHtml('<option value="${item['id']}">${item['clase']}</option>');
	    }

  }).then((_){

      String pUrlConfiguraciones = "http://localhost:8031/rest/obtener_configuraciones";

      HttpRequest.getString(pUrlConfiguraciones).then((String Data){

          Map pData = JSON.decode(Data);
          pFacturacionRestringida = false;//pData["restringir_facturacion"] == "Si";

      });

  });

	ButtonElement btnConsultar = querySelector("#btnConsultar") as ButtonElement;
	btnConsultar.onClick.listen((var ev){
	   consultar();
	});

	ButtonElement btnCancelar = querySelector("#btnCancelar") as ButtonElement;
    btnCancelar.onClick.listen((var ev){
       window.location.href = "/facturas";
    });

	if (pFolio > 0){
	   btnConsultar.disabled = true;
	   llenaGrid();
	}

}

void main() {
	inicializa();
}

